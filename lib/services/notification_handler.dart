// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'auth_service.dart';

// class NotificationHandler {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final AuthService _authService = AuthService();

//   Future<void> initialize() async {
//     try {
//       // 1. Request Permission
//       NotificationSettings settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );

//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print('🔔 User granted permission');

//         // 2. Get Token
//         // We don't await this indefinitely. If it fails, we catch the error.
//         String? token = await _firebaseMessaging.getToken();
        
//         if (token != null) {
//           print("🔥 FCM Token: $token");
//           // 3. Send to Backend
//           await _authService.saveFcmToken(token);
//         }
        
//         // 4. Listen for token refresh
//         FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//           _authService.saveFcmToken(newToken);
//         });

//         // 5. Handle Foreground Messages
//         FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//           print('📩 Message received in foreground: ${message.notification?.title}');
//         });
//       } else {
//         print('🔕 User declined or has not accepted permission');
//       }
//     } catch (e) {
//       // This prevents the dashboard from crashing if Firebase fails
//       print("❌ Error initializing notifications: $e");
//     }
//   }
// }


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();

  /// ✅ NEW: Check permission status and request if needed
  /// This will be called every time the app launches
  Future<bool> checkAndRequestPermission() async {
    try {
      // First check if user has manually disabled notifications from profile
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      if (!notificationsEnabled) {
        print("🔕 User has disabled notifications from profile settings");
        return false;
      }

      // Check current permission status
      NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
      
      // If already authorized, just initialize
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("✅ Notification permission already granted");
        await initialize(); // Make sure token is synced
        return true;
      }
      
      // If denied or not determined, request permission
      if (settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        print("📢 Requesting notification permission...");
        
        settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print("✅ User granted notification permission!");
          await initialize();
          return true;
        } else {
          print("❌ User denied notification permission");
          return false;
        }
      }
      
      return false;
    } catch (e) {
      print("❌ Error checking notification permission: $e");
      return false;
    }
  }

  /// ✅ UPDATED: This now only runs after permission is confirmed
  Future<void> initialize() async {
    try {
      // Check if notifications are enabled in profile
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      if (!notificationsEnabled) {
        print("🔕 Notifications disabled by user in profile");
        return;
      }

      // Get current permission status
      NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('🔔 Initializing notification handlers...');

        // Get Token
        String? token = await _firebaseMessaging.getToken();
        
        if (token != null) {
          print("🔥 FCM Token: $token");
          // Send to Backend
          await _authService.saveFcmToken(token);
        } else {
          print("⚠️ FCM Token is null");
        }
        
        // Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          print("🔄 Token refreshed: $newToken");
          _authService.saveFcmToken(newToken);
        });

        // Handle Foreground Messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('📩 Message received in foreground: ${message.notification?.title}');
          // You can show a local notification here if you want
        });

        // Handle notification tap when app is in background/terminated
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('🔔 Notification tapped: ${message.data}');
          // Handle navigation based on message.data if needed
        });

      } else {
        print('🔕 User has not granted notification permission');
      }
    } catch (e) {
      print("❌ Error initializing notifications: $e");
    }
  }

  /// ✅ NEW: Disable notifications (called from profile toggle)
  Future<void> disableNotifications() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', false);
      print("🔕 Notifications disabled and token deleted");
    } catch (e) {
      print("❌ Error disabling notifications: $e");
    }
  }

  /// ✅ NEW: Enable notifications (called from profile toggle)
  Future<void> enableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);
      
      // Re-initialize to get new token and set up listeners
      await initialize();
      print("✅ Notifications re-enabled");
    } catch (e) {
      print("❌ Error enabling notifications: $e");
    }
  }
}