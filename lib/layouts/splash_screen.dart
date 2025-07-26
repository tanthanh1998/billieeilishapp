import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/apis/common/update_device.dart';
import 'package:music_app/components/dialog/new_version_app/index.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Map<String, dynamic> formData = {
    'deviceId': '',
    'os': '',
    'model': '',
    'appVersion': '',
  };

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      // Kiểm tra nếu không phải là Web
      if (!kIsWeb) {
        _initSetDevice();
      } else {
        onDirectPage();
      }
    });
  }

  void _initSetDevice() async {
    await _onUpdateFormData();

    _onUpdateDevice(); // API cập nhật INFO App
  }

  Future<void> _onUpdateFormData() async {
    await _initDeviceId();
    await _initPackageInfo();
    setState(() {
      formData['os'] = getOS();
    });
  }

  Future<void> _initDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        formData['deviceId'] = androidInfo.id; // Lấy Android deviceId
        formData['model'] = androidInfo.model; // Lấy Android model
      });
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        formData['deviceId'] = iosInfo.identifierForVendor; // Lấy iOS deviceId
        formData['model'] = iosInfo.name; // Lấy iOS model
      });
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      formData['appVersion'] = info.version;
    });

    // Text('App name ${info.appName}'),
    //         Text('packageName name ${info.packageName}'),
    //         Text('version name ${info.version}'),
    //         Text('version name ${info.version}'),
    //         Text('buildNumber name ${info.buildNumber}'),
    //         Text('buildSignature name ${info.buildSignature}'),
    //         Text('installerStore name ${info.installerStore}'),
  }

  Future<void> _onUpdateDevice() async {
    try {
      final data = await postDataUpdateDevice(context, formData);

      if (data['code'] == ResStatus.success) {
        if (data != null &&
            data['data'] != null &&
            data['data']['isSuccess'] != null &&
            data['data']['isSuccess'] == 1) {
          if (data['data']['versionStatus'] != null) {
            if (!mounted) return; // Ensure widget is still in the tree

            switch (data['data']['versionStatus']) {
              case VersionStatus.force:
              case VersionStatus.remind:
                // Delay to allow the UI to rebuild before showing the dialog
                Future.delayed(Duration.zero, () {
                  NewVersionAppDialog.showMyDialog(
                    context,
                    data['data']['versionStatus'],
                  );
                });
                break;
              default:
                break;
            }
          }
          onDirectPage();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void onDirectPage() {
    Navigator.pushReplacementNamed(
      context,
      '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.orange, // Đặt màu nền
        ),
        child: Container(
          color: Colors.white, // Màu nền là màu trắng
          child: const Center(
            // Căn giữa nội dung
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/splash_screen.png'),
                  width: 224.0,
                  height: 30.0,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Everythings for Billie eilish',
                  style: AppStyles.bodyMediumRegular,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
