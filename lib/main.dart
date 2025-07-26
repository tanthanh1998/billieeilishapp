// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:music_app/apis/common/auth_provider.dart';
// import 'package:music_app/apis/common/network_provider.dart';
// import 'package:music_app/apis/common/shared_preferences.dart';
// import 'package:music_app/components/request_login.dart';
// import 'package:music_app/components/splash_screen.dart';
// import 'package:music_app/layouts/auth/sign_in/index.dart';
// import 'package:music_app/layouts/member.dart';
// import 'package:music_app/styles/custom_text.dart';
// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SharedPreferencesManager()
//       .init(); // Khởi tạo Bộ lưu trữ Storge trên thiết bị

//   MobileAds.instance.initialize(); // Khởi tạo quảng cáo

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => NetworkProvider()),
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         colorScheme: Theme.of(context).colorScheme.copyWith(
//               primary: AppColors.orangeColor, // Chỉ thay đổi màu primary
//             ),
//         useMaterial3: true,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const SplashScreen(),
//       routes: {
//         '/sign-in': (context) => const SignIn(),
//         '/home': (context) => const Member(),
//         '/request-login': (context) => const RequestLogin(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
// Chỉ sử dụng cho Android và iOS
import 'package:music_app/apis/common/auth_provider.dart';
import 'package:music_app/apis/common/network_provider.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/layouts/splash_screen.dart';
import 'package:music_app/layouts/auth/sign_in/index.dart';
import 'package:music_app/layouts/member.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesManager().init(); // Khởi tạo bộ lưu trữ

  // Kiểm tra nếu không phải là Web thì khởi tạo Google Mobile Ads
  // if (!kIsWeb) {
  //   MobileAds.instance.initialize(); // Khởi tạo quảng cáo cho Android/iOS
  // }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billie Eilish Songs offline',
      theme: ThemeData(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.orangeColor, // Chỉ thay đổi màu primary
            ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/sign-in': (context) => const SignIn(),
        '/home': (context) => const Member(),
      },
    );
  }
}
