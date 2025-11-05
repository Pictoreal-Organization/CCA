import 'package:flutter/material.dart';
import '../services/meeting_service.dart';
import '../services/user_service.dart';
import '../services/team_service.dart';
import '../core/app_colors.dart';
import '../widgets/date_time_picker_widget.dart';

// ------ CONSTANTS -------
const Color kUnselectedBg = Colors.white;
const Color kUnselectedText = AppColors.lightGray;
const double kBorderRadius = 14;

// Custom segmented button widget with per-tab color logic
class CustomToggleSelector<T> extends StatelessWidget {
  final List<_ToggleOption<T>> options;
  final T selected;
  final void Function(T selected) onSelectionChanged;
  final Map<int, Color>? perOptionSelectedColors;

  const CustomToggleSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelectionChanged,
    this.perOptionSelectedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.asMap().entries.map((entry) {
        final int idx = entry.key;
        final option = entry.value;
        final bool isSelected = option.value == selected;

        final Color selectedBg = perOptionSelectedColors != null && perOptionSelectedColors!.containsKey(idx)
            ? perOptionSelectedColors![idx]!
            : AppColors.orange;
        final Color selectedText = Colors.white;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelectionChanged(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : kUnselectedBg,
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                ],
                border: Border.all(
                  color: isSelected ? selectedBg : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      color: isSelected ? selectedText : kUnselectedText,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? selectedText : kUnselectedText,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToggleOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  const _ToggleOption({required this.value, required this.label, this.icon});
}

// --------- MAIN SCREEN ---------
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
  final UserService userService = UserService();

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

  final ValueNotifier<String> selectedScopeNotifier = ValueNotifier<String>('general');

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
    selectedScopeNotifier.dispose();
    super.dispose();
  }

  void fetchAllUsers() async {
    try {
      final users = await userService.getAllUsers();
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

  // void fetchVisibleTeams() async {
  //   try {
  //     final teams = await teamService.getVisibleTeams();
  //     if (mounted) {
  //       setState(() => allTeams = List<Map<String, dynamic>>.from(teams));
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load teams: $e')));
  //     }
  //   }
  // }
  void fetchVisibleTeams() async {
  try {
    final teams = await teamService.getVisibleTeams();

    // ✅ Clean team names before setting state
    final cleanedTeams = teams.map<Map<String, dynamic>>((team) {
      final name = team['name']?.trim() ?? '';
      final words = name.split(RegExp(r'\s+')); // split by any spaces
      if (words.length > 1) {
        words.removeLast(); // remove last word safely
      }
      final cleanedName = words.join(' ');

      return {
        ...team,
        'name': cleanedName,
      };
    }).toList();

    if (mounted) {
      setState(() => allTeams = cleanedTeams);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load teams: $e')),
      );
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please fill all required fields and pick a date/time.'),
      backgroundColor: AppColors.darkOrange,
    ));
    return;
  }
  if (meetingScope == 'team-specific' && selectedTeamIds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please select at least one team for a team-specific meeting.'),
      backgroundColor: AppColors.darkOrange,
    ));
    return;
  }
  FocusScope.of(context).unfocus();
  setState(() => isSubmitting = true);

