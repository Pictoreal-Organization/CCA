// import 'package:flutter/material.dart';
// import '../services/task_service.dart';
// import '../services/user_service.dart';

// class CreateTaskScreen extends StatefulWidget {
//   final VoidCallback onTaskCreated;
//   const CreateTaskScreen({super.key, required this.onTaskCreated});

//   @override
//   State<CreateTaskScreen> createState() => _CreateTaskScreenState();
// }

// class _CreateTaskScreenState extends State<CreateTaskScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TaskService taskService = TaskService();
//   final UserService userService = UserService();

//   String title = '';
//   String description = '';
//   DateTime? deadline;
//   bool isSubmitting = false;

//   List<Map<String, dynamic>> subtasks = [];
//   List<Map<String, dynamic>> allUsers = [];
//   bool isUsersLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchAllUsers();
//   }

//   void fetchAllUsers() async {
//     try {
//       final users = await userService.getAllUsers();
//       users.sort((a, b) => a['username'].toString().compareTo(b['username'].toString()));
//       if (!mounted) return;
//       setState(() {
//         allUsers = users;
//         isUsersLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isUsersLoading = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
//     }
//   }

//   void addSubtaskField() {
//     setState(() {
//       subtasks.add({
//         "title": "",
//         "description": "",
//         "assignedTo": [],
//         "status": "Pending",
//         "selectedUserName": null,
//       });
//     });
//   }

//   void deleteSubtask(int index) {
//     setState(() {
//       subtasks.removeAt(index);
//     });
//   }

//   void submit() async {
//     if (!_formKey.currentState!.validate() || deadline == null) return;
//     _formKey.currentState!.save();
//     setState(() => isSubmitting = true);

//     try {
//       await taskService.createTask(
//         title: title,
//         description: description,
//         deadline: deadline,
//         subtasks: subtasks.map((s) {
//           return {
//             "title": s["title"],
//             "description": s["description"],
//             "assignedTo": s["assignedTo"],
//             "status": s["status"],
//           };
//         }).toList(),
//       );

//       widget.onTaskCreated();
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() => isSubmitting = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Task')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Title'),
//                 validator: (val) => val!.isEmpty ? 'Enter title' : null,
//                 onSaved: (val) => title = val!,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 onSaved: (val) => description = val ?? '',
//               ),
//               const SizedBox(height: 20),

//               const Text('Subtasks',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               ...subtasks.asMap().entries.map((entry) {
//               int index = entry.key;
//               Map<String, dynamic> subtask = entry.value;

//               return Card(
//                 key: ValueKey(subtask.hashCode), // 👈 unique key for each subtask card
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Subtask ${index + 1}',
//                               style: const TextStyle(fontWeight: FontWeight.bold)),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => deleteSubtask(index),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         decoration: const InputDecoration(labelText: 'Subtask Title'),
//                         validator: (val) =>
//                             val!.isEmpty ? 'Enter subtask title' : null,
//                         onChanged: (val) => subtask["title"] = val,
//                       ),
//                       const SizedBox(height: 10),
//                       TextFormField(
//                         decoration: const InputDecoration(labelText: 'Subtask Description'),
//                         onChanged: (val) => subtask["description"] = val,
//                       ),
//                       const SizedBox(height: 10),
//                       SearchableUserDropdown(
//                         allUsers: allUsers,
//                         isLoading: isUsersLoading,
//                         selectedUserId: subtask["assignedTo"].isNotEmpty
//                             ? subtask["assignedTo"][0]
//                             : null,
//                         onUserSelected: (userId, userName) {
//                           setState(() {
//                             subtask["assignedTo"] =
//                                 userId != null ? [userId] : [];
//                             subtask["selectedUserName"] = userName;
//                           });
//                         },
//                         validator: (val) =>
//                             val == null || val.isEmpty ? 'Select a user' : null,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//               TextButton.icon(
//                 onPressed: addSubtaskField,
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add Subtask'),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime(2100),
//                   );
//                   if (picked != null) setState(() => deadline = picked);
//                 },
//                 child: Text(
//                   deadline == null
//                       ? 'Pick Deadline Date'
//                       : 'Deadline: ${deadline!.toLocal().toString().split(' ')[0]}',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               isSubmitting
//                   ? const Center(child: CircularProgressIndicator())
//                   : ElevatedButton(
//                       onPressed: submit,
//                       child: const Text('Create Task'),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // 🎯 Fully optimized Searchable User Dropdown
// class SearchableUserDropdown extends StatefulWidget {
//   final List<Map<String, dynamic>> allUsers;
//   final bool isLoading;
//   final String? selectedUserId;
//   final Function(String?, String?) onUserSelected;
//   final String? Function(String?)? validator;

