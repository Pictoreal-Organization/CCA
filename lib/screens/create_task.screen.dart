import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import '../services/team_service.dart';
import '../core/app_colors.dart';
import '../widgets/customAppbar.widget.dart';

// Make ToggleOption public (remove underscore)
class ToggleOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  const ToggleOption({required this.value, required this.label, this.icon});
}

// Custom toggle selector for task scope
class CustomToggleSelector<T> extends StatelessWidget {
  final List<ToggleOption<T>> options;
  final T selected;
  final void Function(T selected) onSelectionChanged;
  final Map<int, Color>? perOptionSelectedColors;

  const CustomToggleSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelectionChanged,
    this.perOptionSelectedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.asMap().entries.map((entry) {
        final int idx = entry.key;
        final option = entry.value;
        final bool isSelected = option.value == selected;

        final Color selectedBg =
            perOptionSelectedColors != null &&
                perOptionSelectedColors!.containsKey(idx)
            ? perOptionSelectedColors![idx]!
            : AppColors.orange;
        final Color selectedText = Colors.white;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelectionChanged(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                ],
                border: Border.all(
                  color: isSelected ? selectedBg : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      color: isSelected ? selectedText : AppColors.lightGray,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? selectedText : AppColors.lightGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CreateTaskScreen extends StatefulWidget {
  final VoidCallback onTaskCreated;
  final Map<String, dynamic>? taskToEdit;

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
  final TeamService teamService = TeamService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? deadline;
  bool isSubmitting = false;

  List<Map<String, dynamic>> subtasks = [];
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> allTeams = [];
  bool isUsersLoading = true;
  bool get isEditMode => widget.taskToEdit != null;

  // Task scope variables
  String taskScope = 'general';
  List<String> selectedTeamIds = [];

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
    fetchVisibleTeams();

    if (isEditMode) {
      final task = widget.taskToEdit!;
      _titleController.text = task['title'];
      _descriptionController.text = task['description'] ?? '';
      deadline = task['deadline'] != null
          ? DateTime.parse(task['deadline'])
          : null;

      // Determine task scope based on team field
      if (task['team'] != null) {
        taskScope = 'team-specific';
        // Handle both single team ID (old format) and array (new format)
        if (task['team'] is List) {
          selectedTeamIds = List<String>.from(task['team']);
        } else if (task['team'] is String) {
          selectedTeamIds = [task['team']];
        } else if (task['team'] is Map && task['team']['_id'] != null) {
          selectedTeamIds = [task['team']['_id']];
        }
      }

      if (task['subtasks'] is List) {
        subtasks = List<Map<String, dynamic>>.from(
          (task['subtasks'] as List).map((s) {
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
      users.sort(
        (a, b) => (a['name'] ?? '').toString().compareTo(
          (b['name'] ?? '').toString(),
        ),
      );
      if (!mounted) return;
      setState(() {
        allUsers = users;
        isUsersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isUsersLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  void fetchVisibleTeams() async {
    try {
      final teams = await teamService.getVisibleTeams();

      // Clean team names
      final cleanedTeams = teams.map<Map<String, dynamic>>((team) {
        final name = team['name']?.trim() ?? '';
        final words = name.split(RegExp(r'\s+'));
        if (words.length > 1) {
          words.removeLast();
        }
        final cleanedName = words.join(' ');

        return {...team, 'name': cleanedName};
      }).toList();

      if (mounted) {
        setState(() => allTeams = cleanedTeams);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load teams: $e')));
      }
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
    if (subtasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create at least one subtask.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fix the errors.')));
      return;
    }
    if (deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please pick a deadline.')));
      return;
    }
    if (taskScope == 'team-specific' && selectedTeamIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one team for a team-specific task.',
          ),
          backgroundColor: AppColors.darkOrange,
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => isSubmitting = true);

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
        await taskService.updateTask(widget.taskToEdit!['_id'], {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'deadline': deadline?.toIso8601String(),
          'team': taskScope == 'team-specific' ? selectedTeamIds.first : null,
          'subtasks': cleanSubtasks,
        });
      } else {
        await taskService.createTask(
          title: _titleController.text,
          description: _descriptionController.text,
          deadline: deadline,
          teamId: taskScope == 'team-specific' ? selectedTeamIds.first : null,
          subtasks: cleanSubtasks,
        );
      }

      widget.onTaskCreated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Operation failed: $e')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.lightGray,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: AppColors.green),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.darkGray.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkTeal, width: 2.5),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Subtasks', Icons.checklist_outlined),

        ...subtasks.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> subtask = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.green.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with subtask number and delete button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.darkTeal,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Subtask ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkTeal,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade400,
                        iconSize: 24,
                        onPressed: () => deleteSubtask(index),
                        tooltip: 'Delete subtask',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title field
                  TextFormField(
                    initialValue: subtask["title"],
                    decoration: _buildInputDecoration(
                      'Task Title',
                      Icons.title_rounded,
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Enter subtask title' : null,
                    onChanged: (val) => subtask["title"] = val,
                  ),

                  const SizedBox(height: 14),

                  // Description field
                  TextFormField(
                    initialValue: subtask["description"],
                    decoration: _buildInputDecoration(
                      'Description (Optional)',
                      Icons.description_outlined,
                    ),
                    maxLines: 2,
                    onChanged: (val) => subtask["description"] = val,
                  ),

                  const SizedBox(height: 16),

                  // Assign members button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.green,
                          AppColors.green.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final selected = await showDialog<List<String>>(
  context: context,
  builder: (context) {
    List<String> tempSelected = List.from(subtask["assignedTo"]);
    String searchQuery = "";

    return StatefulBuilder(
      builder: (context, setDialogState) {
        final filteredUsers = allUsers.where((user) {
          final name = user['name'] ?? '';
          final rollNo = user['rollNo'] ?? '';
          final combined = "$name $rollNo".toLowerCase();
          return combined.contains(searchQuery.toLowerCase());
        }).toList();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.people_outline, color: AppColors.darkTeal),
              SizedBox(width: 10),
              Text(
                'Assign to Members',
                style: TextStyle(color: AppColors.darkTeal),
              ),
            ],
          ),
          content: isUsersLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.darkTeal,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name or roll no...',
                        hintStyle: const TextStyle(color: AppColors.lightGray),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.green),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) =>
                          setDialogState(() => searchQuery = val),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: ListView(
                        children: filteredUsers.map((user) {
                          final id = user['_id'];
                          final name = user['name'] ?? '';
                          final rollNo = user['rollNo'] ?? '';
                          final isChecked = tempSelected.contains(id);

                          return CheckboxListTile(
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGray,
                              ),
                            ),
                            subtitle: Text(
                              "Roll No: $rollNo",
                              style: const TextStyle(
                                color: AppColors.lightGray,
                                fontSize: 13,
                              ),
                            ),
                            value: isChecked,
                            activeColor: AppColors.darkTeal,
                            checkColor: Colors.white,
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
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.lightGray),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          child: subtask["assignedTo"].isEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.person_add_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Assign Members',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.people,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Assigned Members',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: allUsers
                                          .where(
                                            (u) => subtask["assignedTo"]
                                                .contains(u['_id']),
                                          )
                                          .map((u) {
                                            final userId = u['_id'];
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "${u['name']} - ${u['rollNo']}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        subtask["assignedTo"]
                                                            .remove(userId);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors
                                                                .white, // white circle
                                                          ),
                                                      padding: const EdgeInsets.all(
                                                        2,
                                                      ), // small padding for the icon
                                                      child: const Icon(
                                                        Icons.close,
                                                        size: 14,
                                                        color:
                                                            AppColors.darkTeal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Add subtask button
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.green.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: addSubtaskField,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.green,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Add Subtask',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(isEditMode ? 'Edit Task' : 'Create Task'),
      //   backgroundColor: AppColors.darkTeal,
      //   foregroundColor: Colors.white,
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   elevation: 4,
      // ),
      appBar: customAppBar(
        title: isEditMode ? "Edit Task" : "Create Task",
        context: context,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('Title', Icons.title_rounded),
                validator: (val) =>
                    val!.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(
                  'Description',
                  Icons.description_outlined,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Task Scope Selector
              _buildSectionHeader('Task Scope', Icons.workspaces_outlined),
              CustomToggleSelector<String>(
                options: const [
                  ToggleOption(
                    value: 'general',
                    label: 'General',
                    icon: Icons.public,
                  ),
                  ToggleOption(
                    value: 'team-specific',
                    label: 'Team-Specific',
                    icon: Icons.group,
                  ),
                ],
                selected: taskScope,
                onSelectionChanged: (selected) {
                  setState(() {
                    taskScope = selected;
                    if (selected == 'general') {
                      selectedTeamIds.clear();
                    }
                  });
                },
                perOptionSelectedColors: const {
                  0: AppColors.darkTeal,
                  1: AppColors.orange,
                },
              ),

              // Team Selection (only for team-specific tasks)
              if (taskScope == 'team-specific') ...[
                const SizedBox(height: 16),
                const Text(
                  'Select Team',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.8,
                    children: allTeams.take(8).map<Widget>((team) {
                      final isSelected = selectedTeamIds.contains(team['_id']);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedTeamIds.clear();
                            } else {
                              selectedTeamIds = [team['_id']];
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkTeal.withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.darkTeal
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check,
                                  color: AppColors.darkTeal,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  team['name'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.darkTeal
                                        : AppColors.lightGray,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Subtasks section (improved UI)
              _buildSubtasksSection(),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkTeal,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
