import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataChatWithUs(BuildContext context) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/chat/getChatHistory');
  return apiService;
}

Future postDataSendChat(BuildContext context, Map<String, dynamic> data) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).postRequest(context, '/v2/chat/sendChat', {
    'message': data['message'],
  });
  return apiService;
}

class ChatWithUs {
  String? message;
  int? hostReply;

  ChatWithUs({this.message, this.hostReply});

  ChatWithUs.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    hostReply = json['hostReply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['hostReply'] = hostReply;
    return data;
  }
}
