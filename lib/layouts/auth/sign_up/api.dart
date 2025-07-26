import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future postDataSignUp(BuildContext context, Map<String, dynamic> data) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).postRequest(context, '/v2/auth/signUp', {
    'viaApp': data['viaApp'],
    'email': data['email'],
    'password': data['password'],
    'nickName': data['nickName'],
    'gender': data['gender'],
    'inviterCode': data['inviterCode'],
  });
  return apiService;
}

Future postDataCheckEmailExists(
    BuildContext context, Map<String, dynamic> data) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).postRequest(context, '/v2/auth/checkEmailExists', {
    'email': data['email'],
  });

  return apiService;
}
