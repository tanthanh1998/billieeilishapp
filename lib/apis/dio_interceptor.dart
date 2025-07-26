import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/dialog/email_verification/index.dart';

const String apiDomain = 'https://api.kongricsstudio.com/api';
String token = SharedPreferencesManager().getToken();

class DioClient {
  late Dio _dio;

  final BuildContext context;
  DioClient(this.context) {
    _dio = Dio(BaseOptions(baseUrl: apiDomain));
    _dio.interceptors.add(CustomInterceptors(context));
  }

  Dio get dio => _dio;
}

class CustomInterceptors extends Interceptor {
  final BuildContext context;
  CustomInterceptors(this.context);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // print('REQUEST[${options.method}] => PATH: ${options.path}');
    String token = SharedPreferencesManager().getToken();

    // Thêm header cho mọi yêu cầu
    options.headers['Content-Type'] = 'application/json';
    options.headers['SecretCode'] = 'ZmF3ZWYzMnIyNDEyMTIzQDEzMjEzMkAjI0A=';
    options.headers['Authorization'] = 'Bearer $token';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print(
    //     'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // ======= START HIỂN THỊ POPUP EMAIL VERIFICATION =======
    if (err.response?.data!['error']![0]!['code'] == 108) {
      EmailVerificationDialog.showMyDialog(context);
    }
    // ======= END HIỂN THỊ POPUP EMAIL VERIFICATION =======
    //   await AuthService().logout(context);
    // print(
    //     'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}
