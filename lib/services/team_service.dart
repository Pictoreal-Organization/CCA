import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TeamService {
  // final String baseUrl = "http://10.0.2.2:5001/api/teams";
  final String baseUrl = "${dotenv.env['BASE_URL']}/api/teams";

  // Get all visible teams
  Future<List<Map<String, dynamic>>> getVisibleTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/visible"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Failed to load visible teams: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching visible teams: $e");
    }
  }

  // Optional: get all teams (admin)
  Future<List<Map<String, dynamic>>> getAllTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Failed to load all teams: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching teams: $e");
    }
  }

  // Optional: get a single team by ID
  Future<Map<String, dynamic>> getTeamById(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    try {
      final response = await http.get(Uri.parse("$baseUrl/$teamId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception("Failed to get team: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching team: $e");
    }
  }
}
