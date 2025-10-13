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
  List<Map<String, dynamic>> attendanceList = [];
  List<Map<String, dynamic>> filteredAttendanceList = [];
  bool isLoading = true;
  bool isSubmitting = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  void fetchAttendance() async {
    try {
      final list =
          await attendanceService.getAttendanceForMeeting(widget.meeting['_id']);
      setState(() {
        attendanceList = List<Map<String, dynamic>>.from(list);
        filteredAttendanceList = List.from(attendanceList);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    }
  }

  void toggleAttendance(String memberId) {
    setState(() {
      final idx =
          attendanceList.indexWhere((record) => record['member']['_id'] == memberId);
      if (idx != -1) {
        attendanceList[idx]['status'] =
            attendanceList[idx]['status'] == 'present' ? 'absent' : 'present';
      }

      // Update filtered list too
      final fIdx = filteredAttendanceList
          .indexWhere((record) => record['member']['_id'] == memberId);
      if (fIdx != -1) {
        filteredAttendanceList[fIdx]['status'] = attendanceList[idx]['status'];
      }
    });
  }

  void submitAttendance() async {
    setState(() => isSubmitting = true);

    try {
      final presentMemberIds = attendanceList
          .where((record) => record['status'] == 'present')
          .map<String>((record) => record['member']['_id'] as String)
          .toList();

      await attendanceService.submitBulkAttendance(
        widget.meeting['_id'],
        presentMemberIds,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void filterSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredAttendanceList = attendanceList.where((record) {
        final member = record['member'];
        final text =
            "${member['name']} ${member['year']} ${member['division']}".toLowerCase();
        return text.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mark Attendance - ${widget.meeting['title']}"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSubmitting ? null : submitAttendance,
        label: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Text('Submit'),
        icon: isSubmitting ? null : const Icon(Icons.check),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // 🔹 Search bar
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by name, year, or division',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onChanged: filterSearch,
                  ),
                  const SizedBox(height: 12),
                  // 🔹 List of filtered members
                  Expanded(
                    child: filteredAttendanceList.isEmpty
                        ? const Center(child: Text('No members found'))
                        : ListView.builder(
                            itemCount: filteredAttendanceList.length,
                            itemBuilder: (context, index) {
                              final record = filteredAttendanceList[index];
                              final member = record['member'];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                      "${member['name']} - ${member['year']} ${member['division']}"),
                                  subtitle: Text("Email: ${member['email']}"),
                                  trailing: Switch(
                                    value: record['status'] == 'present',
                                    onChanged: (_) =>
                                        toggleAttendance(member['_id']),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