//   const SearchableUserDropdown({
//     super.key,
//     required this.allUsers,
//     required this.isLoading,
//     required this.selectedUserId,
//     required this.onUserSelected,
//     this.validator,
//   });

//   @override
//   State<SearchableUserDropdown> createState() => _SearchableUserDropdownState();
// }

// class _SearchableUserDropdownState extends State<SearchableUserDropdown> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _filteredUsers = [];
//   bool _isDropdownOpen = false;
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;

//   @override
//   void initState() {
//     super.initState();
//     _filteredUsers = List.from(widget.allUsers);
//     if (widget.selectedUserId != null) {
//       final selectedUser = widget.allUsers.firstWhere(
//         (user) => user['_id'] == widget.selectedUserId,
//         orElse: () => {},
//       );
//       if (selectedUser.isNotEmpty) {
//         _searchController.text = selectedUser['username'];
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _removeOverlay();
//     super.dispose();
//   }

//   void _filterUsers(String query) {
//     setState(() {
//       _filteredUsers = widget.allUsers
//           .where((user) => user['username']
//               .toString()
//               .toLowerCase()
//               .contains(query.toLowerCase()))
//           .toList();
//     });
//     _overlayEntry?.markNeedsBuild(); // Efficiently refresh overlay
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     _isDropdownOpen = false;
//   }

//   void _createOverlay() {
//     if (_overlayEntry != null) return;

