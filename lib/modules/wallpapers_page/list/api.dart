import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataWallpapersList(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'wallpaperCollectionId': params['wallpaperCollectionId'],
    'limit': params['limit'],
    'page': params['page'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/wallpaper/getWallpaperDetailList',
      queryParams: queryParams);
  return apiService;
}

// Tạo Model
class WallpapersList {
  int? wallpaperCollectionId;
  String? imageLink;
  int? id;

  WallpapersList({this.wallpaperCollectionId, this.imageLink, this.id});

  WallpapersList.fromJson(Map<String, dynamic> json) {
    wallpaperCollectionId = json['wallpaperCollectionId'];
    imageLink = json['imageLink'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wallpaperCollectionId'] = wallpaperCollectionId;
    data['imageLink'] = imageLink;
    data['id'] = id;
    return data;
  }
}
