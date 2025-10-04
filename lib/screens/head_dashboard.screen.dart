import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/meeting_service.dart';
import 'create_meeting.screen.dart';
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
                    MeetingsList(title: "Ongoing Meetings", meetings: ongoingMeetings),
                    MeetingsList(title: "Upcoming Meetings", meetings: upcomingMeetings),
                    MeetingsList(
                        title: "Meetings Pending for Attendance",
                        meetings: attendancePendingMeetings),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: openCreateMeeting,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CreateMeetingScreen extends StatefulWidget {
  final VoidCallback onMeetingCreated;
  const CreateMeetingScreen({super.key, required this.onMeetingCreated});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeetingService meetingService = MeetingService();

  String title = '';
  String description = '';
  String location = '';
  String? agenda;
  int? duration;
  String? priority = 'Medium';
  DateTime? dateTime;

  bool isSubmitting = false;

  void submit() async {
    if (!_formKey.currentState!.validate() || dateTime == null) return;

    _formKey.currentState!.save();

    setState(() => isSubmitting = true);

    try {
      await meetingService.createMeeting(
        title: title,
        description: description,
        location: location,
        dateTime: dateTime!,
        agenda: agenda,
        duration: duration,
        priority: priority,
      );

      widget.onMeetingCreated(); // refresh dashboard
      Navigator.pop(context); // go back
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create meeting: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Meeting')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
                onSaved: (val) => title = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
                onSaved: (val) => description = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (val) => val!.isEmpty ? 'Enter location' : null,
                onSaved: (val) => location = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Agenda (optional)',
                ),
                onSaved: (val) => agenda = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => duration = val!.isEmpty ? 60 : int.parse(val),
              ),
              DropdownButtonFormField<String>(
                value: priority,
                items: ['Low', 'Medium', 'High', 'Urgent']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => priority = val),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        dateTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(
                  dateTime == null
                      ? 'Pick Date & Time'
                      : 'Selected: ${dateTime!.toLocal()}',
                ),
              ),
              const SizedBox(height: 20),
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submit,
                      child: const Text('Create Meeting'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
