import 'package:flutter/material.dart';
import 'package:music_app/components/upgrade_to_premium.dart';
import 'package:music_app/styles/premium_tag.dart';
import 'package:music_app/styles/custom_text.dart';

class UpgradeToPremiumDrawer extends StatefulWidget {
  const UpgradeToPremiumDrawer({super.key});

  @override
  State<UpgradeToPremiumDrawer> createState() => _UpgradeToPremiumDrawerState();
}

class _UpgradeToPremiumDrawerState extends State<UpgradeToPremiumDrawer>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void _onDirectUpgradeToPremium() {
    openFullScreenUpgradeToPremiumDrawer(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 46.0,
          right: 46.0,
          top: 50.0,
          bottom: 8.0,
        ),
        child: Column(
          children: [
            const Text(
              'Please upgrade to Premium to continue',
              style: AppStyles.bodyMediumRegular,
            ),
            const SizedBox(height: 24.0),
            InkWell(
              onTap: () {
                _onDirectUpgradeToPremium();
              },
              borderRadius: BorderRadius.circular(30.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PremiumTag(
                    text: 'UPGRADE',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showModalBottomSheetUpgradeToPremiumDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "RightSheet",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      // return const UpgradeToPremiumDrawer();
      return const Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 200, // Chiều cao cố định là 200 pixel
          child: UpgradeToPremiumDrawer(), // Nội dung của dialog
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(anim1),
        child: child,
      );
    },
  );
}
