// import 'package:flutter/material.dart';
// import '../services/meeting_service.dart';
// import '../services/user_service.dart';
// import '../services/team_service.dart';
// import '../core/app_colors.dart';

// class CreateMeetingScreen extends StatefulWidget {
//   final VoidCallback onMeetingCreated;
//   const CreateMeetingScreen({super.key, required this.onMeetingCreated});

//   @override
//   State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
// }

// class _CreateMeetingScreenState extends State<CreateMeetingScreen> with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final MeetingService meetingService = MeetingService();
//   final TeamService teamService = TeamService();

//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController locationController = TextEditingController();
//   final TextEditingController onlineLinkController = TextEditingController();
//   final TextEditingController agendaController = TextEditingController();
//   final TextEditingController durationController = TextEditingController();

//   String? priority = 'Medium';
//   DateTime? dateTime;

//   List<String> selectedTags = [];
//   List<String> allTags = ['General', 'Impactathon', 'PictoFest', 'BDD'];

//   bool isPrivate = false;
//   List<Map<String, dynamic>> allUsers = [];
//   List<Map<String, dynamic>> filteredUsers = [];
//   List<String> invitedUserIds = [];
//   String searchQuery = '';

//   bool isSubmitting = false;

//   String meetingType = 'offline';

//   String meetingScope = 'general';
//   List<Map<String, dynamic>> allTeams = [];
//   List<String> selectedTeamIds = [];

//   late AnimationController _animationController;
//   late List<Animation<double>> _animations;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     _animations = List.generate(
//       6,
//       (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//           parent: _animationController,
//           curve: Interval(
//             index * 0.15,
//             (index * 0.15) + 0.5,
//             curve: Curves.easeOutCubic,
//           ),
//         ),
//       ),
//     );

//     _animationController.forward();

//     fetchAllUsers();
//     fetchVisibleTeams();
//   }

//   @override
//   void dispose() {
//     titleController.dispose();
//     descriptionController.dispose();
//     locationController.dispose();
//     onlineLinkController.dispose();
//     agendaController.dispose();
//     durationController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void fetchAllUsers() async {
//     try {
//       final users = await UserService().getAllUsers();
//       setState(() {
//         allUsers = List<Map<String, dynamic>>.from(users);
//         filteredUsers = List.from(allUsers);
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load users: $e')));
//       }
//     }
//   }

//   void fetchVisibleTeams() async {
//     try {
//       final teams = await teamService.getVisibleTeams();
//       if (mounted) {
//         setState(() => allTeams = List<Map<String, dynamic>>.from(teams));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to load teams: $e')));
//       }
//     }
//   }

//   void filterUserSearch(String query) {
//     setState(() {
//       searchQuery = query;
//       filteredUsers = allUsers.where((user) {
//         final name = user['name'] ?? '';
//         final year = user['year'] ?? '';
//         final division = user['division'] ?? '';
//         final text = "$name $year $division".toLowerCase();
//         return text.contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   void submit() async {
//     if (!_formKey.currentState!.validate() || dateTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all required fields and pick a date/time.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (meetingScope == 'team-specific' && selectedTeamIds.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select at least one team for a team-specific meeting.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     FocusScope.of(context).unfocus();
//     setState(() => isSubmitting = true);

//     try {
//       await meetingService.createMeeting(
//         title: titleController.text,
//         description: descriptionController.text,
//         location: meetingType == 'offline' ? locationController.text : '',
//         onlineLink: meetingType == 'online' ? onlineLinkController.text : '',
//         dateTime: dateTime!,
//         agenda: agendaController.text,
//         duration: durationController.text.isEmpty
//             ? 60
//             : int.parse(durationController.text),
//         priority: priority,
//         tags: selectedTags,
//         isPrivate: isPrivate,
//         invitedMembers: invitedUserIds,
//         team: meetingScope == 'team-specific' ? selectedTeamIds : null,
//       );

