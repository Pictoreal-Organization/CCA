import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String baseUrl = String.fromEnvironment("BASE_URL");

}
