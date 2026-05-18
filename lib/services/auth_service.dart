import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modul6/config/api_config.dart';
import 'package:modul6/models/user_model.dart';

class AuthService {
  // ── Simpan tokens + data user ─────────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    if (role != null) await prefs.setString('role', role);
  }


  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id ?? '');
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_phone', user.phone ?? '');
    await prefs.setString('user_role', user.role);
    await prefs.setBool('user_isActive', user.isActive);
  }

  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    if (name == null || name.isEmpty) return null;
    return UserModel(
      id: prefs.getString('user_id'),
      name: name,
      email: prefs.getString('user_email') ?? '-',
      phone: prefs.getString('user_phone'),
      role: prefs.getString('user_role') ?? 'user',
      isActive: prefs.getBool('user_isActive') ?? true,
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
    // Hapus data user 
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
    await prefs.remove('user_isActive');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      final data = body['data'];
      final user = UserModel.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      await saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        role: user.role,
      );
      await saveUserData(user); // ✅ simpan data user
      return {
        'user': user,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw Exception(body['message'] ?? 'Login gagal');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    final body = json.decode(response.body);
    if (response.statusCode == 201) {
      final data = body['data'];
      final user = UserModel.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      await saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        role: user.role,
      );
      await saveUserData(user); 
      return {
        'user': user,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw Exception(body['message'] ?? 'Registrasi gagal');
    }
  }

  static Future<void> logout() async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/logout');
      final headers = await _authHeaders();
      await http.post(url, headers: headers);
    } catch (e) {
      // ignore error, tetap logout lokal
    }
    await clearTokens();
  }
}