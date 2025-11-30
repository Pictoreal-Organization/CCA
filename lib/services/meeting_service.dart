import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config.dart';

class MeetingService {
  // final String baseUrl = "http://10.0.2.2:5001/api/meetings";
  // final String baseUrl = "${dotenv.env['BASE_URL']}/api/meetings";
  final String baseUrl = "${AppConfig.baseUrl}/api/meetings";

  // Helper to get token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  Future<bool> getHasControl(String meetingId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/$meetingId/has-control'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["canControl"] ?? false;
    } else {
      return false; // if any error, assume no control
    }
  }

  // ✅ NEW: Get All Heads (Entire Core)
  Future<List<dynamic>> getEntireCore() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/core/entire'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load entire core members');
    }
  }

  // ✅ NEW: Get BE Core Heads Only
  Future<List<dynamic>> getBECore() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/core/be'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('BE Core team not found');
    } else {
      throw Exception('Failed to load BE Core members');
    }
  }

  // ✅ NEW: Get TE Core Heads (All teams except BE Core)
  Future<List<dynamic>> getTECore() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/core/te'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load TE Core members');
    }
  }

  Future<List<dynamic>> getOngoingMeetings() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/status/ongoing'),
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
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/status/scheduled'),
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
    final token = await _getToken();
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
    final token = await _getToken();
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
    required DateTime endTime,
    String? location,
    String? agenda,
    int? duration,
    String? priority,
    String? onlineLink,
    List<String>? tags,
    bool? isPrivate,
    List<String>? invitedMembers,
    List<String>? team,
  }) async {
    final token = await _getToken();

    final body = {
      "title": title,
      "description": description,
      "agenda": agenda,
      "dateTime": dateTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "duration": duration ?? 60,
      "priority": priority ?? "Medium",
      "location": location,
      "onlineLink": onlineLink,
      "team": team,
      "tags": tags ?? [],
      "isPrivate": isPrivate ?? false,
      "invitedMembers": invitedMembers ?? [],
    };
    
    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create meeting: ${response.body}');
    }
  }

  // ✅ ADDED: Update Meeting
  Future<void> updateMeeting(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update meeting: ${response.body}');
    }
  }

  // ✅ ADDED: Delete Meeting
  Future<void> deleteMeeting(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete meeting: ${response.body}');
    }
  }
}