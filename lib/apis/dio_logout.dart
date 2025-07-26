import 'package:flutter/material.dart';
import 'package:music_app/apis/common/shared_preferences.dart';

class AuthService {
  Future<void> logout(BuildContext context) async {
    try {
      await SharedPreferencesManager().removeToken();
      await SharedPreferencesManager().removeProfile();
      await SharedPreferencesManager().removeTracking();

      //     .pushNamedAndRemoveUntil('/sign-in', (Route<dynamic> route) => false);
    } catch (e) {
      // Xử lý khi có lỗi xảy ra
      print('Logout error: $e');
    }
  }
}
