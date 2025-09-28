import 'package:cca/screens/signIn.screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HeadDashboard extends StatefulWidget {
  const HeadDashboard({super.key});

  @override
  State<HeadDashboard> createState() => _HeadDashboard();
}

class _HeadDashboard extends State<HeadDashboard> {
  final authService = AuthService();
  void logout() async {
    await authService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are on Head Dashboard'),
          ],
        ),
      )
    ));
  }
}