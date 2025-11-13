import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  static const _key = 'onboarding_complete';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> setOnboardingComplete(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, val);
  }
}
