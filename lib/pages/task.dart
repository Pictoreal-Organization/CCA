import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Configuration class for API endpoints
class ApiConfig {
  static const String baseUrl = 'https://your-api-url.com/api';
  static const String tasksEndpoint = '$baseUrl/tasks';
  static const String usersEndpoint = '$baseUrl/users';
  static const String notificationsEndpoint = '$baseUrl/notifications';
  
  // Add your API token here or implement token management
  static String get authToken => 'Bearer your_token_here';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': authToken,
  };
}

class TasksPage extends StatefulWidget {
  final String username;
  final String userId;
  
  const TasksPage({Key? key, required this.username, required this.userId}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Admin Task Manager'),
          ],
        ),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh current tab
              if (_tabController.index == 0) {
                // Trigger refresh for MyTasksTab
                setState(() {});
              }
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All Tasks', icon: Icon(Icons.list_alt)),
            Tab(text: 'Create Task', icon: Icon(Icons.add_task)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyTasksTab(username: widget.username, userId: widget.userId),
          CreateTaskTab(
            username: widget.username, 
            userId: widget.userId,
            onTaskCreated: () {
              // Switch to tasks tab after creation
              _tabController.animateTo(0);
            },
          ),
        ],
      ),
    );
  }
}

// Enhanced My Tasks Tab with admin features
class MyTasksTab extends StatefulWidget {
  final String username;
  final String userId;
  
  const MyTasksTab({Key? key, required this.username, required this.userId}) : super(key: key);

  @override
  State<MyTasksTab> createState() => _MyTasksTabState();
}

