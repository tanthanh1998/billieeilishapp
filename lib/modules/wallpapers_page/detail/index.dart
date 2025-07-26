import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/layouts/auth/sign_in/index.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:permission_handler/permission_handler.dart';

class WallpapersDetail extends StatefulWidget {
  final String imageUrl;
  final String text;
  const WallpapersDetail(
      {super.key, required this.imageUrl, required this.text});

  @override
  State<WallpapersDetail> createState() => _WallpapersDetailState();
}

class _WallpapersDetailState extends State<WallpapersDetail> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkTokenToSetWallpaperHomeScreen() async {
    String token = SharedPreferencesManager().getToken();
    if (token != '') {
      // Gọi API & Hiển thị dữ liệu hiện tại
      setWallpaperFromFileHome(context, widget.imageUrl);
    } else {
      onShowRequestLoginScreen(
          context); // Hiển thị BottomSheet khi nhấn vào nút này
    }
  }

  Future<void> setWallpaperFromFileHome(
      BuildContext context, String imageUrl) async {
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await AsyncWallpaper.setWallpaper(
        url: imageUrl,
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN,
        // goToHome: goToHome,
        // toastDetails: ToastDetails.success(),
        toastDetails: ToastDetails(
          message: 'Wallpaper set successfully!',
          backgroundColor: AppColors.orangeColor,
          textColor: Colors.white,
        ),
        errorToastDetails: ToastDetails.error(),
      )
          ? 'Wallpaper set'
          : 'Failed to get wallpaper.';
    } on PlatformException {
      result = 'Failed to get wallpaper.';
    }

    print('setWallpaperFromFileHome $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> _checkTokenToSetWallpaperLocalScreen() async {
    String token = SharedPreferencesManager().getToken();

    if (token != '') {
      // Gọi API & Hiển thị dữ liệu hiện tại
      setWallpaperFromFileLock(context, widget.imageUrl);
    } else {
      onShowRequestLoginScreen(
          context); // Hiển thị BottomSheet khi nhấn vào nút này
    }
  }

  Future<void> setWallpaperFromFileLock(
      BuildContext context, String imageUrl) async {
    String result;
    try {
      result = await AsyncWallpaper.setWallpaper(
        url: imageUrl,
        wallpaperLocation: AsyncWallpaper.LOCK_SCREEN,
        toastDetails: ToastDetails(
          message: 'Wallpaper set successfully!',
          backgroundColor: AppColors.orangeColor,
          textColor: Colors.white,
        ),
        errorToastDetails: ToastDetails.error(),
      )
          ? 'Wallpaper set'
          : 'Failed to get wallpaper.';
    } on PlatformException {
      result = 'Failed to get wallpaper.';
    }
    print('setWallpaperFromFileLock $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> setWallpaperBothScreen() async {
    await setWallpaperFromFileHome(context, widget.imageUrl);
    await setWallpaperFromFileLock(context, widget.imageUrl);
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _downloadImage(imageUrl) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await _requestStoragePermission();
    }

    FileDownloader.downloadFile(
      url: imageUrl,
      onProgress: (name, progress) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image is downloading!')),
        );
      },
      onDownloadCompleted: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo downloaded successfully!')),
        );
      },
    );
  }

  void onSignIn(context) {
    showModalBottomSheetSignIn(context);
  }

  void onShowRequestLoginScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          height: 160, // Chiều cao của BottomSheet
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Please login to use this feature'),
              const SizedBox(height: 16.0),
              FilledButton.tonal(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  onSignIn(context);
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Center(
  //     child: Container(
  //       color: Colors.white,
  //       child: Stack(
  //         children: [
  //           InteractiveViewer(
  //             boundaryMargin: EdgeInsets.zero, // Khoảng cách biên
  //             minScale: 0.5, // Tỷ lệ thu nhỏ tối thiểu
  //             maxScale: 4.0, // Tỷ lệ phóng to tối đa
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 image: DecorationImage(
  //                   image: NetworkImage(widget.imageUrl),
  //                   fit: BoxFit.none,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             top: 16.0, // Đặt vị trí cho nút quay lại (tùy thuộc vào thiết bị)
  //             left: 16.0, // Khoảng cách từ mép trái
  //             right: 16.0, // Khoảng cách từ mép trái
  //             child: SafeArea(
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   CircleAvatar(
  //                     backgroundColor: AppColors.blackBg, // Màu nền xám bo tròn
  //                     child: IconButton(
  //                       icon: const Icon(Icons.arrow_back, color: Colors.white),
  //                       onPressed: () {
  //                         Navigator.pop(context); // Quay lại trang trước
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             bottom: 16.0,
  //             left: 8.0,
  //             child: SafeArea(
  //               child: Column(
  //                 children: [
  //                   IconButton(
  //                     icon: SvgPicture.asset(
  //                       'assets/images/svg/home_screen.svg',
  //                       width: 40.0,
  //                       height: 40.0,
  //                     ),
  //                     onPressed: () {
  //                       _checkTokenToSetWallpaperHomeScreen();
  //                     },
  //                   ),
  //                   const SizedBox(height: 2.0), // Khoảng cách giữa hai icon
  //                   IconButton(
  //                     icon: SvgPicture.asset(
  //                       'assets/images/svg/lock_screen.svg',
  //                       width: 40.0,
  //                       height: 40.0,
  //                     ),
  //                     onPressed: () {
  //                       _checkTokenToSetWallpaperLocalScreen();
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             bottom: 16.0,
  //             right: 8.0,
  //             child: SafeArea(
  //               child: IconButton(
  //                 icon: SvgPicture.asset(
  //                   'assets/images/svg/download.svg',
  //                   width: 40.0,
  //                   height: 40.0,
  //                 ),
  //                 onPressed: () {
  //                   _downloadImage(widget.imageUrl);
  //                 },
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thêm Scaffold ở đây
      body: Center(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              InteractiveViewer(
                boundaryMargin: EdgeInsets.zero, // Khoảng cách biên
                minScale: 0.5, // Tỷ lệ thu nhỏ tối thiểu
                maxScale: 4.0, // Tỷ lệ phóng to tối đa
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
              Positioned(
                top:
                    16.0, // Đặt vị trí cho nút quay lại (tùy thuộc vào thiết bị)
                left: 16.0, // Khoảng cách từ mép trái
                right: 16.0, // Khoảng cách từ mép trái
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.blackBg, // Màu nền xám bo tròn
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context); // Quay lại trang trước
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16.0,
                left: 8.0,
                child: SafeArea(
                  child: Column(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/svg/home_screen.svg',
                          width: 40.0,
                          height: 40.0,
                        ),
                        onPressed: () {
                          _checkTokenToSetWallpaperHomeScreen();
                        },
                      ),
                      const SizedBox(height: 2.0), // Khoảng cách giữa hai icon
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/images/svg/lock_screen.svg',
                          width: 40.0,
                          height: 40.0,
                        ),
                        onPressed: () {
                          _checkTokenToSetWallpaperLocalScreen();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16.0,
                right: 8.0,
                child: SafeArea(
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/images/svg/download.svg',
                      width: 40.0,
                      height: 40.0,
                    ),
                    onPressed: () {
                      _downloadImage(widget.imageUrl);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
