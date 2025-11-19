// import 'package:cca/core/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'profile.screen.dart';
// import '../services/auth_service.dart';
// import '../services/meeting_service.dart';
// import '../services/task_service.dart';
// import '../widgets/meetings_list.widget.dart';
// import 'signIn.screen.dart';
// import '../widgets/logout_confirm.dart';
// import '../widgets/loading_animation.widget.dart';

// class MemberDashboard extends StatefulWidget {
//   const MemberDashboard({super.key});
//   @override
//   State<MemberDashboard> createState() => _MemberDashboardState();
// }

// class _MemberDashboardState extends State<MemberDashboard> {
//   final MeetingService meetingService = MeetingService();
//   final TaskService taskService = TaskService();
//   final AuthService authService = AuthService();

//   List ongoingMeetings = [];
//   List upcomingMeetings = [];
//   List memberTasks = [];
//   bool isLoading = true;
//   bool showMeetings = true; // toggle between meetings and tasks

//   @override
//   void initState() {
//     super.initState();
//     fetchAllData();
//   }

//   Future<void> fetchAllData() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString("userId");
//       if (userId == null) throw Exception("User ID not found.");

//       final data = await Future.wait([
//         meetingService.getOngoingMeetings(),
//         meetingService.getUpcomingMeetings(),
//         taskService.getTasksByMember(userId),
//       ]);

//       if (!mounted) return;
//       setState(() {
//         ongoingMeetings = data[0] as List;
//         upcomingMeetings = data[1] as List;
//         memberTasks = data[2] as List;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load data: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   void _handleStatusChange(String newStatus, dynamic task, dynamic subtask) async {
//     if (newStatus == 'Completed') {
//       String? completionNote = await _showCompletionNoteDialog();
//       if (completionNote != null && completionNote.isNotEmpty) {
//         _updateSubtaskApi(newStatus, task, subtask, description: completionNote);
//       }
//     } else {
//       _updateSubtaskApi(newStatus, task, subtask);
//     }
//   }

//   void _updateSubtaskApi(String status, dynamic task, dynamic subtask, {String? description}) async {
//     try {
//       final data = {'status': status};
//       if (description != null) data['description'] = description;

//       await taskService.updateSubtask(
//         taskId: task['_id'],
//         subtaskId: subtask['_id'],
//         data: data,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${subtask['title']} status updated!'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//       fetchAllData();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }

//   Future<String?> _showCompletionNoteDialog() {
//     final controller = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Complete Subtask'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'Add a completion note*',
//             hintText: 'Describe what you have completed.',
//             border: OutlineInputBorder(),
//           ),
//           autofocus: true,
//           maxLines: 3,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, null),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.trim().isNotEmpty) {
//                 Navigator.pop(context, controller.text);
//               }
//             },
//             child: const Text('Mark as Completed'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       body: isLoading
//           ? const Center(child: LoadingAnimation(size: 180))
//           : RefreshIndicator(
//               onRefresh: fetchAllData,
//               child: CustomScrollView(
//                 slivers: [
//                   SliverAppBar(
//                     floating: true,
//                     pinned: true,
//                     snap: false,
//                     elevation: 2,
//                     backgroundColor: AppColors.darkTeal,
//                     title: const Text('Member Dashboard', style: TextStyle(color: Colors.white)),
//                     actions: [
//                       IconButton(
//                         icon: const Icon(Icons.person, color: Colors.white),
//                         tooltip: "Profile",
//                         onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.logout, color: Colors.white),
//                         tooltip: "Logout",
//                         onPressed: () => showLogoutDialog(context),
//                       ),
//                     ],
//                   ),

//                   // Quick stats section
//                   SliverToBoxAdapter(
//                         child : Padding(
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
//                                     // Meetings Icon
//                                     Container(
//                                       width: 52,
//                                       height: 52,
//                                       // decoration: BoxDecoration(
//                                       //   color: const Color(0xFFE3F2FD),
//                                       //   borderRadius: BorderRadius.circular(8),
//                                       // ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4),
//                                         child: Image.asset(
//                                           'assets/images/meetings_icon.png',
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     // Text and Number
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
//                                             letterSpacing: 0,
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
//                                     // Tasks Icon
//                                     Container(
//                                       width: 52,
//                                       height: 52,
//                                       // decoration: BoxDecoration(
//                                       //   color: const Color(0xFFFFF3E0),
//                                       //   borderRadius: BorderRadius.circular(8),
//                                       // ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4),
//                                         child: Image.asset(
//                                           'assets/images/task_icon.png',
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     // Text and Number
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
//                                             letterSpacing: 0,
//                                             fontFamily: 'Inter',
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           "${memberTasks.length}",
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
//                   ),
//                   // Toggle buttons for switching
//                   SliverToBoxAdapter(
//                     child : Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8 , vertical: 6),
//                         margin: const EdgeInsets.symmetric(horizontal: 14),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                     BoxShadow(
//                       color: AppColors.lightGray.withOpacity(0.4),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: InkWell(
//                                 onTap: () =>
//                                     setState(() => showMeetings = true),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 14,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: showMeetings
//                                         ? AppColors.green
//                                         : Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     "Meetings",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: showMeetings
//                                           ? Colors.white
//                                           : AppColors.darkGray,
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
//                                 onTap: () =>
//                                     setState(() => showMeetings = false),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 14,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: !showMeetings
//                                         ? AppColors.orange
//                                         : Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     "Tasks",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: !showMeetings
//                                           ? Colors.white
//                                           : AppColors.darkGray,
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
//                     ),
//                   ),

//                   const SliverToBoxAdapter(child: SizedBox(height: 16)),

