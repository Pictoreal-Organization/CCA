
// // ------------------------------------------------------------------------------------------------------------------------------





// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';

// // Data models
// class Meeting {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime dateTime;
//   final String location;

//   Meeting({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.dateTime,
//     required this.location,
//   });

//   factory Meeting.fromJson(Map<String, dynamic> json) {
//     return Meeting(
//       id: json['_id'] ?? json['id']?.toString() ?? '',
//       title: json['title'] ?? 'Untitled Meeting',
//       description: json['description'] ?? json['body'] ?? 'No description',
//       dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now().add(Duration(days: 1)),
//       location: json['location'] ?? 'Conference Room A',
//     );
//   }
// }

// class Task {
//   final String id;
//   final String title;
//   final String description;
//   final String priority;
//   final DateTime dueDate;
//   final String status;

//   Task({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.priority,
//     required this.dueDate,
//     required this.status,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//       id: json['_id'] ?? json['id']?.toString() ?? '',
//       title: json['title'] ?? 'Untitled Task',
//       description: json['description'] ?? json['body'] ?? 'No description',
//       priority: json['priority'] ?? ['high', 'medium', 'low'][(json['id'] ?? 1) % 3],
//       dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now().add(Duration(days: 7)),
//       status: json['status'] ?? (json['completed'] == true ? 'completed' : 'pending'),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   final String username;
  
