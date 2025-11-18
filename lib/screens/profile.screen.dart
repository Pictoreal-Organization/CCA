import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
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
  // Services
  final UserService userService = UserService();
  final TaskService taskService = TaskService();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // State variables
  bool _isLoading = true;
  bool _isEditing = false;
  String _email = "";
  String _role = "";
  String _userId = "";
  List _completedTasks = [];
  String _selectedAvatar = AvatarConfig.defaultAvatar;

  @override
  void initState() {
    super.initState();
    loadAllData();
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

  Future<void> loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = await userService.getLoggedInUser();

      // Populate controllers & vars
      _userId = user['_id'] ?? '';
      _email = user['email'] ?? '';
      _role = user['role'] ?? '';
      _nameController.text = user['name'] ?? '';
      _rollController.text = user['rollNo'] ?? '';
      _yearController.text = user['year'] ?? '';
      _divisionController.text = user['division'] ?? '';
      _phoneController.text = user['phone'] ?? '';
      
      // Load avatar from backend
      _selectedAvatar = user['avatar'] ?? AvatarConfig.defaultAvatar;

      // RESTORED LOGIC: Fetch based on Role
      if (_role == 'Head') {
        // Heads see all completed tasks (or team based if preferred, keeping strictly to old logic here)
         _completedTasks = await taskService.getAllCompletedTasks();
      } else if (_role == 'Member' && _userId.isNotEmpty) {
        // Members only see their own
        _completedTasks = await taskService.getCompletedTasksByUser(_userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load profile data: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await userService.updateUserProfile(
        name: _nameController.text,
        rollNo: _rollController.text,
        year: _yearController.text,
        division: _divisionController.text,
        phone: _phoneController.text,
        avatar: _selectedAvatar,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.darkTeal,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isEditing
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              if (_isEditing) {
                saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading Profile...",
                    style: TextStyle(color: AppColors.lightGray, fontSize: 14),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.green,
              backgroundColor: Colors.white,
              onRefresh: loadAllData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                children: [
                  // --- profile header ---
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
                            child: _selectedAvatar.isEmpty ||
                                    _selectedAvatar == AvatarConfig.defaultAvatar
                                ? const Icon(
                                    Icons.account_circle_rounded,
                                    size: 74,
                                    color: Colors.white,
                                  )
                                : ClipOval(
                                    child: Image.asset(
                                      _selectedAvatar,
                                      width: 74,
                                      height: 74,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.account_circle_rounded,
                                          size: 74,
                                          color: Colors.white,
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

                  // --- Personal Information Section ---
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
                        const SizedBox(height: 3.5),
                        _buildEditableField("Full Name", _nameController, Icons.person),
                        const SizedBox(height: 3.5),
                        _buildEditableField("Roll No", _rollController, Icons.badge),
                        const SizedBox(height: 3.5),
                        _buildEditableField("Year", _yearController, Icons.school),
                        const SizedBox(height: 3.5),
                        _buildEditableField("Division", _divisionController, Icons.group),
                        const SizedBox(height: 3.5),
                        _buildEditableField("Phone Number", _phoneController, Icons.phone),
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
                            const Icon(Icons.task_alt, color: AppColors.green, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "Completed Tasks",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGray,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.incomplete_circle_rounded,
                                  color: AppColors.lightGray.withOpacity(0.5),
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No completed tasks yet",
                                  style: TextStyle(color: AppColors.lightGray, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Complete your first task to see it here!",
                                  style: TextStyle(
                                    color: AppColors.lightGray.withOpacity(0.7),
                                    fontSize: 12,
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
                            final subtasks = (task['subtasks'] as List?) ?? [];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Stack(
                                children: [
                                  // RESTORED LOGIC: Logic for ExpansionTile (Head) vs ListTile (Member)
                                  _role == 'Head'
                                    ? Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            leading: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.green.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.green,
                                                size: 20,
                                              ),
                                            ),
                                            title: Text(
                                              task['title'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.darkGray,
                                              ),
                                            ),
                                            subtitle: Text(
                                              task['completedAt'] != null
                                                  ? "Completed: ${_formatDate(DateTime.parse(task['completedAt']))}"
                                                  : task['deadline'] != null
                                                      ? "Deadline was: ${_formatDate(DateTime.parse(task['deadline']))}"
                                                      : 'Completion date not available',
                                              style: const TextStyle(
                                                color: AppColors.lightGray,
                                                fontSize: 12,
                                              ),
                                            ),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Divider(color: Colors.grey.shade300),
                                              ),
                                              ...subtasks.map((sub) {
                                                final assignedUsers = (sub['assignedTo'] as List)
                                                    .map((u) => u['username'])
                                                    .join(', ');
                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.grey.shade200)
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              sub['title'],
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                color: AppColors.darkGray,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        sub['description'] ?? 'No completion note.',
                                                        style: TextStyle(
                                                          color: AppColors.darkGray.withOpacity(0.8),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        "Completed by: $assignedUsers",
                                                        style: const TextStyle(
                                                          fontStyle: FontStyle.italic,
                                                          color: AppColors.lightGray,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              const SizedBox(height: 8),
                                            ],
                                          ),
                                      )
                                    : ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        leading: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.green.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.green,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          task['title'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkGray,
                                          ),
                                        ),
                                        subtitle: Text(
                                          task['completedAt'] != null
                                              ? "Completed: ${_formatDate(DateTime.parse(task['completedAt']))}"
                                              : task['deadline'] != null
                                                  ? "Deadline was: ${_formatDate(DateTime.parse(task['deadline']))}"
                                                  : 'Completion date not available',
                                          style: const TextStyle(
                                            color: AppColors.lightGray,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  
                                  // Decorative Side Bar
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
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_rounded, color: AppColors.green, size: 20),
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          if (_selectedAvatar != AvatarConfig.defaultAvatar)
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
                    side: const BorderSide(color: AppColors.darkOrange, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cancel, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Remove Avatar",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}