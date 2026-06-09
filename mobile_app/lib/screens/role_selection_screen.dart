import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void openLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(role: role),
      ),
    );
  }

  void openSignup(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// ✅ TITLE
              const Text(
                "Choose Your Role",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// ✅ CUSTOMER CARD
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => openLogin(context, "user"),
                  child: Column(
                    children: const [
                      Icon(Icons.person, size: 40),
                      SizedBox(height: 10),
                      Text(
                        "Continue as Customer",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              /// ✅ PROVIDER CARD
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => openLogin(context, "provider"),
                  child: Column(
                    children: const [
                      Icon(Icons.store, size: 40),
                      SizedBox(height: 10),
                      Text(
                        "Continue as Service Provider",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// ✅ SIGNUP OPTIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => openSignup(context, "user"),
                    child: const Text("Signup Customer"),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => openSignup(context, "provider"),
                    child: const Text("Signup Provider"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}