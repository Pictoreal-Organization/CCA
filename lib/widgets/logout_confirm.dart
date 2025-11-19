import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/signIn.screen.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close popup
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 236, 95, 85)),
          onPressed: () async {
            final authService = AuthService();
            await authService.logout();
            Navigator.of(context).pop(); // close dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          },
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
