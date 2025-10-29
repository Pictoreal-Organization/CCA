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
    backgroundColor: AppColors.cream5,
    appBar: AppBar(
      backgroundColor: AppColors.teal1,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.teal1, AppColors.teal2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        "Dashboard",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          // decoration: BoxDecoration(
          //   color: Colors.white.withOpacity(0.2),
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: "Profile",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          // decoration: BoxDecoration(
          //   color: Colors.white.withOpacity(0.2),
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: () {
              showLogoutDialog(context);
            },
          ),
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
                color: AppColors.teal1,
                onRefresh: fetchAllData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Enhanced Welcome Card ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.teal1, AppColors.teal2, AppColors.teal3],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal1.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.waving_hand,
                                color: AppColors.gold1,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Welcome Back!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Here's what's happening today",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- Enhanced Quick Stats Row ---
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, AppColors.cream3],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.amber3,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.amber2.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.amber1, AppColors.amber2],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.amber1.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.video_call,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "${ongoingMeetings.length + upcomingMeetings.length}",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.charcoal1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Meetings",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.charcoal3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, AppColors.cream3],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.mint2,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mint2.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.teal1, AppColors.teal2],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.teal1.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.task_alt,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "${allTasks.length}",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.charcoal1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tasks",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.charcoal3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // --- Enhanced Toggle Buttons ---
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cream3,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.mint4,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.charcoal5.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => showMeetings = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: showMeetings
                                        ? LinearGradient(
                                            colors: [AppColors.teal1, AppColors.teal2],
                                          )
                                        : null,
                                    color: showMeetings ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: showMeetings
                                        ? [
                                            BoxShadow(
                                              color: AppColors.teal1.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event,
                                        color: showMeetings
                                            ? Colors.white
                                            : AppColors.teal2,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Meetings",
                                        style: TextStyle(
                                          color: showMeetings
                                              ? Colors.white
                                              : AppColors.teal2,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => showMeetings = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: !showMeetings
                                        ? LinearGradient(
                                            colors: [AppColors.teal1, AppColors.teal2],
                                          )
                                        : null,
                                    color: !showMeetings ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !showMeetings
                                        ? [
                                            BoxShadow(
                                              color: AppColors.teal1.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.checklist,
                                        color: !showMeetings
                                            ? Colors.white
                                            : AppColors.teal2,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Tasks",
                                        style: TextStyle(
                                          color: !showMeetings
                                              ? Colors.white
                                              : AppColors.teal2,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
    // Header with gradient background
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal1, AppColors.teal2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal1.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "All Tasks",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${allTasks.length} Tasks",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 20),
    allTasks.isEmpty
        ? Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.cream2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.mint3, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: AppColors.teal3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No active tasks found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create your first task to get started!",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.charcoal3,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allTasks.length,
            itemBuilder: (context, index) {
              final task = allTasks[index];
              final subtasks = (task['subtasks'] as List?) ?? [];
              final completedSubtasks = subtasks.where((s) => s['status'] == 'Completed').length;
              final allSubtasksCompleted = subtasks.isNotEmpty && 
                  subtasks.every((s) => s['status'] == 'Completed');
              final needsReview = subtasks.any((s) => s['status'] == 'Completed');
              final progress = subtasks.isEmpty ? 0.0 : completedSubtasks / subtasks.length;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, AppColors.cream4],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.charcoal4.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: needsReview ? AppColors.amber2 : AppColors.mint4,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    childrenPadding: const EdgeInsets.only(bottom: 16),
                    iconColor: AppColors.teal1,
                    collapsedIconColor: AppColors.teal2,
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal1,
                                ),
                              ),
                            ),
                            if (needsReview)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.amber1, AppColors.amber2],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.amber1.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.rate_review, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Needs Review',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: task['status'] == 'Completed'
                                    ? AppColors.mint2
                                    : AppColors.teal4,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task['status'],
                                style: TextStyle(
                                  color: task['status'] == 'Completed'
                                      ? AppColors.charcoal1
                                      : AppColors.teal1,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (subtasks.isNotEmpty) ...[
                              Icon(Icons.playlist_add_check, 
                                   size: 16, 
                                   color: AppColors.charcoal3),
                              const SizedBox(width: 4),
                              Text(
                                "$completedSubtasks/${subtasks.length} subtasks",
                                style: TextStyle(
                                  color: AppColors.charcoal3,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (subtasks.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.mint5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress == 1.0 ? AppColors.mint1 : AppColors.teal2,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: AppColors.mint5,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_rounded, color: AppColors.teal1),
                            tooltip: 'Edit Task',
                            onPressed: () => openCreateTask(taskToEdit: task),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_rounded, color: AppColors.amber1),
                            tooltip: 'Delete Task',
                            onPressed: () => _deleteTask(task['_id']),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      if (subtasks.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cream3,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.subdirectory_arrow_right, 
                                       color: AppColors.teal2, 
                                       size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Subtasks",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.charcoal1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...subtasks.map((sub) {
                                final assignedUsers = (sub['assignedTo'] as List)
                                    .map((u) => u['username'])
                                    .join(', ');
                                final isCompleted = sub['status'] == 'Completed';
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isCompleted 
                                          ? AppColors.mint3 
                                          : AppColors.charcoal5,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.charcoal5.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isCompleted 
                                              ? AppColors.mint4 
                                              : AppColors.teal5,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isCompleted 
                                              ? Icons.check_circle 
                                              : Icons.radio_button_unchecked,
                                          color: isCompleted 
                                              ? AppColors.mint1 
                                              : AppColors.teal2,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sub['title'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: AppColors.charcoal1,
                                                decoration: isCompleted 
                                                    ? TextDecoration.lineThrough 
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.person_outline, 
                                                     size: 14, 
                                                     color: AppColors.charcoal3),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    assignedUsers,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: AppColors.charcoal3,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCompleted 
                                              ? AppColors.mint3 
                                              : AppColors.gold4,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          sub['status'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isCompleted 
                                                ? AppColors.teal1 
                                                : AppColors.gold1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                      if (task['status'] != 'Completed')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: allSubtasksCompleted
                                  ? LinearGradient(
                                      colors: [AppColors.mint1, AppColors.mint2],
                                    )
                                  : null,
                              color: allSubtasksCompleted ? null : AppColors.charcoal5,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: allSubtasksCompleted
                                  ? [
                                      BoxShadow(
                                        color: AppColors.mint1.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.check_circle,
                                color: allSubtasksCompleted 
                                    ? Colors.white 
                                    : AppColors.charcoal4,
                              ),
                              label: Text(
                                'Mark as Completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: allSubtasksCompleted 
                                      ? Colors.white 
                                      : AppColors.charcoal4,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: allSubtasksCompleted
                                  ? () => _completeMainTask(task)
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
  ],
)
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
              shape: CircleBorder(),
              backgroundColor: showMeetings ? AppColors.amber3 : AppColors.mint3,
              onPressed: showMeetings ? openCreateMeeting : openCreateTask,
              
              label:const Icon(Icons.add),
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
