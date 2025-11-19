// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../services/meeting_service.dart';
// import '../services/task_service.dart';
// import 'create_meeting.screen.dart';
// import 'create_task.screen.dart';
// import 'package:intl/intl.dart';
// import 'signIn.screen.dart';
// import 'profile.screen.dart';
// import '../widgets/meetings_list.widget.dart';
// import '../widgets/tasks_list.widget.dart';
// import '../core/app_colors.dart';
// import '../widgets/logout_confirm.dart';
// import '../widgets/loading_animation.widget.dart';

// class HeadDashboard extends StatefulWidget {
//   const HeadDashboard({super.key});

//   @override
//   State<HeadDashboard> createState() => _HeadDashboardState();
// }

// class _HeadDashboardState extends State<HeadDashboard> {
//   // Services
//   final authService = AuthService();
//   final MeetingService meetingService = MeetingService();
//   final TaskService taskService = TaskService();

//   // State
//   List ongoingMeetings = [];
//   List upcomingMeetings = [];
//   List attendancePendingMeetings = [];
//   List allTasks = [];
//   bool isLoading = true;

//   bool showMeetings = true;
//   // Set<String> expandedTasks = {};

//   // Scroll controller for AppBar hide/show
//   final ScrollController _scrollController = ScrollController();
//   bool _isAppBarVisible = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchAllData();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.offset > 50 && _isAppBarVisible) {
//       setState(() => _isAppBarVisible = false);
//     } else if (_scrollController.offset <= 50 && !_isAppBarVisible) {
//       setState(() => _isAppBarVisible = true);
//     }
//   }

//   // --- DATA FETCHING ---
//   Future<void> fetchAllData() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//     try {
//       final data = await Future.wait([
//         meetingService.getOngoingMeetings(),
//         meetingService.getUpcomingMeetings(),
//         meetingService.getMeetingsForAttendance(),
//         taskService.getAllTasks(),
//       ]);
//       if (!mounted) return;
//       setState(() {
//         ongoingMeetings = data[0] as List;
//         upcomingMeetings = data[1] as List;
//         attendancePendingMeetings = data[2] as List;
//         allTasks = data[3] as List;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void logout() async {
//     await authService.logout();
//     if (!mounted) return;
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (_) => SignInScreen()));
//   }

//   void openCreateMeeting() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CreateMeetingScreen(onMeetingCreated: fetchAllData),
//       ),
//     );
//   }

//   void openCreateTask({Map<String, dynamic>? taskToEdit}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CreateTaskScreen(
//           onTaskCreated: fetchAllData,
//           taskToEdit: taskToEdit,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           // AppBar that hides on scroll
//           SliverAppBar(
//             floating: true,
//             snap: true,
//             backgroundColor: AppColors.darkTeal,
//             elevation: 0,
//             pinned: false,
//             expandedHeight: 0,
//             toolbarHeight: _isAppBarVisible ? 56 : 0,
//             title: _isAppBarVisible
//                 ? const Text(
//                     "Dashboard",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                       fontSize: 25,
//                       fontFamily: 'Inter',
//                     ),
//                   )
//                 : null,
//             actions: _isAppBarVisible
//                 ? [
//                     IconButton(
//                       icon: const Icon(Icons.person, color: Colors.white, size: 30),
//                       onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.logout, color: Colors.white, size: 26),
//                       onPressed: () => showLogoutDialog(context),
//                     ),
//                   ]
//                 : [],
//           ),

