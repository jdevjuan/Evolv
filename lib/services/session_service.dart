import 'package:shared_preferences/shared_preferences.dart';

/// Guarda pequenas informações de sessão (ex.: se o cadastro inicial já foi concluído).
class SessionService {
  static const _onboardedKey = 'onboarded';

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, true);
  }
}