class _MyTasksTabState extends State<MyTasksTab> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _sortBy = 'Created Date';
  final List<String> _filterOptions = ['All', 'Pending', 'In Progress', 'Completed', 'Overdue'];
  final List<String> _sortOptions = ['Created Date', 'Due Date', 'Priority', 'Title'];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.tasksEndpoint}/all'), // Admin endpoint to get all tasks
        headers: ApiConfig.headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tasksJson = data['tasks'] ?? data;
        setState(() {
          _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
          _sortTasks();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading tasks: $e');
    }
  }

  void _sortTasks() {
    switch (_sortBy) {
      case 'Due Date':
        _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'Priority':
        final priorityOrder = {'urgent': 4, 'high': 3, 'medium': 2, 'low': 1};
        _tasks.sort((a, b) => (priorityOrder[b.priority] ?? 0).compareTo(priorityOrder[a.priority] ?? 0));
        break;
      case 'Title':
        _tasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      default: // Created Date
        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Future<void> _deleteTask(String taskId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('${ApiConfig.tasksEndpoint}/$taskId'),
          headers: ApiConfig.headers,
        );

        if (response.statusCode == 200) {
          _showSuccessSnackBar('Task deleted successfully!');
          _fetchTasks(); // Refresh the tasks list
        } else {
          throw Exception('Failed to delete task: ${response.statusCode}');
        }
      } catch (e) {
        _showErrorSnackBar('Error deleting task: $e');
      }
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.tasksEndpoint}/$taskId/status'),
        headers: ApiConfig.headers,
        body: json.encode({
          'status': newStatus,
          'updatedBy': widget.userId,
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessSnackBar('Task status updated successfully!');
        _fetchTasks(); // Refresh the tasks list
      } else {
        throw Exception('Failed to update task status: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating task status: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Task> get _filteredTasks {
    List<Task> filtered = _tasks;
    
    if (_selectedFilter != 'All') {
      filtered = filtered.where((task) {
        if (_selectedFilter == 'Overdue') {
          return DateTime.now().isAfter(task.dueDate) && task.status != 'completed';
        }
        return task.status == _selectedFilter.toLowerCase().replaceAll(' ', '_');
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Enhanced Filter and Sort Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Statistics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total', _tasks.length, Colors.blue),
                  _buildStatCard('Pending', _tasks.where((t) => t.status == 'pending').length, Colors.orange),
                  _buildStatCard('Progress', _tasks.where((t) => t.status == 'in_progress').length, Colors.indigo),
                  _buildStatCard('Completed', _tasks.where((t) => t.status == 'completed').length, Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              // Filter and Sort Controls
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterOptions.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedFilter = filter);
                              },
                              selectedColor: Colors.indigo[100],
                              checkmarkColor: Colors.indigo[600],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort, color: Colors.grey[600]),
                    onSelected: (value) {
                      setState(() {
                        _sortBy = value;
                        _sortTasks();
                      });
                    },
                    itemBuilder: (context) => _sortOptions.map((option) {
                      return PopupMenuItem<String>(
                        value: option,
                        child: Row(
                          children: [
                            Icon(
                              _sortBy == option ? Icons.check : Icons.sort,
                              size: 18,
                              color: _sortBy == option ? Colors.indigo : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(option),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Tasks List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFilter == 'All' ? 'Create your first task!' : 'Try changing the filter',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchTasks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          return EnhancedTaskCard(
                            task: _filteredTasks[index],
                            currentUserId: widget.userId,
                            isAdmin: true,
                            onStatusChanged: _updateTaskStatus,
                            onDeleteTask: _deleteTask,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Create Task Tab with better UX
class CreateTaskTab extends StatefulWidget {
  final String username;
  final String userId;
  final VoidCallback? onTaskCreated;
  
  const CreateTaskTab({
    Key? key, 
    required this.username, 
    required this.userId,
    this.onTaskCreated,
  }) : super(key: key);

  @override
  State<CreateTaskTab> createState() => _CreateTaskTabState();
}

class _CreateTaskTabState extends State<CreateTaskTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String _selectedPriority = 'Medium';
  String _assignmentType = 'individual';
  bool _isLoading = false;
  bool _isSearching = false;
  bool _sendNotifications = true;
  
  List<User> _searchResults = [];
  List<User> _selectedUsers = [];
  List<Subtask> _subtasks = [];
  
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.usersEndpoint}/search?q=${Uri.encodeComponent(query)}&excludeId=${widget.userId}'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> usersJson = data['users'] ?? data;
        setState(() {
          _searchResults = usersJson.map((json) => User.fromJson(json)).toList();
          _isSearching = false;
        });
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isSearching = false);
      _showErrorSnackBar('Error searching users: $e');
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? const TimeOfDay(hour: 17, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.indigo[600]!,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dueTime = pickedTime;
        });
      }
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUsers.isEmpty) {
      _showErrorSnackBar('Please select at least one user to assign the task');
      return;
    }
    if (_dueDate == null) {
      _showErrorSnackBar('Please select a due date and time');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final taskData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dueDate': _dueDate!.toIso8601String(),
        'priority': _selectedPriority.toLowerCase(),
        'assignmentType': _assignmentType,
        'assignedUsers': _selectedUsers.map((u) => {
          'userId': u.id,
          'name': u.name,
          'email': u.email,
        }).toList(),
        'subtasks': _subtasks.map((s) => s.toJson()).toList(),
        'createdBy': widget.userId,
        'createdByName': widget.username,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'sendNotifications': _sendNotifications,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.tasksEndpoint}/create'),
        headers: ApiConfig.headers,
        body: json.encode(taskData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _showSuccessSnackBar('Task created successfully! Task ID: ${responseData['taskId'] ?? 'N/A'}');
        _clearForm();
        
        // Call the callback to switch tabs
        widget.onTaskCreated?.call();
        
        // Send notifications if enabled
        if (_sendNotifications) {
          await _sendTaskNotifications(responseData['taskId'] ?? '', _selectedUsers);
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating task: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTaskNotifications(String taskId, List<User> users) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.notificationsEndpoint}/task-assigned'),
        headers: ApiConfig.headers,
        body: json.encode({
          'taskId': taskId,
          'taskTitle': _titleController.text.trim(),
          'assignedBy': widget.username,
          'assignedUsers': users.map((u) => u.id).toList(),
          'message': '${widget.username} assigned you a new task: ${_titleController.text.trim()}',
          'dueDate': _dueDate!.toIso8601String(),
          'priority': _selectedPriority.toLowerCase(),
        }),
      );
    } catch (e) {
      // Notification failure shouldn't break the task creation flow
      debugPrint('Failed to send notifications: $e');
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _searchController.clear();
    setState(() {
      _dueDate = null;
      _dueTime = null;
      _selectedPriority = 'Medium';
      _assignmentType = 'individual';
      _selectedUsers.clear();
      _searchResults.clear();
      _subtasks.clear();
      _sendNotifications = true;
    });
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: _calculateFormProgress(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[600]!),
            ),
            const SizedBox(height: 24),

            // Task Details Card
            _buildCard(
              title: 'Task Details',
              icon: Icons.task_alt,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title *',
                    hintText: 'Enter a clear, descriptive title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    counterText: '${_titleController.text.length}/100',
                  ),
                  maxLength: 100,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    if (value.trim().length < 3) {
                      return 'Task title must be at least 3 characters long';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Provide detailed information about the task',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    counterText: '${_descriptionController.text.length}/500',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task description';
                    }
                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters long';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDueDate,
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Due Date & Time *',
                            prefixIcon: const Icon(Icons.schedule),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          child: Text(
                            _dueDate != null
                                ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} at ${_dueTime?.format(context) ?? "17:00"}'
                                : 'Select due date and time',
                            style: TextStyle(
                              color: _dueDate != null ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: const Icon(Icons.priority_high),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(priority),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPriority = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Assignment Type Card
            _buildCard(
              title: 'Assignment Configuration',
              icon: Icons.group,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Individual Assignment'),
                        subtitle: const Text('Assign the same task to multiple users independently'),
                        value: 'individual',
                        groupValue: _assignmentType,
                        onChanged: (value) {
                          setState(() {
                            _assignmentType = value!;
                            if (value == 'individual') {
                              _subtasks.clear();
                            }
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Group Assignment'),
                        subtitle: const Text('Create a collaborative task with subtasks for team members'),
                        value: 'group',
                        groupValue: _assignmentType,
                        onChanged: (value) {
                          setState(() => _assignmentType = value!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Notification setting
                SwitchListTile(
                  title: const Text('Send Notifications'),
                  subtitle: const Text('Notify assigned users about this task'),
                  value: _sendNotifications,
                  onChanged: (value) {
                    setState(() => _sendNotifications = value);
                  },
                  activeColor: Colors.indigo[600],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // User Assignment Card
            _buildCard(
              title: 'Assign Users',
              icon: Icons.person_add,
              children: [
                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Users',
                    hintText: 'Type to search for users...',
                    prefixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: _searchUsers,
                ),
                const SizedBox(height: 12),
                
                // Selected Users Display
                if (_selectedUsers.isNotEmpty) ...[
                  const Text(
                    'Selected Users:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedUsers.map((user) {
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.indigo[100],
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: TextStyle(color: Colors.indigo[600]),
                          ),
                        ),
                        label: Text(user.name),
                        onDeleted: () {
                          setState(() => _selectedUsers.remove(user));
                        },
                        deleteIconColor: Colors.red[400],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Search Results
                if (_searchResults.isNotEmpty) ...[
                  const Text(
                    'Search Results:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isSelected = _selectedUsers.contains(user);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo[100],
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: TextStyle(color: Colors.indigo[600]),
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.green[600])
                              : const Icon(Icons.add_circle_outline),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedUsers.remove(user);
                              } else {
                                _selectedUsers.add(user);
                              }
                            });
                          },
                          tileColor: isSelected ? Colors.green[50] : null,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),

            // Subtasks Section (only for group assignments)
            if (_assignmentType == 'group') ...[
              const SizedBox(height: 24),
              _buildCard(
                title: 'Subtasks',
                icon: Icons.list_alt,
                children: [
                  if (_subtasks.isNotEmpty) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subtasks.length,
                      itemBuilder: (context, index) {
                        final subtask = _subtasks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(subtask.title),
                            subtitle: Text(subtask.description),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Assigned to: ${subtask.assignedUserName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[400]),
                                  onPressed: () {
                                    setState(() => _subtasks.removeAt(index));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton.icon(
                    onPressed: _selectedUsers.isNotEmpty ? _showAddSubtaskDialog : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subtask'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Create Task Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createTask,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.task_alt),
                label: Text(_isLoading ? 'Creating Task...' : 'Create Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Clear Form Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _clearForm,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Form'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  double _calculateFormProgress() {
    int completedFields = 0;
    int totalFields = 5; // title, description, due date, priority, users

    if (_titleController.text.trim().isNotEmpty) completedFields++;
    if (_descriptionController.text.trim().isNotEmpty) completedFields++;
    if (_dueDate != null) completedFields++;
    if (_selectedPriority.isNotEmpty) completedFields++;
    if (_selectedUsers.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showAddSubtaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    User? selectedUser;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Subtask'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtask Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<User>(
                  decoration: const InputDecoration(
                    labelText: 'Assign to User',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedUser,
                  items: _selectedUsers.map((user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (user) {
                    setState(() => selectedUser = user);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty &&
                    descriptionController.text.trim().isNotEmpty &&
                    selectedUser != null) {
                  Navigator.pop(context, {
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'user': selectedUser,
                  });
                }
              },
              child: const Text('Add Subtask'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final subtask = Subtask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title'],
        description: result['description'],
        assignedUserId: result['user'].id,
        assignedUserName: result['user'].name,
        isCompleted: false,
      );
      setState(() => _subtasks.add(subtask));
    }
  }
}

// Enhanced Task Card Widget
class EnhancedTaskCard extends StatelessWidget {
  final Task task;
  final String currentUserId;
  final bool isAdmin;
  final Function(String, String) onStatusChanged;
  final Function(String) onDeleteTask;

  const EnhancedTaskCard({
    Key? key,
    required this.task,
    required this.currentUserId,
    required this.isAdmin,
    required this.onStatusChanged,
    required this.onDeleteTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateTime.now().isAfter(task.dueDate) && task.status != 'completed';
    final priorityColor = _getPriorityColor(task.priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTaskDetails(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue ? Colors.red.withOpacity(0.5) : Colors.transparent,
              width: isOverdue ? 2 : 0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created by: ${task.createdByName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(),
                    const SizedBox(width: 8),
                    _buildPriorityIndicator(priorityColor),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Assigned Users
                if (task.assignedUsers.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    children: task.assignedUsers.take(3).map((user) {
                      return Chip(
                        label: Text(
                          user['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 11),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList() +
                    (task.assignedUsers.length > 3
                        ? [
                            Chip(
                              label: Text(
                                '+${task.assignedUsers.length - 3} more',
                                style: const TextStyle(fontSize: 11),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            )
                          ]
                        : []),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Footer Row
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OVERDUE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isAdmin) _buildActionButtons(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;
    
    switch (task.status) {
      case 'completed':
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'in_progress':
        chipColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case 'pending':
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      default:
        chipColor = Colors.grey;
        statusText = task.status.replaceAll('_', ' ').toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(Color priorityColor) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: priorityColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) {
            switch (value) {
              case 'change_status':
                _showStatusChangeDialog(context);
                break;
              case 'delete':
                onDeleteTask(task.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_status',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Change Status'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStatusChangeDialog(BuildContext context) {
    final statuses = [
      {'value': 'pending', 'label': 'Pending', 'color': Colors.orange},
      {'value': 'in_progress', 'label': 'In Progress', 'color': Colors.blue},
      {'value': 'completed', 'label': 'Completed', 'color': Colors.green},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Task Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: status['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(status['label'] as String),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged(task.id, status['value'] as String);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Description', task.description),
              _buildDetailRow('Status', task.status.replaceAll('_', ' ').toUpperCase()),
              _buildDetailRow('Priority', task.priority.toUpperCase()),
              _buildDetailRow('Due Date', _formatDateTime(task.dueDate)),
              _buildDetailRow('Created By', task.createdByName),
              _buildDetailRow('Created At', _formatDateTime(task.createdAt)),
              if (task.assignedUsers.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Assigned Users:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...task.assignedUsers.map((user) => Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text('• ${user['name']} (${user['email']})'),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Data Models
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final String status;
  final String createdByName;
  final DateTime createdAt;
  final List<Map<String, dynamic>> assignedUsers;
  final String assignmentType;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.createdByName,
    required this.createdAt,
    required this.assignedUsers,
    required this.assignmentType,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      createdByName: json['createdByName'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      assignedUsers: List<Map<String, dynamic>>.from(json['assignedUsers'] ?? []),
      assignmentType: json['assignmentType'] ?? 'individual',
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Subtask {
  final String id;
  final String title;
  final String description;
  final String assignedUserId;
  final String assignedUserName;
  final bool isCompleted;

  Subtask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedUserId,
    required this.assignedUserName,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedUserId': assignedUserId,
      'assignedUserName': assignedUserName,
      'isCompleted': isCompleted,
    };
  }
}