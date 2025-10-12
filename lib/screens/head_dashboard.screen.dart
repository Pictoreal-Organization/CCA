import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart'; // Import TaskService
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
  final authService = AuthService();
  final MeetingService meetingService = MeetingService();
  final TaskService taskService = TaskService(); // Add TaskService instance

  List ongoingMeetings = [];
  List upcomingMeetings = [];
  List attendancePendingMeetings = [];
  List allTasks = []; // State for storing all tasks
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllData(); // Fetch both meetings and tasks
  }

  // Fetches all data required for the dashboard
  Future<void> fetchAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      // Fetch all data in parallel for faster loading
      final data = await Future.wait([
        meetingService.getOngoingMeetings(),
        meetingService.getUpcomingMeetings(),
        meetingService.getMeetingsForAttendance(),
        taskService.getAllTasks(), // Fetch all tasks
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
          taskToEdit: taskToEdit, // Pass task data for editing
        ),
      ),
    );
  }

  // Logic for deleting a task with a confirmation dialog
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
        fetchAllData(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task: $e')),
        );
      }
    }
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Add bottom padding for FAB
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
                          child: Text("No tasks found. Create one!"),
                        ))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allTasks.length,
                            itemBuilder: (context, index) {
                              final task = allTasks[index];
                              final subtasks = (task['subtasks'] as List?) ?? [];
                              
                              // ✅ USE EXPANSIONTILE FOR DETAILS
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ExpansionTile(
                                  title: Text(task['title']),
                                  subtitle: Text("Status: ${task['status']}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                        tooltip: "Edit Task",
                                        onPressed: () => openCreateTask(taskToEdit: task),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        tooltip: "Delete Task",
                                        onPressed: () => _deleteTask(task['_id']),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    const Divider(height: 1),
                                    // Loop through subtasks and display their details
                                    ...subtasks.map((sub) {
                                      final assignedUsers = (sub['assignedTo'] as List)
                                          .map((user) => user['username'])
                                          .join(', ');

                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        title: Text(sub['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(sub['description'] ?? 'No description.'),
                                            const SizedBox(height: 4),
                                            Text("Assigned to: $assignedUsers", style: const TextStyle(fontStyle: FontStyle.italic)),
                                          ],
                                        ),
                                        trailing: Text(sub['status']),
                                      );
                                    }).toList(),
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