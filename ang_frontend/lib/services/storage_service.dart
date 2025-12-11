import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _awcCodeKey = 'awc_code';
  static const String _awcNameKey = 'awc_name';
  static const String _roleKey = 'user_role';
  static const String _sectorNameKey = 'sector_name';
  static const String _districtNameKey = 'district_name';
  static const String _projectNameKey = 'project_name';

  // Save login data
  static Future<void> saveLoginData({
    required String token,
    required String userId,
    required String awcCode,
    required String awcName,
    required String role,
    String? sectorName,
    String? districtName,
    String? projectName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_awcCodeKey, awcCode);
    await prefs.setString(_awcNameKey, awcName);
    await prefs.setString(_roleKey, role);
    if (sectorName != null) await prefs.setString(_sectorNameKey, sectorName);
    if (districtName != null) await prefs.setString(_districtNameKey, districtName);
    if (projectName != null) await prefs.setString(_projectNameKey, projectName);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get all user data
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'userId': prefs.getString(_userIdKey),
      'awcCode': prefs.getString(_awcCodeKey),
      'awcName': prefs.getString(_awcNameKey),
      'role': prefs.getString(_roleKey),
      'sectorName': prefs.getString(_sectorNameKey),
      'districtName': prefs.getString(_districtNameKey),
      'projectName': prefs.getString(_projectNameKey),
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}