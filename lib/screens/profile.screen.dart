// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/task_service.dart';
// import '../services/user_service.dart';
// import '../services/notification_handler.dart'; // ✅ Ensure this import exists
// import '../widgets/loading_animation.widget.dart';
// import '../widgets/customAppbar.widget.dart';
// import '../core/app_colors.dart';

// class AvatarConfig {
//   static final List<String> avatarPaths = [
//     'assets/images/Avatars/Avatar1.png',
//     'assets/images/Avatars/Avatar2.png',
//     'assets/images/Avatars/Avatar3.png',
//     'assets/images/Avatars/Avatar4.png',
//     'assets/images/Avatars/Avatar5.png',
//     'assets/images/Avatars/Avatar6.png',
//     'assets/images/Avatars/Avatar7.png',
//     'assets/images/Avatars/Avatar8.png',
//     'assets/images/Avatars/Avatar9.png',
//   ];

//   static const String defaultAvatar = 'assets/images/Avatars/default.png';
// }

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   // Services
//   final UserService userService = UserService();
//   final TaskService taskService = TaskService();

//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _rollController = TextEditingController();
//   final TextEditingController _yearController = TextEditingController();
//   final TextEditingController _divisionController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   // State
//   bool _isLoading = true;
//   bool _isEditing = false;
//   bool _notificationsEnabled = true;
//   String _email = "";
//   String _role = "";
//   String _userId = "";
//   String _userTeam = "";
//   List _completedTasks = [];
//   String _selectedAvatar = AvatarConfig.defaultAvatar;

//   @override
//   void initState() {
//     super.initState();
//     loadAllData();
//     _loadNotificationPreference();
//   }

//   Future<void> _loadNotificationPreference() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (mounted) {
//       setState(() {
//         _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
//       });
//     }
//   }

//   // ✅ Notification Toggle Logic
//   Future<void> _toggleNotifications(bool value) async {
//     // 1. Update UI immediately
//     setState(() => _notificationsEnabled = value);

//     // 2. Call Handler to manage Token & Preference
//     await NotificationHandler().toggleNotifications(value);

//     // 3. Show Feedback
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(value ? "Notifications Enabled ✅" : "Notifications Disabled 🔕"),
//           duration: const Duration(seconds: 1),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   Future<void> _saveAvatar(String avatarPath) async {
//     setState(() {
//       _selectedAvatar = avatarPath;
//     });
//   }

//   void _showAvatarSelectionModal() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           insetPadding: const EdgeInsets.all(20),
//           child: _buildAvatarSelectionContent(),
//         );
//       },
//     );
//   }

//   Future<void> loadAllData() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);

//     try {
//       final user = await userService.getLoggedInUser();

//       _userId = user['_id'] ?? '';
//       _email = user['email'] ?? '';
//       _role = user['role'] ?? '';

//       // Extract team ID safely
//       if (user['team'] != null) {
//         if (user['team'] is List && (user['team'] as List).isNotEmpty) {
//           _userTeam = user['team'][0]['_id'] ?? user['team'][0].toString();
//         } else if (user['team'] is Map) {
//           _userTeam = user['team']['_id'] ?? '';
//         } else {
//           _userTeam = user['team'].toString();
//         }
//       } else {
//         _userTeam = '';
//       }

//       _nameController.text = user['name'] ?? '';
//       _rollController.text = user['rollNo'] ?? '';
//       _yearController.text = user['year'] ?? '';
//       _divisionController.text = user['division'] ?? '';
//       _phoneController.text = user['phone'] ?? '';

//       _selectedAvatar = user['avatar'] ?? AvatarConfig.defaultAvatar;

//       // Load completed tasks based on role
//       if (_role == 'Head') {
//         if (_userTeam.isNotEmpty) {
//           _completedTasks = await taskService.getCompletedTasksByTeam(_userTeam);
//         } else {
//           _completedTasks = await taskService.getAllCompletedTasks();
//         }
//       } else if (_role == 'Member' && _userId.isNotEmpty) {
//         _completedTasks = await taskService.getCompletedTasksByUser(_userId);
//       }
//     } catch (e) {
//       print('Error loading data: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to load profile data: $e")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> saveProfile() async {
//     setState(() => _isLoading = true);
//     try {
//       await userService.updateUserProfile(
//         name: _nameController.text,
//         rollNo: _rollController.text,
//         year: _yearController.text,
//         division: _divisionController.text,
//         phone: _phoneController.text,
//         avatar: _selectedAvatar,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Profile updated successfully")),
//       );

