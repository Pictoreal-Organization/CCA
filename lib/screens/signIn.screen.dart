import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'member_dashboard.screen.dart';
import 'head_dashboard.screen.dart';
import 'forgot_password.screen.dart';
import '../core/app_colors.dart';

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
  bool _isPasswordVisible = false;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // simple frontend validation
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await authService.login(email, password);

    if (result["success"] == true) {
      setState(() => isLoading = false);

      final prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString("role");

      if (!mounted) return;

      if (role == "Head") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HeadDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MemberDashboard()),
        );
      }
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Login failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset:
            true, // Important: allows content to resize when keyboard appears
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40), // Top spacing
                  // Main Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo - Hide or shrink when keyboard is visible
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 200,
                        width: 200,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Email Field
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: AppColors.lightGray.withOpacity(0.4),
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: AppColors.lightGray,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password Field
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: AppColors.lightGray.withOpacity(0.4),
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: const TextStyle(
                              color: AppColors.lightGray,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.darkGray,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign In Button
                      isLoading
                          ? Container(
                              height: 44,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.darkTeal.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.darkTeal,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkTeal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Sign in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      // Forgot Password
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Footer - PICTOREAL (Hides when keyboard is visible)
                  // AnimatedOpacity(
                  //   opacity: isKeyboardVisible ? 0.0 : 1.0,
                  //   duration: const Duration(milliseconds: 200),
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(bottom: 30, top: 20),
                  //     child: Text(
                  //       "PICTOREAL",
                  //       style: TextStyle(
                  //         color: isKeyboardVisible
                  //             ? Colors.transparent
                  //             : AppColors.darkGray,
                  //         fontWeight: FontWeight.w500,
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  AnimatedOpacity(
                    opacity: isKeyboardVisible ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Image.asset(
                            'assets/images/pictoreal_logo.png',
                            height: 20,
                          ),
                          const SizedBox(width: 8),

                          // Text
                          Text(
                            "PICTOREAL",
                            style: TextStyle(
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
