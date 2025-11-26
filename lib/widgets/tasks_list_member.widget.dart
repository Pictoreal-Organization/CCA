// import 'package:cca/core/app_colors.dart';
// import 'package:flutter/material.dart';
// import '../services/task_service.dart';

// class TasksListMember extends StatelessWidget {
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
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 12),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Inter',
//           ),
//         ),
//         const SizedBox(height: 8),
//         tasks.isEmpty
//             ? const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Text("You have no tasks assigned."),
//                 ),
//               )
//             : ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: tasks.length,
//                 itemBuilder: (context, index) {
//                   final task = tasks[index];
//                   final subtasks = task['subtasks'] as List;
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             task['title'],
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                               fontFamily: 'Inter',
//                             ),
//                           ),
//                           ...subtasks.map((sub) {
//                             final currentStatus = sub['status'];
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     sub['title'],
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     sub['description'] ??
//                                         'No description provided.',
//                                     style: const TextStyle(
//                                       color: Colors.black54,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   if (currentStatus == 'Completed')
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 6,
//                                         horizontal: 12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.darkTeal,
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: const Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Icon(
//                                             Icons.check_circle,
//                                             color: Colors.white,
//                                           ),
//                                           SizedBox(width: 6),
//                                           Text(
//                                             "Completed",
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                               fontFamily: 'Inter',
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   else
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: ElevatedButton.icon(
//                                             icon: const Icon(Icons.pending),
//                                             label: const Text(
//                                               "Pending",
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontFamily: 'Inter',
//                                               ),
//                                             ),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor:
//                                                   AppColors.orange,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                             ),
//                                             onPressed: () => _handleStatusChange(
//                                               context,
//                                               'Pending',
//                                               task,
//                                               sub,
//                                               onTaskUpdated,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                           child: ElevatedButton.icon(
//                                             icon: const Icon(Icons.done_all),
//                                             label: const Text(
//                                               "Completed",
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontFamily: 'Inter',
//                                               ),
//                                             ),
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: AppColors.green,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                             ),
//                                             onPressed: () => _handleStatusChange(
//                                               context,
//                                               'Completed',
//                                               task,
//                                               sub,
//                                               onTaskUpdated,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ],
//     );
//   }

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

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${subtask['title']} status updated!'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//       onUpdate();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<String?> _showCompletionNoteDialog(BuildContext context) {
//     final controller = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text(
//           'Complete Subtask',
//           style: TextStyle(fontFamily: 'Inter'),
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
//             child: const Text(
//               'Cancel',
//               style: TextStyle(fontFamily: 'Inter'),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.text.trim().isNotEmpty) {
//                 Navigator.pop(context, controller.text);
//               }
//             },
//             child: const Text(
//               'Mark as Completed',
//               style: TextStyle(fontFamily: 'Inter'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cca/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure this is imported for date formatting
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
  final TaskService taskService = TaskService();
  
  // Track which tasks are expanded
  Set<String> expandedTasks = {};

  @override
  Widget build(BuildContext context) {
    // --- SORTING LOGIC ---
    List sortedTasks = List.from(widget.tasks);
    for (var task in sortedTasks) {
      if (task['subtasks'] != null) {
        List subtasks = List.from(task['subtasks']);
        subtasks.sort((a, b) {
          if (a['status'] == 'Pending' && b['status'] != 'Pending') return -1;
          if (a['status'] != 'Pending' && b['status'] == 'Pending') return 1;
          return 0;
        });
        task['subtasks'] = subtasks;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              "${widget.tasks.length} Tasks",
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
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 64, color: Color(0xFFBDBDBD)),
                      SizedBox(height: 16),
                      Text("You have no tasks assigned.",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF757575),
                              fontFamily: 'Inter')),
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
                  return _buildMemberTaskCard(task);
                },
              ),
      ],
    );
  }

  Widget _buildMemberTaskCard(dynamic task) {
    final subtasks = (task['subtasks'] as List?) ?? [];
    
    // Calculate stats
    final completedSubtasks = subtasks.where((s) => s['status'] == 'Completed').length;
    final totalSubtasks = subtasks.length;
    final isCompleted = task['status'] == 'Completed';
    
    // Colors matching Head Dashboard style
    final borderColor = isCompleted ? AppColors.green : AppColors.orange;
    final taskId = task['_id'];
    final isExpanded = expandedTasks.contains(taskId);
    
    // Date Formatting
    String formattedDeadline = "";
    if (task['deadline'] != null) {
      final date = DateTime.parse(task['deadline']).toLocal();
      formattedDeadline = DateFormat('d MMM').format(date);
    }

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
                    // --- HEADER ROW ---
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
                                if (formattedDeadline.isNotEmpty)
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
                                  "📌 $completedSubtasks/$totalSubtasks",
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
                    
                    // --- SUBTASKS LIST (Only show when expanded) ---
                    if (isExpanded) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: subtasks.map<Widget>((sub) {
                            final subTitle = sub['title'];
                            final subDesc = sub['description'] ?? 'No description';
                            final subStatus = sub['status'];
                            final isSubCompleted = subStatus == 'Completed';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50, // Inner card BG
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title & Badge Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          subTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                      // --- STATUS BADGE ---
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSubCompleted
                                              ? AppColors.green.withOpacity(0.1)
                                              : AppColors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          subStatus,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSubCompleted
                                                ? AppColors.green
                                                : AppColors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 6),
                                  
                                  // Description
                                  Text(
                                    subDesc,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // --- ACTION BUTTON ---
                                  if (isSubCompleted)
                                    // Completed State
                                    SizedBox(
                                      width: double.infinity,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkTeal,
                                          borderRadius: BorderRadius.circular(9),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.white, size: 16),
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
                                      ),
                                    )
                                  else
                                    // Mark as Completed Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check, size: 16, color: Colors.white),
                                        label: const Text("Mark as Completed"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(9),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          elevation: 0,
                                        ),
                                        onPressed: () => _handleStatusChange(
                                          context,
                                          'Completed',
                                          task,
                                          sub,
                                          widget.onTaskUpdated,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC METHODS (Same as before) ---
  
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

  void _updateSubtaskApi(
    BuildContext context,
    String status,
    dynamic task,
    dynamic subtask,
    VoidCallback onUpdate, {
    String? description,
  }) async {
    try {
      final data = {'status': status};
      if (description != null) data['description'] = description;

      await taskService.updateSubtask(
        taskId: task['_id'],
        subtaskId: subtask['_id'],
        data: data,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${subtask['title']} status updated!'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.darkTeal,
          ),
        );
      }
      onUpdate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showCompletionNoteDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Inter', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Mark as Completed'),
          ),
        ],
      ),
    );
  }
}