//                   // Meetings section
//                   if (showMeetings)
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings, role: 'Member'),
//                             MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings, role: 'Member'),
//                           ],
//                         ),
//                       ),
//                     ),

//                   // Tasks section
//                   if (!showMeetings)
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 12),
//                             const Text("My Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 8),
//                             memberTasks.isEmpty
//                                 ? const Center(child: Padding(
//                                     padding: EdgeInsets.all(20),
//                                     child: Text("You have no tasks assigned."),
//                                   ))
//                                 : ListView.builder(
//                                     shrinkWrap: true,
//                                     physics: const NeverScrollableScrollPhysics(),
//                                     itemCount: memberTasks.length,
//                                     itemBuilder: (context, index) {
//                                       final task = memberTasks[index];
//                                       final subtasks = task['subtasks'] as List;
//                                       return Card(
//                                         margin: const EdgeInsets.symmetric(vertical: 8),
//                                         elevation: 2,
//                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(16.0),
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(task['title'],
//                                                   style: const TextStyle(
//                                                       fontSize: 18,
//                                                       fontWeight: FontWeight.bold,
//                                                       color: Colors.black)),
//                                               //const Divider(),
//                                               ...subtasks.map((sub) {
//                                                 final currentStatus = sub['status'];
//                                                 return Padding(
//                                                   padding: const EdgeInsets.only(top: 8.0),
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       Text(sub['title'],
//                                                           style: const TextStyle(
//                                                               fontWeight: FontWeight.w600,
//                                                               fontSize: 16)),
//                                                       const SizedBox(height: 4),
//                                                       Text(
//                                                         sub['description'] ?? 'No description provided.',
//                                                         style: const TextStyle(color: Colors.black54),
//                                                       ),
//                                                       const SizedBox(height: 12),
//                                                       if (currentStatus == 'Completed')
//                                                         Container(
//                                                           padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//                                                           decoration: BoxDecoration(
//                                                             color: AppColors.darkTeal,
//                                                             borderRadius: BorderRadius.circular(20),
//                                                           ),
//                                                           child: Row(
//                                                             mainAxisSize: MainAxisSize.min,
//                                                             children: [
//                                                               const Icon(Icons.check_circle,
//                                                                   color: Colors.white),
//                                                               const SizedBox(width: 6),
//                                                               Text("Completed",
//                                                                   style: TextStyle(
//                                                                       color: Colors.white,
//                                                                       fontWeight: FontWeight.bold)),
//                                                             ],
//                                                           ),
//                                                         )
//                                                       else
//                                                         Row(
//                                                           children: [
//                                                             Expanded(
//                                                               child: ElevatedButton.icon(
//                                                                 icon: const Icon(Icons.pending),
//                                                                 label:Text("Pending", style: TextStyle(color: Colors.white)),
//                                                                 style: ElevatedButton.styleFrom(
//                                                                   backgroundColor: AppColors.orange,
//                                                                   shape: RoundedRectangleBorder(
//                                                                     borderRadius: BorderRadius.circular(12),
//                                                                   ),
//                                                                 ),
//                                                                 onPressed: () =>
//                                                                     _handleStatusChange('Pending', task, sub),
//                                                               ),
                                                              
//                                                             ),
//                                                             const SizedBox(width: 8),
//                                                             Expanded(
//                                                               child: ElevatedButton.icon(
//                                                                 icon: const Icon(Icons.done_all),
//                                                                 label: const Text("Completed" ,style: TextStyle(color: Colors.white)),
//                                                                 style: ElevatedButton.styleFrom(
//                                                                   backgroundColor: AppColors.green,
//                                                                   shape: RoundedRectangleBorder(
//                                                                     borderRadius: BorderRadius.circular(12),
//                                                                   ),
//                                                                 ),
//                                                                 onPressed: () =>
//                                                                     _handleStatusChange('Completed', task, sub),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                     ],
//                                                   ),
//                                                 );
//                                               }).toList(),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildStatCard(String title, String count, IconData icon) {
//     return Expanded(
//       child: Container(
//         height: 100,
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         decoration: BoxDecoration(
//           color: Colors.indigo.shade100,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.indigo.shade800, size: 28),
//             const SizedBox(height: 6),
//             Text(count,
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildToggleButton(String title, bool isActive, bool value) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => showMeetings = value),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: isActive ? Colors.indigo.shade600 : Colors.transparent,
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: Text(
//             title,
//             style: TextStyle(
//               color: isActive ? Colors.white : Colors.black87,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




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
    fetchAllData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Fixed AppBar
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkTeal,
            elevation: 4,
            toolbarHeight: 56,
            title: const Text(
              'Member Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 25,
                fontFamily: 'Inter',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white, size: 30),
                tooltip: "Profile",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 26),
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
                onToggle: (value) => setState(() => showMeetings = value),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MeetingsList(
                                      title: "Ongoing Meetings",
                                      meetings: ongoingMeetings,
                                      role: 'Member'),
                                  MeetingsList(
                                      title: "Upcoming Meetings",
                                      meetings: upcomingMeetings,
                                      role: 'Member'),
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}

// Custom delegate for sticky toggle buttons
class _StickyToggleDelegate extends SliverPersistentHeaderDelegate {
  final bool showMeetings;
  final Function(bool) onToggle;

  _StickyToggleDelegate({
    required this.showMeetings,
    required this.onToggle,
  });

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: showMeetings ? AppColors.green : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Meetings",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          showMeetings ? Colors.white : AppColors.darkGray,
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: !showMeetings ? AppColors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Tasks",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          !showMeetings ? Colors.white : AppColors.darkGray,
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