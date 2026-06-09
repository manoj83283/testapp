import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sharedPreferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthService {

  // ------------------------------------------------------------
  // ✅ GOOGLE SIGN-IN (FULL FLOW)
  // ------------------------------------------------------------
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        // ✅ CALL BACKEND
        final response = await ApiService.googleLogin(
          email: user.email ?? "",
          name: user.displayName ?? "",
        );

        // ✅ SAVE TOKEN
        if (response["token"] != null) {
          await saveToken(response["token"]);
        }

        // ✅ SAVE USER ID
        if (response["user"] != null &&
            response["user"]["_id"] != null) {
          await saveUserId(response["user"]["_id"]);
        }
      }

      return user;
    } catch (e) {
      print("Google Login Error: $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // ✅ TOKEN STORAGE
  // ------------------------------------------------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ------------------------------------------------------------
  // ✅ USER ID STORAGE (VERY IMPORTANT)
  // ------------------------------------------------------------
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // ------------------------------------------------------------
  // ✅ HANDLE LOGIN RESPONSE (EMAIL LOGIN)
  // ------------------------------------------------------------
  static Future<void> handleLoginResponse(
      Map<String, dynamic> response) async {

    if (response["token"] != null) {
      await saveToken(response["token"]);
    }

    if (response["user"] != null &&
        response["user"]["_id"] != null) {
      await saveUserId(response["user"]["_id"]);
    }
  }

  // ------------------------------------------------------------
  // ✅ CHECK LOGIN STATUS
  // ------------------------------------------------------------
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ------------------------------------------------------------
  // ✅ LOGOUT (FULL CLEAN)
  // ------------------------------------------------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print("Logout error: $e");
    }
  }
}