//       setState(() => _isEditing = false);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update profile: $e")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: customAppBar(
//         title: "Profile",
//         context: context,
//         showEdit: true,
//         isEditing: _isEditing,
//         onEditToggle: () {
//           if (_isEditing) {
//             saveProfile();
//           } else {
//             setState(() => _isEditing = true);
//           }
//         },
//       ),
//       body: _isLoading
//           ? const Center(child: LoadingAnimation(size: 250))
//           : RefreshIndicator(
//               color: AppColors.green,
//               backgroundColor: Colors.white,
//               onRefresh: loadAllData,
//               child: ListView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(20.0),
//                 children: [
//                   // --- Profile Header ---
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Stack(
//                         children: [
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.white.withOpacity(0.2),
//                               border: Border.all(color: Colors.white, width: 3),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(2, 2),
//                                 ),
//                               ],
//                             ),
//                             child: ClipOval(
//                               child: Image.asset(
//                                 _selectedAvatar,
//                                 width: 74,
//                                 height: 74,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Icon(
//                                     Icons.account_circle_rounded,
//                                     size: 74,
//                                     color: Colors.grey,
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           if (_isEditing)
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: GestureDetector(
//                                 onTap: _showAvatarSelectionModal,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(5),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.darkTeal,
//                                     shape: BoxShape.circle,
//                                     border: Border.all(color: Colors.white, width: 2),
//                                   ),
//                                   child: const Icon(
//                                     Icons.photo_library_rounded,
//                                     color: Colors.white,
//                                     size: 14,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: const Color.fromARGB(255, 255, 155, 55),
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFFFF6B00).withOpacity(0.5),
//                                 blurRadius: 15,
//                                 offset: const Offset(5, 5),
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 _nameController.text.isNotEmpty ? _nameController.text : "Your Name",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _email,
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontSize: 13,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Text(
//                                   _role,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // --- Personal Information ---
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.grey.shade100, width: 1),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: const [
//                             Icon(Icons.person_outline_rounded, color: AppColors.green, size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               "Personal Information",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.darkGray,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         _buildEditableField("Full Name", _nameController, Icons.person),
//                         const SizedBox(height: 12),
//                         _buildEditableField("Roll No", _rollController, Icons.badge),
//                         const SizedBox(height: 12),
//                         _buildEditableField("Year", _yearController, Icons.school),
//                         const SizedBox(height: 12),
//                         _buildEditableField("Division", _divisionController, Icons.group),
//                         const SizedBox(height: 12),
//                         _buildEditableField("Phone Number", _phoneController, Icons.phone),

//                         // ✅ Notification Toggle
//                         const Divider(height: 24),
//                         SwitchListTile(
//                           contentPadding: EdgeInsets.zero,
//                           activeColor: AppColors.green,
//                           title: const Text(
//                             "App Notifications",
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.darkGray,
//                             ),
//                           ),
//                           secondary: Icon(
//                             _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
//                             color: _notificationsEnabled ? AppColors.green : AppColors.lightGray,
//                             size: 20,
//                           ),
//                           value: _notificationsEnabled,
//                           onChanged: _toggleNotifications,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // --- Completed Tasks Section ---
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(Icons.task_alt, color: AppColors.green, size: 20),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 _role == 'Head' ? "Team Completed Tasks" : "My Completed Tasks",
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: AppColors.darkGray,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: AppColors.green.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 "${_completedTasks.length}",
//                                 style: const TextStyle(
//                                   color: AppColors.green,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         if (_completedTasks.isEmpty)
//                           Container(
//                             padding: const EdgeInsets.symmetric(vertical: 40),
//                             width: double.infinity,
//                             child: Column(
//                               children: [
//                                 Icon(
//                                   _role == 'Head' ? Icons.groups_outlined : Icons.incomplete_circle_rounded,
//                                   color: AppColors.lightGray.withOpacity(0.5),
//                                   size: 64,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   _role == 'Head' ? "No completed tasks by your team" : "No completed tasks yet",
//                                   style: const TextStyle(
//                                     color: AppColors.lightGray,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   _role == 'Head'
//                                       ? "Tasks completed by your team members will appear here"
//                                       : "Complete your first task to see it here!",
//                                   style: TextStyle(
//                                     color: AppColors.lightGray.withOpacity(0.7),
//                                     fontSize: 12,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           )
//                         else
//                           ..._completedTasks.asMap().entries.map((entry) {
//                             final taskIndex = entry.key;
//                             final task = entry.value;
//                             final subtasks = (task['subtasks'] as List?) ?? [];

//                             return Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade50,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(color: Colors.grey.shade200),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   // Color indicator
//                                   Positioned(
//                                     left: 0,
//                                     top: 0,
//                                     bottom: 0,
//                                     child: Container(
//                                       width: 8,
//                                       decoration: BoxDecoration(
//                                         color: taskIndex.isEven ? AppColors.orange : AppColors.darkTeal,
//                                         borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(12),
//                                           bottomLeft: Radius.circular(12),
//                                         ),
//                                       ),
//                                     ),
//                                   ),

//                                   // Content
//                                   _role == 'Head'
//                                       ? Theme(
//                                           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                                           child: ExpansionTile(
//                                             tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                                             leading: Container(
//                                               padding: const EdgeInsets.all(6),
//                                               decoration: BoxDecoration(
//                                                 color: AppColors.green.withOpacity(0.1),
//                                                 shape: BoxShape.circle,
//                                               ),
//                                               child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
//                                             ),
//                                             title: Text(
//                                               task['title'],
//                                               style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.darkGray),
//                                             ),
//                                             subtitle: Text(
//                                               task['completedAt'] != null
//                                                   ? "Completed: ${_formatDate(DateTime.parse(task['completedAt']))}"
//                                                   : "Date N/A",
//                                               style: const TextStyle(color: AppColors.lightGray, fontSize: 12),
//                                             ),
//                                             children: [
//                                               Padding(
//                                                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                                                 child: Divider(color: Colors.grey.shade300),
//                                               ),
//                                               if (subtasks.isEmpty)
//                                                 Padding(
//                                                   padding: const EdgeInsets.all(16.0),
//                                                   child: Text("No subtasks", style: TextStyle(color: AppColors.lightGray.withOpacity(0.7), fontSize: 12, fontStyle: FontStyle.italic)),
//                                                 )
//                                               else
//                                                 ...subtasks.map((sub) {
//                                                   final assignedUsers = (sub['assignedTo'] as List).map((u) => u['username']).join(', ');
//                                                   return Container(
//                                                     margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
//                                                     padding: const EdgeInsets.all(12),
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius: BorderRadius.circular(8),
//                                                       border: Border.all(color: Colors.grey.shade200),
//                                                     ),
//                                                     child: Column(
//                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                       children: [
//                                                         Text(sub['title'], style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkGray, fontSize: 14)),
//                                                         const SizedBox(height: 4),
//                                                         Text(sub['description'] ?? 'No note.', style: TextStyle(color: AppColors.darkGray.withOpacity(0.8), fontSize: 12)),
//                                                         const SizedBox(height: 6),
//                                                         Text("Completed by: $assignedUsers", style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.lightGray, fontSize: 11)),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                               const SizedBox(height: 8),
//                                             ],
//                                           ),
//                                         )
//                                       : ListTile(
//                                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                                           leading: Container(
//                                             padding: const EdgeInsets.all(6),
//                                             decoration: BoxDecoration(
//                                               color: AppColors.green.withOpacity(0.1),
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
//                                           ),
//                                           title: Text(task['title'], style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.darkGray)),
//                                           subtitle: Text(
//                                             task['completedAt'] != null
//                                                 ? "Completed: ${_formatDate(DateTime.parse(task['completedAt']))}"
//                                                 : "Date N/A",
//                                             style: const TextStyle(color: AppColors.lightGray, fontSize: 12),
//                                           ),
//                                         ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _isEditing ? Colors.grey.shade50 : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         border: _isEditing ? Border.all(color: AppColors.green.withOpacity(0.3), width: 1.5) : null,
//       ),
//       child: TextField(
//         controller: controller,
//         enabled: _isEditing,
//         style: const TextStyle(color: AppColors.darkGray, fontSize: 14, fontWeight: FontWeight.w500),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: AppColors.lightGray, fontSize: 13),
//           prefixIcon: Icon(icon, color: _isEditing ? AppColors.green : AppColors.lightGray, size: 20),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvatarSelectionContent() {
//     final selectableAvatars = AvatarConfig.avatarPaths.where((path) => path != AvatarConfig.defaultAvatar).toList();

//     return Container(
//       padding: const EdgeInsets.all(20),
//       constraints: const BoxConstraints(maxWidth: 300),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.photo_library_rounded, color: AppColors.green, size: 20),
//               const SizedBox(width: 8),
//               const Text("Choose Your Avatar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkGray)),
//               const Spacer(),
//               IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.of(context).pop()),
//             ],
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0),
//             itemCount: selectableAvatars.length,
//             itemBuilder: (context, index) {
//               final avatarPath = selectableAvatars[index];
//               return GestureDetector(
//                 onTap: () {
//                   _saveAvatar(avatarPath);
//                   Navigator.of(context).pop();
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: _selectedAvatar == avatarPath ? AppColors.green : Colors.grey.shade300, width: _selectedAvatar == avatarPath ? 3 : 2),
//                   ),
//                   child: ClipOval(
//                     child: Image.asset(avatarPath, width: 65, height: 65, fit: BoxFit.cover),
//                   ),
//                 ),
//               );
//             },
//           ),
//           if (_selectedAvatar != AvatarConfig.defaultAvatar) ...[
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   _saveAvatar(AvatarConfig.defaultAvatar);
//                   Navigator.of(context).pop();
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange.withOpacity(0.85), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                 child: const Text("Remove Avatar"),
//               ),
//             ),
//           ]
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return "${date.day}/${date.month}/${date.year}";
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import '../services/notification_handler.dart';
import '../widgets/loading_animation.widget.dart';
import '../widgets/customAppbar.widget.dart';
import '../core/app_colors.dart';

