import 'package:flutter/material.dart';
import './task.dart'; // Import the task system we created

class TasksPage extends StatefulWidget {
  final String username;
  final String userId;

  const TasksPage({
    Key? key,
    required this.username,
    required this.userId,
  }) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _assignedTasks = [];
  List<Task> _createdTasks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load tasks assigned to current user
      final assignedTasks = await TaskManager.getTasksForUser(widget.userId);
      
      // Load all tasks to filter by created by current user
      final allTasks = await TaskApiService.getTasks();
      final createdTasks = allTasks.where((task) => task.createdBy == widget.userId).toList();

      setState(() {
        _assignedTasks = assignedTasks;
        _createdTasks = createdTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading tasks: $e';
        _isLoading = false;
      });
    }
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        createdBy: widget.userId,
        onTaskCreated: _loadTasks,
      ),
    );
  }

  void _showTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          task: task,
          currentUserId: widget.userId,
          onTaskUpdated: _loadTasks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Assigned to Me'),
            Tab(text: 'Created by Me'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(_assignedTasks, isAssigned: true),
                    _buildTaskList(_createdTasks, isAssigned: false),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, {required bool isAssigned}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAssigned ? Icons.inbox_outlined : Icons.create_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isAssigned ? 'No tasks assigned to you' : 'No tasks created by you',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            currentUserId: widget.userId,
            isAssigned: isAssigned,
            onTap: () => _showTaskDetails(task),
          );
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final String currentUserId;
  final bool isAssigned;
  final VoidCallback onTap;

  const TaskCard({
    Key? key,
    required this.task,
    required this.currentUserId,
    required this.isAssigned,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now());
    final userSubtasks = task.subTasks.where((st) => st.assignedUserId == currentUserId).toList();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPriorityChip(task.priority),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(task.dueDate),
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(task.status),
                ],
              ),
              if (userSubtasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.subtitles, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 6),
                      Text(
                        '${userSubtasks.length} subtask${userSubtasks.length > 1 ? 's' : ''} assigned to you',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (task.assignedGroupIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.group, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Group Task',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int priority) {
    Color color;
    String label;
    
    switch (priority) {
      case 3:
        color = Colors.red;
        label = 'High';
        break;
      case 2:
        color = Colors.orange;
        label = 'Medium';
        break;
      default:
        color = Colors.green;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Due Today';
    } else if (difference == 1) {
      return 'Due Tomorrow';
    } else if (difference < 0) {
      return 'Overdue by ${difference.abs()} day${difference.abs() > 1 ? 's' : ''}';
    } else {
      return 'Due in $difference day${difference > 1 ? 's' : ''}';
    }
  }
}

// Create Task Dialog
class CreateTaskDialog extends StatefulWidget {
  final String createdBy;
  final VoidCallback onTaskCreated;

  const CreateTaskDialog({
    Key? key,
    required this.createdBy,
    required this.onTaskCreated,
  }) : super(key: key);

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  int _priority = 1;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(_formatDate(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDueDate,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Low')),
                DropdownMenuItem(value: 2, child: Text('Medium')),
                DropdownMenuItem(value: 3, child: Text('High')),
              ],
              onChanged: (value) => setState(() => _priority = value ?? 1),
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
          onPressed: _isLoading ? null : _createTask,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  Future<void> _createTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await TaskManager.createIndividualTask(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        assignedUserIds: [], // Will be assigned later
        createdBy: widget.createdBy,
        priority: _priority,
      );

      widget.onTaskCreated();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating task: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Task Detail Page (basic implementation)
class TaskDetailPage extends StatelessWidget {
  final Task task;
  final String currentUserId;
  final VoidCallback onTaskUpdated;

  const TaskDetailPage({
    Key? key,
    required this.task,
    required this.currentUserId,
    required this.onTaskUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              task.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Due Date', _formatDate(task.dueDate)),
            _buildInfoRow('Status', task.status),
            _buildInfoRow('Priority', _getPriorityText(task.priority)),
            if (task.subTasks.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Subtasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...task.subTasks.map((subtask) => _buildSubtaskCard(subtask)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildSubtaskCard(SubTask subtask) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtask.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtask.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Status: ${subtask.status}'),
                const Spacer(),
                Text('Due: ${_formatDate(subtask.dueDate)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 3: return 'High';
      case 2: return 'Medium';
      default: return 'Low';
    }
  }
}