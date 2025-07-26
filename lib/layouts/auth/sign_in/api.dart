import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:crypto/crypto.dart';

Future postDataSignIn(BuildContext context, Map<String, dynamic> data) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).postRequest(context, '/v2/auth/signIn', {
    'email': data['email'],
    // 'password': md5.convert(utf8.encode(data['password'])).toString(),
    'password': data['password'],
    'viaApp': data['viaApp'],
  });
  return apiService;
}