//       widget.onMeetingCreated();
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       setState(() => isSubmitting = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to create meeting: $e')));
//       }
//     }
//   }

//   Widget _buildAnimatedSection(int index, Widget child) {
//     return FadeTransition(
//       opacity: _animations[index],
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, 0.3),
//           end: Offset.zero,
//         ).animate(_animations[index]),
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 24.0),
//           child: child,
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         children: [
//           Icon(icon, color: AppColors.yellowIcon),
//           const SizedBox(width: 10),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.teal1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   InputDecoration _buildInputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: AppColors.charcoal3),
//       prefixIcon: Icon(icon, color: AppColors.yellowIcon),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.teal5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.teal1, width: 2),
//       ),
//     );
//   }

//   Widget _buildCoreDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader("Core Details", Icons.article_outlined),
//         TextFormField(
//           controller: titleController,
//           decoration: _buildInputDecoration('Title', Icons.title_rounded),
//           validator: (val) => val!.isEmpty ? 'Enter title' : null,
//         ),
//         const SizedBox(height: 16),
//         TextFormField(
//           controller: descriptionController,
//           decoration: _buildInputDecoration('Description', Icons.description_outlined),
//           validator: (val) => val!.isEmpty ? 'Enter description' : null,
//           maxLines: 3,
//         ),
//       ],
//     );
//   }

//   Widget _buildGradientSegmentedButton<T>({
//   required List<ButtonSegment<T>> segments,
//   required Set<T> selected,
//   required void Function(Set<T>) onSelectionChanged,
//   Color? foregroundColor,
//   double? height,
// }) {
//   return Container(
//     height: height ?? 48,
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [AppColors.teal1, AppColors.teal3],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: AppColors.teal4),
//     ),
//     child: SegmentedButton<T>(
//       segments: segments, // REQUIRED named parameter - fix
//       selected: selected,
//       onSelectionChanged: onSelectionChanged,
//       style: ButtonStyle(
//         textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
//           (states) {
//             if (states.contains(MaterialState.selected)) {
//               return const TextStyle(fontWeight: FontWeight.bold);
//             }
//             return null;
//           },
//         ),
//         backgroundColor: MaterialStateProperty.all(Colors.transparent),
//         foregroundColor: MaterialStateProperty.all(foregroundColor ?? Colors.white),
//         overlayColor: MaterialStateProperty.all(Colors.transparent),
//       ),
//       // Optionally you can set other style properties here
//     ),
//   );
// }

//   Widget _buildScopeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader("Meeting Scope", Icons.group_work_outlined),
//         SizedBox(
//           width: double.infinity,
//           child: _buildGradientSegmentedButton<String>(
//             segments: const [
//               ButtonSegment(
//                 value: 'general',
//                 label: Text('General'),
//                 icon: Icon(Icons.public),
//               ),
//               ButtonSegment(
//                 value: 'team-specific',
//                 label: Text('Team'),
//                 icon: Icon(Icons.group),
//               ),
//             ],
//             selected: {meetingScope},
//             onSelectionChanged: (newSelection) {
//               setState(() => meetingScope = newSelection.first);
//             },
//           ),
//         ),
//         if (meetingScope == 'team-specific') ...[
//           const SizedBox(height: 16),
//           const Text(
//             'Select Teams',
//             style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.charcoal2),
//           ),
//           const SizedBox(height: 8),
//           allTeams.isEmpty
//               ? const Text('Loading teams...')
//               : Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: allTeams.map((team) {
//                     final isSelected = selectedTeamIds.contains(team['_id']);
//                     return ChoiceChip(
//                       label: Text(team['shortName'] ?? team['name']),
//                       selected: isSelected,
//                       selectedColor: AppColors.teal2.withOpacity(0.1),
//                       checkmarkColor: AppColors.teal1,
//                       labelStyle: TextStyle(
//                         color: isSelected ? AppColors.teal1 : AppColors.charcoal2,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       onSelected: (val) {
//                         setState(() {
//                           if (val) {
//                             selectedTeamIds.add(team['_id']);
//                           } else {
//                             selectedTeamIds.remove(team['_id']);
//                           }
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//         ],
//       ],
//     );
//   }

