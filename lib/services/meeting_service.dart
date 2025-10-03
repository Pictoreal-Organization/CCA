import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MeetingService {
  final String baseUrl = "http://10.0.2.2:5001/api/meetings";

  Future<List<dynamic>> getOngoingMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/status/ongoing'), // <- updated endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load ongoing meetings');
    }
  }

  Future<List<dynamic>> getUpcomingMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/status/scheduled'), // <- updated endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load upcoming meetings');
    }
  }

  Future<List<dynamic>> getCompletedMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/status/completed'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load completed meetings');
    }
  }

  Future<List<dynamic>> getMeetingsForAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/attendance/pending'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load meetings for attendance');
    }
  }

}
