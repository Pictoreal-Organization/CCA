import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/task_service.dart';
import '../services/user_service.dart';
import '../core/app_colors.dart';

class AvatarConfig {
  static final List<String> avatarPaths = [
    'assets/images/Avatar1.png',
    'assets/images/Avatar2.png',
    'assets/images/Avatar3.png',
    'assets/images/Avatar4.png',
    'assets/images/Avatar5.png',
    'assets/images/Avatar6.png',
    'assets/images/Avatar7.png',
    'assets/images/Avatar8.png',
    'assets/images/Avatar9.png',
  ];

  static const String defaultAvatar = 'assets/images/default.png';
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
  bool _isEditing = false; // ✏️ toggle edit mode
  String _email = "";
  String _role = "";
  String _userId = "";
  List _completedTasks = [];
  String _selectedAvatar = AvatarConfig.defaultAvatar;
  bool _showAvatarSelection = false;

  final GlobalKey _avatarButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadAllData().then((_) {
      _loadSavedAvatar();
    });
  }

  Future<void> _loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId.isEmpty) {
      await loadAllData();
    }
    setState(() {
      _selectedAvatar =
          prefs.getString('user_avatar_$_userId') ?? AvatarConfig.defaultAvatar;
    });
  }

  Future<void> _saveAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar_$_userId', avatarPath);
    try {
      await userService.updateUserAvatar(avatarPath);
    } catch (e) {
      print('Failed to save avatar to server: $e');
    }
  
    setState(() {
      _selectedAvatar = avatarPath;
      //_showAvatarSelection = false;
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
          insetPadding: EdgeInsets.all(20),
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

      // Fetch completed tasks
      if (_role == 'Head') {
        _completedTasks = await taskService.getAllCompletedTasks();
      } else if (_role == 'Member' && _userId.isNotEmpty) {
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
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.darkTeal,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Toggle Edit / Save
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(6),
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
                children: [
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
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                children: [
                  // --- profile header ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar outside the container (on the left)
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
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          child: _selectedAvatar.isEmpty 
                            ? Icon(
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
                                errorBuilder: (context, error, StackTrace) {
                                  return Icon(
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
                                key: _avatarButtonKey,
                                onTap: _showAvatarSelectionModal,
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkTeal,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.photo_library_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(width: 16), // Space between avatar and container
                      // Text info container only
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            //color: Color.fromARGB(223, 255, 175, 105),
                            color: Color.fromARGB(255, 255, 155, 55),
                            /*gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(233, 252, 83, 31),
                                Color.fromARGB(255, 254, 115, 9),
                                Color.fromARGB(255, 255, 182, 86),
                              ],
                              stops: [0.0, 0.4, 1.2],
                            ),*/
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF6B00).withOpacity(0.5),
                                blurRadius: 15,
                                offset: Offset(5, 5),
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _role ?? 'Member',
                                  style: TextStyle(
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
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
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
                        SizedBox(height: 3.5),
                        _buildEditableField(
                          "Full Name",
                          _nameController,
                          Icons.person,
                        ),
                        SizedBox(height: 3.5),
                        _buildEditableField(
                          "Roll No",
                          _rollController,
                          Icons.badge,
                        ),
                        SizedBox(height: 3.5),
                        _buildEditableField(
                          "Year",
                          _yearController,
                          Icons.school,
                        ),
                        SizedBox(height: 3.5),
                        _buildEditableField(
                          "Division",
                          _divisionController,
                          Icons.group,
                        ),
                        SizedBox(height: 3.5),
                        _buildEditableField(
                          "Phone Number",
                          _phoneController,
                          Icons.phone,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // --- Completed Tasks Section ---
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      //border: Border.all(
                      //color: _completedTasks.length.isEven ? AppColors.orange : AppColors.darkTeal,
                      //width: 2,
                      //),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.task_alt,
                              color: AppColors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Completed Tasks",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGray,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_completedTasks.length}",
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        if (_completedTasks.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 40),
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
                                SizedBox(height: 16),
                                Text(
                                  "No completed tasks yet",
                                  style: TextStyle(
                                    color: AppColors.lightGray,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
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
                            final taskIndex =
                                entry.key; // This gives us the actual index
                            final task = entry.value;
                            final subtasks = (task['subtasks'] as List?) ?? [];
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  //taskIndex.isEven ? AppColors.orange.withOpacity(0.3) : AppColors.darkTeal.withOpacity(0.3),
                                ),

                                /*boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkTeal.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],*/
                              ),

                              child: Stack(
                                children: [
                                  _role == 'Head'
                                      ? ExpansionTile(
                                          leading: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.green
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.green,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            task['title'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.darkGray,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Completed: ${task['deadline'] != null ? _formatDate(DateTime.parse(task['deadline'])) : 'N/A'}",
                                            style: TextStyle(
                                              color: AppColors.lightGray,
                                              fontSize: 12,
                                            ),
                                          ),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                              child: Divider(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            ...subtasks.map((sub) {
                                              final assignedUsers =
                                                  (sub['assignedTo'] as List)
                                                      .map((u) => u['username'])
                                                      .join(', ');
                                              return Container(
                                                margin: EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      sub['title'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.darkGray,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      sub['description'] ??
                                                          'No completion note.',
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .darkGray
                                                            .withOpacity(0.8),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      "Completed by: $assignedUsers",
                                                      style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color:
                                                            AppColors.lightGray,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            SizedBox(height: 8),
                                          ],
                                        )
                                      : ListTile(
                                          leading: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.green
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.green,
                                              size: 20,
                                            ),
                                          ),
                                          title: Text(
                                            task['title'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.darkGray,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Completed: ${task['deadline'] != null ? _formatDate(DateTime.parse(task['deadline'])) : 'N/A'}",
                                            style: TextStyle(
                                              color: AppColors.lightGray,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                  // ADDED: Left colored line
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 8, // Width of the colored line
                                      decoration: BoxDecoration(
                                        color: taskIndex.isEven
                                            ? AppColors.orange
                                            : AppColors.darkTeal,
                                        borderRadius: BorderRadius.only(
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

                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // Helper method for building editable fields
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
        style: TextStyle(
          color: AppColors.darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.lightGray, fontSize: 13),
          prefixIcon: Icon(
            icon,
            color: _isEditing ? AppColors.green : AppColors.lightGray,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAvatarSelectionContent() {
    final selectableAvatars = AvatarConfig.avatarPaths.where(
      (path) => path != AvatarConfig.defaultAvatar
    ).toList();

    return Container(
      padding: EdgeInsets.all(20),
      constraints: BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library_rounded,
                color: AppColors.green,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Choose Your Avatar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                /*() {
                  setState(() {
                    _showAvatarSelection = false;
                  });
                },*/
              ),
            ],
          ),
          SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns for better visual appeal
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: selectableAvatars.length,
            itemBuilder: (context, index) {
              final avatarPath = AvatarConfig.avatarPaths[index];
              return GestureDetector(
                onTap: () {
                  _saveAvatar(avatarPath);
                  Navigator.of(context).pop(); // CHANGED
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
          SizedBox(height: 20),

          // Delete Avatar Button
          if (_selectedAvatar != AvatarConfig.defaultAvatar)
            Container(
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
                    side: BorderSide(color: AppColors.darkOrange, width: 2),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Remove Avatar",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method for date formatting
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
