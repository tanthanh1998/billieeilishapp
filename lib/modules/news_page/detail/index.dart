import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/news_page/detail/news_web_view.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsDetail extends StatefulWidget {
  final String link;
  final String title;

  const NewsDetail({super.key, required this.link, required this.title});

  @override
  State<NewsDetail> createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  late final WebViewController _controller;
  double _brightness = 0.5;

  final List<bool> _selectedfontSize = <bool>[true, false, false];

  @override
  void initState() {
    _controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.link),
      );

    _getBrightness();
    super.initState();
  }

  double fontSize = 16.0; // Kích thước font mặc định

  void _updateFontSize(double scaleFactor) async {
    // Chạy JavaScript để thay đổi kích thước font của nội dung WebView
    setState(() {
      _controller
          .runJavaScript('document.body.style.fontSize = "${scaleFactor}px"');
    });
  }

  // Lấy độ sáng hiện tại của màn hình
  Future<void> _getBrightness() async {
    double brightness = await ScreenBrightness().current;
    setState(() {
      _brightness = brightness;
    });
  }

  // Cập nhật độ sáng màn hình
  Future<void> _setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
      setState(() {
        _brightness = brightness; // Cập nhật Slider
      });
    } catch (e) {
      print("Failed to set brightness: $e");
    }
  }

  void _onUpdateFontSizes(index) {
    switch (index) {
      case 0:
        return _updateFontSize(14.0);
      case 1:
        return _updateFontSize(16.0);
      case 2:
        return _updateFontSize(18.0);
      default:
        return;
    }
  }

  void _onHandleShareLink() {
    // Share link bài viết
    Share.share(widget.link, subject: widget.title);
  }

  void _toggleFontSize(int index) {
    setState(() {
      for (int i = 0; i < _selectedfontSize.length; i++) {
        _selectedfontSize[i] = i == index;
      }
    });
    _onUpdateFontSizes(index);
  }

  void _openBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.zero,
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _onHandleShareLink();
                      },
                      splashColor: Colors.transparent, // Chặn hiệu ứng gợn sóng
                      highlightColor:
                          Colors.transparent, // Chặn hiệu ứng highlight
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/svg/share.svg',
                            width: 24.0,
                            height: 24.0,
                          ),
                          const SizedBox(width: 16.0),
                          const Text(
                            'Share this',
                            style: AppStyles.bodyExtraSmallRegular,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/brightness.svg',
                              width: 24.0,
                              height: 24.0,
                            ),
                            const SizedBox(width: 16.0),
                            const Text(
                              'Brightness',
                              style: AppStyles.bodyExtraSmallRegular,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Slider(
                            value: _brightness,
                            min: 0.0,
                            max: 1.0,
                            // divisions: 10,
                            // label: (_brightness * 100).round().toString(),
                            activeColor: AppColors.orangeColor,
                            inactiveColor: AppColors.greyColor.withOpacity(0.3),
                            onChanged: (double value) {
                              setModalState(() {
                                _brightness = value;
                                _setBrightness(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/increase_font_size.svg',
                              width: 24.0,
                              height: 24.0,
                            ),
                            const SizedBox(width: 16.0),
                            const Text(
                              'Font size',
                              style: AppStyles.bodyExtraSmallRegular,
                            ),
                          ],
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: ToggleButtons(
                            onPressed: (int index) {
                              setModalState(() {
                                _toggleFontSize(index);
                              });
                            },
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16.0)),
                            selectedBorderColor: AppColors.orangeColor,
                            selectedColor: Colors.white,
                            fillColor: AppColors.orangeColor,
                            color: AppColors.orangeColor,
                            borderColor: AppColors.orangeColor,
                            constraints: const BoxConstraints(
                              minHeight: 30.0,
                              minWidth: 80.0,
                            ),
                            isSelected: _selectedfontSize,
                            children: const <Widget>[
                              Text('Small'),
                              Text('Medium'),
                              Text('Large'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          widget.title,
          style: AppStyles.titleLargeBold,
        ),
        actions: <Widget>[
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/svg/setting.svg',
              width: 24.0,
              height: 24.0,
            ),
            onPressed: () {
              _openBottomDrawer(context);
            },
          ),
        ],
      ),
      body: NetworkAwareBody(
        child: NewsWebView(controller: _controller),
      ),
    );
  }
}
