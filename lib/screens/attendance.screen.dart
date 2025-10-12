// import 'package:flutter/material.dart';
// import '../services/attendance_service.dart';

// class AttendanceScreen extends StatefulWidget {
//   final Map meeting;
//   const AttendanceScreen({super.key, required this.meeting});

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   final AttendanceService attendanceService = AttendanceService();
//   List attendanceList = [];
//   bool isLoading = true;
//   bool isSubmitting = false; // New state for submission loading

//   @override
//   void initState() {
//     super.initState();
//     fetchAttendance();
//   }

//   void fetchAttendance() async {
//     // This function remains the same
//     try {
//       final list = await attendanceService.getAttendanceForMeeting(widget.meeting['_id']);
//       setState(() {
//         attendanceList = list;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       // It's good practice to show an error to the user
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load attendance: $e')),
//       );
//     }
//   }

//   // MODIFIED: This function now only changes the state locally
//   void toggleAttendance(String memberId) {
//     setState(() {
//       final recordIndex = attendanceList.indexWhere(
//         (record) => record['member']['_id'] == memberId,
//       );

//       if (recordIndex != -1) {
//         final currentStatus = attendanceList[recordIndex]['status'];
//         // Update the status in the local list
//         attendanceList[recordIndex]['status'] =
//             currentStatus == "present" ? "absent" : "present";
//       }
//     });
//   }

//   // NEW: This function sends the list of present members to the backend
//   void submitAttendance() async {
//     setState(() => isSubmitting = true);

//     try {
//       // 1. Filter the list to get only members marked "present"
//       final List<String> presentMemberIds = attendanceList
//           .where((record) => record['status'] == 'present')
//           .map<String>((record) => record['member']['_id'] as String)
//           .toList();

//       // 2. Call a new service method to submit this array
//       // NOTE: You will need to create this method in your AttendanceService
//       // and a corresponding endpoint on your backend.
//       await attendanceService.submitBulkAttendance(
//         widget.meeting['_id'],
//         presentMemberIds,
//       );

//       // 3. Show a success message and navigate back
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance submitted successfully!')),
//       );
//       Navigator.pop(context);

//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting attendance: $e')),
//       );
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Mark Attendance - ${widget.meeting['title']}")),
//       // NEW: Added a FloatingActionButton for submitting
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: isSubmitting ? null : submitAttendance,
//         label: isSubmitting
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : const Text('Submit'),
//         icon: isSubmitting ? null : const Icon(Icons.check),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: attendanceList.length,
//               itemBuilder: (context, index) {
//                 final record = attendanceList[index];
//                 final member = record['member'];
//                 return Card(
//                   child: ListTile(
//                     title: Text("${member['name']} (${member['rollNo']})"),
//                     subtitle: Text("Email: ${member['email']}"),
//                     // I uncommented your title/subtitle to make it look better
//                     // title: Text(member['_id']), 
//                     trailing: Switch(
//                       value: record['status'] == "present",
//                       onChanged: (newValue) {
//                         // MODIFIED: The switch now calls the local toggle function
//                         toggleAttendance(member['_id']);
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

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