//   Widget _buildTypeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader("Meeting Type", Icons.settings_ethernet_outlined),
//         SizedBox(
//           width: double.infinity,
//           child: _buildGradientSegmentedButton<String>(
//             segments: const [
//               ButtonSegment(
//                 value: 'offline',
//                 label: Text('Offline'),
//                 icon: Icon(Icons.location_on_outlined),
//               ),
//               ButtonSegment(
//                 value: 'online',
//                 label: Text('Online'),
//                 icon: Icon(Icons.videocam_outlined),
//               ),
//             ],
//             selected: {meetingType},
//             onSelectionChanged: (newSelection) {
//               setState(() => meetingType = newSelection.first);
//             },
//           ),
//         ),
//         const SizedBox(height: 16),
//         if (meetingType == 'offline')
//           TextFormField(
//             controller: locationController,
//             decoration: _buildInputDecoration('Location', Icons.location_city_outlined),
//             validator: (val) => val!.isEmpty ? 'Enter location for offline meeting' : null,
//           ),
//         if (meetingType == 'online')
//           TextFormField(
//             controller: onlineLinkController,
//             decoration: _buildInputDecoration('Online Meeting Link', Icons.link_rounded),
//             validator: (val) => val!.isEmpty ? 'Enter meeting link for online meeting' : null,
//           ),
//       ],
//     );
//   }

//   Widget _buildLogistics() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader("Logistics", Icons.schedule_outlined),
//         _buildDateTimePicker(),
//         const SizedBox(height: 16),
//         TextFormField(
//           controller: agendaController,
//           decoration: _buildInputDecoration('Agenda (Optional)', Icons.list_alt_rounded),
//           maxLines: 2,
//         ),
//         const SizedBox(height: 16),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: durationController,
//                 decoration: _buildInputDecoration('Duration (mins)', Icons.timer_outlined),
//                 keyboardType: TextInputType.number,
//                 validator: (val) {
//                   if (val == null || val.isEmpty) return null;
//                   if (int.tryParse(val) == null) return 'Must be a number';
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 value: priority,
//                 items: ['Low', 'Medium', 'High', 'Urgent']
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) => setState(() => priority = val),
//                 decoration: _buildInputDecoration('Priority', Icons.flag_outlined),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.charcoal2)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: allTags.map((tag) {
//             final selected = selectedTags.contains(tag);
//             return ChoiceChip(
//               label: Text(tag),
//               selected: selected,
//               backgroundColor: Colors.white, // White background for unselected
//               selectedColor: AppColors.teal2.withOpacity(0.1), // Teal tinted selected background
//               checkmarkColor: AppColors.teal1,
//               labelStyle: TextStyle(
//                 color: selected ? AppColors.teal1 : AppColors.charcoal2,
//                 fontWeight: FontWeight.w500,
//               ),
//               onSelected: (val) {
//                 setState(() {
//                   if (val) {
//                     selectedTags.add(tag);
//                   } else {
//                     selectedTags.remove(tag);
//                   }
//                 });
//               },
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildVisibility() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader("Visibility & Access", Icons.visibility_outlined),
//         SizedBox(
//           width: double.infinity,
//           child: _buildGradientSegmentedButton<bool>(
//             segments: const [
//               ButtonSegment(value: false, label: Text('Public'), icon: Icon(Icons.public)),
//               ButtonSegment(value: true, label: Text('Private'), icon: Icon(Icons.lock_outline)),
//             ],
//             selected: {isPrivate},
//             onSelectionChanged: (newSelection) {
//               setState(() => isPrivate = newSelection.first);
//             },
//           ),
//         ),
//         if (isPrivate) ...[
//           const SizedBox(height: 20),
//           _buildMemberSelector(),
//         ],
//       ],
//     );
//   }

