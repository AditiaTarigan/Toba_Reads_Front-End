// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static bool isLoggedIn = false;
  static String userName = '';

  // Method untuk initialize status login dari SharedPreferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    userName = prefs.getString('userName') ?? '';
  }

  // Method untuk login
  static Future<void> login(String name) async {
    final prefs = await SharedPreferences.getInstance();

    isLoggedIn = true;
    userName = name;

    // Simpan ke SharedPreferences
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);
  }

  // Method untuk logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    isLoggedIn = false;
    userName = '';

    // Hapus dari SharedPreferences
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
  }

  // Method untuk cek status login
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Method untuk get username
  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? '';
  }
}
