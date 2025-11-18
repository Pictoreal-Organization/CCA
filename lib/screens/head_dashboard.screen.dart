import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart';
import 'create_meeting.screen.dart';
import 'create_task.screen.dart';
import 'package:intl/intl.dart';
import 'signIn.screen.dart';
import 'profile.screen.dart';
import '../widgets/meetings_list.widget.dart';
import '../core/app_colors.dart';
import '../widgets/logout_confirm.dart';
import '../widgets/loading_animation.widget.dart';

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

  bool showMeetings = true;
  Set<String> expandedTasks = {};

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
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
          data: {
            'status': 'Pending',
            'description': controller.text,
          },
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback sent to member.')));
        fetchAllData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error sending feedback: $e')));
      }
    }
  }

  void _completeMainTask(dynamic task) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Main Task?'),
        content: const Text(
            'All subtasks have been approved. Do you want to mark the entire task as completed?'),
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task marked as completed!')));
        fetchAllData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error completing task: $e')));
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully')));
        fetchAllData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
      }
    }
  }

  void logout() async {
    await authService.logout();
    if (!mounted) return;
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
      backgroundColor: Colors.grey.shade50,
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
                      icon: const Icon(Icons.person, color: Colors.white, size: 30),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 26),
                      onPressed: () => showLogoutDialog(context),
                    ),
                  ]
                : [],
          ),

          // Main content
          SliverToBoxAdapter(
            child: isLoading
                ? const SizedBox(
                    height: 600,
                    child: Center(child: LoadingAnimation(size: 180)),
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
                                    Container(
                                      width: 52,
                                      height: 52,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset('assets/images/meetings_icon.png'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text("MEETINGS",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkGray,
                                                fontFamily: 'Inter')),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${ongoingMeetings.length + upcomingMeetings.length}",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                              fontFamily: 'Inter'),
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
                                    Container(
                                      width: 52,
                                      height: 52,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset('assets/images/task_icon.png'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text("TASKS",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkGray,
                                                fontFamily: 'Inter')),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${allTasks.length}",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                              fontFamily: 'Inter'),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightGray.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => showMeetings = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: showMeetings ? AppColors.green : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Meetings",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: showMeetings ? Colors.white : AppColors.darkGray,
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
                                onTap: () => setState(() => showMeetings = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: !showMeetings ? AppColors.orange : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Tasks",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: !showMeetings ? Colors.white : AppColors.darkGray,
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
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  MeetingsList(
                                      title: "Ongoing Meetings",
                                      meetings: ongoingMeetings,
                                      role: 'head'),
                                  MeetingsList(
                                      title: "Upcoming Meetings",
                                      meetings: upcomingMeetings,
                                      role: 'head'),
                                  MeetingsList(
                                      title: "Pending Attendance",
                                      meetings: attendancePendingMeetings,
                                      role: 'head'),
                                ],
                              ),
                            )
                          : _buildTasksSection(),

                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
          ),
        ],
      ),

      // Floating Action Button (Dynamic based on tab)
      floatingActionButton: FloatingActionButton(
        backgroundColor: showMeetings ? const Color(0xFF00897B) : const Color(0xFFFF9800),
        elevation: 6,
        onPressed: showMeetings ? openCreateMeeting : openCreateTask,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTasksSection() {
    // 1. Sort the tasks: Needs Review -> Pending -> Completed
    final sortedTasks = List.from(allTasks);
    sortedTasks.sort((a, b) {
      final subtasksA = (a['subtasks'] as List?) ?? [];
      final subtasksB = (b['subtasks'] as List?) ?? [];

      final needsReviewA = subtasksA.any((s) => s['status'] == 'Completed');
      final needsReviewB = subtasksB.any((s) => s['status'] == 'Completed');

      final isCompletedA = a['status'] == 'Completed';
      final isCompletedB = b['status'] == 'Completed';

      // Priority 1: Needs Review comes first
      if (needsReviewA && !needsReviewB) return -1;
      if (!needsReviewA && needsReviewB) return 1;

      // Priority 2: Completed comes last
      if (!isCompletedA && isCompletedB) return -1;
      if (isCompletedA && !isCompletedB) return 1;

      return 0; // Keep original order if same priority
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("All Tasks",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Inter')),
              Text("${allTasks.length} Tasks",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGray,
                      fontFamily: 'Inter')),
            ],
          ),
          const SizedBox(height: 16),
          sortedTasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        Icon(Icons.assignment_outlined,
                            size: 64, color: Color(0xFFBDBDBD)),
                        SizedBox(height: 16),
                        Text("No tasks available",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF757575),
                                fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedTasks.length,
                  itemBuilder: (context, index) {
                    final task = sortedTasks[index];
                    final subtasks = (task['subtasks'] as List?) ?? [];
                    final completedSubtasks =
                        subtasks.where((s) => s['status'] == 'Completed').length;
                    final needsReview =
                        subtasks.any((s) => s['status'] == 'Completed');

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
    final allSubtasksCompleted =
        subtasks.isNotEmpty && subtasks.every((s) => s['status'] == 'Completed');
    final borderColor = needsReview ? AppColors.orange : AppColors.green;
    final taskId = task['_id'];
    final isExpanded = expandedTasks.contains(taskId);
    final date = DateTime.parse(task['deadline']).toLocal();
    final formattedDeadline = DateFormat('d MMM').format(date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              expandedTasks.remove(taskId);
            } else {
              expandedTasks.add(taskId);
            }
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: borderColor, width: 7)),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE + DEADLINE + ARROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "🗓 $formattedDeadline",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF757575),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "📌 $completedSubtasks/${subtasks.length}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF757575),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                            // Visual cue for expandability
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.lightGray,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// SUBTASKS WHEN EXPANDED
                    if (isExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: subtasks.map<Widget>((s) {
                            final title = s['title'];
                            final status = s['status'];
                            final assignedList = s['assignedTo'] ?? [];
                            final assignedUser =
                                assignedList.isNotEmpty ? assignedList[0] : null;
                            final assignedName =
                                assignedUser?['name'] ?? 'Not Assigned';

                            // Action Buttons for Subtasks
                            Widget actionWidget;
                            if (status == 'Completed') {
                              // Show "Changes" button (Styled like Edit/Review)
                              actionWidget = SizedBox(
                                height: 34,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showSuggestChangesDialog(task, s),
                                  icon: const Icon(Icons.undo, size: 14, color: Colors.white),
                                  label: const Text('Changes'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkTeal,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              );
                            } else {
                              // Show "Mark Done" button (Styled like Edit/Review)
                              actionWidget = SizedBox(
                                height: 34,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    taskService.updateSubtask(
                                      taskId: task['_id'],
                                      subtaskId: s['_id'],
                                      data: {'status': 'Completed'},
                                    ).then((_) => fetchAllData());
                                  },
                                  icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                  label: const Text('Mark Done'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        Text(assignedName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              fontStyle: FontStyle.italic,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Button on the far right
                                  actionWidget,
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Mark Main Task Completed Button
                      if (task['status'] != 'Completed')
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline,
                                  color: Colors.white),
                              label: const Text('Mark Main Task as Completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: allSubtasksCompleted
                                    ? AppColors.green
                                    : Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: allSubtasksCompleted
                                  ? () => _completeMainTask(task)
                                  : null,
                            ),
                          ),
                        ),
                    ] else
                      /// COLLAPSED VIEW: STATUS BADGES AND REVIEW BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // If it needs review, show ONLY Needs Review UI
                          if (needsReview) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.darkOrange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Needs Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            // Review button (moved to the right)
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  height: 38,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        expandedTasks.add(taskId);
                                      });
                                    },
                                    icon: const Icon(Icons.rate_review, size: 16, color: Colors.white),
                                    label: const Text('Review'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkTeal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else
                            // Otherwise show standard status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? AppColors.green
                                    : const Color.fromARGB(255, 103, 186, 254),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                task['status'],
                                style: TextStyle(
                                  color: isCompleted
                                      ? Colors.white
                                      : const Color.fromARGB(255, 5, 38, 94),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              /// BUTTONS (Edit / Delete)
              if (isExpanded || !isCompleted)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => openCreateTask(taskToEdit: task),
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteTask(task['_id']),
                          icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}