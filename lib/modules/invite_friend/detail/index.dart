import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/styles/bullet_text.dart';
import 'package:music_app/styles/custom_text.dart';

class InviteFriendDetail extends StatelessWidget {
  const InviteFriendDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child: _buildBody(),
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
        'Program details',
        style: AppStyles.title2Semi,
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invite New Friends, Receive Money Monthly',
              style: AppStyles.titleMediumBold,
            ),
            const Text(
              'Join the fandom app to immediately receive monthly income with just a few simple steps right on the application. Explore the program below.',
              style: AppStyles.bodyLargeRegular,
            ),
            const SizedBox(height: 16.0),
            const Text(
              '1. Program information',
              style: AppStyles.titleMediumBold,
            ),
            const Text(
              'Share “Referral Code” to enjoy exclusive offers today. Program participants can simultaneously enjoy incentives through the application.',
              style: AppStyles.bodyLargeRegular,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'When the “Invitee” downloads the application, successfully registers and upgrades to the Premium package:',
              style: AppStyles.bodyLargeRegular,
            ),
            const BulletText(
              text: 'Invitees: Receive 3 days of free Premium package',
              bulletStyle: TextStyle(
                fontSize: 20.0,
              ), // Tùy chỉnh dấu chấm
              textStyle:
                  AppStyles.bodyLargeRegular, // Tùy chỉnh style cho văn bản
            ),
            const Text(
              'Referrer: Receive 10% monthly commission of Premium package',
              style: AppStyles.bodyLargeRegular,
            ),
            const SizedBox(height: 16.0),
            const Text(
              '2. How to participate',
              style: AppStyles.titleMediumBold,
            ),
            const Text(
              '2.1. Instructions on how to send code for "Referrer"',
              style: AppStyles.titleMediumBold,
            ),
            const Text(
              'Step 1: Go to the application and access the account management section',
              style: AppStyles.bodyLargeRegular,
            ),
            RichText(
              text: const TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Step 2: Click on the ',
                    style: AppStyles.bodyLargeRegular,
                  ),
                  TextSpan(
                    text: '‘Receiving money every month’',
                    style: AppStyles.titleMediumBold,
                  ),
                ],
              ),
            ),
            const Text(
              'Step 3: Share “Referral Code” with your friends',
              style: AppStyles.bodyLargeRegular,
            ),
            const Text(
              '2.2. Instructions on how to use the code for "Invitees"',
              style: AppStyles.titleMediumBold,
            ),
            const Text(
              'Step 1: Download the application and enter "Referral Code" in the registration section',
              style: AppStyles.bodyLargeRegular,
            ),
            const Text(
              'Step 2: After successfully logging in. “Invitees” immediately receive 3 days of free Premium package',
              style: AppStyles.bodyLargeRegular,
            ),
            const Text(
              'Step 3: Upgrade to Premium package',
              style: AppStyles.bodyLargeRegular,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Download the app now! Invite friends to use the app to receive money every month',
              style: AppStyles.bodyLargeRegular,
            ),
            const SizedBox(height: 16.0),
            const Text(
              '3. Note',
              style: AppStyles.titleMediumBold,
            ),
            const Text(
              "If the “Invitee” cancels the Premium package for the next month. Then the Referrer's introduction will be deleted",
              style: AppStyles.bodyLargeRegular,
            ),
            const SizedBox(height: 16.0),
            const Text(
              '4. Program terms and conditions',
              style: AppStyles.titleMediumBold,
            ),
            const Text(
              'The “Invitee” needs to upgrade to the Premium plan after registration, so that both (“Referrer” and “Invitee”) can receive the reward.',
              style: AppStyles.bodyLargeRegular,
            ),
            const Text(
              'The application reserves the right to revoke commissions and rewards from the program if fraud or abuse of the referral program is detected.',
              style: AppStyles.bodyLargeRegular,
            ),
            const Text(
              'The application reserves the right to change, end, or suspend all or part of the referral program at any time and for any reason.',
              style: AppStyles.bodyLargeRegular,
            ),
          ],
        ),
      ),
    );
  }
}
