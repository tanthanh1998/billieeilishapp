import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataPurposeList(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'albumId': params['albumId'],
  };
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/lyric/getSongList', queryParams: queryParams);
  return apiService;
}

// Tạo Model
class PurposeList {
  int? id;
  String? name;
  String? shortLyric;

  PurposeList({this.id, this.name, this.shortLyric});

  PurposeList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortLyric = json['shortLyric'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['shortLyric'] = shortLyric;
    return data;
  }
}
