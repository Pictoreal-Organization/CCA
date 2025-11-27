// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'signIn.screen.dart';
// import 'member_dashboard.screen.dart';
// import 'head_dashboard.screen.dart';
// import '../widgets/loading_animation.widget.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToNext();
//   }

//   Future<void> _navigateToNext() async {
//     await Future.delayed(const Duration(seconds: 3)); // splash delay
//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString("accessToken");
//     String? role = prefs.getString("role");

//     Widget nextScreen;

//     if (token != null && JwtDecoder.isExpired(token) == false) {
//       if (role == "Head") {
//         nextScreen = HeadDashboard();
//       } else {
//         nextScreen = MemberDashboard();
//       }
//     } else {
//       nextScreen = SignInScreen();
//     }

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => nextScreen),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: LoadingAnimation(size: 250),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io' show InternetAddress;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'signIn.screen.dart';
import 'member_dashboard.screen.dart';
import 'head_dashboard.screen.dart';
import '../widgets/loading_animation.widget.dart';
import '../services/notification_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInternetOnStart();
    });
  }

  // 🔍 Universal Internet Check (WEB + MOBILE)
  Future<bool> hasInternet() async {
    // 👉 Web: InternetAddress is not supported
    if (kIsWeb) {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    }

    // 👉 Android/iOS: Real internet check
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // 🌐 Check internet on splash load
  Future<void> checkInternetOnStart() async {
    bool online = await hasInternet();

    if (!online) {
      showNoInternetDialog();
      return;
    }

    _navigateToNext();
  }

  // 💬 Internet Off Dialog
  void showNoInternetDialog() {
    if (_dialogShown) return;
    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("No Internet"),
          content: const Text("Your internet is off. Please turn it on."),
          actions: [
            TextButton(
              child: const Text("Retry"),
              onPressed: () async {
                bool online = await hasInternet();
                if (online) {
                  Navigator.pop(context);
                  _dialogShown = false;
                  _navigateToNext();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 🚪 Navigation Logic (unchanged)
  // Future<void> _navigateToNext() async {
  //   await Future.delayed(const Duration(seconds: 3));

  //   final prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString("accessToken");
  //   String? role = prefs.getString("role");

  //   Widget nextScreen;

  //   if (token != null && !JwtDecoder.isExpired(token)) {
  //     nextScreen = role == "Head" ? HeadDashboard() : MemberDashboard();
  //   } else {
  //     nextScreen = SignInScreen();
  //   }

  //   if (!mounted) return;

  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => nextScreen),
  //   );
  // }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    String? role = prefs.getString("role");

    Widget nextScreen;

    if (token != null && !JwtDecoder.isExpired(token)) {
      
      // ✅ Initialize Notifications HERE
      // This will check permissions, ask if needed, and sync token
      await NotificationHandler().initialize(); 
      
      nextScreen = role == "Head" ? HeadDashboard() : MemberDashboard();
    } else {
      nextScreen = SignInScreen();
    }

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return const Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Center(child: LoadingAnimation(size: 220)),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    // DEBUG: Get the current URL the app sees
    final currentUrl = Uri.base.toString();
    final redirectParam = Uri.base.queryParameters['redirect'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingAnimation(size: 220),
            const SizedBox(height: 20),
            
            // 🔴 DIAGNOSIS TEXT (Remove this later)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "DEBUG INFO:\nURL: $currentUrl\nRedirect Param: $redirectParam",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
