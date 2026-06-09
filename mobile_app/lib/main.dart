import 'package:flutter/material.dart';

import 'screens/role_selection_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/provider_home_screen.dart';
import 'screens/add_service_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

import 'config/api_config.dart';

void main() {
  print("🌐 Using API base URL: ${ApiConfig.baseUrl}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventEase',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      /// ✅ FIRST SCREEN (VERY IMPORTANT)
      home: const RoleSelectionScreen(),

      routes: {

        /// ✅ CUSTOMER AUTH
        '/login_user': (context) => const LoginScreen(role: "user"),
        '/signup_user': (context) => const SignupScreen(role: "user"),

        /// ✅ PROVIDER AUTH
        '/login_provider': (context) =>
            const LoginScreen(role: "provider"),
        '/signup_provider': (context) =>
            const SignupScreen(role: "provider"),

        /// ✅ MAIN SCREENS
        '/home': (context) => const HomeScreen(),
        '/providerHome': (context) => const ProviderHomeScreen(),

        '/addService': (context) => const AddServiceScreen(),

        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),

        /// ✅ BOOKINGS (TEMP SCREEN)
        '/bookings': (context) => Scaffold(
              appBar: AppBar(title: const Text("My Bookings")),
              body: const Center(
                child: Text("Bookings coming soon"),
              ),
            ),
      },
    );
  }
}