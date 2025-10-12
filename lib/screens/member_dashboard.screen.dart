// import 'package:cca/screens/signIn.screen.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'profile.screen.dart';
// import '../services/auth_service.dart';
// import '../services/meeting_service.dart';
// import '../services/task_service.dart';
// import '../widgets/meetings_list.widget.dart';

// class MemberDashboard extends StatefulWidget {
//   const MemberDashboard({super.key});

//   @override
//   State<MemberDashboard> createState() => _MemberDashboard();
// }

// class _MemberDashboard extends State<MemberDashboard> {
//   final MeetingService meetingService = MeetingService();
//   List ongoingMeetings = [];
//   List upcomingMeetings = [];

//   final TaskService taskService = TaskService();
//   List memberTasks = [];

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchOngoingMeetings();
//     fetchUpcomingMeetings();
//     fetchMemberTasks();
//   }

//   void fetchOngoingMeetings() async {
//     try {
//       final meetings = await meetingService.getOngoingMeetings();
//       setState(() {
//         ongoingMeetings = meetings;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       print(e);
//     }
//   }
//   void fetchUpcomingMeetings() async {
//     try {
//       final meetings = await meetingService.getUpcomingMeetings();
//       setState(() {
//         upcomingMeetings = meetings;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       print(e);
//     }
//   }
//   void fetchMemberTasks() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString("userId");
//       if (userId == null) return;

//       final tasks = await taskService.getTasksByMember(userId);
//       setState(() {
//         memberTasks = tasks;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   final authService = AuthService();
//   void logout() async {
//     await authService.logout();
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(child: Scaffold(
//       // appBar: AppBar(
//       //   title: Text("Member Dashboard"),
//       //   actions: [
//       //     IconButton(
//       //       icon: Icon(Icons.logout),
//       //       onPressed: logout,
//       //     ),
//       //   ],
//       // ),
//       appBar: AppBar(
//           title: const Text("Member Dashboard"),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.person),
//               tooltip: "Profile",
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const ProfileScreen()),
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.logout),
//               tooltip: "Logout",
//               onPressed: logout,
//             ),
//           ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator(),)
//           : SingleChildScrollView(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings,role : 'Member'),
//                   MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings, role: 'Member'),
//                     Text(
//                       "My Tasks",
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     memberTasks.isEmpty
//                         ? Padding(
//                             padding: EdgeInsets.symmetric(vertical: 8),
//                             child: Text("No tasks assigned"),
//                           )
//                         : ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: memberTasks.length,
//                             itemBuilder: (context, index) {
//                               final task = memberTasks[index];
//                               return Card(
//                                 margin: EdgeInsets.symmetric(vertical: 8),
//                                 child: ListTile(
//                                   title: Text(task['title']),
//                                   subtitle: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       if (task['description'] != null)
//                                         Text("Description: ${task['description']}"),
//                                       Text("Status: ${task['status']}"),
//                                       SizedBox(height: 8),
//                                       Text("Subtasks:"),
//                                       ...List.generate(task['subtasks'].length, (i) {
//                                         final sub = task['subtasks'][i];
//                                         final assignedList = sub['assignedTo'] as List;

//                                         if (assignedList.isEmpty) {
//                                           // If nobody is assigned, just show "Not assigned"
//                                           return Text("- ${sub['title']} (${sub['status']}) - Not yet assigned");
//                                         } else {
//                                           // Otherwise, show assigned usernames
//                                           final assignedNames = assignedList.map((u) => u['username']).join(", ");
//                                           return Text("- ${sub['title']} (${sub['status']}) assigned to $assignedNames");
//                                         }
//                                       }),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                 ],
//               )
//           )
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.screen.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart';
import '../widgets/meetings_list.widget.dart';
import 'signIn.screen.dart';

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

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  // Fetches all data needed for the member dashboard
  Future<void> fetchAllData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId == null) {
        throw Exception("User ID not found. Please log in again.");
      }

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

  void logout() async {
    await authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  // Shows a dialog to update a subtask's status and description
  void _showUpdateSubtaskDialog(dynamic task, dynamic subtask) async {
    final descriptionController = TextEditingController(text: subtask['description']);
    String currentStatus = subtask['status'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(subtask['title']),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: currentStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Pending', 'In Progress', 'Completed']
                          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => currentStatus = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await taskService.updateSubtask(
                        taskId: task['_id'],
                        subtaskId: subtask['_id'],
                        data: {
                          'status': currentStatus,
                          'description': descriptionController.text,
                        },
                      );
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Subtask updated!')));
                      fetchAllData(); // Refresh the list
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Dashboard"),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings, role: 'Member'),
                    MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings, role: 'Member'),
                    const SizedBox(height: 24),
                    const Text("My Tasks", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    memberTasks.isEmpty
                        ? const Center(child: Text("You have no tasks assigned."))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: memberTasks.length,
                            itemBuilder: (context, index) {
                              final task = memberTasks[index];
                              final subtasks = task['subtasks'] as List;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task['title'],
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const Divider(height: 20),
                                      ...subtasks.map((sub) {
                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(sub['title']),
                                          subtitle: Text("Status: ${sub['status']}"),
                                          trailing: IconButton(
                                            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                                            tooltip: "Update Subtask",
                                            onPressed: () => _showUpdateSubtaskDialog(task, sub),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}