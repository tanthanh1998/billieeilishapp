import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/dialog/email_verification/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';

class EmailVerificationDialog {
  static final TextEditingController _emailController = TextEditingController();
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static Future<void> showMyDialog(BuildContext context) async {
    String? jsonData = SharedPreferencesManager().getProfile();
    if (jsonData.isNotEmpty) {
      Map<String, dynamic> profile = jsonDecode(jsonData);
      _emailController.text = profile['email'] ?? '';
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Ngăn không cho đóng khi bấm ra ngoài
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Trả về false để chặn việc pop
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Column(
              children: [
                Image(
                  image: AssetImage('assets/images/email_verification.png'),
                  width: 42.0,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 24.0),
                Text(
                  'Email verification',
                  style: AppStyles.bodyMediumSemi,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: ListBody(
                  children: <Widget>[
                    const Text(
                      'Your account has been suspended due to unverified email. A verification email will be sent to the address below or you can enter a new email to verify',
                      style: AppStyles.bodyExtraMediumRegular,
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            offset: Offset(0, 2),
                            blurRadius: 15,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 28.0, vertical: 18.0),
                          hintText: "Email",
                          hintStyle: AppStyles.bodyMediumRegular,
                        ),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          } else if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 54.0,
                child: FilledButton.tonal(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _emailController.text.isEmpty
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _verifyEmail(_emailController.text, context);
                          }
                        },
                  child: Text(
                    'Verify now',
                    style: AppStyles.titleMediumBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _verifyEmail(String email, BuildContext context) async {
    try {
      final Map<String, dynamic> formData = {
        'email': '',
      };
      formData['email'] = {'email: email'};

      final data = await postDataReSendVerifyEmail(context, formData);
      if (data['code'] == ResStatus.success) {
        Navigator.pop(context); // Quay lại trang trước đó
      }
    } catch (e) {
      print('Lỗi trả về :$e');
    }
  }
}
