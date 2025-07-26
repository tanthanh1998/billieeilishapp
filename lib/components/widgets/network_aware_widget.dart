import 'package:flutter/material.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:music_app/apis/common/network_provider.dart';

class NetworkAwareBody extends StatelessWidget {
  final Widget child;

  const NetworkAwareBody({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (!networkProvider.hasInternet) {
          return const NoInternetWidget(); // Hiển thị UI mất kết nối nếu không có Internet
        }
        return child!;
      },
      child: child,
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No internet!!! please try again',
            style: AppStyles.bodyMediumSemi,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