//           // Main content
//           SliverToBoxAdapter(
//             child: isLoading
//                 ? const SizedBox(
//                     height: 600,
//                     child: Center(child: LoadingAnimation(size: 180)),
//                   )
//                 : Column(
//                     children: [
//                       // Stats Cards Row
//                       Container(
//                         color: const Color(0xFFF5F5F5),
//                         padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
//                         child: Row(
//                           children: [
//                             // Meetings Card
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.08),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       width: 52,
//                                       height: 52,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4),
//                                         child: Image.asset('assets/images/meetings_icon.png'),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         const Text("MEETINGS",
//                                             style: TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: AppColors.darkGray,
//                                                 fontFamily: 'Inter')),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           "${ongoingMeetings.length + upcomingMeetings.length}",
//                                           style: const TextStyle(
//                                               fontSize: 25,
//                                               fontWeight: FontWeight.w700,
//                                               color: Colors.black,
//                                               fontFamily: 'Inter'),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             // Tasks Card
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.08),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       width: 52,
//                                       height: 52,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4),
//                                         child: Image.asset('assets/images/task_icon.png'),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         const Text("TASKS",
//                                             style: TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: AppColors.darkGray,
//                                                 fontFamily: 'Inter')),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           "${allTasks.length}",
//                                           style: const TextStyle(
//                                               fontSize: 25,
//                                               fontWeight: FontWeight.w700,
//                                               color: Colors.black,
//                                               fontFamily: 'Inter'),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Toggle Buttons
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                         margin: const EdgeInsets.symmetric(horizontal: 14),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.lightGray.withOpacity(0.4),
//                               blurRadius: 6,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: InkWell(
//                                 onTap: () => setState(() => showMeetings = true),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 14),
//                                   decoration: BoxDecoration(
//                                     color: showMeetings ? AppColors.green : Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     "Meetings",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: showMeetings ? Colors.white : AppColors.darkGray,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 18,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: InkWell(
//                                 onTap: () => setState(() => showMeetings = false),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(vertical: 14),
//                                   decoration: BoxDecoration(
//                                     color: !showMeetings ? AppColors.orange : Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     "Tasks",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: !showMeetings ? Colors.white : AppColors.darkGray,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 18,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       // Content Section
//                       showMeetings
//                           ? Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                               child: Column(
//                                 children: [
//                                   MeetingsList(
//                                       title: "Ongoing Meetings",
//                                       meetings: ongoingMeetings,
//                                       role: 'head'),
//                                   MeetingsList(
//                                       title: "Upcoming Meetings",
//                                       meetings: upcomingMeetings,
//                                       role: 'head'),
//                                   MeetingsList(
//                                       title: "Pending Attendance",
//                                       meetings: attendancePendingMeetings,
//                                       role: 'head'),
//                                 ],
//                               ),
//                             )
//                           : _buildTasksSection(),

//                       const SizedBox(height: 100), // Space for FAB
//                     ],
//                   ),
//           ),
//         ],
//       ),

//       // Floating Action Button (Dynamic based on tab)
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: showMeetings ? const Color(0xFF00897B) : const Color(0xFFFF9800),
//         elevation: 6,
//         onPressed: showMeetings ? openCreateMeeting : openCreateTask,
//         child: const Icon(Icons.add, color: Colors.white, size: 28),
//       ),
//     );
//   }

//   Widget _buildTasksSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: TasksList(
//         title: "All Tasks",
//         tasks: allTasks,
//         onTaskUpdated: fetchAllData,
//         onEditTask: (task) => openCreateTask(taskToEdit: task),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../services/meeting_service.dart';
// import '../services/task_service.dart';
// import 'create_meeting.screen.dart';
// import 'create_task.screen.dart';
// import 'package:intl/intl.dart';
// import 'signIn.screen.dart';
// import 'profile.screen.dart';
// import '../widgets/meetings_list.widget.dart';
// import '../widgets/tasks_list.widget.dart';
// import '../core/app_colors.dart';
// import '../widgets/logout_confirm.dart';
// import '../widgets/loading_animation.widget.dart';
// import '../services/notification_handler.dart';

// class HeadDashboard extends StatefulWidget {
//   const HeadDashboard({super.key});

//   @override
//   State<HeadDashboard> createState() => _HeadDashboardState();
// }

// class _HeadDashboardState extends State<HeadDashboard> {
//   // Services
//   final authService = AuthService();
//   final MeetingService meetingService = MeetingService();
//   final TaskService taskService = TaskService();

//   // State
//   List ongoingMeetings = [];
//   List upcomingMeetings = [];
//   List attendancePendingMeetings = [];
//   List allTasks = [];
//   bool isLoading = true;

//   bool showMeetings = true;

