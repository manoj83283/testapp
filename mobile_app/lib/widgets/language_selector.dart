import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../localization/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  /// ✅ CHANGE LANGUAGE
  Future<void> changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language_code", code);

    /// ✅ instant UI update
    localeNotifier.value = Locale(code);
  }

  /// ✅ LANGUAGE LABELS (NATIVE NAMES - UX BOOST 🔥)
  static const Map<String, String> languageNames = {
    "en": "English",
    "hi": "हिंदी",
    "te": "తెలుగు",
    "ta": "தமிழ்",
    "kn": "ಕನ್ನಡ",
    "ml": "മലയാളം",
    "mr": "मराठी",
    "bn": "বাংলা",
  };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.language),

      /// ✅ MULTI-LANGUAGE TITLE
      title: Text(
        loc.translate("language"),
      ),

      trailing: DropdownButton<String>(
        value: localeNotifier.value.languageCode,
        underline: const SizedBox(),

        /// ✅ DYNAMIC LANGUAGE LIST
        items: languageNames.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),

        onChanged: (val) {
          if (val != null) {
            changeLanguage(val);
          }
        },
      ),
    );
  }
}