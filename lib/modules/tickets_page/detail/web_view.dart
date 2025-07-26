import 'package:flutter/material.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  const WebView({super.key, required this.controller});

  final WebViewController controller;

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  var loadPercentage = 0;
  @override
  void initState() {
    super.initState();

    widget.controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadPercentage = 100;
            });
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('SnackBar', onMessageReceived: (message) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.message)));
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: widget.controller),
        if (loadPercentage < 100)
          LinearProgressIndicator(
            value: loadPercentage / 100.0,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.orangeColor),
          )
      ],
    );
  }
}
