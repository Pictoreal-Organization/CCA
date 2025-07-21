import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/navbar.dart'; // Import the navbar instead of home page directly

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const MainNavigation(username: 'John Doe',userId: '2a',), // Use MainNavigation instead of HomePage
    );
  }
}