import 'package:flutter/material.dart';
import './home.dart';
import './schedule.dart';
import './tasks.dart'; // You'll need to create this
// import './calendar_page.dart'; // You'll need to create this
// import './profile_page.dart'; // You'll need to create this

class MainNavigation extends StatefulWidget {
  final String username;
  final String userId; // Add userId for task assignments
     
  const MainNavigation({
    Key? key, 
    required this.username,
    required this.userId,
  }) : super(key: key);
   
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  // List of pages - now properly structured
  late final List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(username: widget.username),
      SchedulePage(username: widget.username),
      TasksPage(username: widget.username, userId: widget.userId),
      // ProfilePage(username: widget.username, userId: widget.userId),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            activeIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}