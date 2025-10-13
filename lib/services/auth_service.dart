import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // final String baseUrl = "http://10.0.2.2:5001/api/auth"; 
  final String baseUrl = "${dotenv.env['BASE_URL']}/api/auth";

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data["accessToken"];

      // Decode the JWT to get userId
      final payload = accessToken.split('.')[1];
      final normalized = base64Url.normalize(payload);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      final userId = decoded['id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("accessToken", accessToken);
      await prefs.setString("refreshToken", data["refreshToken"]);
      await prefs.setString("role", data["role"]);
      await prefs.setString("userId", userId); // store userId

      return true;
    } else {
      return false;
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
}
