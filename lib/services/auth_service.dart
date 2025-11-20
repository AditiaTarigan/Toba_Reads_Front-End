// lib/services/auth_service.dart

class AuthService {
  // Status login (sementara untuk development)
  static bool isLoggedIn = false;
  static String userName = '';

  // Method untuk login
  static Future<void> login(String name) async {
    isLoggedIn = true;
    userName = name;

    // Simpan ke SharedPreferences jika mau permanen
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('isLoggedIn', true);
    // await prefs.setString('userName', name);
  }

  // Method untuk logout
  static Future<void> logout() async {
    isLoggedIn = false;
    userName = '';

    // Hapus dari SharedPreferences jika mau permanen
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('isLoggedIn', false);
    // await prefs.remove('userName');
  }

  // Method untuk cek status login
  static Future<bool> checkLoginStatus() async {
    return isLoggedIn;

    // Jika pakai SharedPreferences:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool('isLoggedIn') ?? false;
  }

  // Method untuk get username
  static Future<String> getUsername() async {
    return userName;

    // Jika pakai SharedPreferences:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('userName') ?? '';
  }
}
