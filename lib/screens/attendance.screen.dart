import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../core/app_colors.dart';

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
      backgroundColor: AppColors.darkTeal, // solid color for AppBar
      title: Text(
        "Mark Attendance - ${widget.meeting['title']}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      elevation: 6,
      shadowColor: AppColors.green.withAlpha(60),
      iconTheme: IconThemeData(
    color: Colors.white, // sets arrow (and all AppBar icons) to white
  ),
    ),

    // Floating submit button with palette color and white icon
    floatingActionButton: FloatingActionButton.extended(
      onPressed: isSubmitting ? null : submitAttendance,
      label: isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
      icon: isSubmitting
          ? null
          : const Icon(Icons.check, size: 24, color: Colors.white),
      backgroundColor: AppColors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    body: isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Container(
            color: Colors.white, // solid white background
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  // Search bar, glass-like effect, colored border and shadow (palette-based)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.green,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.13),
                          blurRadius: 12,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search by name, Roll no, or division',
                        labelStyle: TextStyle(
                          color: AppColors.darkTeal,
                          fontWeight: FontWeight.bold,
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppColors.green),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                      onChanged: filterSearch,
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // List of colourful member cards
                  Expanded(
  child: filteredAttendanceList.isEmpty
      ? const Center(
          child: Text('No members found',
            style: TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        )
      : ListView.builder(
          itemCount: filteredAttendanceList.length,
          itemBuilder: (context, index) {
            final record = filteredAttendanceList[index];
            final member = record['member'];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.08), // slightly darker for realism
      blurRadius: 20,                        // softer shadow edges
      spreadRadius: 1,                       // small spread for smooth glow
      offset: const Offset(0, 4),            // subtle bottom shadow
    ),
  ],
),

              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.darkTeal,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                  radius: 24,
                ),
                title: Text(
                  "${member['name']} - ${member['year']} ${member['division']}",
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "rollNo: ${member['rollNo']}",
                  style: TextStyle(
                    color: AppColors.lightGray,
                  ),
                ),
                trailing: Checkbox(
  value: record['status'] == 'present',
  onChanged: (_) => toggleAttendance(member['_id']),
  activeColor: AppColors.orange,
)




// Checkbox(
//   value: isPresent,
//   onChanged: (value) {
//     setState(() {
//       isPresent = value!;
//     });
//   },
// )


              ),
            );
          },
        ),

                  ),
                ],
              ),
            ),
          ),
  );
}
}