import 'package:flutter/material.dart';
import '../services/meeting_service.dart';
import '../services/user_service.dart';
import '../services/team_service.dart';
import '../core/app_colors.dart';

// ------ CONSTANTS -------
const Color kSelectedBg = Color(0xFFF0652F); // Orange shade from reference
const Color kSelectedText = Colors.white;
const Color kUnselectedBg = Colors.white;
const Color kUnselectedText = Color(0xFF8D95A8); // Gray shade from reference
const double kBorderRadius = 14;

// Custom segmented button widget
class CustomToggleSelector<T> extends StatelessWidget {
  final List<_ToggleOption<T>> options;
  final T selected;
  final void Function(T selected) onSelectionChanged;

  const CustomToggleSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final bool isSelected = option.value == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelectionChanged(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected ? kSelectedBg : kUnselectedBg,
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
                  color: isSelected ? kSelectedBg : Colors.grey.shade300,
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
                      color: isSelected ? kSelectedText : kUnselectedText,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? kSelectedText : kUnselectedText,
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

// ------------ MAIN SCREEN WIDGET ------------

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
      final users = [
        {'name': 'Alice', 'year': 'SY', 'division': 'A', '_id': 'u1'},
        {'name': 'Bob', 'year': 'TY', 'division': 'B', '_id': 'u2'},
        {'name': 'Charlie', 'year': 'FY', 'division': 'C', '_id': 'u3'},
      ];
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
      final teams = [
        {'name': 'Design SIG', 'shortName': 'Design', '_id': 't1'},
        {'name': 'Development SIG', 'shortName': 'Dev', '_id': 't2'},
        {'name': 'Marketing Team', 'shortName': 'Mktg', '_id': 't3'},
      ];
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
      await Future.delayed(const Duration(milliseconds: 1500));
      widget.onMeetingCreated();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create meeting: $e')));
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
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18), child: child),
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
                ),
              ),
            );
          },
        ),
        if (meetingScope == 'team-specific') ...[
          const SizedBox(height: 16),
          const Text('Select Teams', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGray)),
          const SizedBox(height: 8),
          allTeams.isEmpty
              ? const Text('Loading teams...')
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: allTeams.map<Widget>((team) {
                    final isSelected = selectedTeamIds.contains(team['_id']);
                    return ChoiceChip(
                      label: Text(team['name']),
                      selected: isSelected,
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.green.withOpacity(0.2),
                      checkmarkColor: AppColors.darkTeal,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.darkTeal : AppColors.lightGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.darkTeal : Colors.grey.shade300,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          child: CustomToggleSelector<String>(
            options: const [
              _ToggleOption(value: 'offline', label: 'Offline', icon: Icons.location_on_outlined),
              _ToggleOption(value: 'online', label: 'Online', icon: Icons.videocam_outlined),
            ],
            selected: meetingType,
            onSelectionChanged: (selected) => setState(() => meetingType = selected),
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

  Widget _buildDateTimePicker() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.darkTeal, AppColors.green], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
        height: 55,
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    useMaterial3: true,
                    colorScheme: theme.colorScheme.copyWith(
                      primary: AppColors.darkTeal,
                      onPrimary: Colors.white,
                      onSurface: AppColors.darkGray,
                      surfaceTint: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.white,
                    canvasColor: Colors.white,
                    datePickerTheme: const DatePickerThemeData(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                    ),
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
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: Colors.white,
                        hourMinuteColor: AppColors.darkTeal.withOpacity(0.12),
                        hourMinuteTextColor: AppColors.darkGray,
                        hourMinuteShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        dialBackgroundColor: AppColors.green.withOpacity(0.1),
                        dialHandColor: AppColors.darkTeal,

                        dialTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected) ? Colors.white : AppColors.darkGray,
                        ),

                        entryModeIconColor: AppColors.darkTeal,
                        dayPeriodColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected) ? AppColors.darkTeal : AppColors.green.withOpacity(0.08),
                        ),
                        dayPeriodTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected) ? Colors.white : AppColors.darkTeal,
                        ),
                        helpTextStyle: const TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      colorScheme: theme.colorScheme.copyWith(
                        primary: AppColors.darkTeal,
                        onPrimary: Colors.white,
                        onSurface: AppColors.darkGray,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() {
                  dateTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                });
              }
            }
          },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(
            dateTime == null ? 'Pick Date & Time' : 'Selected: ${dateTime!.toString().substring(0, 16)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invite Specific Members', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGray)),
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
                        title: Text("${user['name']} ${user['year']} ${user['division']}",
                            style: const TextStyle(color: AppColors.darkGray)),
                        trailing: selected ? const Icon(Icons.check, color: AppColors.darkTeal) : null,
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
          children: invitedUserIds.map<Widget>((id) {
            final user = allUsers.firstWhere((u) => u['_id'] == id, orElse: () => {'name': 'Unknown', 'year': '', 'division': ''});
            return Chip(
              label: Text("${user['name']} ${user['year']} ${user['division']}"),
              backgroundColor: AppColors.darkTeal.withOpacity(0.1),
              deleteIconColor: AppColors.darkTeal,
              labelStyle: const TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
            color: AppColors.darkTeal,
          ))
        : Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkTeal, AppColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkTeal.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildAnimatedSection(0, _sectionCard(_buildCoreDetails())),
            _buildAnimatedSection(1, _sectionCard(_buildScopeSelector())),
            _buildAnimatedSection(2, _sectionCard(_buildTypeSelector())),
            _buildAnimatedSection(3, _sectionCard(_buildLogistics())),
            _buildAnimatedSection(4, _sectionCard(_buildVisibility())),
            const SizedBox(height: 24),
            _buildAnimatedSection(
                5,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSubmitButton(),
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
