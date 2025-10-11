import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService userService = UserService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _divisionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  String _email = "";
  String _role = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email') ?? '';
      _role = prefs.getString('role') ?? '';
      _nameController.text = prefs.getString('name') ?? '';
      _rollController.text = prefs.getString('rollNo') ?? '';
      _yearController.text = prefs.getString('year') ?? '';
      _divisionController.text = prefs.getString('division') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
    });
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
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.account_circle, size: 100, color: Colors.blueGrey),
                        const SizedBox(height: 8),
                        Text(_email, style: const TextStyle(fontSize: 16)),
                        Text("Role: $_role", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  TextField(
                    controller: _rollController,
                    decoration: const InputDecoration(labelText: "Roll No"),
                  ),
                  TextField(
                    controller: _yearController,
                    decoration: const InputDecoration(labelText: "Year"),
                  ),
                  TextField(
                    controller: _divisionController,
                    decoration: const InputDecoration(labelText: "Division"),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}
