import 'package:flutter/material.dart';
import 'reset_password.screen.dart';
import '../services/auth_service.dart';
import '../widgets/loading_animation.widget.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  OTPScreen({required this.email});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final otpController = TextEditingController();
  final authService = AuthService();
  bool loading = false;

  void verify() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter OTP first")),
      );
      return;
    }

    if (otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP must be 6 digits")),
      );
      return;
    }

    setState(() => loading = true);

    final result = await authService.verifyOtp(
      widget.email,
      otpController.text,
    );

    setState(() => loading = false);

    if (!result["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );
      return;
    }

    // 🔥 OTP valid → Move to Reset Password Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          email: widget.email,
          otp: otpController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "6-digit OTP"),
            ),
            SizedBox(height: 20),
            loading
                ? LoadingAnimation()
                : ElevatedButton(
                    onPressed: loading ? null : verify,
                    child: Text("Next"),
                  )
          ],
        ),
      ),
    );
  }
}
