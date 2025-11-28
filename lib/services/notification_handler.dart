import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../config.dart';

// 1. Global Navigator Key to allow redirection from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Android Channel
  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', 
    'High Importance Notifications', 
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  // --- A. Initialize ---
  Future<void> initialize() async {
    // 1. Check Profile Preference
    final prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (!isEnabled) {
      print("🔕 Notifications disabled by user.");
      return; 
    }

    // 2. Request Permission (Ask every time app opens if not authorized)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
      await _setupFlutterNotifications();
      await _syncToken();
      _setupMessageHandlers();
    } else {
      print('❌ Permission declined');
      // Optional: Show dialog here if you want to FORCE them to settings
    }
  }

  // --- B. Setup Local Notifications & Channel ---
  Future<void> _setupFlutterNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle tap on Foreground Notification
        if (response.payload != null) {
            // You might need to parse payload string back to json if you pass complex data
            // But usually we rely on onMessageOpenedApp for background taps
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  // --- C. Sync Token ---
  Future<void> _syncToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("🔥 FCM Token: $token");
      await _authService.saveFcmToken(token);
    }
    
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _authService.saveFcmToken(newToken);
    });
  }

  // --- D. Message Handlers ---
 void _setupMessageHandlers() {
    // 1. Foreground Messages (App is Open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground Message: ${message.messageId}');

      // Try to get content from the standard Notification object
      String? title = message.notification?.title;
      String? body = message.notification?.body;

      // If standard notification is empty, check 'data' (For Data-Only strategy)
      if (title == null && message.data.isNotEmpty) {
        title = message.data['title'];
        body = message.data['body'];
      }

      // If we have a title, show the Local Notification manually
      if (title != null) {
        _localNotifications.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_launcher', // Ensure this icon exists
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          // Pass the data payload string so we can handle the click later
          payload: message.data.toString(), 
        );
      }
    });

    // 2. Background Notification Tap (App in Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔄 App opened from background notification");
      _handleRedirect(message.data);
    });

    // 3. Terminated State (App Closed completely)
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("🚀 App launched from terminated state");
        _handleRedirect(message.data);
      }
    });
  }

  // --- E. Redirection Logic ---
  void _handleRedirect(Map<String, dynamic> data) {
    final String? type = data['type'];
    
    if (type == null) return;

    if (type == 'MEETING_CREATED' || type == 'MEETING_UPDATED') {
      // ✅ Use pushNamedAndRemoveUntil to clear the stack
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/meetings', 
        (route) => false, // This removes ALL previous routes
      );
    } 
    else if (type == 'TASK_CREATED' || type == 'TASK_UPDATED' || type == 'SUBTASK_UPDATED') {
      // ✅ Use pushNamedAndRemoveUntil
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/tasks', 
        (route) => false,
      );
    }
  }

  // --- F. Toggle Preference ---
  Future<void> toggleNotifications(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enable);
    
    if (enable) {
      await initialize(); // Re-register
    } else {
      await _firebaseMessaging.deleteToken(); // Stop receiving from backend
      print("🔕 Notifications disabled.");
    }
  }
}