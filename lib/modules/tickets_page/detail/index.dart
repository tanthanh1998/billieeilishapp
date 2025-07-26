import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/tickets_page/detail/web_view.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TicketsDetail extends StatefulWidget {
  final String url;
  final String venueLocation;

  const TicketsDetail(
      {super.key, required this.url, required this.venueLocation});

  @override
  State<TicketsDetail> createState() => _TicketsDetailState();
}

class _TicketsDetailState extends State<TicketsDetail> {
  late final WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.url),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.venueLocation,
          style: AppStyles.titleLargeBold,
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: NetworkAwareBody(
        child: WebView(controller: controller),
      ),
    );
  }
}