//   // Scroll controller for sticky behavior
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     NotificationHandler().initialize();
//     fetchAllData();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // --- DATA FETCHING ---
//   Future<void> fetchAllData() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//     try {
//       final data = await Future.wait([
//         meetingService.getOngoingMeetings(),
//         meetingService.getUpcomingMeetings(),
//         meetingService.getMeetingsForAttendance(),
//         taskService.getAllTasks(),
//       ]);
//       if (!mounted) return;
//       setState(() {
//         ongoingMeetings = data[0] as List;
//         upcomingMeetings = data[1] as List;
//         attendancePendingMeetings = data[2] as List;
//         allTasks = data[3] as List;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void logout() async {
//     await authService.logout();
//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => SignInScreen()),
//     );
//   }

//   void openCreateMeeting() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CreateMeetingScreen(onMeetingCreated: fetchAllData),
//       ),
//     );
//   }

//   void openCreateTask({Map<String, dynamic>? taskToEdit}) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CreateTaskScreen(
//           onTaskCreated: fetchAllData,
//           taskToEdit: taskToEdit,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           // Fixed AppBar - Always visible at top
//           SliverAppBar(
//             floating: false,
//             pinned: true,
//             backgroundColor: AppColors.darkTeal,
//             elevation: 4,
//             toolbarHeight: 56,
//             title: const Text(
//               "Dashboard",
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//                 fontSize: 25,
//                 fontFamily: 'Inter',
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.person, color: Colors.white, size: 30),
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.logout, color: Colors.white, size: 26),
//                 onPressed: () => showLogoutDialog(context),
//               ),
//             ],
//           ),

