import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/more_page/information/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information>
    with SingleTickerProviderStateMixin {
  bool passwordVisible = false;
  bool remember = false;
  bool _isSubmitButtonEnabled = false;
  String errorMessage = '';

  final TextEditingController _nickName = TextEditingController();
  final TextEditingController _email = TextEditingController();

  final Map<String, dynamic> formData = {
    'nickName': '',
    'email': '',
    'gender': '',
  };
  int? selectedGender;

  final Map<String, dynamic> ui = {
    'isSubmitting': false,
  };

  @override
  void initState() {
    super.initState();

    String? jsonData = SharedPreferencesManager().getProfile();
    if (jsonData.isNotEmpty) {
      Map<String, dynamic> profile = jsonDecode(jsonData);

      // Gán dữ liệu cho formData và TextEditingController
      formData['nickName'] = _nickName.text =
          profile['nickname'] ?? ''; // Gán vào TextEditingController
      formData['email'] =
          _email.text = profile['email'] ?? ''; // Gán vào TextEditingController
      formData['gender'] = selectedGender =
          profile['gender']; // Gán giá trị cho giới tính (1: Name, 2: Nữ)
    }

    _validateSubmitButton();

    // Đăng ký listener để kiểm tra tính hợp lệ của form
    _nickName.addListener(_validateInputs);
    _email.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      formData['nickName'] = _nickName.text;
      formData['email'] = _email.text;
    });
    _validateSubmitButton();
  }

  void _validateSubmitButton() {
    setState(() {
      _isSubmitButtonEnabled =
          formData['nickName'] != "" && formData['email'] != "";
    });
  }

  void _onSave() async {
    setState(() {
      ui['isSubmitting'] = true;
    });
    try {
      final data = await postDataUpdateProfile(context, formData);
      if (data['code'] == ResStatus.success) {
        if (data != null &&
            data['data'] != null &&
            data['data']['isSuccess'] != null &&
            data['data']['isSuccess'] == 1) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'profile', json.encode(data['data']['profile']));

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Updated successfully')));
        }
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

  @override
  void dispose() {
    _nickName.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: Colors.black), // Thay đổi màu sắc icon nếu cần
        onPressed: () {
          // Trả về 'need_refresh' khi nhấn nút back
          Navigator.pop(context, 'need_refresh');
        },
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nickname',
                  style: AppStyles.bodyExtraSmallRegular.copyWith(
                    color: AppColors.greyLightColor,
                  ),
                ),
                const SizedBox(height: 10.0),
                _buildTextField(_nickName, 'Nickname', false, true),
                const SizedBox(height: 24),
                Text('Email',
                    style: AppStyles.bodyExtraSmallRegular.copyWith(
                      color: AppColors.greyLightColor,
                    )),
                const SizedBox(height: 10.0),
                _buildTextField(_email, 'Email', false, false),
                const SizedBox(height: 24),
                Text('Gender',
                    style: AppStyles.bodyExtraSmallRegular.copyWith(
                      color: AppColors.greyLightColor,
                    )),
                const SizedBox(height: 10.0),
                _buildGenderSelector(),
                const SizedBox(height: 142.0),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                onPressed: _isSubmitButtonEnabled ? _onSave : null,
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
                        'Save',
                        style: AppStyles.titleLargeBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 16.0),
        GestureDetector(
          onTap: () {
            setState(() {
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
            setState(() {
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
  }
}
