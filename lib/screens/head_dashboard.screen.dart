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

  // Scroll controller for AppBar hide/show
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    fetchAllData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (_scrollController.offset <= 50 && !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
          data: {'status': 'Pending', 'description': controller.text},
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback sent to member.')),
        );
        fetchAllData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending feedback: $e')));
      }
    }
  }

  void _completeMainTask(dynamic task) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Main Task?'),
        content: const Text(
          'All subtasks have been approved. Do you want to mark the entire task as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete Task'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await taskService.updateTask(task['_id'], {'status': 'Completed'});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as completed!')),
        );
        fetchAllData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error completing task: $e')));
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
      }
    }
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar that hides on scroll
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.darkTeal,
            elevation: 0,
            pinned: false,
            expandedHeight: 0,
            toolbarHeight: _isAppBarVisible ? 56 : 0,
            title: _isAppBarVisible
                ? const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Inter',
                    ),
                  )
                : null,
            actions: _isAppBarVisible
                ? [
                    IconButton(
                      icon: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        showLogoutDialog(context);
                      },
                    ),
                  ]
                : [],
          ),

          // Main content
          SliverToBoxAdapter(
            child: isLoading
                ? const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: [
                      // Stats Cards Row
                      Container(
                        color: const Color(0xFFF5F5F5),
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Row(
                          children: [
                            // Meetings Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Meetings Icon
                                    Container(
                                      width: 52,
                                      height: 52,
                                      // decoration: BoxDecoration(
                                      //   color: const Color(0xFFE3F2FD),
                                      //   borderRadius: BorderRadius.circular(8),
                                      // ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(
                                          'assets/images/meetings_icon.png',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Text and Number
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "MEETINGS",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGray,
                                            letterSpacing: 0,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${ongoingMeetings.length + upcomingMeetings.length}",
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Tasks Card
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Tasks Icon
                                    Container(
                                      width: 52,
                                      height: 52,
                                      // decoration: BoxDecoration(
                                      //   color: const Color(0xFFFFF3E0),
                                      //   borderRadius: BorderRadius.circular(8),
                                      // ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(
                                          'assets/images/task_icon.png',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Text and Number
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "TASKS",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGray,
                                            letterSpacing: 0,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${allTasks.length}",
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Toggle Buttons
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => showMeetings = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: showMeetings
                                        ? AppColors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Meetings",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: showMeetings
                                          ? Colors.white
                                          : AppColors.darkGray,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => showMeetings = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !showMeetings
                                        ? AppColors.orange
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Tasks",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: !showMeetings
                                          ? Colors.white
                                          : AppColors.darkGray,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Content Section
                      showMeetings
                          ? Column(
                              children: [
                                MeetingsList(
                                  title: "Ongoing Meetings",
                                  meetings: ongoingMeetings,
                                  role: 'head',
                                ),
                                MeetingsList(
                                  title: "Upcoming Meetings",
                                  meetings: upcomingMeetings,
                                  role: 'head',
                                ),
                                MeetingsList(
                                  title: "Pending Attendance",
                                  meetings: attendancePendingMeetings,
                                  role: 'head',
                                ),
                              ],
                            )
                          : _buildTasksSection(),

                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: showMeetings
            ? const Color(0xFF00897B)
            : const Color(0xFFFF9800),
        elevation: 6,
        onPressed: showMeetings ? openCreateMeeting : openCreateTask,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTasksSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "All Tasks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:Colors.black,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                "${allTasks.length} Tasks",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGray,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tasks List
          allTasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Color(0xFFBDBDBD),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No tasks available",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF757575),
                            fontFamily: 'Inter',
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
                    final completedSubtasks = subtasks
                        .where((s) => s['status'] == 'Completed')
                        .length;
                    final needsReview = subtasks.any(
                      (s) => s['status'] == 'Completed',
                    );

                    return _buildTaskCard(
                      task,
                      subtasks,
                      completedSubtasks,
                      needsReview,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    dynamic task,
    List subtasks,
    int completedSubtasks,
    bool needsReview,
  ) {
    final isCompleted = task['status'] == 'Completed';
    final borderColor = needsReview
        ? AppColors.orange
        : AppColors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Task Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Badge Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    if (needsReview)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Needs Review',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subtasks count
                Text(
                  "${completedSubtasks}/${subtasks.length} subtasks",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 12),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Buttons Section
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => openCreateTask(taskToEdit: task),
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteTask(task['_id']),
                    icon: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
