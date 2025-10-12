import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.screen.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart';
import '../widgets/meetings_list.widget.dart';
import 'signIn.screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});
  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final MeetingService meetingService = MeetingService();
  final TaskService taskService = TaskService();
  final AuthService authService = AuthService();

  List ongoingMeetings = [];
  List upcomingMeetings = [];
  List memberTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  // This function remains the same, no changes needed
  Future<void> fetchAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId == null) throw Exception("User ID not found.");

      final data = await Future.wait([
        meetingService.getOngoingMeetings(),
        meetingService.getUpcomingMeetings(),
        taskService.getTasksByMember(userId),
      ]);

      if (!mounted) return;
      setState(() {
        ongoingMeetings = data[0] as List;
        upcomingMeetings = data[1] as List;
        memberTasks = data[2] as List;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void logout() async {
    await authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  // --- LOGIC FOR HANDLING STATUS CHANGE ---

  // This function now acts as a controller for the UI actions
  void _handleStatusChange(String newStatus, dynamic task, dynamic subtask) async {
    // If the user clicks "Completed", show the dialog first
    if (newStatus == 'Completed') {
      String? completionNote = await _showCompletionNoteDialog();
      // Only proceed if the user provides a note and hits save
      if (completionNote != null && completionNote.isNotEmpty) {
        _updateSubtaskApi(newStatus, task, subtask, description: completionNote);
      }
    } else {
      // For "In Progress", update the status immediately
      _updateSubtaskApi(newStatus, task, subtask);
    }
  }

  // Generic helper to call the API
  void _updateSubtaskApi(String status, dynamic task, dynamic subtask, {String? description}) async {
    try {
      final data = {'status': status};
      // Only add description to the payload if it's provided
      if (description != null) {
        data['description'] = description;
      }
      
      await taskService.updateSubtask(
        taskId: task['_id'],
        subtaskId: subtask['_id'],
        data: data,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${subtask['title']} status updated!'), duration: const Duration(seconds: 2)),
      );
      fetchAllData(); // Refresh the entire dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Dialog for the member to enter completion notes. This is unchanged.
  Future<String?> _showCompletionNoteDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (context) => AlertDialog(
        title: const Text('Complete Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Add a completion note*',
            hintText: 'Describe what you have completed.',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text);
              } else {
                // You can add a small error message here if you want
              }
            },
            child: const Text('Mark as Completed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Dashboard"),
        actions: [
            IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: logout,
          ),
        ]
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAllData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings, role: 'Member'),
                    MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings, role: 'Member'),
                    const SizedBox(height: 24),
                    const Text("My Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    memberTasks.isEmpty
                        ? const Center(child: Text("You have no tasks assigned."))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: memberTasks.length,
                            itemBuilder: (context, index) {
                              final task = memberTasks[index];
                              final subtasks = task['subtasks'] as List;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(task['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const Divider(),
                                      ...subtasks.map((sub) {
                                        final currentStatus = sub['status'];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(sub['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                              const SizedBox(height: 4),
                                              Text(sub['description'] ?? 'No description provided.', style: const TextStyle(color: Colors.black54)),
                                              const SizedBox(height: 12),
                                              
                                              // --- ✅ NEW UI LOGIC ---
                                              // If task is completed, show a final status chip.
                                              if (currentStatus == 'Completed')
                                                Chip(
                                                  label: const Text('Completed'),
                                                  avatar: const Icon(Icons.check_circle, color: Colors.white),
                                                  backgroundColor: Colors.green.shade100,
                                                  labelStyle: TextStyle(color: Colors.green.shade900),
                                                )
                                              // Otherwise, show the action chips.
                                              else
                                                Row(
                                                  children: [
                                                    ActionChip(
                                                      avatar: const Icon(Icons.directions_run),
                                                      label: const Text('In Progress'),
                                                      backgroundColor: currentStatus == 'In Progress' ? Colors.blue.shade100 : null,
                                                      onPressed: () => _handleStatusChange('In Progress', task, sub),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ActionChip(
                                                      avatar: const Icon(Icons.done_all),
                                                      label: const Text('Completed'),
                                                      onPressed: () => _handleStatusChange('Completed', task, sub),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}