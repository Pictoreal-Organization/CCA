import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Services
  final UserService userService = UserService();
  final TaskService taskService = TaskService();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // State variables
  bool _isLoading = true;
  bool _isEditing = false; // ✏️ toggle edit mode
  String _email = "";
  String _role = "";
  String _userId = "";
  List _completedTasks = [];

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = await userService.getLoggedInUser();

      // Populate controllers & vars
      _userId = user['_id'] ?? '';
      _email = user['email'] ?? '';
      _role = user['role'] ?? '';
      _nameController.text = user['name'] ?? '';
      _rollController.text = user['rollNo'] ?? '';
      _yearController.text = user['year'] ?? '';
      _divisionController.text = user['division'] ?? '';
      _phoneController.text = user['phone'] ?? '';

      // Fetch completed tasks
      if (_role == 'Head') {
        _completedTasks = await taskService.getAllCompletedTasks();
      } else if (_role == 'Member' && _userId.isNotEmpty) {
        _completedTasks = await taskService.getCompletedTasksByUser(_userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to load profile data: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await userService.updateUserProfile(
        name: _nameController.text,
        rollNo: _rollController.text,
        year: _yearController.text,
        division: _divisionController.text,
        phone: _phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          // ✏️ Toggle Edit / Save
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAllData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- User Info Section ---
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.account_circle, size: 100, color: Colors.blueGrey),
                        const SizedBox(height: 8),
                        Text(_email, style: const TextStyle(fontSize: 16)),
                        Text("Role: $_role", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Editable Fields ---
                  TextField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  TextField(
                    controller: _rollController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: "Roll No"),
                  ),
                  TextField(
                    controller: _yearController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: "Year"),
                  ),
                  TextField(
                    controller: _divisionController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: "Division"),
                  ),
                  TextField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                  ),

                  const SizedBox(height: 24),

                  // --- Completed Tasks Section ---
                  const Divider(height: 40, thickness: 1),
                  const Text(
                    "Completed Tasks History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_completedTasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("No completed tasks to show."),
                      ),
                    )
                  else
                    ..._completedTasks.map((task) {
                      final subtasks = (task['subtasks'] as List?) ?? [];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: _role == 'Head'
                            ? ExpansionTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: Text(task['title']),
                                subtitle: Text(
                                  "Completed on: ${task['deadline'] != null ? DateTime.parse(task['deadline']).toLocal().toString().split(' ')[0] : 'N/A'}",
                                ),
                                children: [
                                  const Divider(height: 1),
                                  ...subtasks.map((sub) {
                                    final assignedUsers = (sub['assignedTo'] as List)
                                        .map((u) => u['username'])
                                        .join(', ');
                                    return ListTile(
                                      title: Text(sub['title'],
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(sub['description'] ?? 'No completion note.'),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Completed by: $assignedUsers",
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList()
                                ],
                              )
                            : ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: Text(task['title']),
                                subtitle: Text(
                                  "Completed on: ${task['deadline'] != null ? DateTime.parse(task['deadline']).toLocal().toString().split(' ')[0] : 'N/A'}",
                                ),
                              ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
