import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_app/styles/custom_text.dart';

class PremiumTag extends StatelessWidget {
  final String text;

  const PremiumTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(39, 233, 157, 1),
            Color.fromRGBO(39, 227, 245, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 4.0,
        bottom: 4.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/svg/premium.svg',
            width: 12.0,
            height: 12.0,
          ),
          const SizedBox(width: 6.0),
          Text(
            text,
            style: AppStyles.bodyItalic,
          ),
        ],
      ),
    );
  }
}
