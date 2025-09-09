import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonetizationService {
  static MonetizationService? _instance;
  static MonetizationService get instance => _instance ??= MonetizationService._();
  
  MonetizationService._();
  
  // Services
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // State
  bool _isInitialized = false;
  bool _isPremium = false;
  int _monthlyProcessedCount = 0;
  DateTime? _lastResetDate;
  
  // Stream controllers
  final StreamController<bool> _premiumStatusController = StreamController<bool>.broadcast();
  final StreamController<int> _usageCountController = StreamController<int>.broadcast();
  
  // AdMob
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  DateTime? _lastInterstitialShown;
  
  // IAP
  final Set<String> _productIds = {
    'premium_monthly',
    'premium_yearly',
  };
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  
  // Getters
  bool get isPremium => _isPremium;
  int get monthlyProcessedCount => _monthlyProcessedCount;
  int get freeLimit => _remoteConfig.getInt('free_recipe_limit');
  bool get canProcessRecipe => _isPremium || _monthlyProcessedCount < freeLimit;
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;
  Stream<int> get usageCountStream => _usageCountController.stream;
  
  /// Initialize the monetization service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Remote Config
      await _initializeRemoteConfig();
      
      // Initialize IAP
      await _initializeIAP();
      
      // Initialize AdMob
      await _initializeAdMob();
      
      // Load user data
      await _loadUserData();
      
      _isInitialized = true;
      debugPrint('Monetization service initialized');
    } catch (e) {
      debugPrint('Monetization service initialization failed: $e');
    }
  }
  
  /// Check if user can process a recipe
  Future<bool> canProcessRecipeAsync() async {
    if (!_isInitialized) await initialize();
    
    if (_isPremium) return true;
    
    // Check if we need to reset monthly count
    await _checkAndResetMonthlyCount();
    
    return _monthlyProcessedCount < freeLimit;
  }
  
  /// Record recipe processing
  Future<void> recordRecipeProcessing() async {
    if (!_isInitialized) await initialize();
    
    if (_isPremium) return; // Premium users have unlimited processing
    
    _monthlyProcessedCount++;
    _usageCountController.add(_monthlyProcessedCount);
    
    // Save to Firestore
    await _saveUsageData();
    
    // Show interstitial ad occasionally for free users
    if (_shouldShowInterstitial()) {
      await _showInterstitialAd();
    }
  }
  
  /// Purchase premium subscription
  Future<bool> purchasePremium(String productId) async {
    if (!_isInitialized) await initialize();
    
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final purchaseParam = PurchaseParam(productDetails: product);
      
      final success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (success) {
        debugPrint('Purchase initiated for $productId');
        return true;
      } else {
        debugPrint('Failed to initiate purchase for $productId');
        return false;
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }
  
  /// Restore purchases
  Future<bool> restorePurchases() async {
    if (!_isInitialized) await initialize();
    
    try {
      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('Restore purchases error: $e');
      return false;
    }
  }
  
  /// Get premium products
  List<ProductDetails> getPremiumProducts() {
    return _products;
  }
  
  /// Get premium price
  String getPremiumPrice(String productId) {
    final product = _products.firstWhere((p) => p.id == productId, orElse: () => throw Exception('Product not found'));
    return product.price;
  }
  
  /// Create banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
  
  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (!_isInitialized) await initialize();
    
    if (_isPremium) return; // Don't show ads to premium users
    
    await _showInterstitialAd();
  }
  
  /// Check if ads are enabled
  bool get areAdsEnabled => _remoteConfig.getBool('enable_ads') && !_isPremium;
  
  /// Dispose resources
  void dispose() {
    _premiumStatusController.close();
    _usageCountController.close();
    _purchaseSubscription?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
  
  // Private methods
  
  Future<void> _initializeRemoteConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    // Set default values
    await _remoteConfig.setDefaults({
      'free_recipe_limit': 10,
      'premium_price_eur': '4.99',
      'enable_ads': true,
    });
    
    // Fetch and activate
    await _remoteConfig.fetchAndActivate();
  }
  
  Future<void> _initializeIAP() async {
    // Check if IAP is available
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      debugPrint('In-app purchase not available');
      return;
    }
    
    // Load products
    final response = await _inAppPurchase.queryProductDetails(_productIds);
    _products = response.productDetails;
    
    // Listen to purchase updates
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );
  }
  
  Future<void> _initializeAdMob() async {
    await MobileAds.instance.initialize();
  }
  
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Load premium status
      final subscriptionDoc = await _firestore
          .collection('subscriptions')
          .doc(user.uid)
          .get();
      
      if (subscriptionDoc.exists) {
        final data = subscriptionDoc.data()!;
        final premiumUntil = (data['premiumUntil'] as Timestamp?)?.toDate();
        _isPremium = premiumUntil != null && premiumUntil.isAfter(DateTime.now());
      }
      
      // Load usage data
      final usageDoc = await _firestore
          .collection('usage')
          .doc(user.uid)
          .get();
      
      if (usageDoc.exists) {
        final data = usageDoc.data()!;
        _monthlyProcessedCount = data['monthlyProcessedCount'] ?? 0;
        _lastResetDate = (data['lastResetDate'] as Timestamp?)?.toDate();
      }
      
      // Check if we need to reset monthly count
      await _checkAndResetMonthlyCount();
      
      _premiumStatusController.add(_isPremium);
      _usageCountController.add(_monthlyProcessedCount);
    } catch (e) {
      debugPrint('Failed to load user data: $e');
    }
  }
  
  Future<void> _checkAndResetMonthlyCount() async {
    final now = DateTime.now();
    final lastReset = _lastResetDate ?? DateTime(now.year, now.month, 1);
    
    // Reset if it's a new month
    if (now.year > lastReset.year || now.month > lastReset.month) {
      _monthlyProcessedCount = 0;
      _lastResetDate = now;
      await _saveUsageData();
    }
  }
  
  Future<void> _saveUsageData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _firestore.collection('usage').doc(user.uid).set({
        'monthlyProcessedCount': _monthlyProcessedCount,
        'lastResetDate': Timestamp.fromDate(_lastResetDate ?? DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Failed to save usage data: $e');
    }
  }
  
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchaseDetails.error}');
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }
  
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Calculate premium expiration date
      DateTime premiumUntil;
      if (purchaseDetails.productID == 'premium_monthly') {
        premiumUntil = DateTime.now().add(const Duration(days: 30));
      } else if (purchaseDetails.productID == 'premium_yearly') {
        premiumUntil = DateTime.now().add(const Duration(days: 365));
      } else {
        return;
      }
      
      // Save subscription to Firestore
      await _firestore.collection('subscriptions').doc(user.uid).set({
        'productId': purchaseDetails.productID,
        'premiumUntil': Timestamp.fromDate(premiumUntil),
        'purchaseDate': Timestamp.fromDate(DateTime.now()),
        'transactionId': purchaseDetails.purchaseID,
      });
      
      // Update local state
      _isPremium = true;
      _premiumStatusController.add(_isPremium);
      
      debugPrint('Premium subscription activated until $premiumUntil');
    } catch (e) {
      debugPrint('Failed to handle successful purchase: $e');
    }
  }
  
  String _getBannerAdUnitId() {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ad unit ID
    } else {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Replace with your actual ad unit ID
    }
  }
  
  String _getInterstitialAdUnitId() {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ad unit ID
    } else {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Replace with your actual ad unit ID
    }
  }
  
  bool _shouldShowInterstitial() {
    if (!areAdsEnabled) return false;
    
    final now = DateTime.now();
    final lastShown = _lastInterstitialShown;
    
    // Show interstitial max once per hour
    if (lastShown == null || now.difference(lastShown).inHours >= 1) {
      return true;
    }
    
    return false;
  }
  
  Future<void> _showInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: _getInterstitialAdUnitId(),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialAd?.show();
            _lastInterstitialShown = DateTime.now();
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      debugPrint('Failed to show interstitial ad: $e');
    }
  }
}

/// Premium subscription status
class PremiumStatus {
  final bool isPremium;
  final DateTime? premiumUntil;
  final String? productId;
  
  const PremiumStatus({
    required this.isPremium,
    this.premiumUntil,
    this.productId,
  });
  
  /// Check if premium is active
  bool get isActive => isPremium && (premiumUntil?.isAfter(DateTime.now()) ?? false);
  
  /// Get days remaining
  int? get daysRemaining {
    if (premiumUntil == null) return null;
    final now = DateTime.now();
    if (premiumUntil!.isBefore(now)) return 0;
    return premiumUntil!.difference(now).inDays;
  }
}

/// Usage statistics
class UsageStats {
  final int monthlyProcessedCount;
  final int freeLimit;
  final DateTime lastResetDate;
  
  const UsageStats({
    required this.monthlyProcessedCount,
    required this.freeLimit,
    required this.lastResetDate,
  });
  
  /// Get remaining free uses
  int get remainingUses => (freeLimit - monthlyProcessedCount).clamp(0, freeLimit);
  
  /// Get usage percentage
  double get usagePercentage => monthlyProcessedCount / freeLimit;
  
  /// Check if limit is reached
  bool get isLimitReached => monthlyProcessedCount >= freeLimit;
}
