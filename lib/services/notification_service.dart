import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();
  
  // Services
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // State
  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  bool _cookingNotificationsEnabled = true;
  bool _plannerNotificationsEnabled = true;
  bool _streakNotificationsEnabled = true;
  
  // Stream controllers
  final StreamController<RemoteMessage> _messageController = StreamController<RemoteMessage>.broadcast();
  final StreamController<NotificationResponse> _notificationResponseController = StreamController<NotificationResponse>.broadcast();
  
  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get cookingNotificationsEnabled => _cookingNotificationsEnabled;
  bool get plannerNotificationsEnabled => _plannerNotificationsEnabled;
  bool get streakNotificationsEnabled => _streakNotificationsEnabled;
  Stream<RemoteMessage> get messageStream => _messageController.stream;
  Stream<NotificationResponse> get notificationResponseStream => _notificationResponseController.stream;
  
  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase Messaging
      await _initializeFirebaseMessaging();
      
      // Load user preferences
      await _loadUserPreferences();
      
      _isInitialized = true;
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
    }
  }
  
  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();
    
    try {
      // Request local notification permissions
      final localPermission = await _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      
      // Request FCM permissions
      final fcmPermission = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      final granted = (localPermission ?? false) && fcmPermission.authorizationStatus == AuthorizationStatus.authorized;
      
      if (granted) {
        _notificationsEnabled = true;
        await _saveUserPreferences();
      }
      
      return granted;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }
  
  /// Schedule cooking timer notification
  Future<void> scheduleCookingTimer({
    required String recipeTitle,
    required String stepText,
    required Duration duration,
    required int stepIndex,
  }) async {
    if (!_cookingNotificationsEnabled) return;
    
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _localNotifications.zonedSchedule(
        notificationId,
        'Cooking Timer: $recipeTitle',
        'Step $stepIndex: $stepText',
        tz.TZDateTime.now(tz.local).add(duration),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'cooking_timers',
            'Cooking Timers',
            channelDescription: 'Notifications for cooking timers',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('timer_sound'),
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
            category: AndroidNotificationCategory.alarm,
            actions: [
              const AndroidNotificationAction(
                'snooze',
                'Snooze 5 min',
                showsUserInterface: false,
              ),
              const AndroidNotificationAction(
                'stop',
                'Stop Timer',
                showsUserInterface: false,
              ),
            ],
          ),
          iOS: DarwinNotificationDetails(
            sound: 'timer_sound.aiff',
            categoryIdentifier: 'cooking_timer',
            threadIdentifier: 'cooking_timers',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'cooking_timer:$stepIndex:$recipeTitle',
      );
      
      debugPrint('Cooking timer scheduled for ${duration.inSeconds} seconds');
    } catch (e) {
      debugPrint('Failed to schedule cooking timer: $e');
    }
  }
  
  /// Schedule planner reminder
  Future<void> schedulePlannerReminder({
    required String mealTitle,
    required DateTime reminderTime,
    required String mealType,
  }) async {
    if (!_plannerNotificationsEnabled) return;
    
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _localNotifications.zonedSchedule(
        notificationId,
        'Meal Reminder',
        'Time to cook: $mealTitle ($mealType)',
        tz.TZDateTime.from(reminderTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'planner_reminders',
            'Meal Planner Reminders',
            channelDescription: 'Notifications for planned meals',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: 'planner_reminder',
            threadIdentifier: 'planner_reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'planner_reminder:$mealTitle:$mealType',
      );
      
      debugPrint('Planner reminder scheduled for $reminderTime');
    } catch (e) {
      debugPrint('Failed to schedule planner reminder: $e');
    }
  }
  
  /// Schedule streak nudge notification
  Future<void> scheduleStreakNudge() async {
    if (!_streakNotificationsEnabled) return;
    
    try {
      // Check if we already sent a streak nudge today
      final prefs = await SharedPreferences.getInstance();
      final lastStreakNudge = prefs.getString('last_streak_nudge');
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      if (lastStreakNudge == today) return;
      
      // Schedule for tomorrow at 6 PM
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final reminderTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 0);
      
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _localNotifications.zonedSchedule(
        notificationId,
        'Keep your cooking streak! 🔥',
        'Don\'t forget to cook something delicious today!',
        tz.TZDateTime.from(reminderTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_nudges',
            'Streak Nudges',
            channelDescription: 'Motivational notifications to maintain cooking streaks',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
            category: AndroidNotificationCategory.social,
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: 'streak_nudge',
            threadIdentifier: 'streak_nudges',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'streak_nudge',
      );
      
      // Mark as sent today
      await prefs.setString('last_streak_nudge', today);
      
      debugPrint('Streak nudge scheduled for $reminderTime');
    } catch (e) {
      debugPrint('Failed to schedule streak nudge: $e');
    }
  }
  
  /// Cancel all cooking timer notifications
  Future<void> cancelCookingTimers() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('All cooking timers cancelled');
    } catch (e) {
      debugPrint('Failed to cancel cooking timers: $e');
    }
  }
  
  /// Cancel specific notification
  Future<void> cancelNotification(int notificationId) async {
    try {
      await _localNotifications.cancel(notificationId);
      debugPrint('Notification $notificationId cancelled');
    } catch (e) {
      debugPrint('Failed to cancel notification $notificationId: $e');
    }
  }
  
  /// Get FCM token
  Future<String?> getFCMToken() async {
    if (!_isInitialized) await initialize();
    
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }
  
  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Failed to subscribe to topic $topic: $e');
    }
  }
  
  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Failed to unsubscribe from topic $topic: $e');
    }
  }
  
  /// Update notification preferences
  Future<void> updatePreferences({
    bool? notificationsEnabled,
    bool? cookingNotificationsEnabled,
    bool? plannerNotificationsEnabled,
    bool? streakNotificationsEnabled,
  }) async {
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
    if (cookingNotificationsEnabled != null) _cookingNotificationsEnabled = cookingNotificationsEnabled;
    if (plannerNotificationsEnabled != null) _plannerNotificationsEnabled = plannerNotificationsEnabled;
    if (streakNotificationsEnabled != null) _streakNotificationsEnabled = streakNotificationsEnabled;
    
    await _saveUserPreferences();
  }
  
  /// Dispose resources
  void dispose() {
    _messageController.close();
    _notificationResponseController.close();
  }
  
  // Private methods
  
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    
    // Create notification channels for Android
    await _createNotificationChannels();
  }
  
  Future<void> _initializeFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    
    // Handle notification tap when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }
  
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'cooking_timers',
          'Cooking Timers',
          description: 'Notifications for cooking timers',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('timer_sound'),
        ),
      );
      
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'planner_reminders',
          'Meal Planner Reminders',
          description: 'Notifications for planned meals',
          importance: Importance.defaultImportance,
        ),
      );
      
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'streak_nudges',
          'Streak Nudges',
          description: 'Motivational notifications to maintain cooking streaks',
          importance: Importance.low,
        ),
      );
    }
  }
  
  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _cookingNotificationsEnabled = prefs.getBool('cooking_notifications_enabled') ?? true;
    _plannerNotificationsEnabled = prefs.getBool('planner_notifications_enabled') ?? true;
    _streakNotificationsEnabled = prefs.getBool('streak_notifications_enabled') ?? true;
  }
  
  Future<void> _saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('cooking_notifications_enabled', _cookingNotificationsEnabled);
    await prefs.setBool('planner_notifications_enabled', _plannerNotificationsEnabled);
    await prefs.setBool('streak_notifications_enabled', _streakNotificationsEnabled);
  }
  
  void _onNotificationResponse(NotificationResponse response) {
    _notificationResponseController.add(response);
    debugPrint('Notification response: ${response.payload}');
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    _messageController.add(message);
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    _messageController.add(message);
  }
  
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

/// Notification response handler
class NotificationResponseHandler {
  static void handleResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    
    final parts = payload.split(':');
    if (parts.isEmpty) return;
    
    switch (parts[0]) {
      case 'cooking_timer':
        _handleCookingTimerResponse(parts);
        break;
      case 'planner_reminder':
        _handlePlannerReminderResponse(parts);
        break;
      case 'streak_nudge':
        _handleStreakNudgeResponse();
        break;
    }
  }
  
  static void _handleCookingTimerResponse(List<String> parts) {
    if (parts.length < 3) return;
    
    final stepIndex = int.tryParse(parts[1]);
    final recipeTitle = parts[2];
    
    debugPrint('Cooking timer response: Step $stepIndex for $recipeTitle');
    // Navigate to cooking mode or show timer interface
  }
  
  static void _handlePlannerReminderResponse(List<String> parts) {
    if (parts.length < 3) return;
    
    final mealTitle = parts[1];
    final mealType = parts[2];
    
    debugPrint('Planner reminder response: $mealTitle ($mealType)');
    // Navigate to meal planner or recipe
  }
  
  static void _handleStreakNudgeResponse() {
    debugPrint('Streak nudge response');
    // Navigate to home or show streak information
  }
}
