import 'package:flutter/material.dart';
import 'otp.screen.dart';
import '../services/auth_service.dart';
import '../widgets/loading_animation.widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  void requestOTP() async {
    setState(() => loading = true);

    final res = await authService.requestPasswordChange(emailController.text);

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
        content: Text("OTP sent to your email!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OTPScreen(email: emailController.text),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter your email"),
            ),
            SizedBox(height: 20),
            loading
                ? LoadingAnimation()
                : ElevatedButton(
                    onPressed: requestOTP,
                    child: Text("Send OTP"),
                  )
          ],
        ),
      ),
    );
  }
}
