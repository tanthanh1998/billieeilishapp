import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataDownloadAllMusic(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'singerId': params['singerId'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/download/downloadAllMusic',
      queryParams: queryParams);
  return apiService;
}
