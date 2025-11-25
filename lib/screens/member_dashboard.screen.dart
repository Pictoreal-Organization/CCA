import 'package:cca/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.screen.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart';
import '../widgets/meetings_list.widget.dart';
import '../widgets/tasks_list_member.widget.dart';
import 'signIn.screen.dart';
import '../widgets/logout_confirm.dart';
import '../widgets/loading_animation.widget.dart';
import '../services/notification_handler.dart';

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
  bool showMeetings = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    NotificationHandler().initialize();
    fetchAllData();

    // // ✅ Register the callback to control toggle from notifications
    // NotificationHandler.setDashboardToggle = (bool showMeetings) {
    //   if (mounted) {
    //     setState(() {
    //       this.showMeetings = showMeetings;
    //     });
    //     print('🔄 Dashboard toggle set to: ${showMeetings ? "MEETINGS" : "TASKS"}');
    //   }
    // };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // // ✅ Clean up the callback
    // NotificationHandler.setDashboardToggle = null;
    super.dispose();
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isLoading
          ? const Center(child: LoadingAnimation(size: 220))
          : RefreshIndicator(
              color: AppColors.darkTeal,
              onRefresh: fetchAllData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Fixed AppBar
                  SliverAppBar(
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.darkTeal,
                    elevation: 4,
                    toolbarHeight: 56,
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/images/pictoreal_logo.png',
                          height: 32, // adjust to your liking
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),

                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                        tooltip: "Profile",
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
                        tooltip: "Logout",
                        onPressed: () => showLogoutDialog(context),
                      ),
                    ],
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
                              // Quick stats section
                              Container(
                                color: const Color(0xFFF5F5F5),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  16,
                                ),
                                child: Row(
                                  children: [
                                    // Meetings Card
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 52,
                                              height: 52,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: Image.asset(
                                                  'assets/images/meetings_icon.png',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 52,
                                              height: 52,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: Image.asset(
                                                  'assets/images/task_icon.png',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                                  "${memberTasks.length}",
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
                            ],
                          ),
                  ),

                  // Sticky Toggle Buttons
                  if (!isLoading)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyToggleDelegate(
                        showMeetings: showMeetings,
                        onToggle: (value) =>
                            setState(() => showMeetings = value),
                      ),
                    ),

                  // Content Section
                  SliverToBoxAdapter(
                    child: isLoading
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              const SizedBox(height: 16),
                              showMeetings
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MeetingsList(
                                            title: "Ongoing Meetings",
                                            meetings: ongoingMeetings,
                                            role: 'Member',
                                          ),
                                          MeetingsList(
                                            title: "Upcoming Meetings",
                                            meetings: upcomingMeetings,
                                            role: 'Member',
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: TasksListMember(
                                        title: "My Tasks",
                                        tasks: memberTasks,
                                        onTaskUpdated: fetchAllData,
                                      ),
                                    ),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Custom delegate for sticky toggle buttons
class _StickyToggleDelegate extends SliverPersistentHeaderDelegate {
  final bool showMeetings;
  final Function(bool) onToggle;

  _StickyToggleDelegate({required this.showMeetings, required this.onToggle});

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
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
                onTap: () => onToggle(true),
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
                onTap: () => onToggle(false),
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
    );
  }

  @override
  bool shouldRebuild(_StickyToggleDelegate oldDelegate) {
    return showMeetings != oldDelegate.showMeetings;
  }
}
