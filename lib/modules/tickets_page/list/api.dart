import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_client.dart';
import 'package:music_app/apis/dio_interceptor.dart';

Future fetchDataTicketsList(BuildContext context, dynamic params) async {
  // Các params query
  final Map<String, dynamic> queryParams = {
    'singerId': params['singerId'],
    'page': params['page'],
  };

  final Future<Map<String, dynamic>> apiService = ApiService(
    dioClient: DioClient(context),
  ).getRequest(context, '/v2/ticket/getTickets', queryParams: queryParams);
  return apiService;
}

// Tạo Model
class TicketsList {
  String? name;
  String? url;
  String? venueName;
  int? venueCapaciy;
  String? venueLocation;
  String? ticketLeft;
  String? dayOfWeek;
  String? formattedDate;
  String? formattedTime;

  TicketsList(
      {this.name,
      this.url,
      this.venueName,
      this.venueCapaciy,
      this.venueLocation,
      this.ticketLeft,
      this.dayOfWeek,
      this.formattedDate,
      this.formattedTime});

  TicketsList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
    venueName = json['venueName'];
    venueCapaciy = json['venueCapaciy'];
    venueLocation = json['venueLocation'];
    ticketLeft = json['ticketLeft'];
    dayOfWeek = json['dayOfWeek'];
    formattedDate = json['formattedDate'];
    formattedTime = json['formattedTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    data['venueName'] = venueName;
    data['venueCapaciy'] = venueCapaciy;
    data['venueLocation'] = venueLocation;
    data['ticketLeft'] = ticketLeft;
    data['dayOfWeek'] = dayOfWeek;
    data['formattedDate'] = formattedDate;
    data['formattedTime'] = formattedTime;
    return data;
  }
}
