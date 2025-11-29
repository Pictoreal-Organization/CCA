// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import '../core/app_colors.dart';
// // import '../services/task_service.dart';

// // class TasksList extends StatefulWidget {
// //   final String title;
// //   final List tasks;
// //   final VoidCallback onTaskUpdated;
// //   final Function(Map<String, dynamic>) onEditTask;

// //   const TasksList({
// //     super.key,
// //     required this.title,
// //     required this.tasks,
// //     required this.onTaskUpdated,
// //     required this.onEditTask,
// //   });

// //   @override
// //   State<TasksList> createState() => _TasksListState();
// // }

// // class _TasksListState extends State<TasksList> {
// //   final TaskService taskService = TaskService();
// //   Set<String> expandedTasks = {};

// //   // --- HEAD ACTION METHODS ---
// //   void _showSuggestChangesDialog(dynamic task, dynamic subtask) async {
// //     final controller = TextEditingController();
// //     bool? confirmed = await showDialog<bool>(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Suggest Changes'),
// //         content: TextField(
// //           controller: controller,
// //           decoration: const InputDecoration(
// //             labelText: 'Required changes*',
// //             hintText: 'e.g., "Please add responsive support for tablets."',
// //             border: OutlineInputBorder(),
// //           ),
// //           autofocus: true,
// //           maxLines: 3,
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               if (controller.text.trim().isNotEmpty) {
// //                 Navigator.pop(context, true);
// //               }
// //             },
// //             child: const Text('Submit Feedback'),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirmed == true) {
// //       try {
// //         await taskService.updateSubtask(
// //           taskId: task['_id'],
// //           subtaskId: subtask['_id'],
// //           data: {'status': 'Pending', 'description': controller.text},
// //         );
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Feedback sent to member.')),
// //         );
// //         widget.onTaskUpdated();
// //       } catch (e) {
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text('Error sending feedback: $e')));
// //       }
// //     }
// //   }

// //   void _completeMainTask(dynamic task) async {
// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Complete Main Task?'),
// //         content: const Text(
// //           'All subtasks have been approved. Do you want to mark the entire task as completed?',
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             child: const Text('Complete Task'),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       try {
// //         await taskService.updateTask(task['_id'], {'status': 'Completed'});
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Task marked as completed!')),
// //         );
// //         widget.onTaskUpdated();
// //       } catch (e) {
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text('Error completing task: $e')));
// //       }
// //     }
// //   }

// //   void _deleteTask(String taskId) async {
// //     bool? confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Delete Task?'),
// //         content: const Text('This action is permanent and cannot be undone.'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: const Text('Cancel'),
// //           ),
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             child: const Text('Delete', style: TextStyle(color: Colors.red)),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       try {
// //         await taskService.deleteTask(taskId);
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Task deleted successfully')),
// //         );
// //         widget.onTaskUpdated();
// //       } catch (e) {
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
// //       }
// //     }
// //   }

// //   List _sortTasks(List tasks) {
// //     final sortedTasks = List.from(tasks);
// //     sortedTasks.sort((a, b) {
// //       final subtasksA = (a['subtasks'] as List?) ?? [];
// //       final subtasksB = (b['subtasks'] as List?) ?? [];

// //       final needsReviewA = subtasksA.any((s) => s['status'] == 'Completed');
// //       final needsReviewB = subtasksB.any((s) => s['status'] == 'Completed');

// //       final isCompletedA = a['status'] == 'Completed';
// //       final isCompletedB = b['status'] == 'Completed';

// //       // Priority 1: Needs Review comes first
// //       if (needsReviewA && !needsReviewB) return -1;
// //       if (!needsReviewA && needsReviewB) return 1;

// //       // Priority 2: Completed comes last
// //       if (!isCompletedA && isCompletedB) return -1;
// //       if (isCompletedA && !isCompletedB) return 1;

// //       return 0;
// //     });
// //     return sortedTasks;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final sortedTasks = _sortTasks(widget.tasks);

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text(
// //               widget.title,
// //               style: const TextStyle(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.black,
// //                 fontFamily: 'Inter',
// //               ),
// //             ),
// //             Text(
// //               "${widget.tasks.length} Tasks",
// //               style: const TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.bold,
// //                 color: AppColors.lightGray,
// //                 fontFamily: 'Inter',
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 16),
// //         sortedTasks.isEmpty
// //             ? Center(
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(40),
// //                   child: Column(
// //                     children: const [
// //                       Icon(
// //                         Icons.assignment_outlined,
// //                         size: 64,
// //                         color: Color(0xFFBDBDBD),
// //                       ),
// //                       SizedBox(height: 16),
// //                       Text(
// //                         "No tasks available",
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w500,
// //                           color: Color(0xFF757575),
// //                           fontFamily: 'Inter',
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               )
// //             : ListView.builder(
// //                 shrinkWrap: true,
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 itemCount: sortedTasks.length,
// //                 itemBuilder: (context, index) {
// //                   final task = sortedTasks[index];
// //                   final subtasks = (task['subtasks'] as List?) ?? [];
// //                   final completedSubtasks = subtasks
// //                       .where((s) => s['status'] == 'Completed')
// //                       .length;
// //                   final needsReview = subtasks.any(
// //                     (s) => s['status'] == 'Completed',
// //                   );

