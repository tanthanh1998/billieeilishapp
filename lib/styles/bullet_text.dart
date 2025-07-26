import 'package:flutter/material.dart';
import 'package:music_app/styles/custom_text.dart';

class BulletText extends StatelessWidget {
  final String text;
  final TextStyle? bulletStyle;
  final TextStyle? textStyle;

  const BulletText({
    super.key,
    required this.text,
    this.bulletStyle,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '• ',
            style: bulletStyle ??
                const TextStyle(
                  fontSize: 16.0,
                  color: AppColors.blackColor,
                ),
          ),
          TextSpan(
            text: text,
            style: textStyle ??
                const TextStyle(
                  fontSize: 16.0,
                  color: AppColors.blackColor,
                ),
          ),
        ],
      ),
    );
  }
}
