import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Meeting',
      description: json['description'] ?? json['body'] ?? 'No description',
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now().add(Duration(days: 1)),
      location: json['location'] ?? 'Conference Room A',
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
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Task',
      description: json['description'] ?? json['body'] ?? 'No description',
      priority: json['priority'] ?? ['high', 'medium', 'low'][(json['id'] ?? 1) % 3],
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now().add(Duration(days: 7)),
      status: json['status'] ?? (json['completed'] == true ? 'completed' : 'pending'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  
  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Meeting> meetings = [];
  List<Task> tasks = [];
  bool isLoadingMeetings = true;
  bool isLoadingTasks = true;
  String? errorMessage;
  late final String baseUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeApp();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeApp() {
    try {
      baseUrl = dotenv.env['API_URL'] ?? 'https://jsonplaceholder.typicode.com';
      print('Using API URL: $baseUrl');
      _fetchMeetings();
      _fetchTasks();
    } catch (e) {
      print('Error initializing app: $e');
      setState(() {
        errorMessage = 'Failed to initialize app: $e';
        isLoadingMeetings = false;
        isLoadingTasks = false;
      });
    }
  }

  // Mock API call for meetings with fallback
  Future<void> _fetchMeetings() async {
    try {
      setState(() {
        isLoadingMeetings = true;
        errorMessage = null;
      });

      http.Response response;
      try {
        response = await http.get(
          Uri.parse('$baseUrl/api/meetings/status/upcoming'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: 10));
      } catch (e) {
        print('Primary API failed, using mock data: $e');
        response = await http.get(
          Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=3'),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          meetings = jsonData.map((json) => Meeting.fromJson(json)).toList();
          isLoadingMeetings = false;
        });
      } else {
        throw Exception('Failed to load meetings: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingMeetings = false;
        errorMessage = 'Error fetching meetings: $e';
      });
      print('Error fetching meetings: $e');
    }
  }

  // Mock API call for tasks with fallback
  Future<void> _fetchTasks() async {
    try {
      setState(() {
        isLoadingTasks = true;
        errorMessage = null;
      });

      http.Response response;
      try {
        response = await http.get(
          Uri.parse('$baseUrl/api/tasks/team/688517e5a7acdb810118f874'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer your_token_here',
          },
        ).timeout(Duration(seconds: 10));
      } catch (e) {
        print('Primary API failed, using mock data: $e');
        response = await http.get(
          Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          tasks = jsonData.map((json) => Task.fromJson(json)).toList();
          isLoadingTasks = false;
        });
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingTasks = false;
        errorMessage = 'Error fetching tasks: $e';
      });
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, size: 24),
              onPressed: () {
                _fetchMeetings();
                _fetchTasks();
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchMeetings(), _fetchTasks()]);
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with enhanced design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[600]!,
                        Colors.blue[400]!,
                        Colors.purple[400]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.waving_hand,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Welcome Back,\n${widget.username}!',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Here\'s what\'s happening today',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (errorMessage != null) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🎯 Demo mode active',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Meetings',
                        meetings.length.toString(),
                        Icons.event,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Tasks',
                        tasks.length.toString(),
                        Icons.task_alt,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Upcoming Meetings Section
                _buildSectionHeader('Upcoming Meetings', Icons.event, Colors.orange),
                const SizedBox(height: 16),
                _buildMeetingsSection(),
                
                const SizedBox(height: 40),

                // Assigned Tasks Section
                _buildSectionHeader('Assigned Tasks', Icons.task_alt, Colors.green),
                const SizedBox(height: 16),
                _buildTasksSection(),

                SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingsSection() {
    if (isLoadingMeetings) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Loading meetings...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (meetings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No upcoming meetings',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your schedule is clear for now',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: meetings.asMap().entries.map((entry) {
        int index = entry.key;
        Meeting meeting = entry.value;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _buildMeetingCard(meeting),
        );
      }).toList(),
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event, color: Colors.orange[600], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  meeting.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            meeting.description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Colors.blue[600], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${meeting.dateTime.day}/${meeting.dateTime.month} at ${meeting.dateTime.hour}:${meeting.dateTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.green[600], size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        meeting.location,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Loading tasks...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.task_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No assigned tasks',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'All caught up! Great work!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: tasks.asMap().entries.map((entry) {
        int index = entry.key;
        Task task = entry.value;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _buildTaskCard(task),
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor = task.priority.toLowerCase() == 'high' 
        ? Colors.red 
        : task.priority.toLowerCase() == 'medium' 
            ? Colors.orange 
            : Colors.green;

    bool isCompleted = task.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.task_alt, 
                  color: isCompleted ? Colors.green[600] : Colors.blue[600], 
                  size: 24
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    decoration: isCompleted 
                        ? TextDecoration.lineThrough 
                        : TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: Colors.purple[600], size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.info_outline, 
                      color: isCompleted ? Colors.green[600] : Colors.orange[600], 
                      size: 18
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        task.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: isCompleted ? Colors.green[700] : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}