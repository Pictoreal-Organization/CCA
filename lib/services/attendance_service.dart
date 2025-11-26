import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AttendanceService {
  // final String baseUrl = "http://10.0.2.2:5001/api/attendance";
  // final String baseUrl = "${dotenv.env['BASE_URL']}/api/attendance";
  final String baseUrl = "${AppConfig.baseUrl}/api/attendance";

  Future<List<dynamic>> getAttendanceForMeeting(String meetingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/meeting/$meetingId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load attendance');
    }
  }

  Future<void> submitBulkAttendance(String meetingId, List<String> presentMemberIds) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");
    
    final url = Uri.parse('$baseUrl/mark');
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    final body = jsonEncode({
      "meetingId": meetingId,
      "presentMemberIds": presentMemberIds,
    });

    // --- ADD THESE LINES FOR DEBUGGING ---
    if (kDebugMode) { // kDebugMode ensures printing only happens in debug builds
      print("----------- Sending Attendance Data -----------");
      print("URL: $url");
      print("Headers: $headers");
      print("Body: $body");
      print("---------------------------------------------");
    }
    // -----------------------------------------

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      // Also helpful to print the server's response on error
      if (kDebugMode) {
        print("Error Response Body: ${response.body}");
      }
      throw Exception('Failed to submit attendance');
    }
  }
}