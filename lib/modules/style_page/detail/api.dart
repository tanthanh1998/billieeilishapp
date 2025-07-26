import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataStyleAccessoryList(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'styleCollectionDetailId': params['styleCollectionDetailId'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/style/getStyleAccessory',
      queryParams: queryParams);
  return apiService;
}

// Tạo Model
class StyleAccessoryList {
  int? id;
  String? title;
  String? image;
  Null price;
  Null link;

  StyleAccessoryList({this.id, this.title, this.image, this.price, this.link});

  StyleAccessoryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    price = json['price'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['price'] = price;
    data['link'] = link;
    return data;
  }
}
