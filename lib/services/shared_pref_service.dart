import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  /// 🔹 Simpan hanya user_id
  static Future<void> setUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  /// 🔹 Ambil user_id
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  /// 🔹 Hapus user_id dan data lain saat logout
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
  }

  /// 🔹 Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }

  /// 🔹 Simpan user lengkap (ID, username, email)
  static Future<void> saveUser({
    required int id,
    required String username,
    String email = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
  }

  /// 🔹 Ambil username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  /// 🔹 Ambil email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}
