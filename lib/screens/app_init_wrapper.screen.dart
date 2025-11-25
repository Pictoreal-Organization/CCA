import 'package:flutter/material.dart';
import '../services/notification_handler.dart';
import 'splash.screen.dart';

class AppInitWrapper extends StatefulWidget {
  const AppInitWrapper({super.key});

  @override
  State<AppInitWrapper> createState() => _AppInitWrapperState();
}

class _AppInitWrapperState extends State<AppInitWrapper> {
  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    // Wait a brief moment for the UI to settle
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // ✅ This calls the new checkAndRequestPermission method
    await NotificationHandler().checkAndRequestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}