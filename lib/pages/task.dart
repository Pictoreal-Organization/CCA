import 'dart:convert';
import 'package:http/http.dart' as http;

// Models
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
    };
  }
}

class SubTask {
  final String id;
  final String title;
  final String description;
  final String assignedUserId;
  final DateTime dueDate;
  final String status;
  final int priority;

  SubTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedUserId,
    required this.dueDate,
    this.status = 'pending',
    this.priority = 1,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      assignedUserId: json['assignedUserId'],
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedUserId': assignedUserId,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
    };
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final List<String> assignedUserIds;
  final List<String> assignedGroupIds;
  final List<SubTask> subTasks;
  final String status;
  final int priority;
  final String createdBy;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.assignedUserIds = const [],
    this.assignedGroupIds = const [],
    this.subTasks = const [],
    this.status = 'pending',
    this.priority = 1,
    required this.createdBy,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      assignedUserIds: List<String>.from(json['assignedUserIds'] ?? []),
      assignedGroupIds: List<String>.from(json['assignedGroupIds'] ?? []),
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e))
              .toList() ??
          [],
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 1,
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'assignedUserIds': assignedUserIds,
      'assignedGroupIds': assignedGroupIds,
      'subTasks': subTasks.map((e) => e.toJson()).toList(),
      'status': status,
      'priority': priority,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Group {
  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final String createdBy;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
    required this.createdBy,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'createdBy': createdBy,
    };
  }
}

// API Service
class TaskApiService {
  static const String baseUrl = 'https://your-api-endpoint.com/api';
  
