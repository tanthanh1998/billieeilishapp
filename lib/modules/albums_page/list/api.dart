import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataAlbumList(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'singerId': params['singerId'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/lyric/getAlbumList', queryParams: queryParams);
  return apiService;
}

// Tạo Model
class AlbumList {
  int? id;
  String? name;
  String? thumbnail;
  int? totalSong;

  AlbumList({this.id, this.name, this.thumbnail, this.totalSong});

  AlbumList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    thumbnail = json['thumbnail'];
    totalSong = json['totalSong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['thumbnail'] = thumbnail;
    data['totalSong'] = totalSong;
    return data;
  }
}
