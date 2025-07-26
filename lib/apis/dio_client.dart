import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:music_app/apis/dio_interceptor.dart';

class ApiService {
  final Dio _dio;

  ApiService({required DioClient dioClient}) : _dio = dioClient.dio;

  Future<Map<String, dynamic>> getRequest(BuildContext context, String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response.data;
    } catch (e) {
      throw Exception('Failed to getRequest data >>>>>>>>>>>>: $e');
    }
  }

  Future<Map<String, dynamic>> postRequest(
      BuildContext context, String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      return e.response!.data;
    } catch (e) {
      throw Exception('Failed to postRequest data >>>>>>>>>>>>: $e');
    }
  }
}
