import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataLyric(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'songId': params['songId'],
    'translateId': params['translateId'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/lyric/getSongDetail', queryParams: queryParams);
  return apiService;
}

// Tạo Model
class Lyric {
  int? id;
  String? name;
  String? lyric;
  String? downloadLink;
  String? youtubeLink;
  List? translateList;

  Lyric(
      {this.id,
      this.name,
      this.lyric,
      this.downloadLink,
      this.youtubeLink,
      this.translateList});

  Lyric.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lyric = json['lyric'];
    downloadLink = json['downloadLink'];
    youtubeLink = json['youtubeLink'];
    if (json['translateList'] != null) {
      translateList = <Null>[];
      json['translateList'].forEach((v) {});
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['lyric'] = lyric;
    data['downloadLink'] = downloadLink;
    data['youtubeLink'] = youtubeLink;
    if (translateList != null) {
      data['translateList'] = translateList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
