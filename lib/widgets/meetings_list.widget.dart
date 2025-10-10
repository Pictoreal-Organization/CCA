import 'package:flutter/material.dart';
import '../screens/attendance.screen.dart';

class MeetingsList extends StatelessWidget {
  final String title;
  final List meetings;
  final String role;

  const MeetingsList({super.key, required this.title, required this.meetings,required this.role});

  @override
  Widget build(BuildContext context) {
    final showAttendanceButton =
        role == 'head' && (title == "Ongoing Meetings" || title == "Meetings Pending for Attendance");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
                        "Type: ${meet['location'] != null ? 'Offline' : 'Online'}\n"
                        "Location: ${meet['location'] ?? meet['onlineLink'] ?? 'N/A'}",
                      ),

                      trailing: showAttendanceButton
                          ? ElevatedButton(
                              onPressed: () {
                                // Navigate directly to AttendanceScreen from here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceScreen(meeting: meet),
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
}
