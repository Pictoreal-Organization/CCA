// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/auth_service.dart';
// import '../services/notification_handler.dart'; // ✅ Import Notification Handler
// import 'member_dashboard.screen.dart';
// import 'head_dashboard.screen.dart';
// import 'forgot_password.screen.dart';
// import '../core/app_colors.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final authService = AuthService();
//   bool isLoading = false;
//   bool _isPasswordVisible = false;

//   void _handlePostLogin() async {
//     // ✅ Common logic for after successful login (Email or Google)
//     // Initialize Notifications
//     await NotificationHandler().initialize();

//     final prefs = await SharedPreferences.getInstance();
//     String? role = prefs.getString("role");

//     if (!mounted) return;
//     setState(() => isLoading = false);

//     if (role == "Head") {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HeadDashboard()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => MemberDashboard()),
//       );
//     }
//   }

//   void login() async {
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Email and password cannot be empty")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     final result = await authService.login(email, password);

//     if (result["success"] == true) {
//       _handlePostLogin(); // ✅ Reuse logic
//     } else {
//       setState(() => isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(result["message"] ?? "Login failed")),
//         );
//       }
//     }
//   }

//   // ✅ NEW: Google Login Handler
//   void googleLogin() async {
//     setState(() => isLoading = true);
    
//     final result = await authService.loginWithGoogle();

//     if (result["success"] == true) {
//       _handlePostLogin();
//     } else {
//       setState(() => isLoading = false);
//       if (mounted && result["message"] != "Google sign in cancelled") {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(result["message"] ?? "Google Login failed")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//     final isKeyboardVisible = bottomInset > 0;

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         resizeToAvoidBottomInset: true,
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight:
//                     MediaQuery.of(context).size.height -
//                     MediaQuery.of(context).padding.top -
//                     MediaQuery.of(context).padding.bottom,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const SizedBox(height: 40), 
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Logo
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         height: 200,
//                         width: 200,
//                         child: Image.asset(
//                           'assets/images/logo.png',
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       SizedBox(height: 20),

//                       // Email Field
//                       Container(
//                         height: 44,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           border: Border.all(
//                             color: AppColors.lightGray.withOpacity(0.4),
//                             width: 0.8,
//                           ),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: TextField(
//                           controller: emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: const InputDecoration(
//                             hintText: "Email",
//                             hintStyle: TextStyle(
//                               color: AppColors.lightGray,
//                               fontSize: 14,
//                             ),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 12,
//                             ),
//                           ),
//                           style: const TextStyle(
//                             color: AppColors.darkGray,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // Password Field
//                       Container(
//                         height: 44,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           border: Border.all(
//                             color: AppColors.lightGray.withOpacity(0.4),
//                             width: 0.8,
//                           ),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: TextField(
//                           controller: passwordController,
//                           obscureText: !_isPasswordVisible,
//                           decoration: InputDecoration(
//                             hintText: "Password",
//                             hintStyle: const TextStyle(
//                               color: AppColors.lightGray,
//                               fontSize: 14,
//                             ),
//                             border: InputBorder.none,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 12,
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _isPasswordVisible
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 color: AppColors.darkGray,
//                                 size: 18,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _isPasswordVisible = !_isPasswordVisible;
//                                 });
//                               },
//                             ),
//                           ),
//                           style: const TextStyle(
//                             color: AppColors.darkGray,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // Sign In Button
//                       isLoading
//                           ? Container(
//                               height: 44,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: AppColors.darkTeal.withOpacity(0.6),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Center(
//                                 child: SizedBox(
//                                   height: 18,
//                                   width: 18,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       AppColors.darkTeal,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : SizedBox(
//                               height: 44,
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: login,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.darkTeal,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   elevation: 0,
//                                 ),
//                                 child: const Text(
//                                   "Sign in",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                       const SizedBox(height: 15),

//                       // ✅ Google Login Button
//                       if (!isLoading)
//                         SizedBox(
//                           height: 44,
//                           width: double.infinity,
//                           child: OutlinedButton.icon(
//                             onPressed: googleLogin,
//                             icon: const Icon(Icons.login, color: Colors.black54, size: 20), // Replace with Google Logo asset if available
//                             label: const Text(
//                               "Sign in with Google",
//                               style: TextStyle(
//                                 color: Colors.black87,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             style: OutlinedButton.styleFrom(
//                               side: BorderSide(color: Colors.grey.shade300),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                         ),

//                       const SizedBox(height: 20),

//                       // Forgot Password
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ForgotPasswordScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           "Forgot password?",
//                           style: TextStyle(
//                             color: AppColors.green,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   AnimatedOpacity(
//                     opacity: isKeyboardVisible ? 0.0 : 1.0,
//                     duration: const Duration(milliseconds: 200),
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 30, top: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Logo
//                           Image.asset(
//                             'assets/images/pictoreal_logo.png',
//                             height: 20,
//                           ),
//                           const SizedBox(width: 8),

//                           // Text
//                           Text(
//                             "PICTOREAL",
//                             style: TextStyle(
//                               color: AppColors.darkGray,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✅ Import Font Awesome
import '../services/auth_service.dart';
import '../services/notification_handler.dart'; // ✅ Notification Handler
import 'member_dashboard.screen.dart';
import 'head_dashboard.screen.dart';
import '../core/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final authService = AuthService();
  bool isLoading = false;

  void _handlePostLogin() async {
    // ✅ Common logic for after successful login
    // Initialize Notifications
    await NotificationHandler().initialize();

    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString("role");

    if (!mounted) return;
    setState(() => isLoading = false);

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
  }

  // ✅ Google Login Handler
  void googleLogin() async {
    setState(() => isLoading = true);
    
    final result = await authService.loginWithGoogle();

    if (result["success"] == true) {
      _handlePostLogin();
    } else {
      setState(() => isLoading = false);
      if (mounted && result["message"] != "Google sign in cancelled") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Google Login failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 60), 
              
              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 220,
                      width: 220,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // const SizedBox(height: 10),

                    // Welcome Text
                    const Text(
                      "Welcome to PictoCreds",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign in to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.lightGray,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Sign In Button
                    isLoading
                        ? Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
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
                            height: 50,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: googleLogin,
                              icon: Image.asset(
                                'assets/images/google_logo.jpg',
                                height: 20,
                                width: 20,
                              ),
 
                              label: const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.white,
                                elevation: 0,
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              // Footer - PICTOREAL
              Padding(
                padding: const EdgeInsets.only(bottom: 30, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/pictoreal_logo.png',
                      height: 20,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                    const SizedBox(width: 8),

                    // Text
                    const Text(
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
            ],
          ),
        ),
      ),
    );
  }
}