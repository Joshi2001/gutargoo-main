import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  // ── Keys ──
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyPhoneNumber = 'phoneNumber';
  static const String _keyGoogleEmail = 'googleEmail';
  static const String _keyFirstTime = 'is_first_time';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyMobile = 'mobile';

  // ── Login State ──
  static Future<void> saveLoginState({
    required bool isLoggedIn,
    String? userId,
    String? phoneNumber,
    String? googleEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    if (userId != null) await prefs.setString(_keyUserId, userId);
    if (phoneNumber != null) await prefs.setString(_keyPhoneNumber, phoneNumber);
    if (googleEmail != null) await prefs.setString(_keyGoogleEmail, googleEmail);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    print('🔍 Checking login status: $loggedIn');
    return loggedIn;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
    print('💾 Login status set to: $value');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyMobile);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyPhoneNumber);
    print('🚪 User logged out — all session data cleared');
  }

  // ── User Data ──
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_keyUserId),
      'phoneNumber': prefs.getString(_keyPhoneNumber),
      'googleEmail': prefs.getString(_keyGoogleEmail),
    };
  }

  // ── Auth Token ──
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
    print('🔑 Token saved');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  // ── Mobile ──
  static Future<void> setMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMobile, mobile);
    print('📱 Mobile saved: $mobile');
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMobile);
  }
static Future<void> saveEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_email', email);
}

static Future<String?> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_email');
}

static Future<void> saveAge(String age) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_age', age);
}

static Future<String?> getAge() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_age');
}
  // ── First Time ──
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }

  static Future<void> setFirstTimeDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, false);
  }
}