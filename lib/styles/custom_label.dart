import 'package:flutter/material.dart';

class CustomLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final TextStyle? style;

  const CustomLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: style ??
            const TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: style?.fontSize ?? 16.0,
              ),
            ),
        ],
      ),
    );
  }
}
