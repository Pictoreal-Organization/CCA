import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Data models
class Meeting {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime dueDate;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'],
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  
  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Meeting> meetings = [];
  List<Task> tasks = [];
  bool isLoadingMeetings = true;
  bool isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
    _fetchTasks();
  }

  // API call to fetch upcoming meetings
  Future<void> _fetchMeetings() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/api/meetings/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your_token_here', // Add your auth token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          meetings = jsonData.map((json) => Meeting.fromJson(json)).toList();
          isLoadingMeetings = false;
        });
      } else {
        throw Exception('Failed to load meetings');
      }
    } catch (e) {
      setState(() {
        isLoadingMeetings = false;
      });
      print('Error fetching meetings: $e');
    }
  }

  // API call to fetch assigned tasks
  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/api/tasks/assigned'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your_token_here', // Add your auth token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          tasks = jsonData.map((json) => Task.fromJson(json)).toList();
          isLoadingTasks = false;
        });
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      setState(() {
        isLoadingTasks = false;
      });
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchMeetings(), _fetchTasks()]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Welcome ${widget.username}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Upcoming Meetings Section
              _buildSectionHeader('Upcoming Meetings', Icons.event),
              const SizedBox(height: 12),
              _buildMeetingsSection(),
              
              const SizedBox(height: 32),

              // Assigned Tasks Section
              _buildSectionHeader('Assigned Tasks', Icons.task_alt),
              const SizedBox(height: 12),
              _buildTasksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingsSection() {
    if (isLoadingMeetings) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (meetings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No upcoming meetings',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: meetings.map((meeting) => _buildMeetingCard(meeting)).toList(),
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meeting.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meeting.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey[500], size: 16),
              const SizedBox(width: 4),
              Text(
                '${meeting.dateTime.day}/${meeting.dateTime.month} at ${meeting.dateTime.hour}:${meeting.dateTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, color: Colors.grey[500], size: 16),
              const SizedBox(width: 4),
              Text(
                meeting.location,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    if (isLoadingTasks) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No assigned tasks',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      children: tasks.map((task) => _buildTaskCard(task)).toList(),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor = task.priority.toLowerCase() == 'high' 
        ? Colors.red 
        : task.priority.toLowerCase() == 'medium' 
            ? Colors.orange 
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.task_alt, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    fontSize: 12,
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.grey[500], size: 16),
              const SizedBox(width: 4),
              Text(
                'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.info_outline, color: Colors.grey[500], size: 16),
              const SizedBox(width: 4),
              Text(
                task.status,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}