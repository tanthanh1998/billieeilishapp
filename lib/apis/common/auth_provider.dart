import 'package:flutter/material.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/apis/dio_logout.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  bool get isAuthenticated => SharedPreferencesManager().getToken() != '';

  void clearToken(BuildContext context) async {
    await AuthService().logout(context);
    notifyListeners();
  }

  // bool get isChangeProfile => SharedPreferencesManager().getProfile() != '';
}
