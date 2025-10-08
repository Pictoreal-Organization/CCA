import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import 'create_meeting.screen.dart';
import 'create_task.screen.dart';
import 'signIn.screen.dart';
import 'attendance.screen.dart';
import '../widgets/meetings_list.widget.dart';

class HeadDashboard extends StatefulWidget {
  const HeadDashboard({super.key});

  @override
  State<HeadDashboard> createState() => _HeadDashboardState();
}

class _HeadDashboardState extends State<HeadDashboard> {
  final authService = AuthService();
  final MeetingService meetingService = MeetingService();
  // final TasksService taskService = TasksService();

  List ongoingMeetings = [];
  List upcomingMeetings = [];
  List attendancePendingMeetings = []; // attendance pending list
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  void fetchMeetings() async {
    try {
      final ongoing = await meetingService.getOngoingMeetings();
      final upcoming = await meetingService.getUpcomingMeetings();
      final pending = await meetingService.getMeetingsForAttendance();

      if (!mounted) return; // ✅ prevents setState after dispose

      setState(() {
        ongoingMeetings = ongoing;
        upcomingMeetings = upcoming;
        attendancePendingMeetings = pending;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // ✅ also here
      setState(() => isLoading = false);
      print(e);
    }
  }

  void logout() async {
    await authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  Widget buildMeetingList(String title, List meetings,
      {bool showAttendanceButton = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        meetings.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("No meetings available"),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meet = meetings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(meet['title']),
                      subtitle: Text(
                        "Starts: ${DateTime.parse(meet['dateTime']).toLocal()}\n"
                        "Duration: ${meet['duration']} mins\n"
                        "Location: ${meet['location']}",
                      ),
                      trailing: showAttendanceButton
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AttendanceScreen(meeting: meet),
                                  ),
                                );
                              },
                              child: const Text("Mark Attendance"),
                            )
                          : null,
                    ),
                  );
                },
              ),
        const SizedBox(height: 20),
      ],
    );
  }

  void openCreateMeeting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMeetingScreen(onMeetingCreated: fetchMeetings),
      ),
    );
  }
  void openCreateTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(onTaskCreated: () {
          // Optional: Refresh meetings or tasks after creation
          fetchMeetings();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Head Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings,role: 'head'),
                    MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings,role: 'head'),
                    MeetingsList(
                        title: "Meetings Pending for Attendance",
                        meetings: attendancePendingMeetings,role: 'head'),
                        
                  ],
                ),
              ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: openCreateMeeting,
        //   child: const Icon(Icons.add),
        // ),
        floatingActionButton: Stack(
          children: [
            // ➕ Create Task Button
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: "taskBtn",
                onPressed: openCreateTask,
                icon: const Icon(Icons.assignment),
                label: const Text("Task"),
              ),
            ),
            // ➕ Create Meeting Button
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: "meetingBtn",
                onPressed: openCreateMeeting,
                icon: const Icon(Icons.add),
                label: const Text("Meeting"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}