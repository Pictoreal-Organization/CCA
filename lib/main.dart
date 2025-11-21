// import 'package:flutter/material.dart';
// import 'screens/splash.screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: Colors.white,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'screens/splash.screen.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'core/app_colors.dart'; // <-- your color file

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const seedColor = AppColors.darkTeal; // 💚 your base color

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'My App',
//       themeMode: ThemeMode.system,

//       // 🌞 Light Theme
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: seedColor,
//           secondary: AppColors.orange,
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),

//       // 🌚 Dark Theme
//       darkTheme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: seedColor,
//           secondary: AppColors.orange,
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),

//       home: const SplashScreen(),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'screens/splash.screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔵 Background message received: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationHandler().initialize(); // You will add this file
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env");
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = AppColors.darkTeal;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PictoCreds',

      // 👇 Force app to always use light theme
      themeMode: ThemeMode.light,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          secondary: AppColors.orange,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white, // white screens everywhere
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: const SplashScreen(),
    );
  }
}