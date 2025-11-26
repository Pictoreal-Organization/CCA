// services/tag_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config.dart';

class TagService {
  // final String baseUrl = "${dotenv.env['BASE_URL']}/api/tags";
  final String baseUrl = "${AppConfig.baseUrl}/api/tags";


  // Helper to get token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  // Get all tags
  Future<List<dynamic>> getAllTags() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> tags = jsonDecode(response.body);
      // Extract just the tag names from the objects
      return tags.map((tag) => tag['name'] as String).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }

  // Create a new tag (Admin only)
  Future<Map<String, dynamic>> createTag(String tagName) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": tagName}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create tag: ${response.body}');
    }
  }

  // Update tag (Admin only)
  Future<void> updateTag(String id, String newName) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/update/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update tag: ${response.body}');
    }
  }

  // Delete tag (Admin only)
  Future<void> deleteTag(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/$id'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete tag: ${response.body}');
    }
  }
}