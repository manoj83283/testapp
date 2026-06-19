import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/role_selection_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/provider_dashboard_screen.dart';
import 'screens/add_service_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'localization/app_localizations.dart'; 
import 'screens/address_screen.dart';

import 'services/socket_service.dart';
import 'config/api_config.dart';

/// ✅ GLOBAL LOCALE CONTROLLER
ValueNotifier<Locale> localeNotifier =
    ValueNotifier(const Locale('en'));

/// ✅ LOAD SAVED LANGUAGE
Future<void> loadSavedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('language_code') ?? 'en';
  localeNotifier.value = Locale(langCode);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🌐 Using API base URL: ${ApiConfig.baseUrl}");

  await loadSavedLanguage();

  runApp(const MyApp());
}

/// ✅ ROOT APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,

      builder: (_, locale, __) {

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "EventEase",

          /// ✅ LANGUAGE CONFIG
          locale: locale,

          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('te'),
            Locale('ta'),
            Locale('kn'),
            Locale('ml'),
            Locale('mr'),
            Locale('bn'),
          ],

          /// ✅ ✅ SAFE FALLBACK (NO CRASH)
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          /// ✅ THEME
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),

          /// ✅ START ROUTER
          home: const SplashRouter(),

          /// ✅ ROUTES
          routes: {

            /// AUTH
            '/login_user': (context) =>
                const LoginScreen(role: "user"),
            '/signup_user': (context) =>
                const SignupScreen(role: "user"),

            '/login_provider': (context) =>
                const LoginScreen(role: "provider"),
            '/signup_provider': (context) =>
                const SignupScreen(role: "provider"),

            /// MAIN
            '/home': (context) => const HomeScreen(),

            '/providerHome': (context) =>
                const ProviderDashboardScreen(),

            '/addService': (context) =>
                const AddServiceScreen(),
            '/address': (context) => const AddressScreen(),

            '/profile': (context) => ProfileScreen(),
            '/settings': (context) => SettingsScreen(),

            /// TEMP BOOKINGS
            '/bookings': (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text("My Bookings"),
                  ),
                  body: const Center(
                    child: Text("Bookings coming soon"),
                  ),
                ),
          },
        );
      },
    );
  }
}

/// ✅ ✅ SPLASH ROUTER
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {

  @override
  void initState() {
    super.initState();

    SocketService.connect(); 
    checkLogin();
  }

  /// ✅ LOGIN CHECK
  Future<void> checkLogin() async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    final role = prefs.getString("role");

    await Future.delayed(const Duration(milliseconds: 800));

    if (token != null && token.isNotEmpty) {

      if (role == "provider") {
        Navigator.pushReplacementNamed(context, '/providerHome');

      } else if (role == "user") {
        Navigator.pushReplacementNamed(context, '/home');

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RoleSelectionScreen(),
          ),
        );
      }

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
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