class AvatarConfig {
  static final List<String> avatarPaths = [
    'assets/images/Avatars/Avatar1.png',
    'assets/images/Avatars/Avatar2.png',
    'assets/images/Avatars/Avatar3.png',
    'assets/images/Avatars/Avatar4.png',
    'assets/images/Avatars/Avatar5.png',
    'assets/images/Avatars/Avatar6.png',
    'assets/images/Avatars/Avatar7.png',
    'assets/images/Avatars/Avatar8.png',
    'assets/images/Avatars/Avatar9.png',
  ];

  static const String defaultAvatar = 'assets/images/Avatars/default.png';
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();
  final TaskService taskService = TaskService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedYear;
  String? _selectedDept;

  bool _isLoading = true;
  bool _isEditing = false;
  bool _notificationsEnabled = true;
  String _email = "";
  String _role = "";
  String _userId = "";
  String _userTeam = "";
  List _completedTasks = [];
  String _selectedAvatar = AvatarConfig.defaultAvatar;

  final List<String> yearOptions = ['FY', 'SY', 'TE', 'BE'];
  final List<String> deptOptions = ['CE', 'IT', 'ENTC', 'AIDS', 'ECE'];

  @override
  void initState() {
    super.initState();
    loadAllData();
    _loadNotificationPreference();
  }

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

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await NotificationHandler().toggleNotifications(value);

