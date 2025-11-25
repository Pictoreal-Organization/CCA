// // import 'package:flutter/material.dart';
// // import '../services/notification_handler.dart';
// // import 'splash.screen.dart';

// // class AppInitWrapper extends StatefulWidget {
// //   const AppInitWrapper({super.key});

// //   @override
// //   State<AppInitWrapper> createState() => _AppInitWrapperState();
// // }

// // class _AppInitWrapperState extends State<AppInitWrapper> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkNotificationPermission();
// //   }

// //   Future<void> _checkNotificationPermission() async {
// //     await Future.delayed(const Duration(milliseconds: 500));
// //     if (!mounted) return;
    
// //     try {
// //       await NotificationHandler().checkAndRequestPermission();
// //     } catch (e) {
// //       debugPrint('Notification permission check failed: $e');
// //     }
// //   }


// //   @override
// //   Widget build(BuildContext context) {
// //     return const SplashScreen();
// //   }
// // }

// import 'package:flutter/material.dart';
// import '../services/notification_handler.dart';
// import 'splash.screen.dart';

// class AppInitWrapper extends StatefulWidget {
//   const AppInitWrapper({super.key});

//   @override
//   State<AppInitWrapper> createState() => _AppInitWrapperState();
// }

// class _AppInitWrapperState extends State<AppInitWrapper> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//   }

//   Future<void> _initializeNotifications() async {
//     try {
//       // Wait for UI to settle
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       if (!mounted) return;

//       // ✅ Request permission (this will also initialize if granted)
//       final granted = await NotificationHandler().checkAndRequestPermission();
      
//       if (granted) {
//         print("✅ Notifications initialized successfully");
//       } else {
//         print("⚠️ Notification permission not granted");
//       }
//     } catch (e) {
//       print("❌ Error during notification initialization: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const SplashScreen();
//   }
// }