// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'firebase_options.dart';
// import 'services/notification_handler.dart';
// import 'core/app_colors.dart';
// import 'screens/splash.screen.dart';
// // Import your Task and Meeting screens to register routes
// // import 'screens/task_dashboard.screen.dart';
// // import 'screens/meeting_dashboard.screen.dart';

// // Background Handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // 1. ✅ Attach the Global Key
//       navigatorKey: navigatorKey, 
      
//       title: 'PictoCreds',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkTeal),
//         useMaterial3: true,
//       ),
      
//       // 2. ✅ Define Routes for Redirection
//       routes: {
//         '/': (context) => const SplashScreen(),
//         // Add these placeholders or your actual screens
//         '/tasks': (context) => const Scaffold(body: Center(child: Text("Tasks Screen"))), // Replace with MemberDashboard(tab: 0)
//         '/meetings': (context) => const Scaffold(body: Center(child: Text("Meetings Screen"))), // Replace with MemberDashboard(tab: 1)
//       },
//       initialRoute: '/',
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added
import 'firebase_options.dart';
import 'services/notification_handler.dart';
import 'core/app_colors.dart';
import 'screens/splash.screen.dart';
import 'screens/member_dashboard.screen.dart'; // ✅ Added
import 'screens/head_dashboard.screen.dart';   // ✅ Added

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔵 Background message received: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PictoCreds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkTeal),
        useMaterial3: true,
      ),
      
      routes: {
        '/': (context) => const SplashScreen(),
        
        // ✅ Fix: Pass 'openTasks: true' for Tasks route
        '/tasks': (context) => const DashboardRedirector(openTasks: true),
        
        // ✅ Fix: Pass 'openTasks: false' for Meetings route
        '/meetings': (context) => const DashboardRedirector(openTasks: false),
      },
      initialRoute: '/',
    );
  }
}

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