    if (mounted) {
      _showStatusDialog(
        title: value ? "Notifications On" : "Notifications Off",
        message: value
            ? "You will now receive updates."
            : "You have unsubscribed from notifications.",
        isError: false,
      );
    }
  }

  Future<void> _saveAvatar(String avatarPath) async {
    setState(() {
      _selectedAvatar = avatarPath;
    });
  }

  void _showAvatarSelectionModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: _buildAvatarSelectionContent(),
        );
      },
    );
  }

  // Replace the _showTaskDetailsModal method with this version

  void _showTaskDetailsModal(dynamic task) {
    // For Members, show their assigned subtasks with team members
    if (_role != 'Head') {
      _showMemberTaskView(task);
      return;
    }

    // Original modal for Heads
    final subtasks = (task['subtasks'] as List?) ?? [];

    String deadlineStr = "N/A";
    Color deadlineColor = AppColors.lightGray;
    if (task['deadline'] != null) {
      try {
        final deadline = DateTime.parse(task['deadline']).toLocal();
        deadlineStr = DateFormat('d MMM, yyyy').format(deadline);

        final daysUntil = deadline.difference(DateTime.now()).inDays;
        if (daysUntil < 0) {
          deadlineColor = Colors.red.shade600;
        } else if (daysUntil <= 3) {
          deadlineColor = AppColors.orange;
        } else {
          deadlineColor = AppColors.green;
        }
      } catch (e) {
        deadlineStr = "N/A";
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.grey.shade50, 
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Task Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title
                        Text(
                          task['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Deadline
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: deadlineColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Deadline: $deadlineStr",
                              style: TextStyle(
                                fontSize: 13,
                                color: deadlineColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Description
                        if (task['description'] != null &&
                            task['description']
                                .toString()
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTeal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task['description'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkGray,
                              height: 1.4,
                            ),
                          ),
                        ],

                        // Subtasks
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.checklist,
                              size: 18,
                              color: AppColors.darkTeal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Subtasks (${subtasks.length})",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (subtasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "No subtasks",
                                style: TextStyle(
                                  color: AppColors.lightGray,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          ...subtasks.asMap().entries.map((entry) {
                            final subtask = entry.value;
                            final assignedList = subtask['assignedTo'] ?? [];
                            final assignedNames = assignedList
                                .map((user) => user['name'] ?? 'Unknown')
                                .join(', ');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: AppColors.green,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          subtask['title'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkGray,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (subtask['description'] != null &&
                                      subtask['description']
                                          .toString()
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28),
                                      child: Text(
                                        subtask['description'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.lightGray,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: AppColors.darkOrange,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            assignedNames.isNotEmpty
                                                ? assignedNames
                                                : "Not assigned",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.darkTeal,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // New method for Member view
  void _showMemberTaskView(dynamic task) {
    final subtasks = (task['subtasks'] as List?) ?? [];

    // Filter subtasks where current user is assigned
    final mySubtasks = subtasks.where((subtask) {
      try {
        final assignedList = (subtask['assignedTo'] as List?) ?? [];
        return assignedList.any((user) {
          if (user == null) return false;
          final userId = user is Map
              ? (user['_id']?.toString() ?? '')
              : user.toString();
          return userId == _userId;
        });
      } catch (e) {
        print('Error filtering subtask: $e');
        return false;
      }
    }).toList();

    String deadlineStr = "N/A";
    Color deadlineColor = AppColors.lightGray;
    if (task['deadline'] != null) {
      try {
        final deadline = DateTime.parse(task['deadline']).toLocal();
        deadlineStr = DateFormat('d MMM, yyyy').format(deadline);

        final daysUntil = deadline.difference(DateTime.now()).inDays;
        if (daysUntil < 0) {
          deadlineColor = Colors.red.shade600;
        } else if (daysUntil <= 3) {
          deadlineColor = AppColors.orange;
        } else {
          deadlineColor = AppColors.green;
        }
      } catch (e) {
        deadlineStr = "N/A";
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.grey.shade50, 
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.assignment_ind,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "My Contributions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Title
                        Text(
                          task['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Deadline
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: deadlineColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Completed on: $deadlineStr",
                              style: TextStyle(
                                fontSize: 13,
                                color: deadlineColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // My Subtasks
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_pin_outlined,
                              size: 18,
                              color: AppColors.darkTeal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "My Subtasks (${mySubtasks.length})",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (mySubtasks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "No subtasks assigned to you",
                                style: TextStyle(
                                  color: AppColors.lightGray,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        else
                          ...mySubtasks.map((subtask) {
                            final assignedList =
                                (subtask['assignedTo'] as List?) ?? [];
                            final assignedNames = assignedList
                                .map((user) {
                                  if (user == null) return 'Unknown';
                                  if (user is Map) {
                                    return user['name']?.toString() ??
                                        'Unknown';
                                  }
                                  return 'Unknown';
                                })
                                .join(', ');

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: AppColors.green,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          subtask['title'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkGray,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (subtask['description'] != null &&
                                      subtask['description']
                                          .toString()
                                          .trim()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28),
                                      child: Text(
                                        subtask['description'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.lightGray,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.group_outlined,
                                          size: 14,
                                          color: AppColors.darkOrange,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Along with:",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.lightGray,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                assignedNames,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.darkTeal,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = await userService.getLoggedInUser();

      _userId = user['_id'] ?? '';
      _email = user['email'] ?? '';
      _role = user['role'] ?? '';

      if (user['team'] != null) {
        if (user['team'] is List && (user['team'] as List).isNotEmpty) {
          _userTeam = user['team'][0]['_id'] ?? user['team'][0].toString();
        } else if (user['team'] is Map) {
          _userTeam = user['team']['_id'] ?? '';
        } else {
          _userTeam = user['team'].toString();
        }
      } else {
        _userTeam = '';
      }

      _nameController.text = user['name'] ?? '';
      _rollController.text = user['rollNo'] ?? '';
      _phoneController.text = user['phone'] ?? '';

      String fetchedYear = user['year'] ?? '';
      _selectedYear = yearOptions.contains(fetchedYear) ? fetchedYear : null;

      String fetchedDept = user['division'] ?? '';
      _selectedDept = deptOptions.contains(fetchedDept) ? fetchedDept : null;

      _selectedAvatar = user['avatar'] ?? AvatarConfig.defaultAvatar;

      if (_role == 'Head') {
        if (_userTeam.isNotEmpty) {
          _completedTasks = await taskService.getCompletedTasksByTeam(
            _userTeam,
          );
        } else {
          _completedTasks = await taskService.getAllCompletedTasks();
        }
      } else if (_role == 'Member' && _userId.isNotEmpty) {
        _completedTasks = await taskService.getCompletedTasksByUser(_userId);
      }
    } catch (e) {
      if (mounted) {
        _showStatusDialog(
          title: "Error",
          message: "Failed to load profile data: $e",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showStatusDialog(
        title: "Invalid Input",
        message: "Name cannot be empty.",
        isError: true,
      );
      return;
    }

    if (!RegExp(r'^\d{5}$').hasMatch(_rollController.text)) {
      _showStatusDialog(
        title: "Invalid Roll No",
        message: "Roll number must be exactly 5 digits.",
        isError: true,
      );
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(_phoneController.text)) {
      _showStatusDialog(
        title: "Invalid Phone",
        message: "Phone number must be exactly 10 digits.",
        isError: true,
      );
      return;
    }

    if (_selectedYear == null) {
      _showStatusDialog(
        title: "Missing Info",
        message: "Please select your Year.",
        isError: true,
      );
      return;
    }

    if (_selectedDept == null) {
      _showStatusDialog(
        title: "Missing Info",
        message: "Please select your Department.",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await userService.updateUserProfile(
        name: _nameController.text,
        rollNo: _rollController.text,
        year: _selectedYear!,
        division: _selectedDept!,
        phone: _phoneController.text,
        avatar: _selectedAvatar,
      );

      _showStatusDialog(
        title: "Success",
        message: "Profile updated successfully!",
        isError: false,
      );

      setState(() => _isEditing = false);
    } catch (e) {
      _showStatusDialog(
        title: "Update Failed",
        message: "Could not update profile: $e",
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(title: "Profile", context: context),
      body: _isLoading
          ? const Center(child: LoadingAnimation(size: 250))
          : RefreshIndicator(
              color: AppColors.green,
              backgroundColor: Colors.white,
              onRefresh: loadAllData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                children: [
                  // --- Profile Header ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                _selectedAvatar,
                                width: 74,
                                height: 74,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.account_circle_rounded,
                                    size: 74,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showAvatarSelectionModal,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkTeal,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.photo_library_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 155, 55),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B00).withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(5, 5),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text
                                    : "Your Name",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _role,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Personal Information Card ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Personal Information",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              ],
                            ),
                            // ✅ Only show Edit button if NOT editing.
                            // If editing, it disappears (no cross).
                            if (!_isEditing)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: AppColors.darkTeal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _buildEditableField(
                          "Full Name",
                          _nameController,
                          Icons.person,
                        ),
                        const SizedBox(height: 12),

                        _buildEditableField(
                          "Roll No",
                          _rollController,
                          Icons.badge,
                          isNumber: true,
                        ),
                        const SizedBox(height: 12),

                        _buildDropdownField(
                          label: "Year",
                          value: _selectedYear,
                          options: yearOptions,
                          icon: Icons.school,
                          onChanged: (val) =>
                              setState(() => _selectedYear = val),
                        ),
                        const SizedBox(height: 12),

                        _buildDropdownField(
                          label: "Department",
                          value: _selectedDept,
                          options: deptOptions,
                          icon: Icons.business,
                          onChanged: (val) =>
                              setState(() => _selectedDept = val),
                        ),
                        const SizedBox(height: 12),

                        _buildEditableField(
                          "Phone Number",
                          _phoneController,
                          Icons.phone,
                          isNumber: true,
                        ),

                        const Divider(height: 24),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.green,
                          title: const Text(
                            "App Notifications",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGray,
                            ),
                          ),
                          secondary: Icon(
                            _notificationsEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: _notificationsEnabled
                                ? AppColors.green
                                : AppColors.lightGray,
                            size: 20,
                          ),
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                        ),

                        // ✅ SAVE BUTTON (Inside the card, at the bottom)
                        if (_isEditing) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Completed Tasks Section ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.task_alt,
                              color: AppColors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _role == 'Head'
                                    ? "Team Completed Tasks"
                                    : "My Completed Tasks",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_completedTasks.length}",
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_completedTasks.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            width: double.infinity,
                            child: Column(
                              children: [
                                Icon(
                                  _role == 'Head'
                                      ? Icons.groups_outlined
                                      : Icons.incomplete_circle_rounded,
                                  color: AppColors.lightGray.withOpacity(0.5),
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _role == 'Head'
                                      ? "No completed tasks by your team"
                                      : "No completed tasks yet",
                                  style: const TextStyle(
                                    color: AppColors.lightGray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ..._completedTasks.asMap().entries.map((entry) {
                            final taskIndex = entry.key;
                            final task = entry.value;

                            // Parse completion date
                            String completedDateStr = "N/A";
                            if (task['completedAt'] != null) {
                              try {
                                final completedDate = DateTime.parse(
                                  task['completedAt'],
                                ).toLocal();
                                completedDateStr = DateFormat(
                                  'd MMM, yyyy',
                                ).format(completedDate);
                              } catch (e) {
                                completedDateStr = "N/A";
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                onTap: () => _showTaskDetailsModal(task),
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Color indicator
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 8,
                                        decoration: BoxDecoration(
                                          color: taskIndex.isEven
                                              ? AppColors.orange
                                              : AppColors.darkTeal,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.green
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.green,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task['title'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.darkGray,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Completed on: $completedDateStr",
                                                  style: TextStyle(
                                                    color: AppColors.lightGray,
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: AppColors.lightGray,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),

                  // // --- Completed Tasks Section ---
                  // Container(
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.2),
                  //         blurRadius: 8,
                  //         offset: const Offset(0, 2),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           const Icon(
                  //             Icons.task_alt,
                  //             color: AppColors.green,
                  //             size: 20,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               _role == 'Head'
                  //                   ? "Team Completed Tasks"
                  //                   : "My Completed Tasks",
                  //               style: const TextStyle(
                  //                 fontSize: 16,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: AppColors.darkGray,
                  //               ),
                  //             ),
                  //           ),
                  //           Container(
                  //             padding: const EdgeInsets.symmetric(
                  //               horizontal: 8,
                  //               vertical: 4,
                  //             ),
                  //             decoration: BoxDecoration(
                  //               color: AppColors.green.withOpacity(0.1),
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //             child: Text(
                  //               "${_completedTasks.length}",
                  //               style: const TextStyle(
                  //                 color: AppColors.green,
                  //                 fontSize: 12,
                  //                 fontWeight: FontWeight.w600,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 16),

                  //       if (_completedTasks.isEmpty)
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(vertical: 40),
                  //           width: double.infinity,
                  //           child: Column(
                  //             children: [
                  //               Icon(
                  //                 _role == 'Head'
                  //                     ? Icons.groups_outlined
                  //                     : Icons.incomplete_circle_rounded,
                  //                 color: AppColors.lightGray.withOpacity(0.5),
                  //                 size: 64,
                  //               ),
                  //               const SizedBox(height: 16),
                  //               Text(
                  //                 _role == 'Head'
                  //                     ? "No completed tasks by your team"
                  //                     : "No completed tasks yet",
                  //                 style: const TextStyle(
                  //                   color: AppColors.lightGray,
                  //                   fontSize: 14,
                  //                   fontWeight: FontWeight.w500,
                  //                 ),
                  //                 textAlign: TextAlign.center,
                  //               ),
                  //             ],
                  //           ),
                  //         )
                  //       else
                  //         ..._completedTasks.asMap().entries.map((entry) {
                  //           final taskIndex = entry.key;
                  //           final task = entry.value;
                  //           return Container(
                  //             margin: const EdgeInsets.only(bottom: 12),
                  //             decoration: BoxDecoration(
                  //               color: Colors.grey.shade50,
                  //               borderRadius: BorderRadius.circular(12),
                  //               border: Border.all(color: Colors.grey.shade200),
                  //             ),
                  //             child: Stack(
                  //               children: [
                  //                 // Color indicator
                  //                 Positioned(
                  //                   left: 0,
                  //                   top: 0,
                  //                   bottom: 0,
                  //                   child: Container(
                  //                     width: 8,
                  //                     decoration: BoxDecoration(
                  //                       color: taskIndex.isEven
                  //                           ? AppColors.orange
                  //                           : AppColors.darkTeal,
                  //                       borderRadius: const BorderRadius.only(
                  //                         topLeft: Radius.circular(12),
                  //                         bottomLeft: Radius.circular(12),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 // Content
                  //                 ListTile(
                  //                   contentPadding: const EdgeInsets.symmetric(
                  //                     horizontal: 16,
                  //                     vertical: 4,
                  //                   ),
                  //                   leading: Container(
                  //                     padding: const EdgeInsets.all(6),
                  //                     decoration: BoxDecoration(
                  //                       color: AppColors.green.withOpacity(0.1),
                  //                       shape: BoxShape.circle,
                  //                     ),
                  //                     child: const Icon(
                  //                       Icons.check_circle_rounded,
                  //                       color: AppColors.green,
                  //                       size: 20,
                  //                     ),
                  //                   ),
                  //                   title: Text(
                  //                     task['title'],
                  //                     style: const TextStyle(
                  //                       fontWeight: FontWeight.w500,
                  //                       color: AppColors.darkGray,
                  //                     ),
                  //                   ),
                  //                   subtitle: Text(
                  //                     "Completed",
                  //                     style: const TextStyle(
                  //                       color: AppColors.lightGray,
                  //                       fontSize: 12,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           );
                  //         }).toList(),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _isEditing ? Colors.grey.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: _isEditing
            ? Border.all(color: AppColors.green.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(
          color: AppColors.darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.lightGray, fontSize: 13),
          prefixIcon: Icon(
            icon,
            color: _isEditing ? AppColors.green : AppColors.lightGray,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _isEditing ? Colors.grey.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: _isEditing
            ? Border.all(color: AppColors.green.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: AppColors.lightGray,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: _isEditing ? AppColors.green : AppColors.lightGray,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          style: const TextStyle(
            color: AppColors.darkGray,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: _isEditing ? AppColors.green : Colors.transparent,
          ),
          items: options.map((String val) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
          onChanged: _isEditing ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildAvatarSelectionContent() {
    final selectableAvatars = AvatarConfig.avatarPaths
        .where((path) => path != AvatarConfig.defaultAvatar)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library_rounded,
                color: AppColors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Choose Your Avatar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: selectableAvatars.length,
            itemBuilder: (context, index) {
              final avatarPath = selectableAvatars[index];
              return GestureDetector(
                onTap: () {
                  _saveAvatar(avatarPath);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedAvatar == avatarPath
                          ? AppColors.green
                          : Colors.grey.shade300,
                      width: _selectedAvatar == avatarPath ? 3 : 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatarPath,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selectedAvatar != AvatarConfig.defaultAvatar) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _saveAvatar(AvatarConfig.defaultAvatar);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange.withOpacity(0.85),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Remove Avatar"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
