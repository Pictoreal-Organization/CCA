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
          curve: Interval(index * 0.15, (index * 0.15) + 0.5, curve: Curves.easeOutCubic),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load teams: $e')));
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
        duration: durationController.text.isEmpty ? 60 : int.parse(durationController.text),
        priority: priority,
        tags: selectedTags,
        isPrivate: isPrivate,
        invitedMembers: invitedUserIds,
        team: meetingScope == 'team-specific' ? selectedTeamIds : null,
      );

      widget.onMeetingCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create meeting: $e')));
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.lightGray),
      prefixIcon: Icon(icon, color: AppColors.orange),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkTeal),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 2),
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientSegmentedButton<T>({
    required List<ButtonSegment<T>> segments,
    required Set<T> selected,
    required void Function(Set<T>) onSelectionChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkTeal, AppColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkTeal),
      ),
      child: SegmentedButton<T>(
        segments: segments,
        selected: selected,
        onSelectionChanged: onSelectionChanged,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return isSubmitting
        ? const Center(child: CircularProgressIndicator(color: AppColors.darkTeal))
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkTeal, AppColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  shadowColor: Colors.transparent,
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
      backgroundColor: Colors.white,
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
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
