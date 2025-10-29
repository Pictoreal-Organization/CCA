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
          title == "Pending Attendance");

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Enhanced section header
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.teal1, AppColors.teal2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal1.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.event_note,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${meetings.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      meetings.isEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cream2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.mint3, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 56,
                      color: AppColors.teal3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No meetings available",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal2,
                      ),
                    ),
                  ],
                ),
              ),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, AppColors.cream3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.charcoal4.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.mint4,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with enhanced icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.amber1, AppColors.amber2],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.amber1.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                meet['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal1,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Description if available
                        if (meet['description'] != null && meet['description'].toString().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cream4,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.cream3,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 18,
                                  color: AppColors.teal2,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    meet['description'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.charcoal2,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Date/Time and Location chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildInfoChip(
                              Icons.access_time,
                              "${dateTime.day}/${dateTime.month} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
                              AppColors.teal5,
                              AppColors.teal1,
                            ),
                            _buildInfoChip(
                              isOnline ? Icons.link : Icons.location_on,
                              isOnline 
                                  ? (meet['onlineLink'] ?? 'Online Meeting')
                                  : meet['location'],
                              AppColors.mint5,
                              AppColors.teal1,
                            ),
                          ],
                        ),
                        
                        // Attendance button
                        
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.teal2, AppColors.teal3],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.teal1.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
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
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.how_to_reg,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Mark Attendance",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
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

Widget _buildInfoChip(IconData icon, String text, Color bgColor, Color iconColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: iconColor.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: bgColor.withOpacity(0.5),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
}