  // User-related API calls
  static Future<List<User>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=${Uri.encodeQueryComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['users'];
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['users'];
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Group-related API calls
  static Future<List<Group>> getAllGroups() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['groups'];
        return data.map((group) => Group.fromJson(group)).toList();
      } else {
        throw Exception('Failed to fetch groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching groups: $e');
    }
  }

  static Future<List<User>> getGroupMembers(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups/$groupId/members'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['members'];
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to fetch group members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching group members: $e');
    }
  }

  // Task-related API calls
  static Future<Task> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['task'];
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating task: $e');
    }
  }

  static Future<Task> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['task'];
        return Task.fromJson(data);
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  static Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['tasks'];
        return data.map((task) => Task.fromJson(task)).toList();
      } else {
        throw Exception('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  static Future<bool> deleteTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }
}

// Task Management Service
class TaskManager {
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (999 * (DateTime.now().microsecond / 1000000)).round()).toString();
  }

  // Search users with debouncing capability
  static Future<List<User>> searchUsers(String query, {int delayMs = 300}) async {
    if (query.isEmpty) return [];
    
    await Future.delayed(Duration(milliseconds: delayMs));
    return await TaskApiService.searchUsers(query);
  }

  // Create individual task assignment
  static Future<Task> createIndividualTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> assignedUserIds,
    required String createdBy,
    int priority = 1,
  }) async {
    final task = Task(
      id: generateId(),
      title: title,
      description: description,
      dueDate: dueDate,
      assignedUserIds: assignedUserIds,
      priority: priority,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    return await TaskApiService.createTask(task);
  }

  // Create group task assignment
  static Future<Task> createGroupTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> assignedGroupIds,
    required String createdBy,
    int priority = 1,
  }) async {
    final task = Task(
      id: generateId(),
      title: title,
      description: description,
      dueDate: dueDate,
      assignedGroupIds: assignedGroupIds,
      priority: priority,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    return await TaskApiService.createTask(task);
  }

  // Create group task with subtasks
  static Future<Task> createGroupTaskWithSubtasks({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> assignedGroupIds,
    required List<SubTask> subTasks,
    required String createdBy,
    int priority = 1,
  }) async {
    final task = Task(
      id: generateId(),
      title: title,
      description: description,
      dueDate: dueDate,
      assignedGroupIds: assignedGroupIds,
      subTasks: subTasks,
      priority: priority,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    return await TaskApiService.createTask(task);
  }

  // Add subtask to existing task
  static Future<Task> addSubtask({
    required String taskId,
    required String subtaskTitle,
    required String subtaskDescription,
    required String assignedUserId,
    required DateTime dueDate,
    int priority = 1,
  }) async {
    // Get existing task
    final tasks = await TaskApiService.getTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    // Create new subtask
    final subtask = SubTask(
      id: generateId(),
      title: subtaskTitle,
      description: subtaskDescription,
      assignedUserId: assignedUserId,
      dueDate: dueDate,
      priority: priority,
    );

    // Add subtask to existing task
    final updatedSubtasks = List<SubTask>.from(task.subTasks)..add(subtask);
    
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      assignedUserIds: task.assignedUserIds,
      assignedGroupIds: task.assignedGroupIds,
      subTasks: updatedSubtasks,
      status: task.status,
      priority: task.priority,
      createdBy: task.createdBy,
      createdAt: task.createdAt,
    );

    return await TaskApiService.updateTask(updatedTask);
  }

  // Update subtask status
  static Future<Task> updateSubtaskStatus({
    required String taskId,
    required String subtaskId,
    required String status,
  }) async {
    final tasks = await TaskApiService.getTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    final updatedSubtasks = task.subTasks.map((subtask) {
      if (subtask.id == subtaskId) {
        return SubTask(
          id: subtask.id,
          title: subtask.title,
          description: subtask.description,
          assignedUserId: subtask.assignedUserId,
          dueDate: subtask.dueDate,
          status: status,
          priority: subtask.priority,
        );
      }
      return subtask;
    }).toList();

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      assignedUserIds: task.assignedUserIds,
      assignedGroupIds: task.assignedGroupIds,
      subTasks: updatedSubtasks,
      status: task.status,
      priority: task.priority,
      createdBy: task.createdBy,
      createdAt: task.createdAt,
    );

    return await TaskApiService.updateTask(updatedTask);
  }

  // Get tasks assigned to specific user
  static Future<List<Task>> getTasksForUser(String userId) async {
    final allTasks = await TaskApiService.getTasks();
    return allTasks.where((task) {
      return task.assignedUserIds.contains(userId) ||
             task.subTasks.any((subtask) => subtask.assignedUserId == userId);
    }).toList();
  }

  // Get tasks assigned to specific group
  static Future<List<Task>> getTasksForGroup(String groupId) async {
    final allTasks = await TaskApiService.getTasks();
    return allTasks.where((task) => task.assignedGroupIds.contains(groupId)).toList();
  }

  // Auto-assign subtasks to group members
  static Future<Task> autoAssignSubtasksToGroupMembers({
    required String taskId,
    required String groupId,
    required List<String> subtaskTitles,
    required List<String> subtaskDescriptions,
    required DateTime dueDate,
  }) async {
    final groupMembers = await TaskApiService.getGroupMembers(groupId);
    final tasks = await TaskApiService.getTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);

    if (subtaskTitles.length != subtaskDescriptions.length) {
      throw Exception('Subtask titles and descriptions must have the same length');
    }

    List<SubTask> newSubtasks = [];
    for (int i = 0; i < subtaskTitles.length; i++) {
      final assignedMember = groupMembers[i % groupMembers.length];
      newSubtasks.add(SubTask(
        id: generateId(),
        title: subtaskTitles[i],
        description: subtaskDescriptions[i],
        assignedUserId: assignedMember.id,
        dueDate: dueDate,
      ));
    }

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      assignedUserIds: task.assignedUserIds,
      assignedGroupIds: task.assignedGroupIds,
      subTasks: [...task.subTasks, ...newSubtasks],
      status: task.status,
      priority: task.priority,
      createdBy: task.createdBy,
      createdAt: task.createdAt,
    );

    return await TaskApiService.updateTask(updatedTask);
  }
}