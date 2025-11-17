import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // final String baseUrl = "http://10.0.2.2:5001/api/auth"; 
  final String baseUrl = "${dotenv.env['BASE_URL']}/api/auth";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final accessToken = body["accessToken"];
      final payload = accessToken.split('.')[1];
      final normalized = base64Url.normalize(payload);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      final userId = decoded['id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("accessToken", accessToken);
      await prefs.setString("refreshToken", body["refreshToken"]);
      await prefs.setString("role", body["role"]);
      await prefs.setString("userId", userId);

      return {"success": true};
    } 
    else {
      return {
        "success": false,
        "message": body["msg"] ?? "Login failed"
      };
    }
  }


  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "role": "Member" // default role
      }),
    );

    return response.statusCode == 201;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
    await prefs.remove("role");
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken") != null;
  }

  Future<Map<String, dynamic>> requestPasswordChange(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/request-password-change'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true};
    }

    return {
      "success": false,
      "message": body["msg"] ?? "Something went wrong"
    };
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {"success": true};
    }

    return {
      "success": false,
      "message": body["msg"] ?? "Invalid or expired OTP"
    };
  }

  Future<Map<String, dynamic>> changePasswordWithOTP(String email, String otp, String newPassword) async {
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

    if (response.statusCode == 200) {
      return {"success": true};
    }

    return {
      "success": false,
      "message": body["msg"] ?? "Failed to change password"
    };
  }
}
