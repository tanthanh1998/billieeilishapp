import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static final SharedPreferencesManager _instance =
      SharedPreferencesManager._internal();

  late SharedPreferences _prefs;

  factory SharedPreferencesManager() {
    return _instance;
  }

  SharedPreferencesManager._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============= START LƯU TRỮ TOKEN =============
  Future<void> setToken(String token) async {
    await _prefs.setString('token', token);
  }

  String getToken() {
    return _prefs.getString('token') ?? '';
  }

  Future<void> removeToken() async {
    await _prefs.remove('token');
  }
  // ============= END LƯU TRỮ TOKEN =============

  // ============= START LƯU TRỮ PROFILE ACCOUNT =============
  String getProfile() {
    return _prefs.getString('profile') ?? '';
  }

  Future<void> removeProfile() async {
    await _prefs.remove('profile');
  }
  // ============= END LƯU TRỮ PROFILE ACCOUNT =============

  // ============= START LƯU TRỮ ROLE USE PREMIUM =============
  Future<void> setRoleUsePremium(String roleUsePremium) async {
    await _prefs.setString('roleUsePremium', roleUsePremium);
  }

  String getRoleUsePremium() {
    return _prefs.getString('roleUsePremium') ?? '';
  }

  Future<void> removeRoleUsePremium() async {
    await _prefs.remove('roleUsePremium');
  }
  // ============= END LƯU TRỮ ROLE USE PREMIUM =============

  // ============= START LƯU TRỮ TRACKING =============
  String getTracking() {
    return _prefs.getString('tracking') ?? '';
  }

  Future<void> removeTracking() async {
    await _prefs.remove('tracking');
  }
  // ============= END LƯU TRỮ TRACKING =============
}