//   Widget _buildDateTimePicker() {
//     final theme = Theme.of(context);

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.teal1, AppColors.teal3],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.teal2),
//       ),
//       child: SizedBox(
//         height: 55,
//         width: double.infinity,
//         child: ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shadowColor: Colors.transparent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           onPressed: () async {
//             DateTime? picked = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime.now(),
//               lastDate: DateTime(2100),
//               builder: (context, child) {
//                 return Theme(
//                   data: theme.copyWith(
//                     colorScheme: theme.colorScheme.copyWith(
//                       primary: AppColors.teal1, // header, active selection
//                       onPrimary: Colors.white,
//                       onSurface: AppColors.charcoal2,
//                     ),
//                     dialogBackgroundColor: Colors.white,
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//             if (picked != null && mounted) {
//               TimeOfDay? time = await showTimePicker(
//                 context: context,
//                 initialTime: TimeOfDay.now(),
//                 builder: (context, child) {
//                   return Theme(
//                     data: theme.copyWith(
//                       colorScheme: theme.colorScheme.copyWith(
//                         primary: AppColors.teal1, // clock dial and AM/PM selectors color
//                         onPrimary: Colors.white,
//                         onSurface: AppColors.charcoal2,
//                       ),
//                       dialogBackgroundColor: Colors.white,
//                     ),
//                     child: child!,
//                   );
//                 },
//               );
//               if (time != null) {
//                 setState(() {
//                   dateTime = DateTime(
//                     picked.year,
//                     picked.month,
//                     picked.day,
//                     time.hour,
//                     time.minute,
//                   );
//                 });
//               }
//             }
//           },
//           icon: const Icon(Icons.calendar_month_outlined),
//           label: Text(
//             dateTime == null ? 'Pick Date & Time' : 'Selected: ${dateTime!.toLocal()}',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMemberSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Autocomplete<Map<String, dynamic>>(
//           optionsBuilder: (TextEditingValue textEditingValue) {
//             if (textEditingValue.text.isEmpty) {
//               return const Iterable<Map<String, dynamic>>.empty();
//             }
//             return allUsers.where((user) {
//               final name = user['name'] ?? '';
//               final year = user['year'] ?? '';
//               final division = user['division'] ?? '';
//               final text = "$name $year $division".toLowerCase();
//               return text.contains(textEditingValue.text.toLowerCase());
//             });
//           },
//           displayStringForOption: (user) => "${user['name']} ${user['year']} ${user['division']}",
//           fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
//             return TextField(
//               controller: controller,
//               focusNode: focusNode,
//               decoration: _buildInputDecoration('Search & Select Members', Icons.person_search_outlined),
//             );
//           },
//           optionsViewBuilder: (context, onSelected, options) {
//             return Align(
//               alignment: Alignment.topLeft,
//               child: Material(
//                 elevation: 4,
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxHeight: 250),
//                   child: ListView.builder(
//                     padding: EdgeInsets.zero,
//                     itemCount: options.length,
//                     itemBuilder: (context, index) {
//                       final user = options.elementAt(index);
//                       final selected = invitedUserIds.contains(user['_id']);
//                       return ListTile(
//                         title: Text("${user['name']} ${user['year']} ${user['division']}"),
//                         trailing: selected ? const Icon(Icons.check, color: AppColors.teal1) : null,
//                         onTap: () {
//                           setState(() {
//                             if (selected) {
//                               invitedUserIds.remove(user['_id']);
//                             } else {
//                               invitedUserIds.add(user['_id']);
//                             }
//                           });
//                           onSelected(user);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: invitedUserIds.map((id) {
//             final user = allUsers.firstWhere(
//               (u) => u['_id'] == id,
//               orElse: () => {'name': 'Unknown', 'year': '', 'division': ''},
//             );
//             return Chip(
//               label: Text("${user['name']} ${user['year']} ${user['division']}"),
//               backgroundColor: AppColors.teal1.withOpacity(0.15),
//               deleteIconColor: AppColors.teal2,
//               labelStyle: const TextStyle(color: AppColors.teal1),
//               onDeleted: () {
//                 setState(() {
//                   invitedUserIds.remove(id);
//                 });
//               },
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubmitButton() {
//     return isSubmitting
//         ? const Center(
//             child: CircularProgressIndicator(
//             color: AppColors.teal1,
//           ))
//         : Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.teal1, AppColors.teal3],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   foregroundColor: Colors.white,
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   shadowColor: Colors.transparent,
//                   elevation: 0,
//                 ),
//                 onPressed: submit,
//                 icon: const Icon(Icons.check_circle_outline),
//                 label: const Text('Create Meeting'),
//               ),
//             ),
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background, // strictly not cream!
//       appBar: AppBar(
//         title: const Text('Create Meeting'),
//         backgroundColor: AppColors.teal1,
//         foregroundColor: AppColors.background, // strictly not cream!
//         elevation: 2,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             _buildAnimatedSection(0, _buildCoreDetails()),
//             _buildAnimatedSection(1, _buildScopeSelector()),
//             _buildAnimatedSection(2, _buildTypeSelector()),
//             _buildAnimatedSection(3, _buildLogistics()),
//             _buildAnimatedSection(4, _buildVisibility()),
//             const SizedBox(height: 16),
//             _buildAnimatedSection(5, _buildSubmitButton()),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../services/meeting_service.dart';
import '../services/user_service.dart';
import '../services/team_service.dart';
import '../core/app_colors.dart';

class CreateMeetingScreen extends StatefulWidget {
  final VoidCallback onMeetingCreated;
  const CreateMeetingScreen({super.key, required this.onMeetingCreated});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final MeetingService meetingService = MeetingService();
  final TeamService teamService = TeamService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController onlineLinkController = TextEditingController();
  final TextEditingController agendaController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  String? priority = 'Medium';
  DateTime? dateTime;

  List<String> selectedTags = [];
  List<String> allTags = ['General', 'Impactathon', 'PictoFest', 'BDD'];

  bool isPrivate = false;
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> invitedUserIds = [];
  String searchQuery = '';

  bool isSubmitting = false;

  String meetingType = 'offline';

  String meetingScope = 'general';
  List<Map<String, dynamic>> allTeams = [];
  List<String> selectedTeamIds = [];

  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animations = List.generate(
      6,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            (index * 0.15) + 0.5,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.forward();

    fetchAllUsers();
    fetchVisibleTeams();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    onlineLinkController.dispose();
    agendaController.dispose();
    durationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void fetchAllUsers() async {
    try {
      final users = await UserService().getAllUsers();
      setState(() {
        allUsers = List<Map<String, dynamic>>.from(users);
        filteredUsers = List.from(allUsers);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load users: $e')));
      }
    }
  }

  void fetchVisibleTeams() async {
    try {
      final teams = await teamService.getVisibleTeams();
      if (mounted) {
        setState(() => allTeams = List<Map<String, dynamic>>.from(teams));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load teams: $e')));
      }
    }
  }

  void filterUserSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = allUsers.where((user) {
        final name = user['name'] ?? '';
        final year = user['year'] ?? '';
        final division = user['division'] ?? '';
        final text = "$name $year $division".toLowerCase();
        return text.contains(query.toLowerCase());
      }).toList();
    });
  }

  void submit() async {
    if (!_formKey.currentState!.validate() || dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and pick a date/time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (meetingScope == 'team-specific' && selectedTeamIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one team for a team-specific meeting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => isSubmitting = true);

    try {
      await meetingService.createMeeting(
        title: titleController.text,
        description: descriptionController.text,
        location: meetingType == 'offline' ? locationController.text : '',
        onlineLink: meetingType == 'online' ? onlineLinkController.text : '',
        dateTime: dateTime!,
        agenda: agendaController.text,
        duration: durationController.text.isEmpty
            ? 60
            : int.parse(durationController.text),
        priority: priority,
        tags: selectedTags,
        isPrivate: isPrivate,
        invitedMembers: invitedUserIds,
        team: meetingScope == 'team-specific' ? selectedTeamIds : null,
      );

      widget.onMeetingCreated();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create meeting: $e')));
      }
    }
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return FadeTransition(
      opacity: _animations[index],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_animations[index]),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTeal,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.lightGray),
      prefixIcon: Icon(icon, color: AppColors.orange),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkTeal, width: 2),
      ),
    );
  }

  Widget _buildCoreDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Core Details", Icons.article_outlined),
        TextFormField(
          controller: titleController,
          decoration: _buildInputDecoration('Title', Icons.title_rounded),
          validator: (val) => val!.isEmpty ? 'Enter title' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: _buildInputDecoration('Description', Icons.description_outlined),
          validator: (val) => val!.isEmpty ? 'Enter description' : null,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildGradientSegmentedButton<T>({
    required List<ButtonSegment<T>> segments,
    required Set<T> selected,
    required void Function(Set<T>) onSelectionChanged,
    Color? foregroundColor,
    double? height,
  }) {
    return Container(
      height: height ?? 48,
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SegmentedButton<T>(
        segments: segments,
        selected: selected,
        onSelectionChanged: onSelectionChanged,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(fontWeight: FontWeight.bold);
              }
              return null;
            },
          ),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          foregroundColor: MaterialStateProperty.all(foregroundColor ?? Colors.white),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildScopeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Meeting Scope", Icons.group_work_outlined),
        SizedBox(
          width: double.infinity,
          child: _buildGradientSegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'general',
                label: Text('General'),
                icon: Icon(Icons.public),
              ),
              ButtonSegment(
                value: 'team-specific',
                label: Text('Team'),
                icon: Icon(Icons.group),
              ),
            ],
            selected: {meetingScope},
            onSelectionChanged: (newSelection) {
              setState(() => meetingScope = newSelection.first);
            },
          ),
        ),
        if (meetingScope == 'team-specific') ...[
          const SizedBox(height: 16),
          const Text(
            'Select Teams',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGray),
          ),
          const SizedBox(height: 8),
          allTeams.isEmpty
              ? const Text('Loading teams...')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTeams.map((team) {
                    final isSelected = selectedTeamIds.contains(team['_id']);
                    return ChoiceChip(
                      label: Text(team['shortName'] ?? team['name']),
                      selected: isSelected,
                      selectedColor: AppColors.green.withOpacity(0.2),
                      checkmarkColor: AppColors.green,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.green : AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedTeamIds.add(team['_id']);
                          } else {
                            selectedTeamIds.remove(team['_id']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
        ],
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Meeting Type", Icons.settings_ethernet_outlined),
        SizedBox(
          width: double.infinity,
          child: _buildGradientSegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'offline',
                label: Text('Offline'),
                icon: Icon(Icons.location_on_outlined),
              ),
              ButtonSegment(
                value: 'online',
                label: Text('Online'),
                icon: Icon(Icons.videocam_outlined),
              ),
            ],
            selected: {meetingType},
            onSelectionChanged: (newSelection) {
              setState(() => meetingType = newSelection.first);
            },
          ),
        ),
        const SizedBox(height: 16),
        if (meetingType == 'offline')
          TextFormField(
            controller: locationController,
            decoration: _buildInputDecoration('Location', Icons.location_city_outlined),
            validator: (val) => val!.isEmpty ? 'Enter location for offline meeting' : null,
          ),
        if (meetingType == 'online')
          TextFormField(
            controller: onlineLinkController,
            decoration: _buildInputDecoration('Online Meeting Link', Icons.link_rounded),
            validator: (val) => val!.isEmpty ? 'Enter meeting link for online meeting' : null,
          ),
      ],
    );
  }

  Widget _buildLogistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Logistics", Icons.schedule_outlined),
        _buildDateTimePicker(),
        const SizedBox(height: 16),
        TextFormField(
          controller: agendaController,
          decoration: _buildInputDecoration('Agenda (Optional)', Icons.list_alt_rounded),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: durationController,
                decoration: _buildInputDecoration('Duration (mins)', Icons.timer_outlined),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return null;
                  if (int.tryParse(val) == null) return 'Must be a number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: priority,
                items: ['Low', 'Medium', 'High', 'Urgent']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => priority = val),
                decoration: _buildInputDecoration('Priority', Icons.flag_outlined),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGray)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allTags.map((tag) {
            final selected = selectedTags.contains(tag);
            return ChoiceChip(
              label: Text(tag),
              selected: selected,
              backgroundColor: Colors.white,
              selectedColor: AppColors.orange.withOpacity(0.2),
              checkmarkColor: AppColors.orange,
              labelStyle: TextStyle(
                color: selected ? AppColors.orange : AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    selectedTags.add(tag);
                  } else {
                    selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVisibility() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Visibility & Access", Icons.visibility_outlined),
        SizedBox(
          width: double.infinity,
          child: _buildGradientSegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Public'), icon: Icon(Icons.public)),
              ButtonSegment(value: true, label: Text('Private'), icon: Icon(Icons.lock_outline)),
            ],
            selected: {isPrivate},
            onSelectionChanged: (newSelection) {
              setState(() => isPrivate = newSelection.first);
            },
          ),
        ),
        if (isPrivate) ...[
          const SizedBox(height: 20),
          _buildMemberSelector(),
        ],
      ],
    );
  }

  Widget _buildDateTimePicker() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkTeal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 55,
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: AppColors.darkTeal,
                      onPrimary: Colors.white,
                      onSurface: AppColors.darkGray,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && mounted) {
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: theme.copyWith(
                      colorScheme: theme.colorScheme.copyWith(
                        primary: AppColors.darkTeal,
                        onPrimary: Colors.white,
                        onSurface: AppColors.darkGray,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() {
                  dateTime = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(
            dateTime == null ? 'Pick Date & Time' : 'Selected: ${dateTime!.toLocal()}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return allUsers.where((user) {
              final name = user['name'] ?? '';
              final year = user['year'] ?? '';
              final division = user['division'] ?? '';
              final text = "$name $year $division".toLowerCase();
              return text.contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (user) => "${user['name']} ${user['year']} ${user['division']}",
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: _buildInputDecoration('Search & Select Members', Icons.person_search_outlined),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final user = options.elementAt(index);
                      final selected = invitedUserIds.contains(user['_id']);
                      return ListTile(
                        title: Text("${user['name']} ${user['year']} ${user['division']}"),
                        trailing: selected ? const Icon(Icons.check, color: AppColors.green) : null,
                        onTap: () {
                          setState(() {
                            if (selected) {
                              invitedUserIds.remove(user['_id']);
                            } else {
                              invitedUserIds.add(user['_id']);
                            }
                          });
                          onSelected(user);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: invitedUserIds.map((id) {
            final user = allUsers.firstWhere(
              (u) => u['_id'] == id,
              orElse: () => {'name': 'Unknown', 'year': '', 'division': ''},
            );
            return Chip(
              label: Text("${user['name']} ${user['year']} ${user['division']}"),
              backgroundColor: AppColors.green.withOpacity(0.2),
              deleteIconColor: AppColors.green,
              labelStyle: const TextStyle(color: AppColors.green),
              onDeleted: () {
                setState(() {
                  invitedUserIds.remove(id);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return isSubmitting
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.darkTeal,
            ))
        : Container(
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                onPressed: submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Create Meeting'),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Meeting'),
        backgroundColor: AppColors.darkTeal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAnimatedSection(0, _buildCoreDetails()),
            _buildAnimatedSection(1, _buildScopeSelector()),
            _buildAnimatedSection(2, _buildTypeSelector()),
            _buildAnimatedSection(3, _buildLogistics()),
            _buildAnimatedSection(4, _buildVisibility()),
            const SizedBox(height: 16),
            _buildAnimatedSection(5, _buildSubmitButton()),
          ],
        ),
      ),
    );
  }
}