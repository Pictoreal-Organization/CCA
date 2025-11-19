import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth_service.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    try {
      // 1. Request Permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('🔔 User granted permission');

        // 2. Get Token
        // We don't await this indefinitely. If it fails, we catch the error.
        String? token = await _firebaseMessaging.getToken();
        
        if (token != null) {
          print("🔥 FCM Token: $token");
          // 3. Send to Backend
          await _authService.saveFcmToken(token);
        }
        
        // 4. Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          _authService.saveFcmToken(newToken);
        });

        // 5. Handle Foreground Messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('📩 Message received in foreground: ${message.notification?.title}');
        });
      } else {
        print('🔕 User declined or has not accepted permission');
      }
    } catch (e) {
      // This prevents the dashboard from crashing if Firebase fails
      print("❌ Error initializing notifications: $e");
    }
  }
}