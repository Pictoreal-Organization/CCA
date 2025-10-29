import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart';
import 'create_meeting.screen.dart';
import 'create_task.screen.dart';
import 'signIn.screen.dart';
import 'profile.screen.dart';
import '../widgets/meetings_list.widget.dart';
import '../core/app_colors.dart';
import '../widgets/logout_confirm.dart';

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

  int _selectedIndex = 0;
  bool showMeetings = true;

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

  // void logout() async {
  //   await authService.logout();
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInScreen()));
  // }

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.teal1,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.cream5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person,color: AppColors.cream5),
            tooltip: "profile",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.cream5),
            tooltip: "Logout",
            onPressed: () {
              showLogoutDialog(context); 
            },
            
          ),
          
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // ----------- Home / Dashboard -----------
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: fetchAllData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Welcome Card ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.teal1, AppColors.teal2,AppColors.teal3],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back!!",
                                style: TextStyle(
                                  color: AppColors.cream5,
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Here's what's happening today",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- Quick Stats Row ---
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cream4,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 111, 78, 78),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.video_call, color: AppColors.amber3),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${ongoingMeetings.length + upcomingMeetings.length}",
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const Text("Meetings"),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.cream4,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 111, 78, 78),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.task_alt, color: AppColors.teal2),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${allTasks.length}",
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const Text("Tasks"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // --- Toggle Buttons: Meetings / Tasks ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => setState(() => showMeetings = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: showMeetings ? AppColors.teal3 : Colors.white,
                                foregroundColor: showMeetings ? Colors.white : AppColors.teal3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Meetings"),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => setState(() => showMeetings = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !showMeetings ? AppColors.teal3 : Colors.white,
                                foregroundColor: !showMeetings ? Colors.white : AppColors.teal3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Tasks"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // --- Conditional Section ---
                        showMeetings
                            ? Column(
                                children: [
                                  MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings, role: 'head'),
                                  MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings, role: 'head'),
                                  MeetingsList(title: "Pending Attendance", meetings: attendancePendingMeetings, role: 'head'),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("All Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  allTasks.isEmpty
                                      ? const Center(
                                          child: Padding(
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
                                            final allSubtasksCompleted = subtasks.isNotEmpty &&
                                                subtasks.every((s) => s['status'] == 'Completed');
                                            final needsReview = subtasks.any((s) => s['status'] == 'Completed');

                                            return Card(
                                              margin: const EdgeInsets.symmetric(vertical: 6),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              elevation: 2,
                                              child: ExpansionTile(
                                                iconColor: Colors.blueAccent,
                                                collapsedIconColor: AppColors.mint2,
                                                title: Row(
                                                  children: [
                                                    Expanded(child: Text(task['title'])),
                                                    if (needsReview)
                                                      Chip(
                                                        label: const Text('Needs Review'),
                                                        backgroundColor: AppColors.mint1,
                                                      ),
                                                  ],
                                                ),
                                                subtitle: Text("Status: ${task['status']}"),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                                      onPressed: () => openCreateTask(taskToEdit: task),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                      onPressed: () => _deleteTask(task['_id']),
                                                    ),
                                                  ],
                                                ),
                                                children: [
                                                  const Divider(height: 1),
                                                  ...subtasks.map((sub) {
                                                    final assignedUsers =
                                                        (sub['assignedTo'] as List).map((u) => u['username']).join(', ');
                                                    return ListTile(
                                                      title: Text(sub['title'],
                                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      subtitle: Text("Assigned to: $assignedUsers"),
                                                      trailing: Chip(label: Text(sub['status'])),
                                                    );
                                                  }).toList(),
                                                  if (task['status'] != 'Completed')
                                                    Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: ElevatedButton.icon(
                                                        icon: const Icon(Icons.check_circle_outline),
                                                        label: const Text('Mark as Completed'),
                                                        onPressed: allSubtasksCompleted
                                                            ? () => _completeMainTask(task)
                                                            : null,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),

          // ----------- Profile Tab -----------
          const ProfileScreen(),
        ],
      ),

      // --- FAB: depends on selected index ---
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: showMeetings ? AppColors.amber3 : AppColors.mint3,
              onPressed: showMeetings ? openCreateMeeting : openCreateTask,
              icon: const Icon(Icons.add),
              label: Text(showMeetings ? "Meeting" : "Task"),
            )
          : null,

      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedItemColor: AppColors.mint1,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      // ),
    );
  }
}
