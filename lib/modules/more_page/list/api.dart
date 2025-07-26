import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataCountUnreadChat(BuildContext context) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/chat/countUnreadChat');
  return apiService;
}
