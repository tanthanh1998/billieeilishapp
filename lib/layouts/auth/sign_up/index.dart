import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_app/apis/common/auth_provider.dart';
import 'package:music_app/layouts/auth/sign_up/api.dart';
import 'package:music_app/layouts/auth/sign_up/dialog/congratulations_dialog.dart';
import 'package:music_app/styles/custom_label.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  bool passwordVisible = false;
  bool remember = false;
  bool _isSubmitButtonEnabled = false;
  String errorMessage = '';

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _nickName = TextEditingController();
  final TextEditingController _inviterCode = TextEditingController();

  final Map<String, dynamic> formData = {
    'viaApp': 1,
    'email': '',
    'password': '',
    'nickName': '', // value default
    'gender': Gender.male, // value default
    'inviterCode': '',
  };
  int? selectedGender;

  final Map<String, dynamic> ui = {
    'isSubmitting': false,
    'isSaving': false,
  };

  @override
  void initState() {
    super.initState();
    _email.addListener(_validateInputs);
    _password.addListener(_validateInputs);
    _confirmPassword.addListener(_validateInputs);

    passwordVisible = true;

    _nickName.addListener(_validateInputs);
    _inviterCode.addListener(_validateInputs);

    formData['gender'] = selectedGender =
        Gender.male; // Gán giá trị cho giới tính (1: Name, 2: Nữ)
  }

  void _validateInputs() {
    setState(() {
      formData['email'] = _email.text;
      formData['password'] = _password.text;
      formData['nickName'] = _nickName.text;
      formData['inviterCode'] = _inviterCode.text;
    });
    _validateSubmitButton();
  }

  void _validateSubmitButton() {
    setState(() {
      _isSubmitButtonEnabled =
          formData['userId'] != "" && formData['password'] != "";
    });
  }

  void _onSubmit() {
    if (errorMessage.isEmpty) {
      _onCheckEmailExists();
    }
  }

  void _onCheckEmailExists() async {
    setState(() {
      ui['isSubmitting'] = true;
    });
    try {
      final data = await postDataCheckEmailExists(context, formData);

      if (data['code'] == ResStatus.success) {
        if (data != null &&
            data['data'] != null &&
            data['data']['isExists'] != null &&
            data['data']['isExists'] == 1) {
          setState(() {
            errorMessage = 'Email already exists';
          });
        } else {
          showModalRightSheet(context);
        }
      } else {
        // Trả lỗi
        setState(() {
          errorMessage = data['message'];
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

  void _onSignUp(setModalState) async {
    setModalState(() {
      ui['isSaving'] = true;
    });
    try {
      final data = await postDataSignUp(context, formData);
      if (data['code'] == ResStatus.success) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['accessToken']);
        await prefs.setString('profile', json.encode(data['data']['profile']));

        // Sử dụng AuthProvider để setToken
        context.read<AuthProvider>().setToken(data['data']['accessToken']);

        CongratulationsDialog.showMyDialog(
            context); // Hiển thị popup Đăng ký thành công
      } else {
        // Trả lỗi
        setModalState(() {
          errorMessage = data['error']![0]!['message']!;
        });
      }
    } catch (e) {
      print('Lỗi trả về :$e');
    } finally {
      setModalState(() {
        ui['isSaving'] = false;
      });
    }
  }

  void _onDirectSigIn() {
    Navigator.pop(context);
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

  void _onCheckConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        errorMessage = 'Please confirm password';
      } else if (formData['password'] != value) {
        errorMessage = 'Password does not match';
      } else {
        errorMessage = '';
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();

    super.dispose();
  }

  void showModalRightSheet(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "RightSheet",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Scaffold(
              resizeToAvoidBottomInset:
                  true, // Tự động điều chỉnh khi bàn phím xuất hiện
              appBar: AppBar(
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: const Color(0xFFD6D6D6),
                    height: 1.0,
                  ),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text(
                  'Information',
                  style: AppStyles.titleLargeBold,
                ),
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: Colors.white,
                      elevation: 5,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.zero,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 32.0, right: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 18.0),
                                    CustomLabel(
                                      label: 'Email',
                                      isRequired: true,
                                      style: AppStyles.bodyExtraSmallRegular
                                          .copyWith(
                                        color: AppColors.greyLightColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    _buildTextField(
                                        _email, 'Email', false, false),
                                    const SizedBox(height: 24),
                                    CustomLabel(
                                      label: 'Nickname',
                                      isRequired: true,
                                      style: AppStyles.bodyExtraSmallRegular
                                          .copyWith(
                                        color: AppColors.greyLightColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    _buildTextField(
                                        _nickName, 'Nickname', false, true),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Invite code',
                                      style: AppStyles.bodyExtraSmallRegular
                                          .copyWith(
                                        color: AppColors.greyLightColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    _buildTextField(_inviterCode,
                                        'Input invite code', false, true),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Gender',
                                      style: AppStyles.bodyExtraSmallRegular
                                          .copyWith(
                                        color: AppColors.greyLightColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    _buildGenderSelector(),
                                    const SizedBox(height: 142.0)
                                  ],
                                ),
                              ),
                              // ========== START HANDLE ERROR ==========
                              if (errorMessage.isNotEmpty)
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.whiteShadowColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                          ), // Tự động đẩy nút Save lên trên bàn phím
                          child: SizedBox(
                            width: double.infinity,
                            height: 52.0,
                            child: FilledButton.tonal(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orangeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () {
                                _onSignUp(setModalState);
                              },
                              child: ui['isSaving']
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : Text(
                                      'Save',
                                      style: AppStyles.titleLargeBold.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      bool isPassword, bool isEnabled) {
    return Container(
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
        controller: controller,
        obscureText:
            isPassword && !passwordVisible, // Control password visibility
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintText: hintText,
          hintStyle: AppStyles.bodyMediumRegular,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                )
              : null,
        ),
        enabled: isEnabled, // Disable the input field
      ),
    );
  }

  Widget _buildGenderSelector() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 16.0),
            GestureDetector(
              onTap: () {
                setModalState(() {
                  selectedGender = Gender.male;
                  formData['gender'] = Gender.male;
                });
              },
              child: Column(
                children: [
                  Image(
                    image: AssetImage(selectedGender == Gender.male
                        ? 'assets/images/male_active.png'
                        : 'assets/images/male_unactive.png'),
                    width: 40.0,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'Male',
                    style: TextStyle(
                      color: selectedGender == Gender.male
                          ? AppColors.orangeColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32.0),
            GestureDetector(
              onTap: () {
                setModalState(() {
                  selectedGender = Gender.feMale;
                  formData['gender'] = Gender.feMale;
                });
              },
              child: Column(
                children: [
                  Image(
                    image: AssetImage(selectedGender == Gender.feMale
                        ? 'assets/images/female_active.png'
                        : 'assets/images/female_unactive.png'),
                    width: 40.0,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    'Female',
                    style: TextStyle(
                      color: selectedGender == Gender.feMale
                          ? AppColors.orangeColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
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
      title: const Text(
        'SignUp',
        style: AppStyles.titleLargeBold,
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 50.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 24),
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
                const SizedBox(height: 24),
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
                      hintText: "Confirm password",
                      hintStyle: AppStyles.bodyMediumRegular,
                    ),
                    controller: _confirmPassword,
                    onChanged: (value) {
                      _onCheckConfirmPassword(value);
                    },
                  ),
                ),
                const SizedBox(height: 4),
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
                const SizedBox(height: 42.0),
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
                    onPressed: _isSubmitButtonEnabled ? _onSubmit : null,
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
                            'Sign up',
                            style: AppStyles.titleLargeBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                // ======== START TEST DIALOG OPEN ========
                // SizedBox(
                //   width: double.infinity,
                //   height: 54.0,
                //   child: FilledButton.tonal(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.orangeColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12.0),
                //       ),
                //     ),
                //     onPressed: () {
                //       CongratulationsDialog.showMyDialog(context);
                //     },
                //     child: Text(
                //       'TEST DIALOG OPEN ',
                //       style: AppStyles.titleLargeBold.copyWith(
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   width: double.infinity,
                //   height: 54.0,
                //   child: FilledButton.tonal(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.orangeColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12.0),
                //       ),
                //     ),
                //     onPressed: () {
                //       EmailVerificationDialog.showMyDialog(context);
                //     },
                //     child: Text(
                //       'EmailVerificationDialog',
                //       style: AppStyles.titleLargeBold.copyWith(
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16.0),
                // SizedBox(
                //   width: double.infinity,
                //   height: 54.0,
                //   child: FilledButton.tonal(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.orangeColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12.0),
                //       ),
                //     ),
                //     onPressed: () {
                //       NewVersionAppDialog.showMyDialog(
                //         context,
                //         VersionStatus.keep,
                //       );
                //     },
                //     child: Text(
                //       'NewVersionAppDialog',
                //       style: AppStyles.titleLargeBold.copyWith(
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
                // ======== END TEST DIALOG OPEN ========

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: AppStyles.bodyLargeRegular,
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        _onDirectSigIn();
                      },
                      child: Text(
                        'Sign in',
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

void showModalRightSheetSignUp(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "RightSheet",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return const SignUp();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: const Offset(0, 0),
        ).animate(anim1),
        child: child,
      );
    },
  );
}
