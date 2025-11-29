// import 'package:cca/core/app_colors.dart';
// import 'package:flutter/material.dart';
// import '../services/task_service.dart';

// class TasksListMember extends StatefulWidget {
//   final String title;
//   final List tasks;
//   final VoidCallback onTaskUpdated;

//   const TasksListMember({
//     super.key,
//     required this.title,
//     required this.tasks,
//     required this.onTaskUpdated,
//   });

//   @override
//   State<TasksListMember> createState() => _TasksListMemberState();
// }

// class _TasksListMemberState extends State<TasksListMember> {
  
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

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 12),
//         Text(
//           widget.title,
//           style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Inter',
//           ),
//         ),
//         const SizedBox(height: 8),

//         widget.tasks.isEmpty
//             ? const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Text("You have no tasks assigned."),
//                 ),
//               )
//             : () {
//                 // 🔥 SORTING LOGIC
//                 widget.tasks.sort((a, b) {
//                   final aSub = a['subtasks'] as List;
//                   final bSub = b['subtasks'] as List;

//                   bool aHasPending = aSub.any(
//                     (s) => s['status'] != "Completed",
//                   );
//                   bool bHasPending = bSub.any(
//                     (s) => s['status'] != "Completed",
//                   );

//                   if (aHasPending && !bHasPending) return -1; // a first
//                   if (!aHasPending && bHasPending) return 1; // b first
//                   return 0; // same group → keep normal order
//                 });
                
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: widget.tasks.length,
//                   itemBuilder: (context, index) {
//                     final task = widget.tasks[index];
//                     final subtasks = task['subtasks'] as List;

//                     // Determine left border color
//                     bool hasPending = subtasks.any(
//                       (s) => s['status'] != "Completed",
//                     );
//                     final borderColor = hasPending
//                         ? AppColors.orange
//                         : AppColors.green;

//                     return Container(
//                       margin: const EdgeInsets.symmetric(vertical: 7),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border(
//                           left: BorderSide(color: borderColor, width: 7),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.06),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Main Task Title
//                             Text(
//                               task['title'],
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                                 fontFamily: 'Inter',
//                               ),
//                             ),

//                             // List Subtasks
//                             ...subtasks.map((sub) {
//                               final currentStatus = sub['status'];

//                               return Padding(
//                                 padding: const EdgeInsets.only(top: 12.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       sub['title'],
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16,
//                                         fontFamily: 'Inter',
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       sub['description'] ??
//                                           'No description provided.',
//                                       style: const TextStyle(
//                                         color: Colors.black54,
//                                         fontFamily: 'Inter',
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),

//                                     // Status UI
//                                     if (currentStatus == 'Completed')
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 6,
//                                           horizontal: 12,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: AppColors.darkTeal,
//                                           borderRadius: BorderRadius.circular(
//                                             20,
//                                           ),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: const [
//                                             Icon(
//                                               Icons.check_circle,
//                                               color: Colors.white,
//                                             ),
//                                             SizedBox(width: 6),
//                                             Text(
//                                               "Completed",
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily: 'Inter',
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       )
//                                     else
//                                       ElevatedButton.icon(
//                                         icon: const Icon(Icons.done_all),
//                                         label: const Text(
//                                           "Mark as Completed",
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontFamily: 'Inter',
//                                           ),
//                                         ),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: AppColors.green,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           minimumSize: const Size(double.infinity, 48), // full width if needed
//                                         ),
//                                         onPressed: () => _handleStatusChange(
//                                           context,
//                                           'Completed',
//                                           task,
//                                           sub,
//                                           widget.onTaskUpdated,
//                                         ),
//                                       )
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }(),
//       ],
//     );
//   }

//   // Handle Status Change
//   void _handleStatusChange(
//     BuildContext context,
//     String newStatus,
//     dynamic task,
//     dynamic subtask,
//     VoidCallback onUpdate,
//   ) async {
//     if (newStatus == 'Completed') {
//       String? completionNote = await _showCompletionNoteDialog(context);
//       if (completionNote != null && completionNote.isNotEmpty) {
//         _updateSubtaskApi(
//           context,
//           newStatus,
//           task,
//           subtask,
//           onUpdate,
//           description: completionNote,
//         );
//       }
//     } else {
//       _updateSubtaskApi(context, newStatus, task, subtask, onUpdate);
//     }
//   }

//   // API update
//   void _updateSubtaskApi(
//     BuildContext context,
//     String status,
//     dynamic task,
//     dynamic subtask,
//     VoidCallback onUpdate, {
//     String? description,
//   }) async {
//     final taskService = TaskService();
//     try {
//       final data = {'status': status};
//       if (description != null) data['description'] = description;

//       await taskService.updateSubtask(
//         taskId: task['_id'],
//         subtaskId: subtask['_id'],
//         data: data,
//       );

//       if (!mounted) return;

//       // ✅ Popup for Success
//       _showStatusDialog(
//         title: "Status Updated",
//         message: "${subtask['title']} has been marked as $status.",
//         isError: false,
//         onConfirm: onUpdate,
//       );

