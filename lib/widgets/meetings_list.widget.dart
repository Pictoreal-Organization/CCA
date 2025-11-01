import 'package:flutter/material.dart';
import '../screens/attendance.screen.dart';
import '../core/app_colors.dart';

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

  Color _getCardBorderColor() {
    if (title.contains("Ongoing")) return AppColors.green;
    if (title.contains("Upcoming")) return AppColors.lightGray;
    if (title.contains("Pending")) return AppColors.orange;
    return AppColors.lightGray;
  }

  Color _getButtonColor() {
    if (title.contains("Pending")) return AppColors.orange;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final showAttendanceButton = role == 'head' &&
        (title == "Ongoing Meetings" ||
            title == "Meetings Pending for Attendance");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.replaceAll("Meetings", "").trim(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTeal,
              ),
            ),
            Text(
              "${meetings.length} meetings",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // If no meetings
        if (meetings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "No meetings available",
              style: TextStyle(color: AppColors.lightGray),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meet = meetings[index];
              final isOngoing = title.contains("Ongoing");
              final isPending = title.contains("Pending");

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _getCardBorderColor(), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightGray.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        meet['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Date & time
                      Row(
                        children: const [
                          Icon(Icons.access_time,
                              size: 16, color: AppColors.green),
                          SizedBox(width: 6),
                          Text(
                            "Today, 4:00 pm",
                            style: TextStyle(
                              color: AppColors.lightGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Meeting type
                      Row(
                        children: const [
                          Icon(Icons.link, size: 16, color: AppColors.green),
                          SizedBox(width: 6),
                          Text(
                            "Online Meeting",
                            style: TextStyle(
                              color: AppColors.lightGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Buttons
                      if (isOngoing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(70, 34),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Join",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(120, 34),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AttendanceScreen(meeting: meet),
                                  ),
                                );
                              },
                              child: const Text(
                                "Mark Attendance",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      else if (isPending)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size.fromHeight(34),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AttendanceScreen(meeting: meet),
                              ),
                            );
                          },
                          child: const Text(
                            "Mark Attendance",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
}
