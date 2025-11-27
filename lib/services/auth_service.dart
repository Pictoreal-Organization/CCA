//=================================================================================

//========================         FOR APP        =================================

//=================================================================================



// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // ✅ Import
// import 'package:flutter/foundation.dart';
// import '../config.dart';


// class AuthService {
//   // final String baseUrl = "http://10.0.2.2:5001/api/auth";
//   // final String baseUrl = "${dotenv.env['BASE_URL']}/api/auth";
//   final String baseUrl = "${AppConfig.baseUrl}/api/auth";

//   // ✅ Google Sign In Instance
//   // Make sure to use the WEB Client ID from Google Cloud Console here if needed
//   // final GoogleSignIn _googleSignIn = GoogleSignIn(
//   //   clientId: dotenv.env['GOOGLE_CLIENT_ID'],
//   //   scopes: ['email'],
//   // );

//   final GoogleSignIn _googleSignIn = kIsWeb
//     ? GoogleSignIn(
//         scopes: ['email'],                 // ✔ Web version → NO clientId, NO serverClientId
//       )
//     : GoogleSignIn(
//         serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],   // ✔ Backend verification
//         // clientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'],     // ✔ Android OAuth Client ID
//         scopes: ['email'],
//       );

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/login'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"email": email, "password": password}),
//     );

//     final Map<String, dynamic> body = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       final accessToken = body["accessToken"];
//       final payload = accessToken.split('.')[1];
//       final normalized = base64Url.normalize(payload);
//       final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
//       final userId = decoded['id'];

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString("accessToken", accessToken);
//       await prefs.setString("refreshToken", body["refreshToken"]);
//       await prefs.setString("role", body["role"]);
//       await prefs.setString("userId", userId);

//       return {"success": true};
//     } else {
//       return {"success": false, "message": body["msg"] ?? "Login failed"};
//     }
//   }

//   // ✅ NEW: Login With Google
//   Future<Map<String, dynamic>> loginWithGoogle() async {
//     try {
//       print("🔵 Starting Google Sign In...");
      
//       // ✅ Sign out first to ensure clean state
//       await _googleSignIn.signOut();
//       // 1. Start Google Sign In Flow
//       // This opens the dialog on the phone
//       final GoogleSignInAccount? googleUser = await _googleSignIn
//           .signIn();

//       print(dotenv.env['GOOGLE_CLIENT_ID']);


//       if (googleUser == null) {
//         // User canceled the sign-in
//         return {"success": false, "message": "Google sign in cancelled"};
//       }

//       // 2. Get Auth Headers (ID Token)
//       // This retrieves the token we need to send to the backend
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // ⚠️ IMPORTANT: Web gives accessToken, Mobile gives idToken
//       final token = kIsWeb ? googleAuth.accessToken : googleAuth.idToken;

//       if (token == null) {
//         print("❌ No token received");
//         return {
//           "success": false,
//           "message": "Could not retrieve authentication token"
//         };
//       }

//       print("🔑 Sending ${kIsWeb ? 'access' : 'id'} token to backend...");

//       // Send token to backend
//       final response = await http.post(
//         Uri.parse('$baseUrl/google'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "token": token,
//           "isWeb": kIsWeb, // ✅ Tell backend which token type
//         }),
//       );

//       print("📥 Backend response: ${response.statusCode}");

//       final Map<String, dynamic> body = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final accessToken = body["accessToken"];
//         final payload = accessToken.split('.')[1];
//         final normalized = base64Url.normalize(payload);
//         final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
//         final userId = decoded['id'];

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("accessToken", accessToken);
//         await prefs.setString("refreshToken", body["refreshToken"]);
//         await prefs.setString("role", body["role"]);
//         await prefs.setString("userId", userId);

//         print("✅ Login successful!");
//         return {"success": true};
//       } else {
//         await _googleSignIn.signOut();
//         print("❌ Backend rejected: ${body["msg"]}");
//         return {
//           "success": false,
//           "message": body["msg"] ?? "Google Login failed",
//         };
//       }

//       // // Check if we have the token
//       // if (googleAuth.idToken == null) {
//       //   return {"success": false, "message": "Could not retrieve ID token"};
//       // }

//       // // 3. Send ID Token to Backend
//       // // Your backend verifies this token with Google
//       // final response = await http.post(
//       //   Uri.parse('$baseUrl/google'),
//       //   headers: {"Content-Type": "application/json"},
//       //   body: jsonEncode({
//       //     "token": googleAuth.idToken, // Verification token
//       //   }),
//       // );

//       // final Map<String, dynamic> body = jsonDecode(response.body);

//       // if (response.statusCode == 200) {
//       //   // Standard Login Success Logic (Save JWTs)
//       //   final accessToken = body["accessToken"];
//       //   final payload = accessToken.split('.')[1];
//       //   final normalized = base64Url.normalize(payload);
//       //   final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
//       //   final userId = decoded['id'];

//       //   final prefs = await SharedPreferences.getInstance();
//       //   await prefs.setString("accessToken", accessToken);
//       //   await prefs.setString("refreshToken", body["refreshToken"]);
//       //   await prefs.setString("role", body["role"]);
//       //   await prefs.setString("userId", userId);

//       //   return {"success": true};
//       // } else {
//       //   // Ensure we sign out from Google if backend rejects us (e.g. user not in DB)
//       //   await _googleSignIn.signOut();
//       //   return {
//       //     "success": false,
//       //     "message": body["msg"] ?? "Google Login failed",
//       //   };
//       // }
//     } catch (e) {
//       return {"success": false, "message": "Error: $e"};
//     }
//   }

//   Future<bool> register(String username, String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/register'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "username": username,
//         "email": email,
//         "password": password,
//         "role": "Member", // default role
//       }),
//     );

