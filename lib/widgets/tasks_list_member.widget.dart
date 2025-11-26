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
import '../services/task_service.dart';

class TasksListMember extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // --- 1. SORTING LOGIC (Pending First) ---
    List sortedTasks = List.from(tasks);
    
    for (var task in sortedTasks) {
      if (task['subtasks'] != null) {
        List subtasks = List.from(task['subtasks']);
        subtasks.sort((a, b) {
          // Put 'Pending' before 'Completed'
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        sortedTasks.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("You have no tasks assigned."),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];
                  final subtasks = task['subtasks'] as List;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Inter',
                            ),
                          ),
                          ...subtasks.map((sub) {
                            final currentStatus = sub['status'];
                            final isCompleted = currentStatus == 'Completed';

                            return Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sub['title'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                      // --- 2. COLORED STATUS BADGE ---
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? AppColors.darkTeal.withOpacity(0.1)
                                              : AppColors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isCompleted
                                                ? AppColors.darkTeal
                                                : AppColors.orange,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          currentStatus,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isCompleted
                                                ? AppColors.darkTeal
                                                : AppColors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sub['description'] ?? 'No description provided.',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // --- 3. ACTION BUTTON (Only for Pending) ---
                                  if (!isCompleted)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                        label: const Text(
                                          "Mark as Completed",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () => _handleStatusChange(
                                          context,
                                          'Completed',
                                          task,
                                          sub,
                                          onTaskUpdated,
                                        ),
                                      ),
                                    ),
                                  
                                  // Separator line between subtasks
                                  const SizedBox(height: 8),
                                  const Divider(),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

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
    final taskService = TaskService();
    try {
      final data = {'status': status};
      if (description != null) data['description'] = description;

      await taskService.updateSubtask(
        taskId: task['_id'],
        subtaskId: subtask['_id'],
        data: data,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${subtask['title']} status updated!'),
          duration: const Duration(seconds: 2),
        ),
      );
      onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal),
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