import 'package:flutter/material.dart';
import 'package:music_app/styles/custom_text.dart';

class CongratulationsDialog {
  static Future<void> showMyDialog(BuildContext context) async {
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
                  image: AssetImage('assets/images/successfully.png'),
                  width: 80.0,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 24.0),
                Text(
                  'Congratulations',
                  style: AppStyles.bodyMediumSemi,
                ),
              ],
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Congratulations on your successful registration.',
                    style: AppStyles.bodyExtraMediumRegular,
                    textAlign: TextAlign.center,
                  ),
                ],
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
                  onPressed: () {
                    // Navigator.of(context).pop();
                    Navigator.of(context).popUntil(
                        (route) => route.isFirst); // Trở về màn hình đầu tiên
                  },
                  child: Text(
                    'Continue',
                    style: AppStyles.titleMediumBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
