import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import '../widgets/searchable_user_dropdown.dart';
import 'package:cca/core/app_colors.dart';

class CreateTaskScreen extends StatefulWidget {
  final VoidCallback onTaskCreated;
  final Map<String, dynamic>? taskToEdit; // Make task optional for editing

  const CreateTaskScreen({
    super.key,
    required this.onTaskCreated,
    this.taskToEdit,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskService taskService = TaskService();
  final UserService userService = UserService();

  // Controllers for text fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? deadline;
  bool isSubmitting = false;

  List<Map<String, dynamic>> subtasks = [];
  List<Map<String, dynamic>> allUsers = [];
  bool isUsersLoading = true;
  bool get isEditMode => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    fetchAllUsers();

    // If in edit mode, populate the fields with existing data
    if (isEditMode) {
      final task = widget.taskToEdit!;
      _titleController.text = task['title'];
      _descriptionController.text = task['description'] ?? '';
      deadline = task['deadline'] != null ? DateTime.parse(task['deadline']) : null;
      
      // Populate subtasks
      if (task['subtasks'] is List) {
        subtasks = List<Map<String, dynamic>>.from(
          (task['subtasks'] as List).map((s) {
            // Ensure assignedTo is a list of ObjectIDs (Strings)
            final assignedToList = (s['assignedTo'] as List)
                .map((user) => user['_id'] as String)
                .toList();

            return {
              "title": s['title'],
              "description": s['description'],
              "assignedTo": assignedToList,
              "status": s['status'],
            };
          }),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void fetchAllUsers() async {
    try {
      final users = await userService.getAllUsers();
      users.sort((a, b) => a['username'].toString().compareTo(b['username'].toString()));
      if (!mounted) return;
      setState(() {
        allUsers = users;
        isUsersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isUsersLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  void addSubtaskField() {
    setState(() {
      subtasks.add({
        "title": "",
        "description": "",
        "assignedTo": [],
        "status": "Pending",
      });
    });
  }

  void deleteSubtask(int index) {
    setState(() {
      subtasks.removeAt(index);
    });
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix the errors.')));
      return;
    }
     if (deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a deadline.')));
      return;
    }

    _formKey.currentState!.save();
    setState(() => isSubmitting = true);

    // Prepare subtasks data by removing any temporary UI state
    final cleanSubtasks = subtasks.map((s) {
      return {
        "title": s["title"],
        "description": s["description"],
        "assignedTo": s["assignedTo"],
        "status": s["status"],
      };
    }).toList();

    try {
      if (isEditMode) {
        // UPDATE existing task
        await taskService.updateTask(widget.taskToEdit!['_id'], {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'deadline': deadline?.toIso8601String(),
          'subtasks': cleanSubtasks,
        });
      } else {
        // CREATE new task
        await taskService.createTask(
          title: _titleController.text,
          description: _descriptionController.text,
          deadline: deadline,
          subtasks: cleanSubtasks,
        );
      }

      widget.onTaskCreated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream5,
      appBar: AppBar(
  backgroundColor: AppColors.teal1,
  title: Text(
    isEditMode ? 'Edit Task' : 'Create Task',
    style: const TextStyle(color: AppColors.cream1),
  ),
  iconTheme: const IconThemeData(color: AppColors.cream1),
),      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                labelText: 'Title', // or 'Description'
                labelStyle: const TextStyle(color: AppColors.charcoal3),
                enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.teal2),
                ),
                focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.teal1, width: 2),
                ),
              ),

                validator: (val) => val!.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: AppColors.charcoal3),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.teal2),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.teal1, width: 2),
                ),
              ),

              ),
              const SizedBox(height: 20),
              const Text('Subtasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...subtasks.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> subtask = entry.value;

                return Card(
                  color: AppColors.mint5,
                  key: ValueKey('subtask_$index'),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtask ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteSubtask(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: subtask["title"],
                          decoration: InputDecoration(
                          labelText: 'Task', 
                          labelStyle: const TextStyle(color: AppColors.charcoal3),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.teal2),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.teal1, width: 2),
                          ),
                        ),

                          validator: (val) => val!.isEmpty ? 'Enter subtask title' : null,
                          onChanged: (val) => subtask["title"] = val,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: subtask["description"],
                          decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: const TextStyle(color: AppColors.charcoal3),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.teal2),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.teal1, width: 2),
                          ),
                        ),

                          onChanged: (val) => subtask["description"] = val,
                        ),
                        const SizedBox(height: 10),
                        // SearchableUserDropdown(
                        //   allUsers: allUsers,
                        //   isLoading: isUsersLoading,
                        //   selectedUserId: subtask["assignedTo"] != null && subtask["assignedTo"].isNotEmpty
                        //       ? subtask["assignedTo"][0]
                        //       : null,
                        //   onUserSelected: (userId, userName) {
                        //     setState(() {
                        //       subtask["assignedTo"] = userId != null ? [userId] : [];
                        //     });
                        //   },
                        //   validator: (val) =>
                        //       subtask["assignedTo"] == null || subtask["assignedTo"].isEmpty ? 'Select a user' : null,
                        // ),
                        ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.teal2,
    foregroundColor: AppColors.cream1,    
  ),
  onPressed: () async {
  final selected = await showDialog<List<String>>(
    context: context,
    builder: (context) {
      // temporary selected IDs
      List<String> tempSelected = List.from(subtask["assignedTo"]);
      String searchQuery = "";

      return StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredUsers = allUsers
              .where((user) =>
                  user['username']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            title: const Text('Assign to members'),
            content: isUsersLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔍 Search bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search members...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onChanged: (val) =>
                            setDialogState(() => searchQuery = val),
                      ),
                      const SizedBox(height: 10),

                      // 📜 Filtered list of users
                      SizedBox(
                        width: double.maxFinite,
                        height: 300, // limit dialog height
                        child: ListView(
                          children: filteredUsers.map((user) {
                            final id = user['_id'];
                            final name = user['username'];
                            final isChecked = tempSelected.contains(id);

                            return CheckboxListTile(
                              title: Text(name),
                              value: isChecked,
                              onChanged: (checked) {
                                setDialogState(() {
                                  if (checked == true) {
                                    tempSelected.add(id);
                                  } else {
                                    tempSelected.remove(id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, tempSelected),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal1),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );

  if (selected != null) {
    setState(() {
      subtask["assignedTo"] = selected;
    });
  }
},
child: Text(
  subtask["assignedTo"].isEmpty
      ? 'Select Members'
      : 'Assigned: ${allUsers
          .where((u) => subtask["assignedTo"].contains(u['_id']))
          .map((u) => u['username'])
          .join(', ')}',
),

                        ),


                      ],
                    ),
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: addSubtaskField,
                icon: const Icon(Icons.add, color: AppColors.teal1),
                label: const Text('Add Subtask', style: TextStyle(color: AppColors.teal1)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal1,
                foregroundColor: AppColors.cream1,
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: deadline ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => deadline = picked);
                },
                label: Text(
                  deadline == null
                      ? 'Pick Deadline Date'
                      : 'Deadline: ${deadline!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              const SizedBox(height: 20),
              isSubmitting
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teal1))
                  : ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber1,
                      foregroundColor: AppColors.charcoal1,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                      child: Text(isEditMode ? 'Update Task' : 'Create Task'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
