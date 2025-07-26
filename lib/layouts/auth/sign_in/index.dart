import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_app/apis/common/auth_provider.dart';
import 'package:music_app/layouts/auth/sign_in/api.dart';
import 'package:music_app/layouts/auth/sign_up/index.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  bool passwordVisible = false;
  bool remember = false;
  String errorMessage = '';

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final Map<String, dynamic> formData = {
    'email': '',
    'password': '',
    'viaApp': 1, // Set default
  };

  final Map<String, dynamic> ui = {
    'isSubmitting': false,
  };

  @override
  void initState() {
    super.initState();
    _email.addListener(_validateInputs);
    _password.addListener(_validateInputs);

    passwordVisible = true;
  }

  void _validateInputs() {
    setState(() {
      formData['email'] = _email.text;
      formData['password'] = _password.text;
    });
  }

  void _onCheckMail(value) {
    setState(() {
      if (value == null || value.isEmpty) {
        errorMessage = 'Please enter email';
      } else if (!isValidEmail(value)) {
        errorMessage = 'Invalid email';
      } else {
        errorMessage = ''; // Hoặc thông báo khác nếu cần
      }
    });
  }

  void _onSignIn() async {
    setState(() {
      ui['isSubmitting'] = true;
    });
    try {
      final data = await postDataSignIn(context, formData);
      if (data['code'] == ResStatus.success) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['accessToken']);
        await prefs.setString('profile', json.encode(data['data']['profile']));
        // await prefs.setString(
        //     'tracking', json.encode(data['data']['tracking']));

        // Sử dụng AuthProvider để setToken
        context.read<AuthProvider>().setToken(data['data']['accessToken']);
        Navigator.pop(context); // Quay lại trang trước đó
      } else {
        // Trả lỗi
        setState(() {
          errorMessage = data['error']![0]!['message']!;
        });
      }
    } catch (e) {
      print('Lỗi trả về :$e');
    } finally {
      setState(() {
        ui['isSubmitting'] = false;
      });
    }
  }

  void _onDirectSignUp() {
    showModalRightSheetSignUp(context);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0, // Remove shadow if needed
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFFD6D6D6), // Underline color
          height: 1.0,
        ),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      title: const Text(
        'Sign-in',
        style: AppStyles.titleLargeBold,
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.close), // Icon mà bạn muốn thay đổi
        onPressed: () {
          Navigator.of(context).pop(); // Hành động khi nhấn vào icon
        },
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 50.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Màu nền của container
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2, // Độ lan rộng của bóng
                        blurRadius: 15, // Độ mờ của bóng
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 18.0),
                      hintText: "Email",
                      hintStyle: AppStyles.bodyMediumRegular,
                    ),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      _onCheckMail(value);
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Màu nền của container
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2, // Độ lan rộng của bóng
                        blurRadius: 15, // Độ mờ của bóng
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    obscureText: true, // Ẩn mật khẩu khi nhập
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 18.0),
                      hintText: "Password",
                      hintStyle: AppStyles.bodyMediumRegular,
                    ),
                    controller: _password,
                  ),
                ),
                const SizedBox(height: 4),
                // ========== START HANDLE ERROR ==========
                if (errorMessage != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                // ========== END HANDLE ERROR ==========
                const SizedBox(height: 42),
                SizedBox(
                  width: double.infinity,
                  height: 54.0,
                  child: FilledButton.tonal(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: _onSignIn,
                    child: ui['isSubmitting']
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : Text(
                            'Sign in',
                            style: AppStyles.titleLargeBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account?',
                      style: AppStyles.bodyLargeRegular,
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        _onDirectSignUp();
                      },
                      child: Text(
                        'Sign up',
                        style: AppStyles.titleSmallBold.copyWith(
                          color: AppColors.orangeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void showModalBottomSheetSignIn(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "RightSheet",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return const SignIn();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(anim1),
        child: child,
      );
    },
  );
}
