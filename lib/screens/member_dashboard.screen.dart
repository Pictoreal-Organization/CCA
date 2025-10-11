import 'package:cca/screens/signIn.screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.screen.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import '../services/task_service.dart';
import '../widgets/meetings_list.widget.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboard();
}

class _MemberDashboard extends State<MemberDashboard> {
  final MeetingService meetingService = MeetingService();
  List ongoingMeetings = [];
  List upcomingMeetings = [];

  final TaskService taskService = TaskService();
  List memberTasks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOngoingMeetings();
    fetchUpcomingMeetings();
    fetchMemberTasks();
  }

  void fetchOngoingMeetings() async {
    try {
      final meetings = await meetingService.getOngoingMeetings();
      setState(() {
        ongoingMeetings = meetings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print(e);
    }
  }
  void fetchUpcomingMeetings() async {
    try {
      final meetings = await meetingService.getUpcomingMeetings();
      setState(() {
        upcomingMeetings = meetings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print(e);
    }
  }
  void fetchMemberTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      if (userId == null) return;

      final tasks = await taskService.getTasksByMember(userId);
      setState(() {
        memberTasks = tasks;
      });
    } catch (e) {
      print(e);
    }
  }

  final authService = AuthService();
  void logout() async {
    await authService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      // appBar: AppBar(
      //   title: Text("Member Dashboard"),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout),
      //       onPressed: logout,
      //     ),
      //   ],
      // ),
      appBar: AppBar(
          title: const Text("Head Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: "Profile",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: logout,
            ),
          ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(),)
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings,role : 'Member'),
                  MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings, role: 'Member'),
                    Text(
                      "My Tasks",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    memberTasks.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("No tasks assigned"),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: memberTasks.length,
                            itemBuilder: (context, index) {
                              final task = memberTasks[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(task['title']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (task['description'] != null)
                                        Text("Description: ${task['description']}"),
                                      Text("Status: ${task['status']}"),
                                      SizedBox(height: 8),
                                      Text("Subtasks:"),
                                      ...List.generate(task['subtasks'].length, (i) {
                                        final sub = task['subtasks'][i];
                                        final assignedList = sub['assignedTo'] as List;

                                        if (assignedList.isEmpty) {
                                          // If nobody is assigned, just show "Not assigned"
                                          return Text("- ${sub['title']} (${sub['status']}) - Not yet assigned");
                                        } else {
                                          // Otherwise, show assigned usernames
                                          final assignedNames = assignedList.map((u) => u['username']).join(", ");
                                          return Text("- ${sub['title']} (${sub['status']}) assigned to $assignedNames");
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ],
              )
          )
    ));
  }
}