import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  final String baseUrl = "http://10.0.2.2:5001/api/tasks";

  Future<List<dynamic>> getTasksByMember(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
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

  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    String? status,
    DateTime? startDate,
    DateTime? deadline,
    String? teamId,
    List<Map<String, dynamic>>? subtasks,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final body = {
      "title": title,
      "description": description ?? "",
      "status": status ?? "Pending",
      "startDate": startDate?.toIso8601String(),
      "deadline": deadline?.toIso8601String(),
      "team": teamId,
      "subtasks": subtasks ?? [],
    };

    print("📤 Sending task data: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("📥 Response ${response.statusCode}: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Failed to create task: ${response.body}');
    }
  }

}
