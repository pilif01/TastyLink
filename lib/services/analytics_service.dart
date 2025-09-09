import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();
  
  AnalyticsService._();
  
  // Services
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // State
  bool _isInitialized = false;
  bool _analyticsEnabled = true;
  bool _crashlyticsEnabled = true;
  String? _userId;
  Map<String, dynamic> _userProperties = {};
  
  // Event tracking
  final Map<String, DateTime> _eventTimestamps = {};
  final Map<String, int> _eventCounts = {};
  
  // Getters
  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashlyticsEnabled => _crashlyticsEnabled;
  String? get userId => _userId;
  
  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Crashlytics
      await _initializeCrashlytics();
      
      // Initialize Analytics
      await _initializeAnalytics();
      
      // Set up user tracking
      await _setupUserTracking();
      
      _isInitialized = true;
      debugPrint('Analytics service initialized');
    } catch (e) {
      debugPrint('Analytics service initialization failed: $e');
    }
  }
  
  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    if (!_isInitialized) await initialize();
    
    _userId = userId;
    
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId ?? 'anonymous');
      
      debugPrint('User ID set: $userId');
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }
  
  /// Set user properties
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (!_isInitialized) await initialize();
    
    _userProperties.addAll(properties);
    
    try {
      for (final entry in properties.entries) {
        await _analytics.setUserProperty(
          name: entry.key,
          value: entry.value?.toString(),
        );
      }
      
      debugPrint('User properties set: $properties');
    } catch (e) {
      debugPrint('Failed to set user properties: $e');
    }
  }
  
  /// Log custom event
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (!_isInitialized) await initialize();
    if (!_analyticsEnabled) return;
    
    try {
      // Add common parameters
      final eventParams = <String, dynamic>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'user_id': _userId ?? 'anonymous',
        ...?parameters,
      };
      
      await _analytics.logEvent(
        name: eventName,
        parameters: eventParams,
      );
      
      // Track event frequency
      _eventCounts[eventName] = (_eventCounts[eventName] ?? 0) + 1;
      _eventTimestamps[eventName] = DateTime.now();
      
      debugPrint('Event logged: $eventName with parameters: $eventParams');
    } catch (e) {
      debugPrint('Failed to log event $eventName: $e');
    }
  }
  
  /// Log screen view
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    if (!_isInitialized) await initialize();
    if (!_analyticsEnabled) return;
    
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      
      debugPrint('Screen view logged: $screenName');
    } catch (e) {
      debugPrint('Failed to log screen view $screenName: $e');
    }
  }
  
  /// Log share intent opened
  Future<void> logShareIntentOpened(String sourceType, String contentType) async {
    await logEvent('share_intent_opened', parameters: {
      'source_type': sourceType,
      'content_type': contentType,
    });
  }
  
  /// Log process started
  Future<void> logProcessStarted(String processType, String sourceType) async {
    await logEvent('process_started', parameters: {
      'process_type': processType,
      'source_type': sourceType,
    });
  }
  
  /// Log process success
  Future<void> logProcessSuccess(String processType, {Map<String, dynamic>? additionalParams}) async {
    await logEvent('process_success', parameters: {
      'process_type': processType,
      ...?additionalParams,
    });
  }
  
  /// Log process failed
  Future<void> logProcessFailed(String processType, String reason, {Map<String, dynamic>? additionalParams}) async {
    await logEvent('process_failed_reason', parameters: {
      'process_type': processType,
      'failure_reason': reason,
      ...?additionalParams,
    });
  }
  
  /// Log recipe saved
  Future<void> logRecipeSaved(String recipeId, String sourceType, bool isUserCreated) async {
    await logEvent('recipe_saved', parameters: {
      'recipe_id': recipeId,
      'source_type': sourceType,
      'is_user_created': isUserCreated,
    });
  }
  
  /// Log shopping item added
  Future<void> logShoppingAdd(String itemName, String category, String source) async {
    await logEvent('shopping_add', parameters: {
      'item_name': itemName,
      'category': category,
      'source': source,
    });
  }
  
  /// Log planner item added
  Future<void> logPlannerAdd(String mealType, String recipeId, DateTime date) async {
    await logEvent('planner_add', parameters: {
      'meal_type': mealType,
      'recipe_id': recipeId,
      'date': date.toIso8601String(),
    });
  }
  
  /// Log cooking mode started
  Future<void> logCookingModeStart(String recipeId, int stepCount, Duration estimatedTime) async {
    await logEvent('cooking_mode_start', parameters: {
      'recipe_id': recipeId,
      'step_count': stepCount,
      'estimated_time_seconds': estimatedTime.inSeconds,
    });
  }
  
  /// Log badge unlocked
  Future<void> logBadgeUnlocked(String badgeName, String badgeType) async {
    await logEvent('badge_unlocked', parameters: {
      'badge_name': badgeName,
      'badge_type': badgeType,
    });
  }
  
  /// Log IAP purchase
  Future<void> logIapPurchase(String productId, String currency, double value) async {
    await logEvent('iap_purchase', parameters: {
      'product_id': productId,
      'currency': currency,
      'value': value,
    });
  }
  
  /// Log ad impression
  Future<void> logAdImpression(String adType, String adUnitId) async {
    await logEvent('ad_impression', parameters: {
      'ad_type': adType,
      'ad_unit_id': adUnitId,
    });
  }
  
  /// Log ad click
  Future<void> logAdClick(String adType, String adUnitId) async {
    await logEvent('ad_click', parameters: {
      'ad_type': adType,
      'ad_unit_id': adUnitId,
    });
  }
  
  /// Log translation used
  Future<void> logTranslationUsed(String sourceLanguage, String targetLanguage, int textLength) async {
    await logEvent('translation_used', parameters: {
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'text_length': textLength,
    });
  }
  
  /// Log OCR used
  Future<void> logOcrUsed(String imageSource, int textLength, double confidence) async {
    await logEvent('ocr_used', parameters: {
      'image_source': imageSource,
      'text_length': textLength,
      'confidence': confidence,
    });
  }
  
  /// Log performance metric
  Future<void> logPerformanceMetric(String metricName, double value, String unit) async {
    await logEvent('performance_metric', parameters: {
      'metric_name': metricName,
      'value': value,
      'unit': unit,
    });
  }
  
  /// Log error
  Future<void> logError(dynamic error, StackTrace? stackTrace, {Map<String, dynamic>? context}) async {
    if (!_crashlyticsEnabled) return;
    
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: false,
      );
      
      debugPrint('Error logged: $error');
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }
  
  /// Log fatal error
  Future<void> logFatalError(dynamic error, StackTrace? stackTrace, {Map<String, dynamic>? context}) async {
    if (!_crashlyticsEnabled) return;
    
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: true,
      );
      
      debugPrint('Fatal error logged: $error');
    } catch (e) {
      debugPrint('Failed to log fatal error: $e');
    }
  }
  
  /// Set custom key for crashlytics
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_crashlyticsEnabled) return;
    
    try {
      await _crashlytics.setCustomKey(key, value);
      debugPrint('Custom key set: $key = $value');
    } catch (e) {
      debugPrint('Failed to set custom key: $e');
    }
  }
  
  /// Enable/disable analytics
  Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('analytics_enabled', enabled);
      
      debugPrint('Analytics enabled: $enabled');
    } catch (e) {
      debugPrint('Failed to set analytics enabled: $e');
    }
  }
  
  /// Enable/disable crashlytics
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    _crashlyticsEnabled = enabled;
    
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('crashlytics_enabled', enabled);
      
      debugPrint('Crashlytics enabled: $enabled');
    } catch (e) {
      debugPrint('Failed to set crashlytics enabled: $e');
    }
  }
  
  /// Get event count for a specific event
  int getEventCount(String eventName) {
    return _eventCounts[eventName] ?? 0;
  }
  
  /// Get last event timestamp
  DateTime? getLastEventTimestamp(String eventName) {
    return _eventTimestamps[eventName];
  }
  
  /// Get all event counts
  Map<String, int> getAllEventCounts() {
    return Map.from(_eventCounts);
  }
  
  /// Clear event tracking data
  void clearEventTracking() {
    _eventCounts.clear();
    _eventTimestamps.clear();
  }
  
  // Private methods
  
  Future<void> _initializeCrashlytics() async {
    try {
      // Set up crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      
      // Set up error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics.recordFlutterFatalError(details);
      };
      
      // Set up platform error handling
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
      
      debugPrint('Crashlytics initialized');
    } catch (e) {
      debugPrint('Failed to initialize crashlytics: $e');
    }
  }
  
  Future<void> _initializeAnalytics() async {
    try {
      // Set up analytics
      await _analytics.setAnalyticsCollectionEnabled(true);
      
      // Set default event parameters
      await _analytics.setDefaultEventParameters({
        'app_version': '1.0.0', // This should come from package_info
        'platform': defaultTargetPlatform.name,
        'build_mode': kDebugMode ? 'debug' : 'release',
      });
      
      debugPrint('Analytics initialized');
    } catch (e) {
      debugPrint('Failed to initialize analytics: $e');
    }
  }
  
  Future<void> _setupUserTracking() async {
    try {
      // Load user preferences
      final prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _crashlyticsEnabled = prefs.getBool('crashlytics_enabled') ?? true;
      
      // Set up auth state listener
      _auth.authStateChanges().listen((user) {
        if (user != null) {
          setUserId(user.uid);
          setUserProperties({
            'email': user.email,
            'email_verified': user.emailVerified,
            'creation_time': user.metadata.creationTime?.toIso8601String(),
            'last_sign_in': user.metadata.lastSignInTime?.toIso8601String(),
          });
        } else {
          setUserId(null);
        }
      });
      
      debugPrint('User tracking set up');
    } catch (e) {
      debugPrint('Failed to set up user tracking: $e');
    }
  }
}

