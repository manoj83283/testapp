import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'provider_home_screen.dart';
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

      if (user == null) {
        Fluttertoast.showToast(msg: "Invalid response");
        setState(() => isLoading = false);
        return;
      }

      final role = (user["role"] ?? "").toString().toLowerCase().trim();

      if (role != widget.role) {
        Fluttertoast.showToast(
          msg: "⚠️ Please login as ${widget.role}",
        );
        setState(() => isLoading = false);
        return;
      }

      Fluttertoast.showToast(msg: "✅ Login successful");

      navigateByRole(role);

    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }

    setState(() => isLoading = false);
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

      if (user == null) {
        Fluttertoast.showToast(msg: "Invalid response");
        setState(() => isLoading = false);
        return;
      }

      final role = (user["role"] ?? "").toString().toLowerCase().trim();

      if (role != widget.role) {
        Fluttertoast.showToast(
          msg: "⚠️ Please login as ${widget.role}",
        );
        setState(() => isLoading = false);
        return;
      }

      Fluttertoast.showToast(msg: "✅ Google login successful");

      navigateByRole(role);

    } catch (e) {
      Fluttertoast.showToast(
        msg: "Google Login Error: ${e.toString()}",
      );
    }

    setState(() => isLoading = false);
  }

  // ===========================================================
  // ✅ NAVIGATION
  // ===========================================================
  void navigateByRole(String role) {
    if (role == "provider") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProviderHomeScreen(),
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
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
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
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 10),

                /// ✅ GOOGLE LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text("Continue with Google"),
                    onPressed: isLoading
                        ? null
                        : handleGoogleLogin,
                  ),
                ),

                const SizedBox(height: 10),

                /// ✅ SIGNUP
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SignupScreen(role: widget.role),
                      ),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
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