//     return response.statusCode == 201;
//   }

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove("accessToken");
//     await prefs.remove("refreshToken");
//     await prefs.remove("role");
//     await _googleSignIn.signOut(); // ✅ Sign out of Google too
//   }

//   Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString("accessToken") != null;
//   }

//   Future<Map<String, dynamic>> requestPasswordChange(String email) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/request-password-change'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"email": email}),
//     );

//     final body = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return {"success": true};
//     }

//     return {"success": false, "message": body["msg"] ?? "Something went wrong"};
//   }

//   Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/verify-otp'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"email": email, "otp": otp}),
//     );

//     final body = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return {"success": true};
//     }

//     return {
//       "success": false,
//       "message": body["msg"] ?? "Invalid or expired OTP",
//     };
//   }

//   Future<Map<String, dynamic>> changePasswordWithOTP(
//     String email,
//     String otp,
//     String newPassword,
//   ) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/change-password-otp'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "email": email,
//         "otp": otp,
//         "newPassword": newPassword,
//       }),
//     );

//     final body = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return {"success": true};
//     }

//     return {
//       "success": false,
//       "message": body["msg"] ?? "Failed to change password",
//     };
//   }

//   Future<void> saveFcmToken(String fcmToken) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString("accessToken");

//     if (token == null) return; // User not logged in yet

//     try {
//       await http.put(
//         Uri.parse(
//           '$baseUrl/fcm-token',
//         ), // Ensure this route exists in your backend auth.routes.js
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode({"fcmToken": fcmToken}),
//       );
//       print("✅ FCM Token saved to backend");
//     } catch (e) {
//       print("❌ Failed to save FCM Token: $e");
//     }
//   }
// }


//=================================================================================

//========================         FOR WEB        =================================

//=================================================================================


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../config.dart'; // ✅ Ensure this imports your AppConfig class

class AuthService {
  // ✅ Use AppConfig.baseUrl instead of dotenv
  final String baseUrl = "${AppConfig.baseUrl}/api/auth";

  // ✅ FIX: Explicitly define Client ID for Web/Mobile stability
  // This fixes the "minified" error on Vercel deployments
  static const String _webClientId = "116396092394-skr8i8kgq6b4k8s9eab1u3bll9raa6bm.apps.googleusercontent.com";

  final GoogleSignIn _googleSignIn = kIsWeb
    ? GoogleSignIn(
        clientId: _webClientId, // ✅ Required for Web (Mobile Browsers)
        scopes: ['email', 'profile'],
      )
    : GoogleSignIn(
        serverClientId: _webClientId, // ✅ Required for Android
        scopes: ['email', 'profile'],
      );

  // --- 1. Login with Email/Password ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(body);
        return {"success": true};
      } else {
        return {"success": false, "message": body["msg"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: $e"};
    }
  }

  // --- 2. Login with Google ---
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      print("🔵 Starting Google Sign In...");
      
      // ✅ Ensure clean state
      await _googleSignIn.signOut();
      
      // A. Start Flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {"success": false, "message": "Google sign in cancelled"};
      }

      // B. Get Auth Headers
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // ⚠️ Web uses accessToken, Mobile uses idToken
      final token = kIsWeb ? googleAuth.accessToken : googleAuth.idToken;

      if (token == null) {
        print("❌ No token received");
        return {
          "success": false,
          "message": "Could not retrieve authentication token"
        };
      }

      print("🔑 Sending ${kIsWeb ? 'access' : 'id'} token to backend...");

      // C. Send to Backend
      final response = await http.post(
        Uri.parse('$baseUrl/google'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "isWeb": kIsWeb, 
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(body);
        print("✅ Login successful!");
        return {"success": true};
      } else {
        await _googleSignIn.signOut();
        print("❌ Backend rejected: ${body["msg"]}");
        return {
          "success": false,
          "message": body["msg"] ?? "Google Login failed",
        };
      }
    } catch (e) {
      print("❌ Google Auth Error: $e");
      return {"success": false, "message": "Login Error: $e"};
    }
  }

  // --- 3. Helper: Save Data ---
  Future<void> _saveAuthData(Map<String, dynamic> body) async {
    final accessToken = body["accessToken"];
    
    // Decode JWT to get User ID
    final payload = accessToken.split('.')[1];
    final normalized = base64Url.normalize(payload);
    final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    final userId = decoded['id'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", body["refreshToken"]);
    await prefs.setString("role", body["role"]);
    await prefs.setString("userId", userId);
  }

  // --- 4. Register ---
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "role": "Member",
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // --- 5. Logout ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears tokens and preferences
    await _googleSignIn.signOut();
  }

  // --- 6. Check Login Status ---
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken") != null;
  }

  // --- 7. Password Reset Methods ---
  Future<Map<String, dynamic>> requestPasswordChange(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request-password-change'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) return {"success": true};
      return {"success": false, "message": body["msg"] ?? "Error"};
    } catch (e) {
      return {"success": false, "message": "Connection Error"};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) return {"success": true};
      return {"success": false, "message": body["msg"] ?? "Invalid OTP"};
    } catch (e) {
      return {"success": false, "message": "Connection Error"};
    }
  }

  Future<Map<String, dynamic>> changePasswordWithOTP(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
        }),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) return {"success": true};
      return {"success": false, "message": body["msg"] ?? "Failed"};
    } catch (e) {
      return {"success": false, "message": "Connection Error"};
    }
  }

  // --- 8. FCM Token ---
  Future<void> saveFcmToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    if (token == null) return;

    try {
      await http.put(
        Uri.parse('$baseUrl/fcm-token'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"fcmToken": fcmToken}),
      );
      print("✅ FCM Token saved");
    } catch (e) {
      print("❌ Failed to save FCM Token: $e");
    }
  }
}