//     } catch (e) {
//       if (!mounted) return;
//       // ✅ Popup for Error
//       _showStatusDialog(
//         title: "Update Failed",
//         message: "Could not update status: $e",
//         isError: true,
//       );
//     }
//   }

//   // Completion note dialog
//   Future<String?> _showCompletionNoteDialog(BuildContext context) {
//     final controller = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Complete Subtask',
//           style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
//         ),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'Add a completion note*',
//             hintText: 'Describe what you have completed.',
//             border: OutlineInputBorder(),
//           ),
//           autofocus: true,
//           maxLines: 3,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, null),
//             child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter', color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal),
//             onPressed: () {
//               if (controller.text.trim().isNotEmpty) {
//                 Navigator.pop(context, controller.text);
//               }
//             },
//             child: const Text(
//               'Mark as Completed',
//               style: TextStyle(fontFamily: 'Inter', color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:cca/core/app_colors.dart';
import 'package:flutter/material.dart';
import '../services/task_service.dart';

class TasksListMember extends StatefulWidget {
  final String title;
  final List tasks;
  final VoidCallback onTaskUpdated;

  const TasksListMember({
    super.key,
    required this.title,
    required this.tasks,
    required this.onTaskUpdated,
  });

  @override
  State<TasksListMember> createState() => _TasksListMemberState();
}

class _TasksListMemberState extends State<TasksListMember> {
  
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
                Navigator.of(ctx).pop();
                if (onConfirm != null) {
                  onConfirm();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),

        widget.tasks.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("You have no tasks assigned."),
                ),
              )
            : () {
                // 🔥 SORTING LOGIC
                widget.tasks.sort((a, b) {
                  final aSub = a['subtasks'] as List;
                  final bSub = b['subtasks'] as List;

                  bool aHasPending = aSub.any(
                    (s) => s['status'] != "Completed",
                  );
                  bool bHasPending = bSub.any(
                    (s) => s['status'] != "Completed",
                  );

                  if (aHasPending && !bHasPending) return -1;
                  if (!aHasPending && bHasPending) return 1;
                  return 0;
                });
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.tasks.length,
                  itemBuilder: (context, index) {
                    final task = widget.tasks[index];
                    final subtasks = task['subtasks'] as List;

                    // 🆕 GET TEAM NAME
                    String teamName = 'General';
                    if (task['team'] != null) {
                      // If team is populated as an object
                      if (task['team'] is Map) {
                        teamName = task['team']['name'] ?? 'General';
                      }
                    }

                    // Determine left border color
                    bool hasPending = subtasks.any(
                      (s) => s['status'] != "Completed",
                    );
                    final borderColor = hasPending
                        ? AppColors.orange
                        : AppColors.green;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(color: borderColor, width: 7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🆕 HEADER ROW: Title + Team Badge
                            Row(
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
                                const SizedBox(width: 8),
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
                                    teamName,
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

                            // List Subtasks
                            ...subtasks.map((sub) {
                              final currentStatus = sub['status'];

                              return Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sub['description'] ??
                                          'No description provided.',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Status UI
                                    if (currentStatus == 'Completed')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkTeal,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "Completed",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.done_all),
                                        label: const Text(
                                          "Mark as Completed",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          minimumSize: const Size(double.infinity, 48),
                                        ),
                                        onPressed: () => _handleStatusChange(
                                          context,
                                          'Completed',
                                          task,
                                          sub,
                                          widget.onTaskUpdated,
                                        ),
                                      )
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }(),
      ],
    );
  }

  // Handle Status Change
  void _handleStatusChange(
    BuildContext context,
    String newStatus,
    dynamic task,
    dynamic subtask,
    VoidCallback onUpdate,
  ) async {
    if (newStatus == 'Completed') {
      String? completionNote = await _showCompletionNoteDialog(context);
      if (completionNote != null && completionNote.isNotEmpty) {
        _updateSubtaskApi(
          context,
          newStatus,
          task,
          subtask,
          onUpdate,
          description: completionNote,
        );
      }
    } else {
      _updateSubtaskApi(context, newStatus, task, subtask, onUpdate);
    }
  }

  // API update
  void _updateSubtaskApi(
    BuildContext context,
    String status,
    dynamic task,
    dynamic subtask,
    VoidCallback onUpdate, {
    String? description,
  }) async {
    final taskService = TaskService();
    try {
      final data = {'status': status};
      if (description != null) data['description'] = description;

      await taskService.updateSubtask(
        taskId: task['_id'],
        subtaskId: subtask['_id'],
        data: data,
      );

      if (!mounted) return;

      _showStatusDialog(
        title: "Status Updated",
        message: "${subtask['title']} has been marked as $status.",
        isError: false,
        onConfirm: onUpdate,
      );

    } catch (e) {
      if (!mounted) return;
      _showStatusDialog(
        title: "Update Failed",
        message: "Could not update status: $e",
        isError: true,
      );
    }
  }

  // Completion note dialog
  Future<String?> _showCompletionNoteDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Complete Subtask',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Add a completion note*',
            hintText: 'Describe what you have completed.',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text(
              'Mark as Completed',
              style: TextStyle(fontFamily: 'Inter', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}