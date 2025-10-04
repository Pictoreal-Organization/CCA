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

  Future<Map<String, dynamic>> createMeeting({
  required String title,
  required String description,
  required DateTime dateTime,
  required String location,
  String? agenda,
  int? duration,
  String? priority,
  String? onlineLink,
  String? teamId,
  }) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");

      final body = {
        "title": title,
        "description": description,
        "agenda": agenda,
        "dateTime": dateTime.toIso8601String(),
        "duration": duration ?? 60,
        "priority": priority ?? "Medium",
        "location": location,
        "onlineLink": onlineLink,
        "team": teamId,
      };

      print(" Sending meeting data: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print(" Response ${response.statusCode}: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create meeting: ${response.body}');
      }
    }
}