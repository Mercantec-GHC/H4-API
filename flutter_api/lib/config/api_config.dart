import 'package:flutter/foundation.dart';

class ApiConfig {
  static final String apiUrl =
      kReleaseMode ? 'https://h4-jwt.onrender.com' : 'https://localhost:7105';
}
