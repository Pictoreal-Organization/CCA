import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/attendance.screen.dart';
import '../core/app_colors.dart';
import 'package:intl/intl.dart';
import '../services/meeting_service.dart';
import '../screens/create_meeting.screen.dart';

class MeetingsList extends StatelessWidget {
  final String title;
  final List meetings;
  final String role;
  final VoidCallback? onListUpdated;

  const MeetingsList({
    super.key,
    required this.title,
    required this.meetings,
    required this.role,
    this.onListUpdated,
  });

  // ❌ DELETED: _fetchControlStatus()
  // ❌ DELETED: _isLoading state
  // ❌ DELETED: initState()

  Color _getCardBorderColor() {
    if (title.contains("Ongoing")) return AppColors.darkTeal;
    if (title.contains("Upcoming")) return AppColors.green;
    if (title.contains("Pending")) return AppColors.darkOrange;
    return AppColors.lightGray;
  }

  void _deleteMeeting(BuildContext context, String meetingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Meeting?"),
        content: const Text(
          "This will notify all members and cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MeetingService().deleteMeeting(meetingId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Meeting cancelled")));
          onListUpdated?.call();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  void _editMeeting(BuildContext context, Map meeting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMeetingScreen(
          onMeetingCreated: () {
            onListUpdated?.call();
          },
          meetingToEdit: Map<String, dynamic>.from(meeting),
        ),
      ),
    );
  }

  String _formatTimeRange(String startIso, String endIso) {
    try {
      final start = DateTime.parse(startIso).toLocal();
      final end = DateTime.parse(endIso).toLocal();
      final formatter = DateFormat('h:mm a');
      return "${formatter.format(start)} - ${formatter.format(end)}";
    } catch (e) {
      return "Time N/A";
    }
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      return DateFormat('d MMM yyyy').format(date);
    } catch (e) {
      return "";
    }
  }

  String _getTeamNames(dynamic teamField) {
    if (teamField == null || teamField is! List || teamField.isEmpty) {
      return "General";
    }

    try {
      List<String> names = teamField
          .where((t) => t != null && t is Map && t['name'] != null)
          .map<String>((t) {
            String name = t['name'].toString().trim();

            // 🔥 Remove trailing “Team”
            if (name.toLowerCase().endsWith(" team")) {
              name = name.substring(0, name.length - 5).trim();
            }

            // If name becomes empty → ignore
            return name.isEmpty ? "General" : name;
          })
          .toList();

      // Remove duplicates & "General" if real names exist
      names = names.toSet().toList();

      // If all processed names became "General"
      if (names.every((n) => n == "General")) return "General";

      return names.join(", ");
    } catch (e) {
      return "General";
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMeetings = title.contains("Pending")
        ? meetings.where((m) => m['canControl'] == true).toList()
        : meetings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.replaceAll("Meetings", "").trim(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "${filteredMeetings.length} meetings",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.lightGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (filteredMeetings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "No meetings available",
              style: TextStyle(color: AppColors.lightGray),
            ),
          )
        // ❌ DELETED: "else if (_isLoading)" check
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMeetings.length,
            itemBuilder: (context, index) {
              final meet = filteredMeetings[index];

              // ✅ READ DIRECTLY from the meeting object (Fast!)
              final hasControl = meet['canControl'] ?? false;

              final isOngoing = title.contains("Ongoing");
              final isUpcoming = title.contains("Upcoming");
              final isPending = title.contains("Pending");
              final isOnline =
                  meet['location'] == "" || meet['location'] == null;

              final showEditDelete = hasControl && (isUpcoming || isOngoing);
              final showMarkAttendance = hasControl && (isOngoing || isPending);

              final organizerName =
                  meet['organizer'] != null && meet['organizer'] is Map
                  ? meet['organizer']['name']
                  : "Unknown";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _getCardBorderColor(),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightGray.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TITLE & ACTIONS ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                meet['title'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isOngoing && isOnline)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(70, 31),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final raw = meet['onlineLink'];
                                      final link = raw.startsWith("http")
                                          ? raw
                                          : "https://$raw";
                                      if (link != null && link.isNotEmpty) {
                                        final uri = Uri.parse(link);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Could not open link",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      "Join",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),

                                if (showEditDelete) ...[
                                  if (isOngoing && isOnline)
                                    const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _editMeeting(context, meet),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkGray.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () =>
                                        _deleteMeeting(context, meet['_id']),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // --- DATE, TIME & DURATION ---
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppColors.darkGray,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(meet['dateTime']),
                              style: const TextStyle(
                                color: AppColors.darkGray,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.access_time_filled_rounded,
                              size: 16,
                              color: AppColors.darkGray,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                meet['endTime'] != null
                                    ? _formatTimeRange(
                                        meet['dateTime'],
                                        meet['endTime'],
                                      )
                                    : "Time N/A",
                                style: const TextStyle(
                                  color: AppColors.darkGray,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // --- DURATION & LOCATION ---
                        // Row(
                        //   children: [
                        //     const Icon(Icons.timer_outlined, size: 16, color: AppColors.darkGray),
                        //     const SizedBox(width: 6),
                        //     Text(
                        //       "${meet['duration'] ?? 0} mins",
                        //       style: const TextStyle(color: AppColors.darkGray, fontSize: 13, fontWeight: FontWeight.w500),
                        //     ),
                        //     const SizedBox(width: 12),
                        //     Icon(isOnline ? Icons.link : Icons.location_on, size: 16, color: AppColors.darkGray),
                        //     const SizedBox(width: 6),
                        //     Expanded(
                        //       child: Text(
                        //         isOnline ? "Online Meeting" : (meet['location'] ?? "No Location"),
                        //         maxLines: 1,
                        //         overflow: TextOverflow.ellipsis,
                        //         style: const TextStyle(color: AppColors.darkGray, fontSize: 13, fontWeight: FontWeight.w500),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: AppColors.darkGray,
                            ),

                            Text(
                              "${meet['duration'] ?? 0} mins",
                              style: const TextStyle(
                                color: AppColors.darkGray,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Icon(
                              isOnline ? Icons.link : Icons.location_on,
                              size: 16,
                              color: AppColors.darkGray,
                            ),

                            Text(
                              isOnline
                                  ? "Online Meeting"
                                  : (meet['location'] ?? "No Location"),
                              style: const TextStyle(
                                color: AppColors.darkGray,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // ⭐ TEAM BADGE — NOW WRAPS CLEANLY
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                _getTeamNames(meet['team']),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkOrange,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // --- ORGANIZER ---
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: AppColors.lightGray,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Created by: $organizerName",
                                style: const TextStyle(
                                  color: AppColors.lightGray,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // --- ATTENDANCE BUTTON ---
                        if (showMarkAttendance) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getCardBorderColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}
