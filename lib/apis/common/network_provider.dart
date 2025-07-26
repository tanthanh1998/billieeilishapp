import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _hasInternet = true;

  bool get hasInternet => _hasInternet;

  NetworkProvider() {
    checkInternetConnection();
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        checkInternetConnection();
      }
    });
  }

  Future<void> checkInternetConnection() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult[0] == ConnectivityResult.mobile ||
          connectivityResult[0] == ConnectivityResult.wifi) {
        _hasInternet = true;
      } else {
        _hasInternet = false;
      }

      notifyListeners();
    } catch (e) {
      _hasInternet = false;
      notifyListeners();
    }
  }
}
