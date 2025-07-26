import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future postDataReSendVerifyEmail(
    BuildContext context, Map<String, dynamic> data) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).postRequest(context, '/v2/auth/reSendVerifyEmail', {
    'email': data['email'],
  });
  return apiService;
}
