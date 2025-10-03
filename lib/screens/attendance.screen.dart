import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  final Map meeting;
  const AttendanceScreen({super.key, required this.meeting});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService attendanceService = AttendanceService();
  List attendanceList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  void fetchAttendance() async {
    try {
      final list = await attendanceService.getAttendanceForMeeting(widget.meeting['_id']);
      // list.sort((a, b) => a['member']['name'].compareTo(b['member']['name'])); // sort by name
      setState(() {
        attendanceList = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print(e);
    }
  }

  void toggleAttendance(String memberId, String currentStatus) async {
    final newStatus = currentStatus == "present" ? "absent" : "present";
    await attendanceService.markAttendance(widget.meeting['_id'], memberId, newStatus);
    fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mark Attendance - ${widget.meeting['title']}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final record = attendanceList[index];
                final member = record['member'];
                return Card(
                  child: ListTile(
                    // title: Text("${member['name']} (${member['rollNo']})"),
                    // subtitle: Text("Email: ${member['email']}"),
                    title: Text(member['_id']),
                    trailing: Switch(
                      value: record['status'] == "present",
                      onChanged: (_) {
                        toggleAttendance(member['_id'], record['status']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
