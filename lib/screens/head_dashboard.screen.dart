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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback sent to member.')),
        );
        fetchAllData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending feedback: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing task: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task: $e')),
        );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.darkTeal,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: "Profile",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
                  color: AppColors.darkTeal,
                  onRefresh: fetchAllData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeCard(),
                        const SizedBox(height: 24),
                        _buildQuickStats(),
                        const SizedBox(height: 24),
                        _buildToggleButtons(),
                        const SizedBox(height: 16),
                        showMeetings ? _buildMeetingsView() : _buildTasksView(),
                      ],
                    ),
                  ),
                ),
          // ----------- Profile Tab -----------
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: showMeetings ? AppColors.orange : AppColors.green,
              onPressed: showMeetings ? openCreateMeeting : openCreateTask,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkTeal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.waving_hand,
            color: AppColors.orange,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            "Welcome Back!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Here's what's happening today",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.video_call,
            count: ongoingMeetings.length + upcomingMeetings.length,
            label: "Meetings",
            color: AppColors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.task_alt,
            count: allTasks.length,
            label: "Tasks",
            color: AppColors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.event,
              label: "Meetings",
              isSelected: showMeetings,
              onTap: () => setState(() => showMeetings = true),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.checklist,
              label: "Tasks",
              isSelected: !showMeetings,
              onTap: () => setState(() => showMeetings = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.lightGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.lightGray,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingsView() {
    return Column(
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
    );
  }

  Widget _buildTasksView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTasksHeader(),
        const SizedBox(height: 16),
        allTasks.isEmpty ? _buildEmptyTasksView() : _buildTasksList(),
      ],
    );
  }

  Widget _buildTasksHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "All Tasks",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${allTasks.length} Tasks",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.green.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 64, color: AppColors.green),
            const SizedBox(height: 16),
            Text(
              "No active tasks found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first task to get started!",
              style: TextStyle(fontSize: 14, color: AppColors.lightGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allTasks.length,
      itemBuilder: (context, index) => _buildTaskItem(allTasks[index]),
    );
  }

  Widget _buildTaskItem(dynamic task) {
    final subtasks = (task['subtasks'] as List?) ?? [];
    final completedSubtasks =
        subtasks.where((s) => s['status'] == 'Completed').length;
    final allSubtasksCompleted = subtasks.isNotEmpty &&
        subtasks.every((s) => s['status'] == 'Completed');
    final needsReview = subtasks.any((s) => s['status'] == 'Completed');
    final progress =
        subtasks.isEmpty ? 0.0 : completedSubtasks / subtasks.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: needsReview 
              ? AppColors.orange.withOpacity(0.5) 
              : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          iconColor: AppColors.darkTeal,
          collapsedIconColor: AppColors.lightGray,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          title: _buildTaskTitle(task, subtasks, completedSubtasks, needsReview, progress),
          trailing: _buildTaskActions(task),
          children: [
            if (subtasks.isNotEmpty) _buildSubtasksList(subtasks),
            if (task['status'] != 'Completed')
              _buildCompleteButton(task, allSubtasksCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTitle(dynamic task, List subtasks, int completedSubtasks,
      bool needsReview, double progress) {
    return Column(
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
                  color: AppColors.darkGray,
                ),
              ),
            ),
            if (needsReview)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.rate_review, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
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
                    ? AppColors.green.withOpacity(0.2)
                    : AppColors.darkTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task['status'],
                style: TextStyle(
                  color: task['status'] == 'Completed'
                      ? AppColors.green
                      : AppColors.darkTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (subtasks.isNotEmpty) ...[
              Icon(Icons.playlist_add_check,
                  size: 16, color: AppColors.lightGray),
              const SizedBox(width: 4),
              Text(
                "$completedSubtasks/${subtasks.length} subtasks",
                style: TextStyle(
                  color: AppColors.lightGray,
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
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.green : AppColors.darkTeal,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaskActions(dynamic task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.darkTeal, size: 20),
            tooltip: 'Edit Task',
            onPressed: () => openCreateTask(taskToEdit: task),
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppColors.darkOrange, size: 20),
            tooltip: 'Delete Task',
            onPressed: () => _deleteTask(task['_id']),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksList(List subtasks) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.subdirectory_arrow_right,
                  color: AppColors.darkTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                "Subtasks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...subtasks.map((sub) => _buildSubtaskItem(sub)).toList(),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(dynamic sub) {
    final assignedUsers =
        (sub['assignedTo'] as List).map((u) => u['username']).join(', ');
    final isCompleted = sub['status'] == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? AppColors.green.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppColors.green.withOpacity(0.1) 
                  : AppColors.darkTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? AppColors.green : AppColors.darkTeal,
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
                    color: AppColors.darkGray,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: AppColors.lightGray),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        assignedUsers,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.lightGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppColors.green.withOpacity(0.2) 
                  : AppColors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sub['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCompleted ? AppColors.green : AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(dynamic task, bool allSubtasksCompleted) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(
            Icons.check_circle,
            color: allSubtasksCompleted ? Colors.white : Colors.grey,
          ),
          label: const Text(
            'Mark as Completed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: allSubtasksCompleted 
                ? AppColors.green 
                : Colors.grey[300],
            foregroundColor: allSubtasksCompleted ? Colors.white : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              allSubtasksCompleted ? () => _completeMainTask(task) : null,
        ),
      ),
    );
  }
}