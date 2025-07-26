import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataFeedsList(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'singerId': params['singerId'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/feeds/getFeeds', queryParams: queryParams);
  return apiService;
}

Future postDataLikeFeeds(
    BuildContext context, Map<String, dynamic> data) async {
  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).postRequest(context, '/v2/feeds/likeFeeds', {
    'feedsId': data['feedsId'],
    'like': data['like'],
  });

  return apiService;
}

class FeedsList {
  String? nickName;
  int? gender;
  String? content;
  int? numLike;
  int? numComment;
  String? createTime;

  FeedsList(
      {this.nickName,
      this.gender,
      this.content,
      this.numLike,
      this.numComment,
      this.createTime});

  FeedsList.fromJson(Map<String, dynamic> json) {
    nickName = json['nickName'];
    gender = json['gender'];
    content = json['content'];
    numLike = json['numLike'];
    numComment = json['numComment'];
    createTime = json['createTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nickName'] = nickName;
    data['gender'] = gender;
    data['content'] = content;
    data['numLike'] = numLike;
    data['numComment'] = numComment;
    data['createTime'] = createTime;
    return data;
  }
}