//   const HomePage({Key? key, required this.username}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//   List<Meeting> meetings = [];
//   List<Task> tasks = [];
//   bool isLoadingMeetings = true;
//   bool isLoadingTasks = true;
//   String? errorMessage;
//   late final String baseUrl;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _initializeApp();
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _initializeApp() {
//     try {
//       baseUrl = dotenv.env['API_URL'] ?? 'https://jsonplaceholder.typicode.com';
//       print('Using API URL: $baseUrl');
//       _fetchMeetings();
//       _fetchTasks();
//     } catch (e) {
//       print('Error initializing app: $e');
//       setState(() {
//         errorMessage = 'Failed to initialize app: $e';
//         isLoadingMeetings = false;
//         isLoadingTasks = false;
//       });
//     }
//   }

//   // Mock API call for meetings with fallback
//   Future<void> _fetchMeetings() async {
//     try {
//       setState(() {
//         isLoadingMeetings = true;
//         errorMessage = null;
//       });

//       http.Response response;
//       try {
//         response = await http.get(
//           Uri.parse('$baseUrl/api/meetings/status/upcoming'),
//           headers: {'Content-Type': 'application/json'},
//         ).timeout(Duration(seconds: 10));
//       } catch (e) {
//         print('Primary API failed, using mock data: $e');
//         response = await http.get(
//           Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=3'),
//           headers: {'Content-Type': 'application/json'},
//         );
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           meetings = jsonData.map((json) => Meeting.fromJson(json)).toList();
//           isLoadingMeetings = false;
//         });
//       } else {
//         throw Exception('Failed to load meetings: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoadingMeetings = false;
//         errorMessage = 'Error fetching meetings: $e';
//       });
//       print('Error fetching meetings: $e');
//     }
//   }

//   // Mock API call for tasks with fallback
//   Future<void> _fetchTasks() async {
//     try {
//       setState(() {
//         isLoadingTasks = true;
//         errorMessage = null;
//       });

//       http.Response response;
//       try {
//         response = await http.get(
//           Uri.parse('$baseUrl/api/tasks/assigned'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer your_token_here',
//           },
//         ).timeout(Duration(seconds: 10));
//       } catch (e) {
//         print('Primary API failed, using mock data: $e');
//         response = await http.get(
//           Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
//           headers: {'Content-Type': 'application/json'},
//         );
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           tasks = jsonData.map((json) => Task.fromJson(json)).toList();
//           isLoadingTasks = false;
//         });
//       } else {
//         throw Exception('Failed to load tasks: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoadingTasks = false;
//         errorMessage = 'Error fetching tasks: $e';
//       });
//       print('Error fetching tasks: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.blue[600],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           Container(
//             margin: EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.refresh, size: 24),
//               onPressed: () {
//                 _fetchMeetings();
//                 _fetchTasks();
//               },
//             ),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await Future.wait([_fetchMeetings(), _fetchTasks()]);
//         },
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SingleChildScrollView(
//             physics: AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Welcome Section with enhanced design
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(24.0),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.blue[600]!,
//                         Colors.blue[400]!,
//                         Colors.purple[400]!,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         spreadRadius: 0,
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Icon(
//                               Icons.waving_hand,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Text(
//                               'Welcome Back,\n${widget.username}!',
//                               style: const TextStyle(
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 height: 1.2,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         'Here\'s what\'s happening today',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white.withOpacity(0.9),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       if (errorMessage != null) ...[
//                         SizedBox(height: 12),
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             '🎯 Demo mode active',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 32),

//                 // Quick Stats Row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Meetings',
//                         meetings.length.toString(),
//                         Icons.event,
//                         Colors.orange,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Tasks',
//                         tasks.length.toString(),
//                         Icons.task_alt,
//                         Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 32),

//                 // Upcoming Meetings Section
//                 _buildSectionHeader('Upcoming Meetings', Icons.event, Colors.orange),
//                 const SizedBox(height: 16),
//                 _buildMeetingsSection(),
                
//                 const SizedBox(height: 40),

//                 // Assigned Tasks Section
//                 _buildSectionHeader('Assigned Tasks', Icons.task_alt, Colors.green),
//                 const SizedBox(height: 16),
//                 _buildTasksSection(),

//                 SizedBox(height: 20), // Bottom padding
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String count, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.1),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 28),
//           ),
//           SizedBox(height: 12),
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 26,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMeetingsSection() {
//     if (isLoadingMeetings) {
//       return Container(
//         height: 200,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(strokeWidth: 3),
//               SizedBox(height: 16),
//               Text(
//                 'Loading meetings...',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (meetings.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 0,
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Column(
//             children: [
//               Icon(
//                 Icons.event_busy,
//                 size: 64,
//                 color: Colors.grey[400],
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'No upcoming meetings',
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Your schedule is clear for now',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: meetings.asMap().entries.map((entry) {
//         int index = entry.key;
//         Meeting meeting = entry.value;
//         return AnimatedContainer(
//           duration: Duration(milliseconds: 300 + (index * 100)),
//           child: _buildMeetingCard(meeting),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildMeetingCard(Meeting meeting) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(Icons.event, color: Colors.orange[600], size: 24),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   meeting.title,
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             meeting.description,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[700],
//               height: 1.4,
//             ),
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.access_time, color: Colors.blue[600], size: 18),
//                     const SizedBox(width: 6),
//                     Text(
//                       '${meeting.dateTime.day}/${meeting.dateTime.month} at ${meeting.dateTime.hour}:${meeting.dateTime.minute.toString().padLeft(2, '0')}',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.blue[700],
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.location_on, color: Colors.green[600], size: 18),
//                     const SizedBox(width: 6),
//                     Text(
//                       meeting.location,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.green[700],
//                         fontWeight: FontWeight.w600,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTasksSection() {
//     if (isLoadingTasks) {
//       return Container(
//         height: 200,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(strokeWidth: 3),
//               SizedBox(height: 16),
//               Text(
//                 'Loading tasks...',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (tasks.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 0,
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Column(
//             children: [
//               Icon(
//                 Icons.task_outlined,
//                 size: 64,
//                 color: Colors.grey[400],
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'No assigned tasks',
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'All caught up! Great work!',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: tasks.asMap().entries.map((entry) {
//         int index = entry.key;
//         Task task = entry.value;
//         return AnimatedContainer(
//           duration: Duration(milliseconds: 300 + (index * 100)),
//           child: _buildTaskCard(task),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildTaskCard(Task task) {
//     Color priorityColor = task.priority.toLowerCase() == 'high' 
//         ? Colors.red 
//         : task.priority.toLowerCase() == 'medium' 
//             ? Colors.orange 
//             : Colors.green;

//     bool isCompleted = task.status.toLowerCase() == 'completed';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 0,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: isCompleted 
//                       ? Colors.green.withOpacity(0.1)
//                       : Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   isCompleted ? Icons.check_circle : Icons.task_alt, 
//                   color: isCompleted ? Colors.green[600] : Colors.blue[600], 
//                   size: 24
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   task.title,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     decoration: isCompleted 
//                         ? TextDecoration.lineThrough 
//                         : TextDecoration.none,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: priorityColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   task.priority.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: priorityColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             task.description,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[700],
//               height: 1.4,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.purple.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.schedule, color: Colors.purple[600], size: 18),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.purple[700],
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isCompleted 
//                       ? Colors.green.withOpacity(0.1)
//                       : Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       isCompleted ? Icons.check_circle : Icons.info_outline, 
//                       color: isCompleted ? Colors.green[600] : Colors.orange[600], 
//                       size: 18
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       task.status.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: isCompleted ? Colors.green[700] : Colors.orange[700],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }






// ------------------------------------------------------------------------------------------------------------------------------







// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';

// // Data models
// class Meeting {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime dateTime;
//   final String location;

//   Meeting({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.dateTime,
//     required this.location,
//   });

//   factory Meeting.fromJson(Map<String, dynamic> json) {
//     return Meeting(
//       id: json['_id'],
//       title: json['title'],
//       description: json['description'],
//       dateTime: DateTime.parse(json['dateTime']),
//       location: json['location'],
//     );
//   }
// }

// class Task {
//   final String id;
//   final String title;
//   final String description;
//   final String priority;
//   final DateTime dueDate;
//   final String status;

//   Task({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.priority,
//     required this.dueDate,
//     required this.status,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//       id: json['_id'],
//       title: json['title'],
//       description: json['description'],
//       priority: json['priority'],
//       dueDate: DateTime.parse(json['dueDate']),
//       status: json['status'],
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   final String username;
  
//   const HomePage({Key? key, required this.username}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<Meeting> meetings = [];
//   List<Task> tasks = [];
//   bool isLoadingMeetings = true;
//   bool isLoadingTasks = true;
//   String? errorMessage;
//   late final String baseUrl;

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   void _initializeApp() {
//     try {
//       baseUrl = dotenv.env['API_URL'] ?? 'https://jsonplaceholder.typicode.com';
//       _fetchMeetings();
//       _fetchTasks();
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to initialize app: $e';
//         isLoadingMeetings = false;
//         isLoadingTasks = false;
//       });
//     }
//   }

//   Future<void> _fetchMeetings() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/meetings/status/upcoming'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           meetings = jsonData.map((json) => Meeting.fromJson(json)).toList();
//           isLoadingMeetings = false;
//         });
//       } else {
//         throw Exception('Failed to load meetings');
//       }
//     } catch (e) {
//       setState(() {
//         isLoadingMeetings = false;
//       });
//     }
//   }

//   Future<void> _fetchTasks() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/tasks/assigned'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer your_token_here',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           tasks = jsonData.map((json) => Task.fromJson(json)).toList();
//           isLoadingTasks = false;
//         });
//       } else {
//         throw Exception('Failed to load tasks');
//       }
//     } catch (e) {
//       setState(() {
//         isLoadingTasks = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         backgroundColor: Colors.blue[600],
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await Future.wait([_fetchMeetings(), _fetchTasks()]);
//         },
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24.0),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.blue[700]!, Colors.blue[400]!],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withOpacity(0.2),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   'Welcome ${widget.username}!',
//                   style: const TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _buildSectionHeader('Upcoming Meetings', Icons.event),
//               const SizedBox(height: 12),
//               _buildMeetingsSection(),
//               const SizedBox(height: 32),
//               _buildSectionHeader('Assigned Tasks', Icons.task_alt),
//               const SizedBox(height: 12),
//               _buildTasksSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.grey[700], size: 26),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.w700,
//             color: Colors.grey[800],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMeetingCard(Meeting meeting) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             spreadRadius: 1,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.event, color: Colors.blue[600], size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   meeting.title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             meeting.description,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Icon(Icons.access_time, color: Colors.grey[600], size: 18),
//               const SizedBox(width: 6),
//               Text(
//                 '${meeting.dateTime.day}/${meeting.dateTime.month} at ${meeting.dateTime.hour}:${meeting.dateTime.minute.toString().padLeft(2, '0')}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Icon(Icons.location_on, color: Colors.grey[600], size: 18),
//               const SizedBox(width: 6),
//               Text(
//                 meeting.location,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMeetingsSection() {
//     if (isLoadingMeetings) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (meetings.isEmpty) {
//       return _buildEmptyCard('No upcoming meetings');
//     }
//     return Column(
//       children: meetings.map((meeting) => _buildMeetingCard(meeting)).toList(),
//     );
//   }

//   Widget _buildTasksSection() {
//     if (isLoadingTasks) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (tasks.isEmpty) {
//       return _buildEmptyCard('No assigned tasks');
//     }
//     return Column(
//       children: tasks.map((task) => _buildTaskCard(task)).toList(),
//     );
//   }

//   Widget _buildTaskCard(Task task) {
//     Color priorityColor = task.priority.toLowerCase() == 'high' 
//         ? Colors.red 
//         : task.priority.toLowerCase() == 'medium' 
//             ? Colors.orange 
//             : Colors.green;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.task_alt, color: Colors.green[600], size: 24),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   task.title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: priorityColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   task.priority,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: priorityColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             task.description,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Icon(Icons.schedule, color: Colors.grey[600], size: 18),
//               const SizedBox(width: 6),
//               Text(
//                 'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Icon(Icons.info_outline, color: Colors.grey[600], size: 18),
//               const SizedBox(width: 6),
//               Text(
//                 task.status,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyCard(String message) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           message,
//           style: const TextStyle(
//             fontSize: 16,
//             color: Colors.grey,
//           ),
//         ),
//       ),
//     );
//   }
// }




// ------------------------------------------------------------------------------------------------------------------------------






// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';

// // Custom color palette
// class AppColors {
//   static const Color darkGreen = Color(0xFF0B545A);     // #0b545a
//   static const Color lightOrange = Color(0xFFF8AD51);   // #f8ad51  
//   static const Color tealBlue = Color(0xFF5FB6B0);      // #5fb6b0
//   static const Color lightYellow = Color(0xFFF5D49F);   // #f5d49f
  
//   // Additional complementary colors
//   static const Color softWhite = Color(0xFFFAFAFA);
//   static const Color cardWhite = Color(0xFFFFFFFF);
//   static const Color textDark = Color(0xFF2C3E50);
//   static const Color textLight = Color(0xFF7F8C8D);
// }

// // Data models
// class Meeting {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime dateTime;
//   final String location;

//   Meeting({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.dateTime,
//     required this.location,
//   });

//   factory Meeting.fromJson(Map<String, dynamic> json) {
//     return Meeting(
//       id: json['_id'] ?? json['id']?.toString() ?? '',
//       title: json['title'] ?? 'Untitled Meeting',
//       description: json['description'] ?? json['body'] ?? 'No description',
//       dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now().add(Duration(days: 1)),
//       location: json['location'] ?? 'Conference Room A',
//     );
//   }
// }

// class Task {
//   final String id;
//   final String title;
//   final String description;
//   final String priority;
//   final DateTime dueDate;
//   final String status;

//   Task({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.priority,
//     required this.dueDate,
//     required this.status,
//   });

//   factory Task.fromJson(Map<String, dynamic> json) {
//     return Task(
//       id: json['_id'] ?? json['id']?.toString() ?? '',
//       title: json['title'] ?? 'Untitled Task',
//       description: json['description'] ?? json['body'] ?? 'No description',
//       priority: json['priority'] ?? ['high', 'medium', 'low'][(json['id'] ?? 1) % 3],
//       dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now().add(Duration(days: 7)),
//       status: json['status'] ?? (json['completed'] == true ? 'completed' : 'pending'),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   final String username;
  
//   const HomePage({Key? key, required this.username}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//   List<Meeting> meetings = [];
//   List<Task> tasks = [];
//   bool isLoadingMeetings = true;
//   bool isLoadingTasks = true;
//   String? errorMessage;
//   late final String baseUrl;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _initializeApp();
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _initializeApp() {
//     try {
//       baseUrl = dotenv.env['API_URL'] ?? 'https://jsonplaceholder.typicode.com';
//       print('Using API URL: $baseUrl');
//       _fetchMeetings();
//       _fetchTasks();
//     } catch (e) {
//       print('Error initializing app: $e');
//       setState(() {
//         errorMessage = 'Failed to initialize app: $e';
//         isLoadingMeetings = false;
//         isLoadingTasks = false;
//       });
//     }
//   }

//   // Mock API call for meetings with fallback
//   Future<void> _fetchMeetings() async {
//     try {
//       setState(() {
//         isLoadingMeetings = true;
//         errorMessage = null;
//       });

//       http.Response response;
//       try {
//         response = await http.get(
//           Uri.parse('$baseUrl/api/meetings/status/upcoming'),
//           headers: {'Content-Type': 'application/json'},
//         ).timeout(Duration(seconds: 10));
//       } catch (e) {
//         print('Primary API failed, using mock data: $e');
//         response = await http.get(
//           Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=3'),
//           headers: {'Content-Type': 'application/json'},
//         );
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           meetings = jsonData.map((json) => Meeting.fromJson(json)).toList();
//           isLoadingMeetings = false;
//         });
//       } else {
//         throw Exception('Failed to load meetings: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoadingMeetings = false;
//         errorMessage = 'Error fetching meetings: $e';
//       });
//       print('Error fetching meetings: $e');
//     }
//   }

//   // Mock API call for tasks with fallback
//   Future<void> _fetchTasks() async {
//     try {
//       setState(() {
//         isLoadingTasks = true;
//         errorMessage = null;
//       });

//       http.Response response;
//       try {
//         response = await http.get(
//           Uri.parse('$baseUrl/api/tasks/assigned'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer your_token_here',
//           },
//         ).timeout(Duration(seconds: 10));
//       } catch (e) {
//         print('Primary API failed, using mock data: $e');
//         response = await http.get(
//           Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
//           headers: {'Content-Type': 'application/json'},
//         );
//       }

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           tasks = jsonData.map((json) => Task.fromJson(json)).toList();
//           isLoadingTasks = false;
//         });
//       } else {
//         throw Exception('Failed to load tasks: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoadingTasks = false;
//         errorMessage = 'Error fetching tasks: $e';
//       });
//       print('Error fetching tasks: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.softWhite,
//       appBar: AppBar(
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: AppColors.darkGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           Container(
//             margin: EdgeInsets.only(right: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.refresh, size: 24),
//               onPressed: () {
//                 _fetchMeetings();
//                 _fetchTasks();
//               },
//             ),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await Future.wait([_fetchMeetings(), _fetchTasks()]);
//         },
//         color: AppColors.darkGreen,
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SingleChildScrollView(
//             physics: AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Welcome Section with enhanced design
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(28.0),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.darkGreen,
//                         AppColors.tealBlue,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.darkGreen.withOpacity(0.3),
//                         spreadRadius: 0,
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(18),
//                             ),
//                             child: Icon(
//                               Icons.dashboard_rounded,
//                               color: Colors.white,
//                               size: 30,
//                             ),
//                           ),
//                           SizedBox(width: 18),
//                           Expanded(
//                             child: Text(
//                               'Welcome Back,\n${widget.username}!',
//                               style: const TextStyle(
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 height: 1.2,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'Here\'s your overview for today',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white.withOpacity(0.9),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       if (errorMessage != null) ...[
//                         SizedBox(height: 16),
//                         Container(
//                           padding: EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             color: AppColors.lightYellow.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: AppColors.lightYellow.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Demo mode active',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
                
//                 const SizedBox(height: 32),

//                 // Quick Stats Row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Meetings',
//                         meetings.length.toString(),
//                         Icons.event_note_rounded,
//                         AppColors.lightOrange,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Tasks',
//                         tasks.length.toString(),
//                         Icons.task_rounded,
//                         AppColors.tealBlue,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 36),

//                 // Upcoming Meetings Section
//                 _buildSectionHeader('Upcoming Meetings', Icons.event_note_rounded, AppColors.lightOrange),
//                 const SizedBox(height: 18),
//                 _buildMeetingsSection(),
                
//                 const SizedBox(height: 40),

//                 // Assigned Tasks Section
//                 _buildSectionHeader('Assigned Tasks', Icons.task_rounded, AppColors.tealBlue),
//                 const SizedBox(height: 18),
//                 _buildTasksSection(),

//                 SizedBox(height: 24), // Bottom padding
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String count, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: AppColors.cardWhite,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.15),
//             spreadRadius: 0,
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(icon, color: color, size: 32),
//           ),
//           SizedBox(height: 16),
//           Text(
//             count,
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textDark,
//             ),
//           ),
//           SizedBox(height: 6),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.textLight,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Icon(icon, color: color, size: 26),
//         ),
//         const SizedBox(width: 16),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textDark,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMeetingsSection() {
//     if (isLoadingMeetings) {
//       return Container(
//         height: 200,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(
//                 strokeWidth: 3,
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Loading meetings...',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: AppColors.textLight,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (meetings.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(36),
//         decoration: BoxDecoration(
//           color: AppColors.cardWhite,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.08),
//               spreadRadius: 0,
//               blurRadius: 15,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.lightYellow.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   Icons.event_busy_rounded,
//                   size: 48,
//                   color: AppColors.lightOrange,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'No upcoming meetings',
//                 style: TextStyle(
//                   fontSize: 22,
//                   color: AppColors.textDark,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Your calendar is clear for now',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: AppColors.textLight,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: meetings.asMap().entries.map((entry) {
//         int index = entry.key;
//         Meeting meeting = entry.value;
//         return AnimatedContainer(
//           duration: Duration(milliseconds: 300 + (index * 100)),
//           child: _buildMeetingCard(meeting),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildMeetingCard(Meeting meeting) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 18),
//       padding: const EdgeInsets.all(26),
//       decoration: BoxDecoration(
//         color: AppColors.cardWhite,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 0,
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: AppColors.lightOrange.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(Icons.event_note_rounded, color: AppColors.lightOrange, size: 26),
//               ),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: Text(
//                   meeting.title,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textDark,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           Text(
//             meeting.description,
//             style: TextStyle(
//               fontSize: 17,
//               color: AppColors.textLight,
//               height: 1.5,
//             ),
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 22),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.tealBlue.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.schedule_rounded, color: AppColors.tealBlue, size: 18),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${meeting.dateTime.day}/${meeting.dateTime.month} at ${meeting.dateTime.hour}:${meeting.dateTime.minute.toString().padLeft(2, '0')}',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: AppColors.tealBlue,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.darkGreen.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.location_on_rounded, color: AppColors.darkGreen, size: 18),
//                     const SizedBox(width: 8),
//                     Text(
//                       meeting.location,
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: AppColors.darkGreen,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTasksSection() {
//     if (isLoadingTasks) {
//       return Container(
//         height: 200,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(
//                 strokeWidth: 3,
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Loading tasks...',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: AppColors.textLight,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (tasks.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(36),
//         decoration: BoxDecoration(
//           color: AppColors.cardWhite,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.08),
//               spreadRadius: 0,
//               blurRadius: 15,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.tealBlue.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   Icons.task_alt_rounded,
//                   size: 48,
//                   color: AppColors.tealBlue,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'No assigned tasks',
//                 style: TextStyle(
//                   fontSize: 22,
//                   color: AppColors.textDark,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'All caught up! Great work!',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: AppColors.textLight,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: tasks.asMap().entries.map((entry) {
//         int index = entry.key;
//         Task task = entry.value;
//         return AnimatedContainer(
//           duration: Duration(milliseconds: 300 + (index * 100)),
//           child: _buildTaskCard(task),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildTaskCard(Task task) {
//     Color priorityColor = task.priority.toLowerCase() == 'high' 
//         ? Color(0xFFE74C3C)  // Red for high priority
//         : task.priority.toLowerCase() == 'medium' 
//             ? AppColors.lightOrange  // Orange for medium
//             : AppColors.tealBlue;    // Teal for low priority

//     bool isCompleted = task.status.toLowerCase() == 'completed';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 18),
//       padding: const EdgeInsets.all(26),
//       decoration: BoxDecoration(
//         color: AppColors.cardWhite,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 0,
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: isCompleted 
//                       ? AppColors.tealBlue.withOpacity(0.15)
//                       : AppColors.darkGreen.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Icon(
//                   isCompleted ? Icons.check_circle_rounded : Icons.task_rounded, 
//                   color: isCompleted ? AppColors.tealBlue : AppColors.darkGreen, 
//                   size: 26
//                 ),
//               ),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: Text(
//                   task.title,
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textDark,
//                     decoration: isCompleted 
//                         ? TextDecoration.lineThrough 
//                         : TextDecoration.none,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: priorityColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   task.priority.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: priorityColor,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           Text(
//             task.description,
//             style: TextStyle(
//               fontSize: 17,
//               color: AppColors.textLight,
//               height: 1.5,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 22),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.lightYellow.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.schedule_rounded, color: AppColors.lightOrange, size: 18),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: AppColors.lightOrange,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: isCompleted 
//                       ? AppColors.tealBlue.withOpacity(0.15)
//                       : AppColors.lightOrange.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded, 
//                       color: isCompleted ? AppColors.tealBlue : AppColors.lightOrange, 
//                       size: 18
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       task.status.toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: isCompleted ? AppColors.tealBlue : AppColors.lightOrange,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }




// ------------------------------------------------------------------------------------------------------------------------------






import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

// Data models
class Meeting {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Meeting',
      description: json['description'] ?? json['body'] ?? 'No description',
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now().add(Duration(days: 1)),
      location: json['location'] ?? 'Conference Room A',
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime dueDate;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Task',
      description: json['description'] ?? json['body'] ?? 'No description',
      priority: json['priority'] ?? ['high', 'medium', 'low'][(json['id'] ?? 1) % 3],
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now().add(Duration(days: 7)),
      status: json['status'] ?? (json['completed'] == true ? 'completed' : 'pending'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  
  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Meeting> meetings = [];
  List<Task> tasks = [];
  bool isLoadingMeetings = true;
  bool isLoadingTasks = true;
  String? errorMessage;
  late final String baseUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeApp();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeApp() {
    try {
      baseUrl = dotenv.env['API_URL'] ?? 'https://jsonplaceholder.typicode.com';
      print('Using API URL: $baseUrl');
      _fetchMeetings();
      _fetchTasks();
    } catch (e) {
      print('Error initializing app: $e');
      setState(() {
        errorMessage = 'Failed to initialize app: $e';
        isLoadingMeetings = false;
        isLoadingTasks = false;
      });
    }
  }

  // Mock API call for meetings with fallback
  Future<void> _fetchMeetings() async {
    try {
      setState(() {
        isLoadingMeetings = true;
        errorMessage = null;
      });

      http.Response response;
      try {
        response = await http.get(
          Uri.parse('$baseUrl/api/meetings/status/upcoming'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: 10));
      } catch (e) {
        print('Primary API failed, using mock data: $e');
        response = await http.get(
          Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=3'),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          meetings = jsonData.map((json) => Meeting.fromJson(json)).toList();
          isLoadingMeetings = false;
        });
      } else {
        throw Exception('Failed to load meetings: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingMeetings = false;
        errorMessage = 'Error fetching meetings: $e';
      });
      print('Error fetching meetings: $e');
    }
  }

  // Mock API call for tasks with fallback
  Future<void> _fetchTasks() async {
    try {
      setState(() {
        isLoadingTasks = true;
        errorMessage = null;
      });

      http.Response response;
      try {
        response = await http.get(
          Uri.parse('$baseUrl/api/tasks/team/688517e5a7acdb810118f874'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer your_token_here',
          },
        ).timeout(Duration(seconds: 10));
      } catch (e) {
        print('Primary API failed, using mock data: $e');
        response = await http.get(
          Uri.parse('https://jsonplaceholder.typicode.com/todos?_limit=5'),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          tasks = jsonData.map((json) => Task.fromJson(json)).toList();
          isLoadingTasks = false;
        });
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoadingTasks = false;
        errorMessage = 'Error fetching tasks: $e';
      });
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, size: 24),
              onPressed: () {
                _fetchMeetings();
                _fetchTasks();
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchMeetings(), _fetchTasks()]);
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with enhanced design
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[600]!,
                        Colors.blue[400]!,
                        Colors.purple[400]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.waving_hand,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Welcome Back,\n${widget.username}!',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Here\'s what\'s happening today',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (errorMessage != null) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🎯 Demo mode active',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Meetings',
                        meetings.length.toString(),
                        Icons.event,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Tasks',
                        tasks.length.toString(),
                        Icons.task_alt,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Upcoming Meetings Section
                _buildSectionHeader('Upcoming Meetings', Icons.event, Colors.orange),
                const SizedBox(height: 16),
                _buildMeetingsSection(),
                
                const SizedBox(height: 40),

                // Assigned Tasks Section
                _buildSectionHeader('Assigned Tasks', Icons.task_alt, Colors.green),
                const SizedBox(height: 16),
                _buildTasksSection(),

                SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingsSection() {
    if (isLoadingMeetings) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Loading meetings...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (meetings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No upcoming meetings',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your schedule is clear for now',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: meetings.asMap().entries.map((entry) {
        int index = entry.key;
        Meeting meeting = entry.value;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _buildMeetingCard(meeting),
        );
      }).toList(),
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event, color: Colors.orange[600], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  meeting.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            meeting.description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, color: Colors.blue[600], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${meeting.dateTime.day}/${meeting.dateTime.month} at ${meeting.dateTime.hour}:${meeting.dateTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.green[600], size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        meeting.location,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    if (isLoadingTasks) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Loading tasks...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.task_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No assigned tasks',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'All caught up! Great work!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: tasks.asMap().entries.map((entry) {
        int index = entry.key;
        Task task = entry.value;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _buildTaskCard(task),
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor = task.priority.toLowerCase() == 'high' 
        ? Colors.red 
        : task.priority.toLowerCase() == 'medium' 
            ? Colors.orange 
            : Colors.green;

    bool isCompleted = task.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.task_alt, 
                  color: isCompleted ? Colors.green[600] : Colors.blue[600], 
                  size: 24
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    decoration: isCompleted 
                        ? TextDecoration.lineThrough 
                        : TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: Colors.purple[600], size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.info_outline, 
                      color: isCompleted ? Colors.green[600] : Colors.orange[600], 
                      size: 18
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        task.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: isCompleted ? Colors.green[700] : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}