import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'dashboard.screen.dart';
import 'member_dashboard.screen.dart';
import 'head_dashboard.screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);
    bool success = await authService.login(emailController.text, passwordController.text);
    setState(() => isLoading = false);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString("role");
      if (role == "Head") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HeadDashboard()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MemberDashboard()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid Credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: emailController, 
                decoration: InputDecoration(
                  hintText: "Email"
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: passwordController, 
                decoration: InputDecoration(
                  hintText: "Password"
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20,),
            isLoading 
              ? CircularProgressIndicator()
              : SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(onPressed: login, child: Text("Sign In"))
              ),
              // : ElevatedButton(onPressed: login, child: Text("Sign In"),),
          ],
        ),
      )
    ));
  }
}