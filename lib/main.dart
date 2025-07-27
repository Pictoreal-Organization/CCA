import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './pages/navbar.dart'; // Import the navbar instead of home page directly

// void main() {
//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    print('Environment loaded successfully');
    print('API_URL: ${dotenv.env['API_URL']}');
  } catch (e) {
    print('Failed to load .env file: $e');
    print('Using fallback environment variables');
    // Initialize dotenv with fallback values
    dotenv.testLoad(fileInput: '''
API_URL=https://jsonplaceholder.typicode.com
DEBUG_MODE=true
''');
  }

  runApp(MyApp());
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