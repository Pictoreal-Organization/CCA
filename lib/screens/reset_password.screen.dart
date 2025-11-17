import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signin.screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  ResetPasswordScreen({required this.email, required this.otp});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  void resetPassword() async {
    setState(() => loading = true);

    final res = await authService.changePasswordWithOTP(
      widget.email,
      widget.otp,
      passwordController.text,
    );

    setState(() => loading = false);

    if (!res["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"]),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Password changed successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resetPassword,
                    child: Text("Update Password"),
                  )
          ],
        ),
      ),
    );
  }
}
