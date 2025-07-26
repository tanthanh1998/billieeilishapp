import 'dart:math';
import 'package:flutter/material.dart';

/// [int] is index
/// the [bool] value decided if they are vertical layout
var random = Random();

// Hàm trả về một màu ngẫu nhiên trong số đỏ, vàng, xanh
Color getRandomColor() {
  final colors = [Colors.red, Colors.yellow, Colors.blue];
  return colors[random.nextInt(colors.length)];
}
