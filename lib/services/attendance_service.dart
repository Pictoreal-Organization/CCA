import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  final String baseUrl = "http://10.0.2.2:5001/api/attendance";

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

  Future<void> markAttendance(String meetingId, String memberId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final response = await http.post(
      Uri.parse('$baseUrl/mark'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "meetingId": meetingId,
        "memberId": memberId,
        "status": status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark attendance');
    }
  }
}
