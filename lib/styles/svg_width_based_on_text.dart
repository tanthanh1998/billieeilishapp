import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgWidthBasedOnText extends StatelessWidget {
  final String svgImage;
  final String text;
  final Color textColor;

  const SvgWidthBasedOnText({
    super.key,
    required this.text,
    required this.svgImage,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Hàm để tính toán kích thước SVG dựa trên số lượng text
    double calculateSvgWidthBasedOnText(String text, double baseWidth) {
      // Giả sử cứ mỗi ký tự tăng thêm 2 đơn vị chiều rộng của SVG
      return baseWidth + (text.length - 1) * 4;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              // Đo chiều rộng của Text để điều chỉnh kích thước SVG
              double svgWidth = calculateSvgWidthBasedOnText(text, 24);

              return SvgPicture.asset(
                svgImage,
                width: svgWidth,
              );
            },
          ),
          Positioned(
            right: 0,
            left: 0,
            top: calculateSvgWidthBasedOnText(text, 0) / 3,
            child: Align(
              alignment: Alignment.topCenter, // Đặt text ở giữa trên của SVG
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
