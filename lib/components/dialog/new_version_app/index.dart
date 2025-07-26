import 'package:flutter/material.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:url_launcher/url_launcher.dart';

class NewVersionAppDialog {
  static Future<void> showMyDialog(
      BuildContext context, int versionStatus) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Ngăn không cho đóng khi bấm ra ngoài
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Trả về false để chặn việc pop
          child: AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(4.0),
            title: const Column(
              children: [
                Image(
                  image: AssetImage('assets/images/new_version_app.png'),
                  width: 80.0,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 24.0),
                Text(
                  'New version app released!!',
                  style: AppStyles.bodyMediumSemi,
                ),
                SizedBox(height: 16.0),
              ],
            ),
            content: const SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 36.0),
              child: ListBody(
                children: <Widget>[
                  Text(
                    'The application has a new version. Please upgrade to improve your experience.',
                    style: AppStyles.bodyExtraMediumRegular,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              versionStatus != VersionStatus.force
                  ? SizedBox(
                      width: double.infinity,
                      height: 54.0,
                      child: FilledButton.tonal(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side:
                                const BorderSide(color: AppColors.orangeColor),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Continue using app',
                          style: AppStyles.titleMediumBold.copyWith(
                            color: AppColors.orangeColor,
                          ),
                        ),
                      ))
                  : const SizedBox(),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 54.0,
                child: FilledButton.tonal(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    // Navigator.of(context).pop();
                    launch(
                        'https://play.google.com/store/apps/details?id=com.fandom.billieeilishapp');
                  },
                  child: Text(
                    'Upgrade',
                    style: AppStyles.titleMediumBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
