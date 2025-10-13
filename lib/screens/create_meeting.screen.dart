import 'package:flutter/material.dart';
import '../services/meeting_service.dart';
import '../services/user_service.dart';
import '../services/team_service.dart';

class CreateMeetingScreen extends StatefulWidget {
  final VoidCallback onMeetingCreated;
  const CreateMeetingScreen({super.key, required this.onMeetingCreated});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeetingService meetingService = MeetingService();
  final TeamService teamService = TeamService();

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController onlineLinkController = TextEditingController();
  final TextEditingController agendaController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  String? priority = 'Medium';
  DateTime? dateTime;

  // Tags
  List<String> selectedTags = [];
  List<String> allTags = ['General', 'Impactathon', 'PictoFest', 'BDD'];

  // Private meeting & invited members
  bool isPrivate = false;
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> invitedUserIds = [];
  String searchQuery = '';

  bool isSubmitting = false;

  // Meeting type: offline / online
  String meetingType = 'offline';

  // Meeting scope: general / team-specific
  String meetingScope = 'general';
  List<Map<String, dynamic>> allTeams = [];
  List<String> selectedTeamIds = [];

  @override
  void initState() {
    super.initState();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  void fetchVisibleTeams() async {
    try {
      final teams = await teamService.getVisibleTeams();
      setState(() => allTeams = List<Map<String, dynamic>>.from(teams));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load teams: $e')));
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
    if (!_formKey.currentState!.validate() || dateTime == null) return;

    FocusScope.of(context).unfocus(); // ensures all controllers have latest value
    setState(() => isSubmitting = true);

    try {
      await meetingService.createMeeting(
        title: titleController.text,
        description: descriptionController.text,
        location:
            meetingType == 'offline' ? locationController.text : '',
        onlineLink:
            meetingType == 'online' ? onlineLinkController.text : '',
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
      Navigator.pop(context);
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create meeting: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Meeting')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title & Description
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
              ),

              const SizedBox(height: 16),

              // Meeting Scope: General / Team-specific
              Text('Meeting Scope',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(
                    value: 'general',
                    groupValue: meetingScope,
                    onChanged: (val) => setState(() => meetingScope = val!),
                  ),
                  const Text('General'),
                  Radio<String>(
                    value: 'team-specific',
                    groupValue: meetingScope,
                    onChanged: (val) => setState(() => meetingScope = val!),
                  ),
                  const Text('Team-specific'),
                ],
              ),

              if (meetingScope == 'team-specific') ...[
                const SizedBox(height: 8),
                Text('Select Teams',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 6,
                  children: allTeams.map((team) {
                    final isSelected = selectedTeamIds.contains(team['_id']);
                    return ChoiceChip(
                      label: Text(team['shortName'] ?? team['name']),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) selectedTeamIds.add(team['_id']);
                          else selectedTeamIds.remove(team['_id']);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 16),

              // Meeting type: offline / online
              Text('Meeting Type',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(
                    value: 'offline',
                    groupValue: meetingType,
                    onChanged: (val) => setState(() => meetingType = val!),
                  ),
                  const Text('Offline'),
                  Radio<String>(
                    value: 'online',
                    groupValue: meetingType,
                    onChanged: (val) => setState(() => meetingType = val!),
                  ),
                  const Text('Online'),
                ],
              ),

              if (meetingType == 'offline')
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter location for offline meeting' : null,
                ),
              if (meetingType == 'online')
                TextFormField(
                  controller: onlineLinkController,
                  decoration: const InputDecoration(labelText: 'Online Meeting Link'),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter meeting link for online meeting' : null,
                ),

              TextFormField(
                controller: agendaController,
                decoration: const InputDecoration(labelText: 'Agenda (optional)'),
              ),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
              ),

              DropdownButtonFormField<String>(
                value: priority,
                items: ['Low', 'Medium', 'High', 'Urgent']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => priority = val),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),

              const SizedBox(height: 12),

              Text('Tags', style: const TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 6,
                children: allTags.map((tag) {
                  final selected = selectedTags.contains(tag);
                  return ChoiceChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) selectedTags.add(tag);
                        else selectedTags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              Text('Meeting Visibility',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: isPrivate,
                    onChanged: (val) => setState(() => isPrivate = val!),
                  ),
                  const Text('Public'),
                  Radio<bool>(
                    value: true,
                    groupValue: isPrivate,
                    onChanged: (val) => setState(() => isPrivate = val!),
                  ),
                  const Text('Private'),
                ],
              ),

              if (isPrivate) ...[
                const SizedBox(height: 10),
                Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty)
                      return const Iterable<Map<String, dynamic>>.empty();
                    return allUsers.where((user) {
                      final name = user['name'] ?? '';
                      final year = user['year'] ?? '';
                      final division = user['division'] ?? '';
                      final text = "$name $year $division".toLowerCase();
                      return text.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (user) =>
                      "${user['name']} ${user['year']} ${user['division']}",
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Search & Select Members',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final user = options.elementAt(index);
                              final selected = invitedUserIds.contains(user['_id']);
                              return ListTile(
                                title: Text("${user['name']} ${user['year']} ${user['division']}"),
                                trailing: selected ? const Icon(Icons.check) : null,
                                onTap: () {
                                  onSelected(user);
                                  setState(() {
                                    if (selected) invitedUserIds.remove(user['_id']);
                                    else invitedUserIds.add(user['_id']);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: invitedUserIds.map((id) {
                    final user = allUsers.firstWhere((u) => u['_id'] == id);
                    return Chip(
                      label: Text("${user['name']} ${user['year']} ${user['division']}"),
                      onDeleted: () {
                        setState(() {
                          invitedUserIds.remove(id);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
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
                child: Text(dateTime == null
                    ? 'Pick Date & Time'
                    : 'Selected: ${dateTime!.toLocal()}'),
              ),

              const SizedBox(height: 20),

              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submit,
                      child: const Text('Create Meeting'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