/// Analytics event constants
class AnalyticsEvents {
  static const String shareIntentOpened = 'share_intent_opened';
  static const String processStarted = 'process_started';
  static const String processSuccess = 'process_success';
  static const String processFailed = 'process_failed_reason';
  static const String recipeSaved = 'recipe_saved';
  static const String shoppingAdd = 'shopping_add';
  static const String plannerAdd = 'planner_add';
  static const String cookingModeStart = 'cooking_mode_start';
  static const String badgeUnlocked = 'badge_unlocked';
  static const String iapPurchase = 'iap_purchase';
  static const String adImpression = 'ad_impression';
  static const String adClick = 'ad_click';
  static const String translationUsed = 'translation_used';
  static const String ocrUsed = 'ocr_used';
  static const String performanceMetric = 'performance_metric';
}

/// Analytics parameters
class AnalyticsParameters {
  static const String processType = 'process_type';
  static const String sourceType = 'source_type';
  static const String contentType = 'content_type';
  static const String failureReason = 'failure_reason';
  static const String recipeId = 'recipe_id';
  static const String isUserCreated = 'is_user_created';
  static const String itemName = 'item_name';
  static const String category = 'category';
  static const String source = 'source';
  static const String mealType = 'meal_type';
  static const String date = 'date';
  static const String stepCount = 'step_count';
  static const String estimatedTimeSeconds = 'estimated_time_seconds';
  static const String badgeName = 'badge_name';
  static const String badgeType = 'badge_type';
  static const String productId = 'product_id';
  static const String currency = 'currency';
  static const String value = 'value';
  static const String adType = 'ad_type';
  static const String adUnitId = 'ad_unit_id';
  static const String sourceLanguage = 'source_language';
  static const String targetLanguage = 'target_language';
  static const String textLength = 'text_length';
  static const String imageSource = 'image_source';
  static const String confidence = 'confidence';
  static const String metricName = 'metric_name';
  static const String unit = 'unit';
}
