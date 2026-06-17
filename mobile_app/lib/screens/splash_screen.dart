import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import 'provider_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    final role = prefs.getString("role");

    await Future.delayed(const Duration(seconds: 1)); // small splash

    if (token != null) {

      if (role == "provider") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderDashboardScreen(),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}