// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import './pages/navbar.dart'; // Import the navbar instead of home page directly

// // void main() {
// //   runApp(const MyApp());
// // }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await dotenv.load(fileName: ".env");
//     print('Environment loaded successfully');
//     print('API_URL: ${dotenv.env['API_URL']}');
//   } catch (e) {
//     print('Failed to load .env file: $e');
//     print('Using fallback environment variables');
//     // Initialize dotenv with fallback values
//     dotenv.testLoad(fileInput: '''
// API_URL=https://jsonplaceholder.typicode.com
// DEBUG_MODE=true
// ''');
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.blue,
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//         appBarTheme: const AppBarTheme(
//           systemOverlayStyle: SystemUiOverlayStyle.light,
//         ),
//       ),
//       home: const MainNavigation(username: 'John Doe',userId: '688517e3a7acdb810118f86f',), // Use MainNavigation instead of HomePage
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import './screens/signIn.screen.dart';
// import './screens/member_dashboard.screen.dart';
// import './screens/head_dashboard.screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString("accessToken");
//   String? role = prefs.getString("role");
//   runApp(MyApp(token: token, role: role));
// }

// class MyApp extends StatelessWidget {
//   final String? token;
//   final String? role;
//   const MyApp({Key? key, this.token, this.role}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Widget homeScreen;

//     if (token != null && JwtDecoder.isExpired(token!) == false) {
//       if (role == "Head") homeScreen = HeadDashboard();
//       else homeScreen = MemberDashboard();
//     } else {
//       homeScreen = SignInScreen();
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primaryColor: Colors.white, visualDensity: VisualDensity.adaptivePlatformDensity),
//       home:  homeScreen,
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'screens/splash.screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
