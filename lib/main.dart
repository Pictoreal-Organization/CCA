import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/notification_handler.dart';
import 'core/app_colors.dart';
import 'screens/splash.screen.dart';
import 'screens/member_dashboard.screen.dart';
import 'screens/head_dashboard.screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔵 Background message received: ${message.messageId}");

  // ✅ Manual Display for Mobile Background (Data-Only)
  if (message.notification == null && message.data.isNotEmpty) {
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    
    // Must use the SAME channel ID as defined in NotificationHandler
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', 
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    await localNotifications.show(
      message.hashCode,
      message.data['title'], // Read from data
      message.data['body'], 
      NotificationDetails(android: androidDetails),
      payload: message.data.toString(), // Pass data for click logic
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env"); // Keep commented for Vercel

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ SAFE WEB REDIRECT CHECK (Works on Android/iOS too)
    // Uri.base gets the current URL. On mobile, it's usually just '/'.
    // On Web, if we redirected to '/?redirect=tasks', this will catch it.
    String initialRoute = '/';
    
    // Check for query parameter "redirect"
    final String? redirectParam = Uri.base.queryParameters['redirect'];
    
    if (redirectParam == 'tasks') {
      initialRoute = '/tasks';
    } else if (redirectParam == 'meetings') {
      initialRoute = '/meetings';
    }

    return MaterialApp(
      navigatorKey: navigatorKey, 
      title: 'PictoCreds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkTeal),
        useMaterial3: true,
      ),
      
      // ✅ Use the calculated route
      initialRoute: initialRoute, 
      
      routes: {
        '/': (context) => const SplashScreen(),
        '/tasks': (context) => const DashboardRedirector(openTasks: true),
        '/meetings': (context) => const DashboardRedirector(openTasks: false),
      },
    );
  }
}

// ... (Keep your DashboardRedirector class here) ...
class DashboardRedirector extends StatefulWidget {
  final bool openTasks; // ✅ Changed from int to bool
  const DashboardRedirector({super.key, required this.openTasks});

  @override
  State<DashboardRedirector> createState() => _DashboardRedirectorState();
}

class _DashboardRedirectorState extends State<DashboardRedirector> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString("role");

    if (!mounted) return;

    // ✅ Check Role and Pass the Boolean
    if (role == "Head") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HeadDashboard(openTasks: widget.openTasks),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MemberDashboard(openTasks: widget.openTasks),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()), 
    );
  }
}