// //                   return _buildTaskCard(
// //                     task,
// //                     subtasks,
// //                     completedSubtasks,
// //                     needsReview,
// //                   );
// //                 },
// //               ),
// //       ],
// //     );
// //   }

// //   Widget _buildTaskCard(
// //     dynamic task,
// //     List subtasks,
// //     int completedSubtasks,
// //     bool needsReview,
// //   ) {
// //     final isCompleted = task['status'] == 'Completed';
// //     final allSubtasksCompleted =
// //         subtasks.isNotEmpty &&
// //         subtasks.every((s) => s['status'] == 'Completed');
// //     final borderColor = needsReview ? AppColors.orange : AppColors.green;
// //     final taskId = task['_id'];
// //     final isExpanded = expandedTasks.contains(taskId);
// //     final date = DateTime.parse(task['deadline']).toLocal();
// //     final formattedDeadline = DateFormat('d MMM').format(date);

// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: () {
// //           setState(() {
// //             if (isExpanded) {
// //               expandedTasks.remove(taskId);
// //             } else {
// //               expandedTasks.add(taskId);
// //             }
// //           });
// //         },
// //         borderRadius: BorderRadius.circular(14),
// //         child: Container(
// //           margin: const EdgeInsets.only(bottom: 12),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(14),
// //             border: Border(left: BorderSide(color: borderColor, width: 7)),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.06),
// //                 blurRadius: 4,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           child: Column(
// //             children: [
// //               Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     /// TITLE + DEADLINE + ARROW
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Expanded(
// //                           child: Text(
// //                             task['title'],
// //                             style: const TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black,
// //                               fontFamily: 'Inter',
// //                             ),
// //                           ),
// //                         ),
// //                         Column(
// //                           crossAxisAlignment: CrossAxisAlignment.end,
// //                           children: [
// //                             Row(
// //                               children: [
// //                                 Text(
// //                                   "🗓 $formattedDeadline",
// //                                   style: const TextStyle(
// //                                     fontSize: 12,
// //                                     color: Color(0xFF757575),
// //                                     fontFamily: 'Inter',
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 8),
// //                                 Text(
// //                                   "📌 $completedSubtasks/${subtasks.length}",
// //                                   style: const TextStyle(
// //                                     fontSize: 12,
// //                                     color: Color(0xFF757575),
// //                                     fontFamily: 'Inter',
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             Icon(
// //                               isExpanded
// //                                   ? Icons.keyboard_arrow_up
// //                                   : Icons.keyboard_arrow_down,
// //                               color: AppColors.lightGray,
// //                               size: 20,
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),

// //                     const SizedBox(height: 12),

// //                     /// SUBTASKS WHEN EXPANDED
// //                     if (isExpanded) ...[
// //                       Padding(
// //                         padding: const EdgeInsets.only(left: 4, bottom: 8),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: subtasks.map<Widget>((s) {
// //                             final title = s['title'];
// //                             final status = s['status'];
// //                             final assignedList = s['assignedTo'] ?? [];
// //                             final assignedUser = assignedList.isNotEmpty
// //                                 ? assignedList[0]
// //                                 : null;
// //                             final assignedName =
// //                                 assignedUser?['name'] ?? 'Not Assigned';

// //                             Widget actionWidget;
// //                             if (status == 'Completed') {
// //                               actionWidget = SizedBox(
// //                                 height: 34,
// //                                 child: ElevatedButton.icon(
// //                                   onPressed: () =>
// //                                       _showSuggestChangesDialog(task, s),
// //                                   icon: const Icon(
// //                                     Icons.undo,
// //                                     size: 14,
// //                                     color: Colors.white,
// //                                   ),
// //                                   label: const Text('Changes'),
// //                                   style: ElevatedButton.styleFrom(
// //                                     backgroundColor: AppColors.darkTeal,
// //                                     foregroundColor: Colors.white,
// //                                     shape: RoundedRectangleBorder(
// //                                       borderRadius: BorderRadius.circular(9),
// //                                     ),
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 12,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               );
// //                             } else {
// //                               actionWidget = SizedBox(
// //                                 height: 34,
// //                                 child: ElevatedButton.icon(
// //                                   onPressed: () {
// //                                     taskService
// //                                         .updateSubtask(
// //                                           taskId: task['_id'],
// //                                           subtaskId: s['_id'],
// //                                           data: {'status': 'Completed'},
// //                                         )
// //                                         .then((_) => widget.onTaskUpdated());
// //                                   },
// //                                   icon: const Icon(
// //                                     Icons.check,
// //                                     size: 14,
// //                                     color: Colors.white,
// //                                   ),
// //                                   label: const Text('Mark Done'),
// //                                   style: ElevatedButton.styleFrom(
// //                                     backgroundColor: AppColors.green,
// //                                     foregroundColor: Colors.white,
// //                                     shape: RoundedRectangleBorder(
// //                                       borderRadius: BorderRadius.circular(9),
// //                                     ),
// //                                     padding: const EdgeInsets.symmetric(
// //                                       horizontal: 12,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               );
// //                             }