//     final renderBox = context.findRenderObject() as RenderBox?;
//     final width = renderBox?.size.width ?? 200;

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         width: width,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: Offset(0, renderBox?.size.height ?? 56),
//           child: Material(
//             elevation: 4,
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxHeight: 200),
//               child: ListView.builder(
//                 padding: EdgeInsets.zero,
//                 shrinkWrap: true,
//                 itemCount: _filteredUsers.length,
//                 itemBuilder: (context, index) {
//                   final user = _filteredUsers[index];
//                   return ListTile(
//                     title: Text(user['username']),
//                     onTap: () {
//                       _searchController.text = user['username'];
//                       widget.onUserSelected(user['_id'], user['username']);
//                       _removeOverlay();
//                       FocusScope.of(context).unfocus();
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//     _isDropdownOpen = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: TextFormField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           labelText: 'Assign To',
//           prefixIcon: const Icon(Icons.person_search),
//           suffixIcon: widget.isLoading
//               ? const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   ),
//                 )
//               : IconButton(
//                   icon: Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
//                   onPressed: () {
//                     if (_isDropdownOpen) {
//                       _removeOverlay();
//                     } else {
//                       _createOverlay();
//                     }
//                   },
//                 ),
//         ),
//         readOnly: widget.isLoading,
//         onTap: () {
//           if (!_isDropdownOpen && !widget.isLoading) _createOverlay();
//         },
//         onChanged: (val) {
//           _filterUsers(val);
//           if (!_isDropdownOpen && val.isNotEmpty) _createOverlay();
//           if (val.isEmpty) widget.onUserSelected(null, null);
//         },
//         validator: widget.validator,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';

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
      appBar: AppBar(title: Text(isEditMode ? 'Edit Task' : 'Create Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              const Text('Subtasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...subtasks.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> subtask = entry.value;

                return Card(
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
                          decoration: const InputDecoration(labelText: 'Subtask Title'),
                          validator: (val) => val!.isEmpty ? 'Enter subtask title' : null,
                          onChanged: (val) => subtask["title"] = val,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: subtask["description"],
                          decoration: const InputDecoration(labelText: 'Subtask Description'),
                          onChanged: (val) => subtask["description"] = val,
                        ),
                        const SizedBox(height: 10),
                        SearchableUserDropdown(
                          allUsers: allUsers,
                          isLoading: isUsersLoading,
                          selectedUserId: subtask["assignedTo"] != null && subtask["assignedTo"].isNotEmpty
                              ? subtask["assignedTo"][0]
                              : null,
                          onUserSelected: (userId, userName) {
                            setState(() {
                              subtask["assignedTo"] = userId != null ? [userId] : [];
                            });
                          },
                          validator: (val) =>
                              subtask["assignedTo"] == null || subtask["assignedTo"].isEmpty ? 'Select a user' : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: addSubtaskField,
                icon: const Icon(Icons.add),
                label: const Text('Add Subtask'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
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
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(isEditMode ? 'Update Task' : 'Create Task'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// Searchable User Dropdown (no changes needed)
class SearchableUserDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> allUsers;
  final bool isLoading;
  final String? selectedUserId;
  final Function(String?, String?) onUserSelected;
  final String? Function(String?)? validator;

  const SearchableUserDropdown({
    super.key,
    required this.allUsers,
    required this.isLoading,
    required this.selectedUserId,
    required this.onUserSelected,
    this.validator,
  });

  @override
  State<SearchableUserDropdown> createState() => _SearchableUserDropdownState();
}

class _SearchableUserDropdownState extends State<SearchableUserDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(widget.allUsers);
    _updateControllerWithSelectedUser();
  }

  @override
  void didUpdateWidget(covariant SearchableUserDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedUserId != oldWidget.selectedUserId) {
      _updateControllerWithSelectedUser();
    }
    if (widget.allUsers != oldWidget.allUsers) {
      _filteredUsers = List.from(widget.allUsers);
    }
  }
  
  void _updateControllerWithSelectedUser() {
    if (widget.selectedUserId != null) {
      final selectedUser = widget.allUsers.firstWhere(
        (user) => user['_id'] == widget.selectedUserId,
        orElse: () => {},
      );
      if (selectedUser.isNotEmpty) {
        _searchController.text = selectedUser['username'];
      }
    } else {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = widget.allUsers
          .where((user) => user['username']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownOpen = false);
  }

  void _createOverlay() {
    if (_overlayEntry != null || !mounted) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return ListTile(
                  title: Text(user['username']),
                  onTap: () {
                    _searchController.text = user['username'];
                    widget.onUserSelected(user['_id'], user['username']);
                    _removeOverlay();
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Assign To',
        prefixIcon: const Icon(Icons.person_search),
        suffixIcon: widget.isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: Icon(_isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                onPressed: () {
                  if (_isDropdownOpen) {
                    _removeOverlay();
                  } else {
                    _createOverlay();
                  }
                },
              ),
      ),
      readOnly: widget.isLoading,
      onTap: () {
        if (!_isDropdownOpen && !widget.isLoading) _createOverlay();
      },
      onChanged: (val) {
        _filterUsers(val);
        if (!_isDropdownOpen && val.isNotEmpty) _createOverlay();
        if (val.isEmpty) {
          widget.onUserSelected(null, null);
        }
      },
      validator: (val) {
        // Custom validator to check if an actual user is selected
        if (widget.selectedUserId == null || widget.selectedUserId!.isEmpty) {
          return 'Please select a user from the list.';
        }
        return null;
      },
    );
  }
}