//           // Main content
//           SliverToBoxAdapter(
//             child: isLoading
//                 ? const SizedBox(
//                     height: 600,
//                     child: Center(child: LoadingAnimation(size: 180)),
//                   )
//                 : Column(
//                     children: [
//                       // Stats Cards Row (Scrollable)
//                       Container(
//                         color: const Color(0xFFF5F5F5),
//                         padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
//                         child: Row(
//                           children: [
//                             // Meetings Card
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.08),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       width: 52,
//                                       height: 52,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4),
//                                         child: Image.asset(
//                                           'assets/images/meetings_icon.png',
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         const Text(
//                                           "MEETINGS",
//                                           style: TextStyle(
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppColors.darkGray,
//                                             fontFamily: 'Inter',
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           "${ongoingMeetings.length + upcomingMeetings.length}",
//                                           style: const TextStyle(
//                                             fontSize: 25,
//                                             fontWeight: FontWeight.w700,
//                                             color: Colors.black,
//                                             fontFamily: 'Inter',
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             // Tasks Card
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.08),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       width: 52,
//                                       height: 52,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4),
//                                         child: Image.asset(
//                                           'assets/images/task_icon.png',
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         const Text(
//                                           "TASKS",
//                                           style: TextStyle(
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                             color: AppColors.darkGray,
//                                             fontFamily: 'Inter',
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           "${allTasks.length}",
//                                           style: const TextStyle(
//                                             fontSize: 25,
//                                             fontWeight: FontWeight.w700,
//                                             color: Colors.black,
//                                             fontFamily: 'Inter',
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//           ),

//           if (!isLoading)
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _StickyToggleDelegate(
//                 showMeetings: showMeetings,
//                 onToggle: (value) => setState(() => showMeetings = value),
//               ),
//             ),

//           // Content Section
//           SliverToBoxAdapter(
//             child: isLoading
//                 ? const SizedBox(
//                     height: 600,
//                     child: Center(child: LoadingAnimation(size: 180)),
//                   )
//                 : Column(
//                     children: [
//                       const SizedBox(height: 16),
//                       showMeetings
//                           ? Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                               ),
//                               child: Column(
//                                 children: [
//                                   MeetingsList(
//                                     title: "Ongoing Meetings",
//                                     meetings: ongoingMeetings,
//                                     role: 'head',
//                                   ),
//                                   MeetingsList(
//                                     title: "Upcoming Meetings",
//                                     meetings: upcomingMeetings,
//                                     role: 'head',
//                                   ),
//                                   MeetingsList(
//                                     title: "Pending Attendance",
//                                     meetings: attendancePendingMeetings,
//                                     role: 'head',
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : _buildTasksSection(),
//                       const SizedBox(height: 100), // Space for FAB
//                     ],
//                   ),
//           ),
//         ],
//       ),

//       // Floating Action Button (Dynamic based on tab)
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: showMeetings
//             ? const Color(0xFF00897B)
//             : const Color(0xFFFF9800),
//         elevation: 6,
//         onPressed: showMeetings ? openCreateMeeting : openCreateTask,
//         child: const Icon(Icons.add, color: Colors.white, size: 28),
//       ),
//     );
//   }

//   Widget _buildTasksSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: TasksList(
//         title: "All Tasks",
//         tasks: allTasks,
//         onTaskUpdated: fetchAllData,
//         onEditTask: (task) => openCreateTask(taskToEdit: task),
//       ),
//     );
//   }
// }

// // Custom delegate for sticky toggle buttons
// class _StickyToggleDelegate extends SliverPersistentHeaderDelegate {
//   final bool showMeetings;
//   final Function(bool) onToggle;

//   _StickyToggleDelegate({required this.showMeetings, required this.onToggle});

//   @override
//   double get minExtent => 70;

//   @override
//   double get maxExtent => 70;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: Colors.grey.shade50,
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         margin: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.lightGray.withOpacity(0.4),
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: InkWell(
//                 onTap: () => onToggle(true),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(
//                     color: showMeetings ? AppColors.green : Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     "Meetings",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: showMeetings ? Colors.white : AppColors.darkGray,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       fontFamily: 'Inter',
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: InkWell(
//                 onTap: () => onToggle(false),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(
//                     color: !showMeetings ? AppColors.orange : Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     "Tasks",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: !showMeetings ? Colors.white : AppColors.darkGray,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 18,
//                       fontFamily: 'Inter',
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   bool shouldRebuild(_StickyToggleDelegate oldDelegate) {
//     return showMeetings != oldDelegate.showMeetings;
//   }
// }

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
import '../widgets/tasks_list.widget.dart';
import '../core/app_colors.dart';
import '../widgets/logout_confirm.dart';
import '../widgets/loading_animation.widget.dart';
import '../services/notification_handler.dart';

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

  // Scroll controller for sticky behavior
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    NotificationHandler().initialize();
    fetchAllData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void logout() async {
    await authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignInScreen()),
    );
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
      body: RefreshIndicator(
        color: AppColors.darkTeal,
        onRefresh: fetchAllData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Fixed AppBar - Always visible at top
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkTeal,
            elevation: 4,
            toolbarHeight: 56,
            title: const Text(
              "Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 25,
                fontFamily: 'Inter',
              ),
            ),
            actions: [
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
                      // Stats Cards Row (Scrollable)
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
                                    Container(
                                      width: 52,
                                      height: 52,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
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
                    ],
                  ),
          ),

          if (!isLoading)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyToggleDelegate(
                showMeetings: showMeetings,
                onToggle: (value) => setState(() => showMeetings = value),
              ),
            ),

          // Content Section
          SliverToBoxAdapter(
            child: isLoading
                ? const SizedBox(
                    height: 600,
                    child: Center(child: LoadingAnimation(size: 180)),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 16),
                      showMeetings
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  MeetingsList(
                                    title: "Ongoing Meetings",
                                    meetings: ongoingMeetings,
                                    role: 'head',
                                    onListUpdated: fetchAllData, // ✅ Added
                                  ),
                                  MeetingsList(
                                    title: "Upcoming Meetings",
                                    meetings: upcomingMeetings,
                                    role: 'head',
                                    onListUpdated: fetchAllData, // ✅ Added
                                  ),
                                  MeetingsList(
                                    title: "Pending Attendance",
                                    meetings: attendancePendingMeetings,
                                    role: 'head',
                                    onListUpdated: fetchAllData, // ✅ Added
                                  ),
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
      ),

      // Floating Action Button (Dynamic based on tab)
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TasksList(
        title: "All Tasks",
        tasks: allTasks,
        onTaskUpdated: fetchAllData,
        onEditTask: (task) => openCreateTask(taskToEdit: task),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
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