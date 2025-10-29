import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'member_dashboard.screen.dart';
import 'head_dashboard.screen.dart';
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
    setState(() => isLoading = true);
    bool success = await authService.login(
      emailController.text,
      passwordController.text,
    );
    setState(() => isLoading = false);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString("role");
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid Credentials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    //Logo
                    Image.asset('assets/images/logo.png', height: 60, width: 60),
                    SizedBox(height: 40),

                    //Email Field
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cream5,
                        border: Border.all(color: AppColors.charcoal4, width: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                            color: AppColors.charcoal3,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(color: AppColors.charcoal1, fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 12),

                    //Password Field
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cream5,
                        border: Border.all(color: AppColors.charcoal4, width: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: AppColors.charcoal3,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.charcoal3,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(color: AppColors.charcoal1, fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 20),

                    //Sign In Button
                    isLoading
                        ? Container(
                            height: 44,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.teal1.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.teal1,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 44,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20),

                    // Forgot Password
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: AppColors.teal2,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer to push everything up
              //Spacer(),

              // Footer - PICTOREAL
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(
                  "PICTOREAL",
                  style: TextStyle(
                    color: AppColors.charcoal2,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}