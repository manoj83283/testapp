class ApiConfig {
  // For Android emulator use 10.0.2.2, for iOS simulator use 127.0.0.1
  static const String baseUrl = 'http://10.0.2.2:5000';
  static const String signupUrl = "$baseUrl/auth/signup";
  static const String loginUrl  = "$baseUrl/auth/login"; 
  static const String serviceUrl = "$baseUrl/services";
}