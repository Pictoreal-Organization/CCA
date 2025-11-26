// import 'package:flutter/material.dart';
// import 'screens/splash.screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'core/app_colors.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'services/notification_handler.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("🔵 Background message received: ${message.messageId}");
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   NotificationHandler().initialize(); // You will add this file
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const seedColor = AppColors.darkTeal;

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'PictoCreds',

//       // 👇 Force app to always use light theme
//       themeMode: ThemeMode.light,

//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: seedColor,
//           secondary: AppColors.orange,
//           brightness: Brightness.light,
//         ),
//         scaffoldBackgroundColor: Colors.white, // white screens everywhere
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.darkTeal,
//           foregroundColor: Colors.white,
//           elevation: 2,
//         ),
//         useMaterial3: true,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),

//       home: const SplashScreen(),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'screens/app_init_wrapper.screen.dart'; // ✅ Import the wrapper
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'core/app_colors.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'services/notification_handler.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("🔵 Background message received: ${message.messageId}");
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
  
//   // ✅ REMOVED: Don't call initialize() here anymore
//   // NotificationHandler().initialize();
  
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const seedColor = AppColors.darkTeal;

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'PictoCreds',
//       navigatorKey: NotificationHandler.navigatorKey,
//       themeMode: ThemeMode.light,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: seedColor,
//           secondary: AppColors.orange,
//           brightness: Brightness.light,
//         ),
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.darkTeal,
//           foregroundColor: Colors.white,
//           elevation: 2,
//         ),
//         useMaterial3: true,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const AppInitWrapper(), // ✅ Use wrapper instead of SplashScreen
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'services/notification_handler.dart';
import 'core/app_colors.dart';
import 'screens/splash.screen.dart';
// Import your Task and Meeting screens to register routes
// import 'screens/task_dashboard.screen.dart';
// import 'screens/meeting_dashboard.screen.dart';

// Background Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
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
      // 1. ✅ Attach the Global Key
      navigatorKey: navigatorKey, 
      
      title: 'PictoCreds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkTeal),
        useMaterial3: true,
      ),
      
      // 2. ✅ Define Routes for Redirection
      routes: {
        '/': (context) => const SplashScreen(),
        // Add these placeholders or your actual screens
        '/tasks': (context) => const Scaffold(body: Center(child: Text("Tasks Screen"))), // Replace with MemberDashboard(tab: 0)
        '/meetings': (context) => const Scaffold(body: Center(child: Text("Meetings Screen"))), // Replace with MemberDashboard(tab: 1)
      },
      initialRoute: '/',
    );
  }
}