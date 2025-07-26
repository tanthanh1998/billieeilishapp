import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataWallpapersOverview(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'singerId': params['singerId'],
    'limit': params['limit'],
    'page': params['page'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/wallpaper/getWallpaperCollectionList',
      queryParams: queryParams);
  return apiService;
}

// Tạo Model
class WallpapersOverview {
  String? title;
  String? imageLink;
  int? id;

  WallpapersOverview({this.title, this.imageLink, this.id});

  WallpapersOverview.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    imageLink = json['imageLink'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['imageLink'] = imageLink;
    data['id'] = id;
    return data;
  }
}
