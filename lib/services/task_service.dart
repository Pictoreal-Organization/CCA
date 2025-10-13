import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaskService {
  // final String baseUrl = "http://10.0.2.2:5001/api/tasks";
  final String baseUrl = "${dotenv.env['BASE_URL']}/api/tasks";

  // Helper method to get the token securely
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  // --- METHODS FOR HEADS ---

  // Fetches all tasks for the Head Dashboard
  Future<List<dynamic>> getAllTasks() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Creates a new task (already existed, no changes)
  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    String? status,
    DateTime? startDate,
    DateTime? deadline,
    String? teamId,
    List<Map<String, dynamic>>? subtasks,
  }) async {
    final token = await _getToken();
    final body = {
      "title": title,
      "description": description ?? "",
      "status": status ?? "Pending",
      "startDate": startDate?.toIso8601String(),
      "deadline": deadline?.toIso8601String(),
      "team": teamId,
      "subtasks": subtasks ?? [],
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
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  // Updates an entire task document
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/update/$taskId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  // Deletes a task by its ID
  Future<void> deleteTask(String taskId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/$taskId'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

  // --- METHODS FOR MEMBERS ---

  // Fetches only the tasks/subtasks assigned to a specific member
  Future<List<dynamic>> getTasksByMember(String userId) async {
    final token = await _getToken();
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
      throw Exception('Failed to load member tasks');
    }
  }

  // Updates a specific subtask's status and description
  Future<void> updateSubtask({
    required String taskId,
    required String subtaskId,
    required Map<String, dynamic> data,
  }) async {
    final token = await _getToken();
    final response = await http.put(
      // This matches the specific backend route for updating a subtask
      Uri.parse('$baseUrl/$taskId/subtasks/$subtaskId/status'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update subtask: ${response.body}');
    }
  }

  Future<List<dynamic>> getCompletedTasksByUser(String userId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/completed'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load completed tasks');
    }
  }

  Future<List<dynamic>> getAllCompletedTasks() async {
    final token = await _getToken();
    // This assumes you have a backend route like '/status/Completed'
    final response = await http.get(
      Uri.parse('$baseUrl/status/Completed'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load all completed tasks');
    }
  }
}