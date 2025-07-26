import 'package:flutter/material.dart';

class AppStyles {
  static const TextStyle titleExtraLargeBold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.2,
    color: AppColors.blackColor,
  );

  static const TextStyle titleLargeBold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.33,
    color: AppColors.blackColor,
  );

  static const TextStyle titleMediumBold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.5,
    color: AppColors.blackColor,
  );

  static const TextStyle titleSmallBold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.6,
    color: AppColors.blackColor,
  );

  static const TextStyle titleExtraSmallBold = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 2,
    color: AppColors.blackColor,
  );

  static const TextStyle title1Semi = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.bold,
    fontSize: 20,
    height: 1.2, // Line height = 24px / 20px (line-height / font-size)
    color: AppColors.blackColor,
  );

  static const TextStyle title2Semi = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.33,
    color: AppColors.blackColor,
  );

  static const TextStyle bodyLargeSemi = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.5,
    color: AppColors.blackColor,
  );

  static const TextStyle bodyMediumSemi = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.6,
    color: AppColors.blackColor,
  );

  static const TextStyle bodySmallSemi = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 2,
    color: AppColors.blackColor,
  );

  static const TextStyle bodyLargeRegular = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    color: AppColors.blackColor,
  );

  static const TextStyle bodyMediumRegular = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    color: AppColors.blackColor,
  );

  static const TextStyle bodyExtraMediumRegular = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.7,
    color: AppColors.blackColor,
  );

  static const TextStyle bodyExtraSmallRegular = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.85,
    color: AppColors.blackColor,
  );

  static const TextStyle bodySmallRegular = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 2.0,
    color: AppColors.blackColor,
  );

  static const TextStyle bodyItalic = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 2.1,
    color: AppColors.blackColor,
  );

  static const TextStyle bodySmallItalic = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w400,
    fontSize: 10,
    height: 1,
    color: AppColors.blackColor,
  );
}

class AppColors {
  // Define color palette
  static const Color blackColor = Color.fromRGBO(0, 0, 0, 1.0);
  static const Color orangeColor = Color.fromRGBO(251, 182, 0, 1.0);
  static const Color greyColor = Color.fromRGBO(109, 109, 109, 1);
  static const Color greyLightColor = Color.fromRGBO(159, 159, 159, 1);
  static const Color greyExtraLightColor = Color.fromRGBO(166, 166, 166, 1);
  static const Color greyItalicColor = Color.fromRGBO(141, 141, 141, 1);
  static const Color redColor = Color.fromRGBO(255, 0, 0, 1);

  static const Color whiteShadowColor = Color.fromRGBO(255, 255, 255, 1);
  static const Color greyShadowColor = Color.fromRGBO(0, 0, 0, 0.3);

  static const Color orangeLightColor = Color.fromRGBO(255, 233, 175, 1);

  static const Color blackBg = Color.fromRGBO(0, 0, 0, 0.5);
  static const Color greyBg = Color.fromRGBO(242, 242, 242, 1);
  static const Color orangeBg = Color.fromRGBO(255, 232, 173, 1);
  static const Color redBg = Color.fromRGBO(255, 230, 230, 1);

  static const Color greyDivider = Color.fromRGBO(138, 138, 138, 0.5);
}
