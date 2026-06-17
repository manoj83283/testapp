import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // ===========================================================
  // ✅ SAVE LOGIN SESSION
  // ===========================================================
  Future<void> saveUserSession(Map user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", token);
    await prefs.setString("role", user["role"] ?? "");
    await prefs.setString("userId", user["_id"] ?? "");
    await prefs.setString("name", user["name"] ?? "");
    await prefs.setString("email", user["email"] ?? "");
  }

  // ===========================================================
  // ✅ EMAIL LOGIN
  // ===========================================================
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService.login({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      });

      final user = res["user"];
      final token = res["token"];

      if (user == null || token == null) {
        Fluttertoast.showToast(msg: "Invalid response");
        return;
      }

      final role = (user["role"] ?? "").toString().toLowerCase().trim();

      /// ✅ ROLE VALIDATION
      if (role != widget.role) {
        Fluttertoast.showToast(
          msg: "⚠️ Please login as ${widget.role}",
        );
        return;
      }

      /// ✅ SAVE SESSION
      await saveUserSession(user, token);

      Fluttertoast.showToast(msg: "✅ Login successful");

      navigateByRole(role);

    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===========================================================
  // ✅ GOOGLE LOGIN
  // ===========================================================
  Future<void> handleGoogleLogin() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.googleLogin(
        email: "test@gmail.com",
        name: "Test User",
      );

      final user = res["user"];
      final token = res["token"];

      if (user == null || token == null) {
        Fluttertoast.showToast(msg: "Invalid response");
        return;
      }

      final role = (user["role"] ?? "").toString().toLowerCase().trim();

      if (role != widget.role) {
        Fluttertoast.showToast(
          msg: "⚠️ Please login as ${widget.role}",
        );
        return;
      }

      /// ✅ SAVE SESSION
      await saveUserSession(user, token);

      Fluttertoast.showToast(msg: "✅ Google login successful");

      navigateByRole(role);

    } catch (e) {
      Fluttertoast.showToast(
        msg: "Google Login Error: ${e.toString()}",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ===========================================================
  // ✅ NAVIGATION
  // ===========================================================
  void navigateByRole(String role) {

    if (!context.mounted) return;

    if (role == "provider") {

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/providerHome',
        (route) => false,
      );

    } else {

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );

    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              children: [

                const SizedBox(height: 50),

                /// ✅ TITLE
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// ✅ EMAIL
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.contains("@")
                          ? null
                          : "Enter valid email",
                ),

                const SizedBox(height: 15),

                /// ✅ PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 6
                          ? null
                          : "Minimum 6 characters",
                ),

                const SizedBox(height: 20),

                /// ✅ LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 10),

                /// ✅ GOOGLE LOGIN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.account_circle),
                    label: const Text("Continue with Google"),
                    onPressed: isLoading ? null : handleGoogleLogin,
                  ),
                ),

                const SizedBox(height: 10),

                /// ✅ SIGNUP NAVIGATION
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(role: widget.role),
                      ),
                    );
                  },
                  child: Text(
                    widget.role == "provider"
                        ? "Don't have a provider account? Sign Up"
                        : "Don't have an account? Sign Up",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}