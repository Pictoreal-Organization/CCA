// import 'package:flutter/material.dart';
// import '../screens/attendance.screen.dart';
// import '../core/app_colors.dart';
// import '../services/user_service.dart';
// import 'package:intl/intl.dart';

// class MeetingsList extends StatelessWidget {
//   final String title;
//   final List meetings;
//   final String role;

//   const MeetingsList({
//     super.key,
//     required this.title,
//     required this.meetings,
//     required this.role,
//   });

//   Color _getCardBorderColor() {
//     if (title.contains("Ongoing")) return AppColors.darkTeal;
//     if (title.contains("Upcoming")) return AppColors.green;
//     if (title.contains("Pending")) return AppColors.darkOrange;
//     return AppColors.lightGray;
//   }

//   Color _getButtonColor() {
//     if (title.contains("Pending")) return AppColors.orange;
//     return AppColors.green;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final showAttendanceButton = role == 'head' &&
//         (title == "Ongoing Meetings" ||
//             title == "Meetings Pending for Attendance");

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Title Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title.replaceAll("Meetings", "").trim(),
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             Text(
//               "${meetings.length} meetings",
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppColors.lightGray,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),

//         // If no meetings
//         if (meetings.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: Text(
//               "No meetings available",
//               style: TextStyle(color: AppColors.lightGray),
//             ),
//           )
//         else
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: meetings.length,
//             itemBuilder: (context, index) {
//               final meet = meetings[index];
//               final isOngoing = title.contains("Ongoing");
//               final isPending = title.contains("Pending");
//               final isUpcoming = title.contains("Upcoming");

//               return Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: _getCardBorderColor(),
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.lightGray.withOpacity(0.4),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 //----------------------------------------------
//                 child: Container(
//                 margin: const EdgeInsets.only(left: 7),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(14),
//                 ),


//                 child: Padding(
//                   padding: const EdgeInsets.all(14.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title
// // Title Row (with Join button at right)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Title Text
//                           Expanded(
//                             child: Text(
//                               meet['title'] ?? '',
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w900,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),

//                           if (isOngoing)
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.orange,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 minimumSize: const Size(70, 31),
//                                 padding: const EdgeInsets.symmetric(horizontal: 14),
//                               ),
//                               onPressed: () {
//                                 // TODO: Add join logic
//                               },
//                               child: const Text(
//                                 "Join",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),


//                       // Date & time
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                             const Icon(
//                               Icons.access_time_filled_rounded,
//                               size: 19,
//                               color: AppColors.darkGray, // white icon
//                             ),
//                           const SizedBox(width: 8),
//                           Expanded(

//                             child: Text(
//                                   () {
//                                 final date = DateTime.parse(meet['dateTime']).toLocal();
//                                 final formattedDate = DateFormat('d MMM, h:mm a').format(date);
//                                 return "Starts: $formattedDate";
//                               }(),
//                               style: const TextStyle(
//                                 color: AppColors.darkGray,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),

//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 7),

//                       // Meeting type
//                       Row(
//                         children:  [
//                           meet['location'] == null
//                           ? Icon(Icons.link, size: 19, color: AppColors.darkGray)
//                           : Icon(Icons.location_on, size: 19, color: AppColors.darkGray,),
//                           SizedBox(width: 8),
//                           Text(
//                             "${meet['location'] != null ? "Location: ${meet['location'] ?? meet['onlineLink'] ?? 'N/A'}" : "Online Meeting"}",
//                             style: TextStyle(
//                               color: AppColors.darkGray,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 10),

//                       // Buttons
//                       if (!isUpcoming && role == 'head')
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: _getCardBorderColor(),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 minimumSize: const Size.fromHeight(34),
//                               ),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) =>
//                                         AttendanceScreen(meeting: meet),
//                                   ),
//                                 );
//                               },
//                               child: const Text(
//                                 "Mark Attendance",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),

//                     ],
//                   ),
//                 ),
//                 ),
//               );
//             },
//           ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/attendance.screen.dart';
import '../core/app_colors.dart';
import 'package:intl/intl.dart';

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
    if (title.contains("Ongoing")) return AppColors.darkTeal;
    if (title.contains("Upcoming")) return AppColors.green;
    if (title.contains("Pending")) return AppColors.darkOrange;
    return AppColors.lightGray;
  }

  @override
  Widget build(BuildContext context) {
    final showAttendanceButton =
        role == 'head' &&
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "${meetings.length} meetings",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.lightGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

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
              final isUpcoming = title.contains("Upcoming");
              final isOnline = meet['location'] == null; // important!

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
                        // Title + Join button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                            // JOIN BUTTON → only if ongoing & online
                            if (isOngoing && isOnline)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(70, 31),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                ),
                                onPressed: () async {
                                  // final link = meet['onlineLink'];
                                  final raw = meet['onlineLink'];
                                  final link = raw.startsWith("http") ? raw : "https://$raw";
                                  // final uri = Uri.parse(link);

                                  if (link != null && link.isNotEmpty) {
                                    final uri = Uri.parse(link);

                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Could not open link"),
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
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Date & time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_filled_rounded,
                              size: 19,
                              color: AppColors.darkGray,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                () {
                                  final date = DateTime.parse(meet['dateTime'])
                                      .toLocal();
                                  final formattedDate = DateFormat(
                                      'd MMM, h:mm a').format(date);
                                  return "Starts: $formattedDate";
                                }(),
                                style: const TextStyle(
                                  color: AppColors.darkGray,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        // LOCATION ROW (clean & correct)
                        Row(
                          children: [
                            Icon(
                              isOnline ? Icons.link : Icons.location_on,
                              size: 19,
                              color: AppColors.darkGray,
                            ),
                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                isOnline
                                    ? "Online Meeting"
                                    : "Location: ${meet['location']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.darkGray,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Mark Attendance button (only for heads)
                        if (!isUpcoming && role == 'head')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getCardBorderColor(),
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
                ),
              );
            },
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}
