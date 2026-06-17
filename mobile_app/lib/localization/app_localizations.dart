import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// ✅ SAFE ACCESS
  static AppLocalizations of(BuildContext context) {
    final instance =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    return instance ?? AppLocalizations(const Locale('en'));
  }

  /// ✅ SUPPORTED LANGUAGES
  static const supportedLanguages = [
    'en','hi','te','ta','kn','ml','mr','bn'
  ];

  /// ✅ ALL TRANSLATIONS
  static final Map<String, Map<String, String>> _localizedValues = {

    /// ✅ ENGLISH
    "en": {
      "home": "Home",
      "profile": "Profile",
      "settings": "Settings",
      "language": "Language",
      "logout": "Logout",
      "orders": "Orders",
      "services": "Services",
      "categories": "Categories",

      "photography": "Photography",
      "decoration": "Decoration",
      "catering": "Catering",
      "makeup": "Makeup",
      "dj": "DJ",

      "customer_panel": "Customer Panel",
      "deliver_to": "Deliver to",
      "search_hint": "Search events or services",
      "event_categories": "Event Categories",
      "no_categories": "No categories found",

      "dashboard": "Dashboard",
      "wallet": "Wallet",
      "earnings": "Earnings",
      "pending_orders": "Pending Orders",
      "completed_orders": "Completed Orders",
      "add_service": "Add Service",
      "edit_service": "Edit Service",
      "delete_service": "Delete Service",
      "online": "Online",
      "offline": "Offline",
    },

    /// ✅ HINDI
    "hi": {
      "home": "होम",
      "profile": "प्रोफाइल",
      "settings": "सेटिंग्स",
      "language": "भाषा",
      "logout": "लॉगआउट",
      "orders": "ऑर्डर",
      "services": "सेवाएं",
      "categories": "श्रेणियाँ",

      "photography": "फोटोग्राफी",
      "decoration": "सजावट",
      "catering": "कैटरिंग",
      "makeup": "मेकअप",
      "dj": "डीजे",

      "customer_panel": "ग्राहक पैनल",
      "deliver_to": "डिलीवर टू",
      "search_hint": "इवेंट या सेवाएं खोजें",
      "event_categories": "इवेंट श्रेणियां",
      "no_categories": "कोई श्रेणी नहीं मिली",

      "dashboard": "डैशबोर्ड",
      "wallet": "वॉलेट",
      "earnings": "कमाई",
      "pending_orders": "लंबित ऑर्डर",
      "completed_orders": "पूर्ण ऑर्डर",
      "add_service": "सेवा जोड़ें",
      "edit_service": "सेवा संपादित करें",
      "delete_service": "सेवा हटाएं",
      "online": "ऑनलाइन",
      "offline": "ऑफलाइन",
    },

    /// ✅ TELUGU
    "te": {
      "home": "హోమ్",
      "profile": "ప్రొఫైల్",
      "settings": "సెట్టింగ్స్",
      "language": "భాష",
      "logout": "లాగౌట్",
      "orders": "ఆర్డర్లు",
      "services": "సేవలు",
      "categories": "వర్గాలు",

      "photography": "ఫోటోగ్రఫీ",
      "decoration": "అలంకరణ",
      "catering": "కేటరింగ్",
      "makeup": "మేకప్",
      "dj": "డీజే",

      "customer_panel": "కస్టమర్ ప్యానెల్",
      "deliver_to": "ఇక్కడకు పంపించండి",
      "search_hint": "ఈవెంట్ లేదా సేవలను వెతకండి",
      "event_categories": "ఈవెంట్ వర్గాలు",
      "no_categories": "వర్గాలు లేవు",

      "dashboard": "డాష్‌బోర్డ్",
      "wallet": "వాలెట్",
      "earnings": "ఆదాయం",
      "pending_orders": "పెండింగ్ ఆర్డర్లు",
      "completed_orders": "పూర్తైన ఆర్డర్లు",
      "add_service": "సేవను జోడించండి",
      "edit_service": "సేవను సవరించండి",
      "delete_service": "సేవను తొలగించండి",
      "online": "ఆన్‌లైన్",
      "offline": "ఆఫ్‌లైన్",
    },

    /// ✅ TAMIL
    "ta": {
      "home": "முகப்பு",
      "profile": "ப்ரொஃபைல்",
      "settings": "அமைப்புகள்",
      "language": "மொழி",
      "logout": "வெளியேறு",
      "orders": "ஆர்டர்கள்",
      "services": "சேவைகள்",
      "categories": "வகைகள்",

      "photography": "புகைப்படம்",
      "decoration": "அலங்காரம்",
      "catering": "கேட்டரிங்",
      "makeup": "மேக்கப்",
      "dj": "டிஜே",

      "customer_panel": "வாடிக்கையாளர் பேனல்",
      "deliver_to": "இங்கே டெலிவரி",
      "search_hint": "நிகழ்வு அல்லது சேவையை தேடவும்",
      "event_categories": "நிகழ்வு வகைகள்",
      "no_categories": "வகைகள் இல்லை",

      "dashboard": "டாஷ்போர்டு",
      "wallet": "வாலெட்",
      "earnings": "வருமானம்",
      "pending_orders": "நிலுவை ஆர்டர்கள்",
      "completed_orders": "முடிந்த ஆர்டர்கள்",
      "add_service": "சேவையை சேர்க்கவும்",
      "edit_service": "சேவையை திருத்தவும்",
      "delete_service": "சேவையை நீக்கவும்",
      "online": "ஆன்லைன்",
      "offline": "ஆஃப்லைன்",
    },

    /// ✅ KANNADA / ML / MR / BN (SHORT SAFE VERSION)
    "kn": {
      "home": "ಮುಖಪುಟ",
      "profile": "ಪ್ರೊಫೈಲ್",
      "settings": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
      "language": "ಭಾಷೆ",
      "logout": "ಲಾಗ್‌ಔಟ್",
      "categories": "ವರ್ಗಗಳು",
      "makeup": "ಮೇಕಪ್",
      "dj": "ಡಿಜೆ",
    },

    "ml": {
      "home": "ഹോം",
      "profile": "പ്രൊഫൈൽ",
      "settings": "സജ്ജീകരണങ്ങൾ",
      "language": "ഭാഷ",
      "logout": "ലോഗ്‌ഔട്ട്",
      "categories": "വിഭാഗങ്ങൾ",
      "makeup": "മേക്ക്‌അപ്പ്",
      "dj": "ഡി ജെ",
    },

    "mr": {
      "home": "होम",
      "profile": "प्रोफाइल",
      "settings": "सेटिंग्स",
      "language": "भाषा",
      "logout": "लॉगआउट",
      "categories": "श्रेण्या",
      "makeup": "मेकअप",
      "dj": "डीजे",
    },

    "bn": {
      "home": "হোম",
      "profile": "প্রোফাইল",
      "settings": "সেটিংস",
      "language": "ভাষা",
      "logout": "লগআউট",
      "categories": "বিভাগ",
      "makeup": "মেকআপ",
      "dj": "ডিজে",
    },
  };

  /// ✅ TRANSLATION (SAFE)
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues["en"]?[key] ??
        key;
  }
}

/// ✅ DELEGATE
class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {

  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLanguages
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