  try {
    // Call the createMeeting method in MeetingService with data from form fields
    final createdMeeting = await meetingService.createMeeting(
      title: titleController.text,
      description: descriptionController.text,
      dateTime: dateTime!,
      location: meetingType == 'offline' ? locationController.text : '',
      onlineLink: meetingType == 'online' ? onlineLinkController.text : null,
      agenda: agendaController.text,
      duration: int.tryParse(durationController.text) ?? 60,
      priority: priority,
      tags: selectedTags,
      isPrivate: isPrivate,
      invitedMembers: invitedUserIds,
      team: meetingScope == 'team-specific' ? selectedTeamIds : null,
    );

    // After successful creation, you can notify parent and close screen
    widget.onMeetingCreated();
    if (mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    setState(() => isSubmitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create meeting: $e')),
      );
    }
  }
}


  Widget _buildAnimatedSection(int index, Widget child) {
    return FadeTransition(
      opacity: _animations[index],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_animations[index]),
        child: Padding(padding: const EdgeInsets.only(bottom: 18.0), child: child),
      ),
    );
  }

  Widget _sectionCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 28),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkTeal, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.lightGray, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: AppColors.green),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.darkGray.withOpacity(0.1), width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.darkTeal, width: 2.5)),
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

  Widget _buildScopeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Meeting Scope", Icons.group_work_outlined),
        ValueListenableBuilder<String>(
          valueListenable: selectedScopeNotifier,
          builder: (context, selectedScope, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: SizedBox(
                key: ValueKey(selectedScope),
                width: double.infinity,
                child: CustomToggleSelector<String>(
                  options: const [
                    _ToggleOption(value: 'general', label: 'General', icon: Icons.public),
                    _ToggleOption(value: 'team-specific', label: 'Team-Specific', icon: Icons.group),
                  ],
                  selected: meetingScope,
                  onSelectionChanged: (selected) {
                    setState(() {
                      meetingScope = selected;
                      selectedScopeNotifier.value = selected;
                    });
                  },
                  perOptionSelectedColors: const {
                    0: AppColors.darkTeal,
                    1: AppColors.orange,
                  },
                ),
              ),
            );
          },
        ),

      if (meetingScope == 'team-specific') ...[
  const SizedBox(height: 16),
  const Text(
    'Select Teams',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.darkGray,
    ),
  ),
  const SizedBox(height: 8),

  // ✅ Outer padding for the whole grid
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, // ✅ 2 columns
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 3.8, // ✅ Keeps equal box shape
      children: allTeams.take(8).map<Widget>((team) {
        final isSelected = selectedTeamIds.contains(team['_id']);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedTeamIds.remove(team['_id']);
              } else {
                selectedTeamIds.add(team['_id']);
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.darkTeal.withOpacity(0.2)
                  : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? AppColors.darkTeal
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check,
                    color: AppColors.darkTeal,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    team['name'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.darkTeal
                          : AppColors.lightGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  ),
]

     

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
          child: CustomToggleSelector<String>(
            options: const [
              _ToggleOption(value: 'offline', label: 'Offline', icon: Icons.location_on_outlined),
              _ToggleOption(value: 'online', label: 'Online', icon: Icons.videocam_outlined),
            ],
            selected: meetingType,
            onSelectionChanged: (selected) => setState(() => meetingType = selected),
            perOptionSelectedColors: const {
              0: AppColors.darkTeal,
              1: AppColors.orange,
            },
          ),
        ),
        const SizedBox(height: 16),
        if (meetingType == 'offline')
          TextFormField(
            controller: locationController,
            decoration: _buildInputDecoration('Location (e.g., Conference Room B)', Icons.location_city_outlined),
            validator: (val) => val!.isEmpty ? 'Enter location for offline meeting' : null,
          ),
        if (meetingType == 'online')
          TextFormField(
            controller: onlineLinkController,
            decoration: _buildInputDecoration('Online Meeting Link (e.g., Zoom/Meet URL)', Icons.link_rounded),
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
        DateTimePickerWidget(
          initialDateTime: dateTime,
          onDateTimeChanged: (selectedDateTime) {
            setState(() {
              dateTime = selectedDateTime;
            });
          },
        ),
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
                    .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(value: e, child: Text(e)))
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
          spacing: 10,
          runSpacing: 10,
          children: allTags.map<Widget>((tag) {
            final selected = selectedTags.contains(tag);
            return ChoiceChip(
              label: Text(tag),
              selected: selected,
              backgroundColor: Colors.white,
              selectedColor: AppColors.green.withOpacity(0.2),
              checkmarkColor: AppColors.darkTeal,
              labelStyle: TextStyle(color: selected ? AppColors.darkTeal : AppColors.lightGray, fontWeight: FontWeight.w600),
              side: BorderSide(
                color: selected ? AppColors.darkTeal : Colors.grey.shade300,
                width: 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          child: CustomToggleSelector<bool>(
            options: const [
              _ToggleOption(value: false, label: 'Public', icon: Icons.public),
              _ToggleOption(value: true, label: 'Private', icon: Icons.lock_outline),
            ],
            selected: isPrivate,
            onSelectionChanged: (selected) => setState(() => isPrivate = selected),
            perOptionSelectedColors: const {
              0: AppColors.darkTeal,
              1: AppColors.orange,
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

 
  Widget _buildMemberSelector() {
  TextEditingController? memberController; // ✅ store controller reference

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Invite Specific Members',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
      ),
      const SizedBox(height: 12),
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
        displayStringForOption: (user) =>
            "${user['name']} ${user['year']} ${user['division']}",
        fieldViewBuilder:
            (context, controller, focusNode, onFieldSubmitted) {
          // ✅ keep a reference so we can clear it later
          memberController = controller;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: _buildInputDecoration(
              'Search & Select Members',
              Icons.person_search_outlined,
            ),
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
                    final selected =
                        invitedUserIds.contains(user['_id']);

                    return ListTile(
                      title: Text(
                        "${user['name']} ${user['year']} ${user['division']}",
                        style: const TextStyle(color: AppColors.darkGray),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check,
                              color: AppColors.darkTeal)
                          : null,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            invitedUserIds.remove(user['_id']);
                          } else {
                            invitedUserIds.add(user['_id']);
                          }
                        });

                        // ✅ Clear field text immediately after selection
                        memberController?.clear();
                        FocusScope.of(context).unfocus();

                        onSelected(user);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
        onSelected: (user) {
          // ✅ Ensure focus reset and text cleared safely
          memberController?.clear();
          FocusScope.of(context).unfocus();
        },
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: invitedUserIds.map<Widget>((id) {
          final user = allUsers.firstWhere(
            (u) => u['_id'] == id,
            orElse: () =>
                {'name': 'Unknown', 'year': '', 'division': ''},
          );
          return Chip(
            label: Text(
              "${user['name']} ${user['year']} ${user['division']}",
            ),
            backgroundColor: AppColors.darkTeal.withOpacity(0.1),
            deleteIconColor: AppColors.darkTeal,
            labelStyle: const TextStyle(
              color: AppColors.darkTeal,
              fontWeight: FontWeight.w500,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            side: const BorderSide(color: AppColors.green),
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
          color: AppColors.darkTeal, // 🟢 match the same tone
        ))
      : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkTeal, // 🟢 solid darkTeal background
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkTeal.withOpacity(0.4),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                onPressed: submit,
                icon: const Icon(Icons.add_circle_outline, size: 24),
                label: const Text('Create Meeting'),
              ),
            ),
          ),
        );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Meeting'),
        backgroundColor: AppColors.darkTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildAnimatedSection(0, _sectionCard(_buildCoreDetails())),
            _buildAnimatedSection(1, _sectionCard(_buildScopeSelector())),
            _buildAnimatedSection(2, _sectionCard(_buildTypeSelector())),
            _buildAnimatedSection(3, _sectionCard(_buildLogistics())),
            _buildAnimatedSection(4, _sectionCard(_buildVisibility())),
            const SizedBox(height: 24),
            _buildAnimatedSection(5, _buildSubmitButton()),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