// //                             return Padding(
// //                               padding: const EdgeInsets.symmetric(vertical: 8),
// //                               child: Row(
// //                                 children: [
// //                                   const Icon(
// //                                     Icons.person,
// //                                     size: 16,
// //                                     color: Colors.grey,
// //                                   ),
// //                                   const SizedBox(width: 10),
// //                                   Expanded(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.start,
// //                                       children: [
// //                                         Text(
// //                                           title,
// //                                           style: const TextStyle(
// //                                             fontWeight: FontWeight.w600,
// //                                             fontSize: 14,
// //                                           ),
// //                                         ),

// //                                         if (s['description'] != null &&
// //                                             s['description']
// //                                                 .toString()
// //                                                 .trim()
// //                                                 .isNotEmpty)
// //                                           Padding(
// //                                             padding: const EdgeInsets.only(
// //                                               top: 4.0,
// //                                               bottom: 4,
// //                                             ),
// //                                             child: Text(
// //                                               s['description'],
// //                                               style: TextStyle(
// //                                                 fontSize: 12,
// //                                                 height: 1.3,
// //                                                 color: Colors.grey.shade700,
// //                                                 fontFamily: 'Inter',
// //                                               ),
// //                                               maxLines: 4,
// //                                               overflow: TextOverflow.ellipsis,
// //                                             ),
// //                                           ),
                                       

// //                                         Text(
// //                                           assignedName,
// //                                           style: TextStyle(
// //                                             fontSize: 12,
// //                                             color: Colors.black,
// //                                             fontStyle: FontStyle.italic,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                   const SizedBox(width: 8),
// //                                   actionWidget,
// //                                 ],
// //                               ),
// //                             );
// //                           }).toList(),
// //                         ),
// //                       ),

