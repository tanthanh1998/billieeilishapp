import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataNewsList(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'singerId': params['singerId'],
    'limit': params['limit'],
    'page': params['page'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/news/getNewsList', queryParams: queryParams);
  return apiService;
}

// Tạo Model
class NewsList {
  String? title;
  String? summary;
  String? image;
  String? time;
  String? link;

  NewsList({this.title, this.summary, this.image, this.time, this.link});

  NewsList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    summary = json['summary'];
    image = json['image'];
    time = json['time'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['summary'] = summary;
    data['image'] = image;
    data['time'] = time;
    data['link'] = link;
    return data;
  }
}
