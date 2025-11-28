// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../screens/attendance.screen.dart';
// import '../core/app_colors.dart';
// import 'package:intl/intl.dart';
// import '../services/meeting_service.dart';
// import '../screens/create_meeting.screen.dart'; // Import this!

// class MeetingsList extends StatelessWidget {
//   final String title;
//   final List meetings;
//   final String role;
//   final VoidCallback? onListUpdated;

//   const MeetingsList({
//     super.key,
//     required this.title,
//     required this.meetings,
//     required this.role,
//     this.onListUpdated,
//   });

//   Color _getCardBorderColor() {
//     if (title.contains("Ongoing")) return AppColors.darkTeal;
//     if (title.contains("Upcoming")) return AppColors.green;
//     if (title.contains("Pending")) return AppColors.darkOrange;
//     return AppColors.lightGray;
//   }

//   void _deleteMeeting(BuildContext context, String meetingId) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Cancel Meeting?"),
//         content: const Text("This will notify all members and cannot be undone."),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text("Yes, Delete"),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await MeetingService().deleteMeeting(meetingId);
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Meeting cancelled")));
//           onListUpdated?.call();
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//         }
//       }
//     }
//   }

//   // ✅ Updated Edit Logic: Opens Screen
//   void _editMeeting(BuildContext context, Map meeting) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => CreateMeetingScreen(
//           onMeetingCreated: () {
//             // We use the existing callback to refresh the list when coming back
//             onListUpdated?.call();
//           },
//           meetingToEdit: Map<String, dynamic>.from(meeting),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title.replaceAll("Meetings", "").trim(),
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
//             ),
//             Text(
//               "${meetings.length} meetings",
//               style: const TextStyle(fontSize: 14, color: AppColors.lightGray, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),

//         if (meetings.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: Text("No meetings available", style: TextStyle(color: AppColors.lightGray)),
//           )
//         else
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: meetings.length,
//             itemBuilder: (context, index) {
//               final meet = meetings[index];
//               final isOngoing = title.contains("Ongoing");
//               final isUpcoming = title.contains("Upcoming");
//               final isOnline = meet['location'] == null;

//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: _getCardBorderColor(),
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(color: AppColors.lightGray.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3)),
//                   ],
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.only(left: 7),
//                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(14.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 meet['title'] ?? '',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
//                               ),
//                             ),
//                             if (isOngoing && isOnline)
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.orange,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                   minimumSize: const Size(70, 31),
//                                   padding: const EdgeInsets.symmetric(horizontal: 14),
//                                 ),
//                                 onPressed: () async {
//                                   final raw = meet['onlineLink'];
//                                   final link = raw.startsWith("http") ? raw : "https://$raw";
//                                   if (link != null && link.isNotEmpty) {
//                                     final uri = Uri.parse(link);
//                                     if (await canLaunchUrl(uri)) {
//                                       await launchUrl(uri, mode: LaunchMode.externalApplication);
//                                     } else {
//                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open link")));
//                                     }
//                                   }
//                                 },
//                                 child: const Text("Join", style: TextStyle(color: Colors.white)),
//                               ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(Icons.access_time_filled_rounded, size: 19, color: AppColors.darkGray),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 () {
//                                   final date = DateTime.parse(meet['dateTime']).toLocal();
//                                   final formattedDate = DateFormat('d MMM, h:mm a').format(date);
//                                   return "Starts: $formattedDate";
//                                 }(),
//                                 style: const TextStyle(color: AppColors.darkGray, fontSize: 15, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 7),
//                         Row(
//                           children: [
//                             Icon(isOnline ? Icons.link : Icons.location_on, size: 19, color: AppColors.darkGray),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 isOnline ? "Online Meeting" : "Location: ${meet['location']}",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(color: AppColors.darkGray, fontSize: 15, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),

//                         if (role == 'head') ...[
//                           const Divider(),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton.icon(
//                                   icon: const Icon(Icons.edit, size: 18),
//                                   label: const Text("Edit"),
//                                   style: OutlinedButton.styleFrom(foregroundColor: AppColors.darkGray),
//                                   onPressed: () => _editMeeting(context, meet), // Call new function
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: OutlinedButton.icon(
//                                   icon: const Icon(Icons.delete, size: 18),
//                                   label: const Text("Cancel"),
//                                   style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
//                                   onPressed: () => _deleteMeeting(context, meet['_id']),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],

//                         if (!isUpcoming && role == 'head')
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: _getCardBorderColor(),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                 minimumSize: const Size.fromHeight(34),
//                               ),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (_) => AttendanceScreen(meeting: meet)),
//                                 );
//                               },
//                               child: const Text("Mark Attendance", style: TextStyle(color: Colors.white)),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
// }



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
        content: const Text("This will notify all members and cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Meeting cancelled")));
          onListUpdated?.call();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.replaceAll("Meetings", "").trim(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              "${meetings.length} meetings",
              style: const TextStyle(fontSize: 14, color: AppColors.lightGray, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (meetings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("No meetings available", style: TextStyle(color: AppColors.lightGray)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meet = meetings[index];
              final isOngoing = title.contains("Ongoing");
              final isUpcoming = title.contains("Upcoming");
              final isPending = title.contains("Pending");
              final isOnline = meet['location'] == "";
              
              // Show edit/delete only for upcoming and ongoing, not for pending
              final showEditDelete = role == 'head' && (isUpcoming || isOngoing);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _getCardBorderColor(),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppColors.lightGray.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                meet['title'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Action buttons in top right corner
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isOngoing && isOnline)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.orange,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      minimumSize: const Size(70, 31),
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                    onPressed: () async {
                                      final raw = meet['onlineLink'];
                                      final link = raw.startsWith("http") ? raw : "https://$raw";
                                      if (link != null && link.isNotEmpty) {
                                        final uri = Uri.parse(link);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open link")));
                                        }
                                      }
                                    },
                                    child: const Text("Join", style: TextStyle(color: Colors.white)),
                                  ),
                                
                                if (showEditDelete) ...[
                                  if (isOngoing && isOnline) const SizedBox(width: 8),
                                  
                                  // Edit icon button
                                  InkWell(
                                    onTap: () => _editMeeting(context, meet),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkGray.withOpacity(0.1),
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
                                  
                                  // Delete icon button
                                  InkWell(
                                    onTap: () => _deleteMeeting(context, meet['_id']),
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
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded, size: 19, color: AppColors.darkGray),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                () {
                                  final date = DateTime.parse(meet['dateTime']).toLocal();
                                  final formattedDate = DateFormat('d MMM, h:mm a').format(date);
                                  return "Starts: $formattedDate";
                                }(),
                                style: const TextStyle(color: AppColors.darkGray, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(isOnline ? Icons.link : Icons.location_on, size: 19, color: AppColors.darkGray),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isOnline ? "Online Meeting" : "Location: ${meet['location']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.darkGray, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        // Mark Attendance button (for non-upcoming meetings when user is head)
                        if (!isUpcoming && role == 'head')
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getCardBorderColor(),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: const Size.fromHeight(34),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AttendanceScreen(meeting: meet)),
                                );
                              },
                              child: const Text("Mark Attendance", style: TextStyle(color: Colors.white)),
                            ),
                          ),
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