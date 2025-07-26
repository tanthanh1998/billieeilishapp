import 'dart:io';
import 'package:intl/intl.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/utils/const.dart';

String formatDateUI(String dateTimeString, bool formatType) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String dateFormat;
  if (formatType) {
    dateFormat = 'HH:mm, dd/MM/yyyy';
  } else {
    dateFormat = 'dd/MM/yyyy';
  }
  String formattedDateTime = DateFormat(dateFormat).format(dateTime);
  return formattedDateTime;
}

String timeAgo(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);

  final Duration difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 365) {
    final int years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 30) {
    final int months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}

bool isLoggedIn() {
  return true;
}

Future<bool> checkTokenExists() async {
  return SharedPreferencesManager().getToken().isNotEmpty;
}

bool isValidEmail(String email) {
  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegExp.hasMatch(email);
}

String formatCurrency(num? amount) {
  if (amount == null) {
    // return '\$0.00'; // Hoặc giá trị mặc định khác
    return 'N/A'; // Hoặc giá trị mặc định khác
  }
  final formatCurrency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  return formatCurrency
      .format(amount.toDouble()); // Chuyển `int` hoặc `num` sang `double`
}

String getCurrentTimeFormatted() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  String formatted = formatter.format(now);
  return formatted;
}

// ===== START FUNC CHECK OS DEVICE =====
int? getOS() {
  if (Platform.isAndroid) {
    return OS.android;
  } else if (Platform.isIOS) {
    return OS.ios;
  } else if (Platform.isWindows) {
    return OS.web;
  } else if (Platform.isLinux) {
    return OS.web;
  } else if (Platform.isMacOS) {
    return OS.web;
  } else {
    return null;
  }
}
// ===== END FUNC CHECK OS DEVICE =====