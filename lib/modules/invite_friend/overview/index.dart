import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/invite_friend/detail/index.dart';
import 'package:music_app/styles/custom_text.dart';

class InviteFriendOverview extends StatefulWidget {
  const InviteFriendOverview({super.key});

  @override
  State<InviteFriendOverview> createState() => _InviteFriendOverviewState();
}

class _InviteFriendOverviewState extends State<InviteFriendOverview> {
  final Map<String, dynamic> ui = {
    'memberCode': '',
  };

  @override
  void initState() {
    super.initState();

    String? jsonData = SharedPreferencesManager().getProfile();
    if (jsonData.isNotEmpty) {
      Map<String, dynamic> profile = jsonDecode(jsonData);
      ui['memberCode'] = profile['memberCode'] ?? '';
    }
  }

  void _onDirectInviteFriendDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InviteFriendDetail()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child: _buildBody(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFFD6D6D6),
          height: 1.0,
        ),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text(
        'Invite friend',
        style: AppStyles.titleLargeBold,
      ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/svg/note.svg',
            width: 24.0,
            height: 24.0,
          ),
          onPressed: () {
            _onDirectInviteFriendDetail();
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 26.0, bottom: 26.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: AppColors.orangeLightColor, // Màu nền của container
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 0.0, // Độ lan rộng của bóng
                    blurRadius: 4.0, // Độ mờ của bóng
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0, bottom: 18.0),
                child: Column(
                  children: [
                    const Image(
                      image: AssetImage('assets/images/rewards_money.png'),
                      width: 42,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 24,
                      height: 16,
                    ),
                    const Text(
                      'Receiving money every month',
                      style: AppStyles.titleMediumBold,
                    ),
                    const Text(
                      'Invite friends to get cool rewards, get it now!',
                      style: AppStyles.bodySmallRegular,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        // Sao chép text vào clipboard
                        Clipboard.setData(ClipboardData(
                          text: ui['memberCode'],
                        )).then((_) {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //       content: Text('Copied successfully!')),
                          // );
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.74, // Giới hạn chiều rộng tối đa là 70% chiều rộng màn hình
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orangeColor,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding:
                                const EdgeInsets.only(left: 22.0, right: 22.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.copy, color: Colors.white),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      ui['memberCode'],
                                      style: AppStyles.titleMediumBold.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    const Text(
                                      '|',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: null,
                                      child: Text(
                                        'Share',
                                        style:
                                            AppStyles.titleMediumBold.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                children: [
                  const Text(
                    'How to get rewards when inviting a friend?',
                    style: AppStyles.bodyMediumRegular,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/step_1.svg',
                        width: 28.0,
                        height: 28.0,
                      ),
                      const SizedBox(
                        width: 24.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Step 1: Share your code',
                              style: AppStyles.bodyLargeRegular,
                            ),
                            Text(
                              'Copy or Share the referral code with your friends and invite them to join',
                              style: AppStyles.bodySmallRegular
                                  .copyWith(color: AppColors.greyColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/step_2.svg',
                        width: 28.0,
                        height: 28.0,
                      ),
                      const SizedBox(
                        width: 24.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Step 2: Invitee downloads app & successfully signs up with code',
                              style: AppStyles.bodyLargeRegular,
                            ),
                            Text(
                              '- Share the link below to download the app https://kongricsstudio.com/ed-sheeran',
                              style: AppStyles.bodySmallRegular
                                  .copyWith(color: AppColors.greyColor),
                            ),
                            Text(
                              '- Your friend will have free  3 days Premium',
                              style: AppStyles.bodySmallRegular
                                  .copyWith(color: AppColors.greyColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/step_3.svg',
                        width: 28.0,
                        height: 28.0,
                      ),
                      const SizedBox(
                        width: 24.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Step 3: Invitee upgrade to Premium successfully',
                              style: AppStyles.bodyLargeRegular,
                            ),
                            Text(
                              '- You will receive commission monthly per one invitee via PayPal',
                              style: AppStyles.bodySmallRegular
                                  .copyWith(color: AppColors.greyColor),
                            ),
                            Text(
                              '- There is no limit to the number of invitee, the more you invite, the more money you get',
                              style: AppStyles.bodySmallRegular
                                  .copyWith(color: AppColors.greyColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