// //                       // Mark Main Task Completed Button
// //                       if (task['status'] != 'Completed')
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                           child: SizedBox(
// //                             width: double.infinity,
// //                             child: ElevatedButton.icon(
// //                               icon: const Icon(
// //                                 Icons.check_circle_outline,
// //                                 color: Colors.white,
// //                               ),
// //                               label: const Text('Mark Main Task as Completed'),
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: allSubtasksCompleted
// //                                     ? AppColors.green
// //                                     : Colors.grey.shade400,
// //                                 padding: const EdgeInsets.symmetric(
// //                                   vertical: 12,
// //                                 ),
// //                                 foregroundColor: Colors.white,
// //                               ),
// //                               onPressed: allSubtasksCompleted
// //                                   ? () => _completeMainTask(task)
// //                                   : null,
// //                             ),
// //                           ),
// //                         ),
// //                     ] else
// //                       /// COLLAPSED VIEW: STATUS BADGES AND REVIEW BUTTON
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           if (needsReview) ...[
// //                             Container(
// //                               padding: const EdgeInsets.symmetric(
// //                                 horizontal: 14,
// //                                 vertical: 4,
// //                               ),
// //                               decoration: BoxDecoration(
// //                                 color: AppColors.darkOrange,
// //                                 borderRadius: BorderRadius.circular(20),
// //                               ),
// //                               child: const Text(
// //                                 'Needs Review',
// //                                 style: TextStyle(
// //                                   color: Colors.white,
// //                                   fontWeight: FontWeight.w600,
// //                                   fontSize: 11,
// //                                   fontFamily: 'Inter',
// //                                 ),
// //                               ),
// //                             ),
// //                             Expanded(
// //                               child: Align(
// //                                 alignment: Alignment.centerRight,
// //                                 child: SizedBox(
// //                                   height: 38,
// //                                   child: ElevatedButton.icon(
// //                                     onPressed: () {
// //                                       setState(() {
// //                                         expandedTasks.add(taskId);
// //                                       });
// //                                     },
// //                                     icon: const Icon(
// //                                       Icons.rate_review,
// //                                       size: 16,
// //                                       color: Colors.white,
// //                                     ),
// //                                     label: const Text('Review'),
// //                                     style: ElevatedButton.styleFrom(
// //                                       backgroundColor: AppColors.darkTeal,
// //                                       foregroundColor: Colors.white,
// //                                       shape: RoundedRectangleBorder(
// //                                         borderRadius: BorderRadius.circular(9),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ] else
// //                             Container(
// //                               padding: const EdgeInsets.symmetric(
// //                                 horizontal: 14,
// //                                 vertical: 4,
// //                               ),
// //                               decoration: BoxDecoration(
// //                                 color: isCompleted
// //                                     ? AppColors.green
// //                                     : const Color.fromARGB(255, 103, 186, 254),
// //                                 borderRadius: BorderRadius.circular(20),
// //                               ),
// //                               child: Text(
// //                                 task['status'],
// //                                 style: TextStyle(
// //                                   color: isCompleted
// //                                       ? Colors.white
// //                                       : const Color.fromARGB(255, 5, 38, 94),
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 11,
// //                                   fontFamily: 'Inter',
// //                                 ),
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                   ],
// //                 ),
// //               ),

// //               /// BUTTONS (Edit / Delete)
// //               if (isExpanded || !isCompleted)
// //                 Padding(
// //                   padding: const EdgeInsets.only(
// //                     left: 16,
// //                     right: 16,
// //                     bottom: 18,
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: ElevatedButton.icon(
// //                           onPressed: () => widget.onEditTask(task),
// //                           icon: const Icon(
// //                             Icons.edit,
// //                             size: 16,
// //                             color: Colors.white,
// //                           ),
// //                           label: const Text('Edit'),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: AppColors.darkTeal,
// //                             foregroundColor: Colors.white,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(9),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: ElevatedButton.icon(
// //                           onPressed: () => _deleteTask(task['_id']),
// //                           icon: const Icon(
// //                             Icons.delete,
// //                             size: 16,
// //                             color: Colors.white,
// //                           ),
// //                           label: const Text('Delete'),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: AppColors.darkOrange,
// //                             foregroundColor: Colors.white,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(9),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../core/app_colors.dart';
// import '../services/task_service.dart';

// class TasksList extends StatefulWidget {
//   final String title;
//   final List tasks;
//   final VoidCallback onTaskUpdated;
//   final Function(Map<String, dynamic>) onEditTask;

//   const TasksList({
//     super.key,
//     required this.title,
//     required this.tasks,
//     required this.onTaskUpdated,
//     required this.onEditTask,
//   });

//   @override
//   State<TasksList> createState() => _TasksListState();
// }

// class _TasksListState extends State<TasksList> {
//   final TaskService taskService = TaskService();
//   Set<String> expandedTasks = {};

//   // ---------------------------------------------------------
//   // ✅ REUSABLE POPUP DIALOG FUNCTION
//   // ---------------------------------------------------------
//   void _showStatusDialog({
//     required String title,
//     required String message,
//     bool isError = false,
//     VoidCallback? onConfirm,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: !isError,
//       builder: (BuildContext ctx) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 isError ? Icons.error_outline : Icons.check_circle_outline,
//                 color: isError ? Colors.red : AppColors.darkTeal,
//                 size: 28,
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     color: isError ? Colors.red : AppColors.darkTeal,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(fontSize: 16, height: 1.4),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(ctx).pop(); // Close the dialog
//                 if (onConfirm != null) {
//                   onConfirm(); // Run success logic
//                 }
//               },
//               child: const Text(
//                 "OK",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: AppColors.darkTeal,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // --- ACTION METHODS ---

//   void _showSuggestChangesDialog(dynamic task, dynamic subtask) async {
//     final controller = TextEditingController();
//     bool? confirmed = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Suggest Changes'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'Required changes*',
//             hintText: 'e.g., "Please add responsive support for tablets."',
//             border: OutlineInputBorder(),
//           ),
//           autofocus: true,
//           maxLines: 3,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal),
//             onPressed: () {
//               if (controller.text.trim().isNotEmpty) {
//                 Navigator.pop(context, true);
//               }
//             },
//             child: const Text('Submit Feedback', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await taskService.updateSubtask(
//           taskId: task['_id'],
//           subtaskId: subtask['_id'],
//           data: {'status': 'Pending', 'description': controller.text},
//         );
//         if (!mounted) return;
        
//         // ✅ Popup for Success
//         _showStatusDialog(
//           title: "Feedback Sent",
//           message: "Your feedback has been sent to the member.",
//           isError: false,
//           onConfirm: widget.onTaskUpdated,
//         );
//       } catch (e) {
//         if (!mounted) return;
//         // ✅ Popup for Error
//         _showStatusDialog(
//           title: "Error",
//           message: "Failed to send feedback: $e",
//           isError: true,
//         );
//       }
//     }
//   }

//   void _markSubtaskDone(dynamic task, dynamic subtask) async {
//     try {
//       await taskService.updateSubtask(
//         taskId: task['_id'],
//         subtaskId: subtask['_id'],
//         data: {'status': 'Completed'},
//       );
//       if(!mounted) return;

//       // ✅ Popup for Success
//       _showStatusDialog(
//         title: "Subtask Completed",
//         message: "Great job! Subtask marked as done.",
//         isError: false,
//         onConfirm: widget.onTaskUpdated,
//       );

//     } catch (e) {
//       if(!mounted) return;
//       // ✅ Popup for Error
//       _showStatusDialog(
//         title: "Action Failed",
//         message: "Could not update subtask: $e",
//         isError: true,
//       );
//     }
//   }

//   void _completeMainTask(dynamic task) async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Complete Main Task?'),
//         content: const Text(
//           'All subtasks have been approved. Do you want to mark the entire task as completed?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Complete Task', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await taskService.updateTask(task['_id'], {'status': 'Completed'});
//         if (!mounted) return;
        
//         // ✅ Popup for Success
//         _showStatusDialog(
//           title: "Task Completed",
//           message: "The main task has been successfully marked as completed!",
//           isError: false,
//           onConfirm: widget.onTaskUpdated,
//         );
//       } catch (e) {
//         if (!mounted) return;
//         // ✅ Popup for Error
//         _showStatusDialog(
//           title: "Error",
//           message: "Failed to complete task: $e",
//           isError: true,
//         );
//       }
//     }
//   }

//   void _deleteTask(String taskId) async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Delete Task?'),
//         content: const Text('This action is permanent and cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await taskService.deleteTask(taskId);
//         if (!mounted) return;
        
//         // ✅ Popup for Success
//         _showStatusDialog(
//           title: "Deleted",
//           message: "Task deleted successfully.",
//           isError: false,
//           onConfirm: widget.onTaskUpdated,
//         );
//       } catch (e) {
//         if (!mounted) return;
//         // ✅ Popup for Error
//         _showStatusDialog(
//           title: "Error",
//           message: "Failed to delete task: $e",
//           isError: true,
//         );
//       }
//     }
//   }

//   List _sortTasks(List tasks) {
//     final sortedTasks = List.from(tasks);
//     sortedTasks.sort((a, b) {
//       final subtasksA = (a['subtasks'] as List?) ?? [];
//       final subtasksB = (b['subtasks'] as List?) ?? [];

//       final needsReviewA = subtasksA.any((s) => s['status'] == 'Completed');
//       final needsReviewB = subtasksB.any((s) => s['status'] == 'Completed');

//       final isCompletedA = a['status'] == 'Completed';
//       final isCompletedB = b['status'] == 'Completed';

//       if (needsReviewA && !needsReviewB) return -1;
//       if (!needsReviewA && needsReviewB) return 1;

//       if (!isCompletedA && isCompletedB) return -1;
//       if (isCompletedA && !isCompletedB) return 1;

//       return 0;
//     });
//     return sortedTasks;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sortedTasks = _sortTasks(widget.tasks);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               widget.title,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//                 fontFamily: 'Inter',
//               ),
//             ),
//             Text(
//               "${widget.tasks.length} Tasks",
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.lightGray,
//                 fontFamily: 'Inter',
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         sortedTasks.isEmpty
//             ? Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(40),
//                   child: Column(
//                     children: const [
//                       Icon(
//                         Icons.assignment_outlined,
//                         size: 64,
//                         color: Color(0xFFBDBDBD),
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         "No tasks available",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF757575),
//                           fontFamily: 'Inter',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: sortedTasks.length,
//                 itemBuilder: (context, index) {
//                   final task = sortedTasks[index];
//                   final subtasks = (task['subtasks'] as List?) ?? [];
//                   final completedSubtasks = subtasks
//                       .where((s) => s['status'] == 'Completed')
//                       .length;
//                   final needsReview = subtasks.any(
//                     (s) => s['status'] == 'Completed',
//                   );

//                   return _buildTaskCard(
//                     task,
//                     subtasks,
//                     completedSubtasks,
//                     needsReview,
//                   );
//                 },
//               ),
//       ],
//     );
//   }

//   Widget _buildTaskCard(
//     dynamic task,
//     List subtasks,
//     int completedSubtasks,
//     bool needsReview,
//   ) {
//     final isCompleted = task['status'] == 'Completed';
//     final allSubtasksCompleted =
//         subtasks.isNotEmpty &&
//         subtasks.every((s) => s['status'] == 'Completed');
//     final borderColor = needsReview ? AppColors.orange : AppColors.green;
//     final taskId = task['_id'];
//     final isExpanded = expandedTasks.contains(taskId);
//     final date = DateTime.parse(task['deadline']).toLocal();
//     final formattedDeadline = DateFormat('d MMM').format(date);

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             if (isExpanded) {
//               expandedTasks.remove(taskId);
//             } else {
//               expandedTasks.add(taskId);
//             }
//           });
//         },
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border(left: BorderSide(color: borderColor, width: 7)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// TITLE + DEADLINE + ARROW
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             task['title'],
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                               fontFamily: 'Inter',
//                             ),
//                           ),
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   "🗓 $formattedDeadline",
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Color(0xFF757575),
//                                     fontFamily: 'Inter',
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "📌 $completedSubtasks/${subtasks.length}",
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Color(0xFF757575),
//                                     fontFamily: 'Inter',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               isExpanded
//                                   ? Icons.keyboard_arrow_up
//                                   : Icons.keyboard_arrow_down,
//                               color: AppColors.lightGray,
//                               size: 20,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     /// SUBTASKS WHEN EXPANDED
//                     if (isExpanded) ...[
//                       Padding(
//                         padding: const EdgeInsets.only(left: 4, bottom: 8),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: subtasks.map<Widget>((s) {
//                             final title = s['title'];
//                             final status = s['status'];
//                             final assignedList = s['assignedTo'] ?? [];
//                             final assignedUser = assignedList.isNotEmpty
//                                 ? assignedList[0]
//                                 : null;
//                             final assignedName =
//                                 assignedUser?['name'] ?? 'Not Assigned';

//                             Widget actionWidget;
//                             if (status == 'Completed') {
//                               // ✅ Button for Changes
//                               actionWidget = SizedBox(
//                                 height: 34,
//                                 child: ElevatedButton.icon(
//                                   onPressed: () =>
//                                       _showSuggestChangesDialog(task, s),
//                                   icon: const Icon(
//                                     Icons.undo,
//                                     size: 14,
//                                     color: Colors.white,
//                                   ),
//                                   label: const Text('Changes'),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.darkTeal,
//                                     foregroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(9),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             } else {
//                               // ✅ Button for Mark Done
//                               actionWidget = SizedBox(
//                                 height: 34,
//                                 child: ElevatedButton.icon(
//                                   onPressed: () => _markSubtaskDone(task, s),
//                                   icon: const Icon(
//                                     Icons.check,
//                                     size: 14,
//                                     color: Colors.white,
//                                   ),
//                                   label: const Text('Mark Done'),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.green,
//                                     foregroundColor: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(9),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }

//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.person,
//                                     size: 16,
//                                     color: Colors.grey,
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           title,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                           ),
//                                         ),

//                                         if (s['description'] != null &&
//                                             s['description']
//                                                 .toString()
//                                                 .trim()
//                                                 .isNotEmpty)
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                               top: 4.0,
//                                               bottom: 4,
//                                             ),
//                                             child: Text(
//                                               s['description'],
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 height: 1.3,
//                                                 color: Colors.grey.shade700,
//                                                 fontFamily: 'Inter',
//                                               ),
//                                               maxLines: 4,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
                                        
//                                         Text(
//                                           assignedName,
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.black,
//                                             fontStyle: FontStyle.italic,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   actionWidget,
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),

//                       // ✅ Mark Main Task Completed Button
//                       if (task['status'] != 'Completed')
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           child: SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               icon: const Icon(
//                                 Icons.check_circle_outline,
//                                 color: Colors.white,
//                               ),
//                               label: const Text('Mark Main Task as Completed'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: allSubtasksCompleted
//                                     ? AppColors.green
//                                     : Colors.grey.shade400,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                 ),
//                                 foregroundColor: Colors.white,
//                               ),
//                               onPressed: allSubtasksCompleted
//                                   ? () => _completeMainTask(task)
//                                   : null,
//                             ),
//                           ),
//                         ),
//                     ] else
//                       /// COLLAPSED VIEW: STATUS BADGES AND REVIEW BUTTON
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           if (needsReview) ...[
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.darkOrange,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Text(
//                                 'Needs Review',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 11,
//                                   fontFamily: 'Inter',
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Align(
//                                 alignment: Alignment.centerRight,
//                                 child: SizedBox(
//                                   height: 38,
//                                   child: ElevatedButton.icon(
//                                     onPressed: () {
//                                       setState(() {
//                                         expandedTasks.add(taskId);
//                                       });
//                                     },
//                                     icon: const Icon(
//                                       Icons.rate_review,
//                                       size: 16,
//                                       color: Colors.white,
//                                     ),
//                                     label: const Text('Review'),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.darkTeal,
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(9),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ] else
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isCompleted
//                                     ? AppColors.green
//                                     : const Color.fromARGB(255, 103, 186, 254),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 task['status'],
//                                 style: TextStyle(
//                                   color: isCompleted
//                                       ? Colors.white
//                                       : const Color.fromARGB(255, 5, 38, 94),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 11,
//                                   fontFamily: 'Inter',
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),

//               /// BUTTONS (Edit / Delete)
//               if (isExpanded || !isCompleted)
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 16,
//                     right: 16,
//                     bottom: 18,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () => widget.onEditTask(task),
//                           icon: const Icon(
//                             Icons.edit,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                           label: const Text('Edit'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.darkTeal,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(9),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () => _deleteTask(task['_id']),
//                           icon: const Icon(
//                             Icons.delete,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                           label: const Text('Delete'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.darkOrange,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(9),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../services/task_service.dart';

class TasksList extends StatefulWidget {
  final String title;
  final List tasks;
  final VoidCallback onTaskUpdated;
  final Function(Map<String, dynamic>) onEditTask;

  const TasksList({
    super.key,
    required this.title,
    required this.tasks,
    required this.onTaskUpdated,
    required this.onEditTask,
  });

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  final TaskService taskService = TaskService();
  Set<String> expandedTasks = {};

  // ---------------------------------------------------------
  // ✅ REUSABLE POPUP DIALOG FUNCTION
  // ---------------------------------------------------------
  void _showStatusDialog({
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isError,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red : AppColors.darkTeal,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isError ? Colors.red : AppColors.darkTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                if (onConfirm != null) {
                  onConfirm(); // Run success logic
                }
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkTeal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- ACTION METHODS ---

  void _showSuggestChangesDialog(dynamic task, dynamic subtask) async {
    final controller = TextEditingController();
    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Suggest Changes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Required changes*',
            hintText: 'e.g., "Please add responsive support for tablets."',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Submit Feedback', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await taskService.updateSubtask(
          taskId: task['_id'],
          subtaskId: subtask['_id'],
          data: {'status': 'Pending', 'description': controller.text},
        );
        if (!mounted) return;
        
        // ✅ Popup for Success
        _showStatusDialog(
          title: "Feedback Sent",
          message: "Your feedback has been sent to the member.",
          isError: false,
          onConfirm: widget.onTaskUpdated,
        );
      } catch (e) {
        if (!mounted) return;
        // ✅ Popup for Error
        _showStatusDialog(
          title: "Error",
          message: "Failed to send feedback: $e",
          isError: true,
        );
      }
    }
  }

  void _markSubtaskDone(dynamic task, dynamic subtask) async {
    try {
      await taskService.updateSubtask(
        taskId: task['_id'],
        subtaskId: subtask['_id'],
        data: {'status': 'Completed'},
      );
      if(!mounted) return;

      _showStatusDialog(
        title: "Subtask Completed",
        message: "Great job! Subtask marked as done.",
        isError: false,
        onConfirm: widget.onTaskUpdated,
      );

    } catch (e) {
      if(!mounted) return;
      _showStatusDialog(
        title: "Action Failed",
        message: "Could not update subtask: $e",
        isError: true,
      );
    }
  }

  void _completeMainTask(dynamic task) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Complete Main Task?'),
        content: const Text(
          'All subtasks have been approved. Do you want to mark the entire task as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete Task', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await taskService.updateTask(task['_id'], {'status': 'Completed'});
        if (!mounted) return;
        
        _showStatusDialog(
          title: "Task Completed",
          message: "The main task has been successfully marked as completed!",
          isError: false,
          onConfirm: widget.onTaskUpdated,
        );
      } catch (e) {
        if (!mounted) return;
        _showStatusDialog(
          title: "Error",
          message: "Failed to complete task: $e",
          isError: true,
        );
      }
    }
  }

  void _deleteTask(String taskId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task?'),
        content: const Text('This action is permanent and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await taskService.deleteTask(taskId);
        if (!mounted) return;
        
        _showStatusDialog(
          title: "Deleted",
          message: "Task deleted successfully.",
          isError: false,
          onConfirm: widget.onTaskUpdated,
        );
      } catch (e) {
        if (!mounted) return;
        _showStatusDialog(
          title: "Error",
          message: "Failed to delete task: $e",
          isError: true,
        );
      }
    }
  }

  List _sortTasks(List tasks) {
    final sortedTasks = List.from(tasks);
    sortedTasks.sort((a, b) {
      final subtasksA = (a['subtasks'] as List?) ?? [];
      final subtasksB = (b['subtasks'] as List?) ?? [];

      // Sort by "Any subtask completed" (Needs Review)
      final needsReviewA = subtasksA.any((s) => s['status'] == 'Completed');
      final needsReviewB = subtasksB.any((s) => s['status'] == 'Completed');

      final isCompletedA = a['status'] == 'Completed';
      final isCompletedB = b['status'] == 'Completed';

      if (needsReviewA && !needsReviewB) return -1;
      if (!needsReviewA && needsReviewB) return 1;

      if (!isCompletedA && isCompletedB) return -1;
      if (isCompletedA && !isCompletedB) return 1;

      return 0;
    });
    return sortedTasks;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter Active Tasks
    final activeTasks = widget.tasks.where((t) => t['status'] != 'Completed').toList();
    // 2. Sort
    final sortedTasks = _sortTasks(activeTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              "${sortedTasks.length} Tasks",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGray,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        sortedTasks.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Color(0xFFBDBDBD),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No active tasks",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];
                  final subtasks = (task['subtasks'] as List?) ?? [];
                  final completedSubtasks = subtasks
                      .where((s) => s['status'] == 'Completed')
                      .length;
                  
                  // ✅ FIXED: Use .any() so Orange Border appears if even 1 subtask is done
                  final needsReview = subtasks.isNotEmpty && 
                                      subtasks.any((s) => s['status'] == 'Completed');

                  return _buildTaskCard(
                    task,
                    subtasks,
                    completedSubtasks,
                    needsReview,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildTaskCard(
    dynamic task,
    List subtasks,
    int completedSubtasks,
    bool needsReview, // This is now true if ANY subtask is completed
  ) {
    final isCompleted = task['status'] == 'Completed';
    
    // This is strict check for the "Mark Main Task Completed" button
    final allSubtasksCompleted =
        subtasks.isNotEmpty &&
        subtasks.every((s) => s['status'] == 'Completed');

    final borderColor = needsReview ? AppColors.orange : AppColors.green;
    final taskId = task['_id'];
    final isExpanded = expandedTasks.contains(taskId);
    final date = DateTime.parse(task['deadline']).toLocal();
    final formattedDeadline = DateFormat('d MMM').format(date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              expandedTasks.remove(taskId);
            } else {
              expandedTasks.add(taskId);
            }
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: borderColor, width: 7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE + DEADLINE + ARROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "🗓 $formattedDeadline",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF757575),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "📌 $completedSubtasks/${subtasks.length}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF757575),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.lightGray,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// SUBTASKS WHEN EXPANDED
                    if (isExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: subtasks.map<Widget>((s) {
                            final title = s['title'];
                            final status = s['status'];
                            final assignedList = s['assignedTo'] ?? [];
                            final assignedUser = assignedList.isNotEmpty
                                ? assignedList[0]
                                : null;
                            final assignedName =
                                assignedUser?['name'] ?? 'Not Assigned';

                            Widget actionWidget;
                            if (status == 'Completed') {
                              // Button for Changes
                              actionWidget = SizedBox(
                                height: 34,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _showSuggestChangesDialog(task, s),
                                  icon: const Icon(
                                    Icons.undo,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  label: const Text('Changes'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkTeal,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Button for Mark Done
                              actionWidget = SizedBox(
                                height: 34,
                                child: ElevatedButton.icon(
                                  onPressed: () => _markSubtaskDone(task, s),
                                  icon: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  label: const Text('Mark Done'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),

                                        if (s['description'] != null &&
                                            s['description']
                                                .toString()
                                                .trim()
                                                .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                              bottom: 4,
                                            ),
                                            child: Text(
                                              s['description'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                height: 1.3,
                                                color: Colors.grey.shade700,
                                                fontFamily: 'Inter',
                                              ),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        
                                        Text(
                                          assignedName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  actionWidget,
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Mark Main Task Completed Button
                      if (task['status'] != 'Completed')
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              label: const Text('Mark Main Task as Completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: allSubtasksCompleted
                                    ? AppColors.green
                                    : Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: allSubtasksCompleted
                                  ? () => _completeMainTask(task)
                                  : null,
                            ),
                          ),
                        ),
                    ] else
                      /// COLLAPSED VIEW: STATUS BADGES AND REVIEW BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (needsReview) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.darkOrange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Needs Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  height: 38,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        expandedTasks.add(taskId);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.rate_review,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: const Text('Review'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkTeal,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? AppColors.green
                                    : const Color.fromARGB(255, 103, 186, 254),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                task['status'],
                                style: TextStyle(
                                  color: isCompleted
                                      ? Colors.white
                                      : const Color.fromARGB(255, 5, 38, 94),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              /// BUTTONS (Edit / Delete)
              /// Shows always unless expanded (content pushes it down)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 18,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onEditTask(task),
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteTask(task['_id']),
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}