import 'package:cca/core/app_colors.dart';
import 'package:flutter/material.dart';
import '../screens/attendance.screen.dart';

class MeetingsList extends StatelessWidget {
  final String title;
  final List meetings;
  final String role;

  const MeetingsList({
    super.key,
    required this.title,
    required this.meetings,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final showAttendanceButton =
        role == 'head' &&
        (title == "Ongoing Meetings" ||
            title == "Meetings Pending for Attendance");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
                  final dateTime = DateTime.parse(meet['dateTime']).toLocal();
                  final isOnline = meet['location'] == null;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cream5,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.cream4,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: AppColors.amber1,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  meet['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Description if available
                          if (meet['description'] != null && meet['description'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                meet['description'],
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          
                          Row(
                            children: [
                          // Date and Time
                          _buildInfoChip(
                            Icons.access_time,
                            "${dateTime.day}/${dateTime.month} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
                            AppColors.teal5,
                            AppColors.teal1,
                          ),
                          
                          //const SizedBox(height: 8),
                          
                          // Location
                          _buildInfoChip(
                            isOnline ? Icons.link : Icons.location_on,
                            isOnline 
                                ? (meet['onlineLink'] ?? 'Online Meeting')
                                : meet['location'],
                            AppColors.mint5,
                            AppColors.teal1,
                          ),
                            ]
                          ),
                          
                          // Attendance button if applicable
                          //if (showAttendanceButton) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AttendanceScreen(meeting: meet),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal2,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Mark Attendance",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          //],
                        ],
                      ),
                    ),
                  );
                },
              ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}