import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/styles/custom_text.dart';

class UpgradeToPremiumDrawer extends StatelessWidget {
  const UpgradeToPremiumDrawer({super.key});

  void _onJoinGroupToLearnMore() {
    print('_onJoinGroupToLearnMore');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/svg/note.svg',
            width: 24.0,
            height: 24.0,
          ),
          onPressed: () {
            // _onDirectInviteFriendDetail();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildPremiumImage(),
            _buildPremiumContainer(),
            const SizedBox(height: 48.0),
            _buildFeaturesList(),
            const SizedBox(height: 36),
          ],
        ),
        _buildJoinButton(),
      ],
    );
  }

  Widget _buildPremiumImage() {
    return SvgPicture.asset(
      'assets/images/svg/upgrade_to_premium.svg',
      width: 140.0,
      height: 126.0,
    );
  }

  Widget _buildPremiumContainer() {
    return Container(
      width: 206.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(39, 233, 157, 1),
            Color.fromRGBO(39, 227, 245, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            'Enjoy unlimited app',
            style: AppStyles.titleMediumBold.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Remove ads',
      'Play music offline',
      'Premium wallpapers',
      'Up-to-date new features',
      'Can request a feature',
      'Connect to other fandoms',
      '24/7 support',
    ];

    return Expanded(
      child: Row(
        children: [
          Expanded(child: Container()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                features.map((feature) => _buildFeatureItem(feature)).toList(),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(feature, style: AppStyles.bodyMediumRegular),
        ],
      ),
    );
  }

  Positioned _buildJoinButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.whiteShadowColor,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: FilledButton.tonal(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: _onJoinGroupToLearnMore,
              child: const Text(
                'JOIN GROUP TO LEARN MORE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void openFullScreenUpgradeToPremiumDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: "RightSheet",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return const UpgradeToPremiumDrawer();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: const Offset(0, 0),
        ).animate(anim1),
        child: child,
      );
    },
  );
}
