import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart';
import 'create_meeting.screen.dart';
import 'create_task.screen.dart';
import 'signIn.screen.dart';
import 'profile.screen.dart';
import '../widgets/meetings_list.widget.dart';

class HeadDashboard extends StatefulWidget {
  const HeadDashboard({super.key});

  @override
  State<HeadDashboard> createState() => _HeadDashboardState();
}

class _HeadDashboardState extends State<HeadDashboard> {
  // Services
  final authService = AuthService();
  final MeetingService meetingService = MeetingService();
  final TaskService taskService = TaskService();

  // State
  List ongoingMeetings = [];
  List upcomingMeetings = [];
  List attendancePendingMeetings = [];
  List allTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  // --- DATA FETCHING ---
  Future<void> fetchAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await Future.wait([
        meetingService.getOngoingMeetings(),
        meetingService.getUpcomingMeetings(),
        meetingService.getMeetingsForAttendance(),
        taskService.getAllTasks(),
      ]);
      if (!mounted) return;
      setState(() {
        ongoingMeetings = data[0] as List;
        upcomingMeetings = data[1] as List;
        attendancePendingMeetings = data[2] as List;
        allTasks = data[3] as List;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- HEAD ACTION METHODS ---
  // All the action methods below are already correct and do not need changes.
  void _showSuggestChangesDialog(dynamic task, dynamic subtask) async {
    final controller = TextEditingController();
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Suggest Changes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Required changes*',
            hintText: 'e.g., "Please add responsive support for tablets."',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await taskService.updateSubtask(
          taskId: task['_id'],
          subtaskId: subtask['_id'],
          data: {
            'status': 'Pending',
            'description': controller.text,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback sent to member.')));
        fetchAllData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending feedback: $e')));
      }
    }
  }

  void _completeMainTask(dynamic task) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Main Task?'),
        content: const Text('All subtasks have been approved. Do you want to mark the entire task as completed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Complete Task')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await taskService.updateTask(task['_id'], {'status': 'Completed'});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task marked as completed!')));
        fetchAllData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error completing task: $e')));
      }
    }
  }

  void _deleteTask(String taskId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This action is permanent and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await taskService.deleteTask(taskId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
        fetchAllData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task: $e')),
        );
      }
    }
  }

  void logout() async {
    await authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  void openCreateMeeting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMeetingScreen(onMeetingCreated: fetchAllData),
      ),
    );
  }

  void openCreateTask({Map<String, dynamic>? taskToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(
          onTaskCreated: fetchAllData,
          taskToEdit: taskToEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Head Dashboard"),
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
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAllData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings, role: 'head'),
                    MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings, role: 'head'),
                    MeetingsList(title: "Meetings Pending for Attendance", meetings: attendancePendingMeetings, role: 'head'),
                    const SizedBox(height: 24),
                    const Text("All Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    allTasks.isEmpty
                        ? const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No active tasks found. Create one!"),
                        ))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allTasks.length,
                            itemBuilder: (context, index) {
                              final task = allTasks[index];
                              final subtasks = (task['subtasks'] as List?) ?? [];
                              final allSubtasksCompleted = subtasks.isNotEmpty && subtasks.every((s) => s['status'] == 'Completed');
                              // ✅ CORRECT LOGIC: Check if any subtask is 'Completed'.
                              final needsReview = subtasks.any((s) => s['status'] == 'Completed');
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ExpansionTile(
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(task['title'])),
                                      // ✅ CORRECT LOGIC: Show the chip if review is needed.
                                      if (needsReview)
                                        Chip(
                                          label: const Text('Needs Review'),
                                          backgroundColor: Colors.amber.shade200,
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          labelStyle: TextStyle(color: Colors.brown.shade900, fontSize: 12),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                  subtitle: Text("Status: ${task['status']}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => openCreateTask(taskToEdit: task)),
                                      IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteTask(task['_id'])),
                                    ],
                                  ),
                                  children: [
                                    const Divider(height: 1),
                                    ...subtasks.map((sub) {
                                      final assignedUsers = (sub['assignedTo'] as List).map((u) => u['username']).join(', ');
                                      return ListTile(
                                        title: Text(sub['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(sub['description'] ?? 'No description.'),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Assigned to: $assignedUsers",
                                              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        trailing: sub['status'] == 'Completed'
                                            ? ActionChip(
                                                avatar: const Icon(Icons.undo, size: 16),
                                                label: const Text('Changes?'),
                                                tooltip: 'Suggest Changes',
                                                onPressed: () => _showSuggestChangesDialog(task, sub),
                                                backgroundColor: Colors.orange.shade100,
                                              )
                                            : Chip(label: Text(sub['status'])),
                                      );
                                    }).toList(),
                                    if (task['status'] != 'Completed')
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.check_circle_outline),
                                          label: const Text('Mark Main Task as Completed'),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(double.infinity, 40),
                                            backgroundColor: allSubtasksCompleted ? Colors.green : Colors.grey.shade400,
                                          ),
                                          onPressed: allSubtasksCompleted ? () => _completeMainTask(task) : null,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: "taskBtn",
              onPressed: () => openCreateTask(),
              icon: const Icon(Icons.assignment),
              label: const Text("Task"),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: "meetingBtn",
              onPressed: openCreateMeeting,
              icon: const Icon(Icons.add),
              label: const Text("Meeting"),
            ),
          ),
        ],
      ),
    );
  }
}