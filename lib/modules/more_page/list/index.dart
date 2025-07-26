import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_app/apis/common/auth_provider.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/upgrade_to_premium.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/layouts/auth/sign_in/index.dart';
import 'package:music_app/modules/invite_friend/overview/index.dart';
import 'package:music_app/modules/more_page/chat_with_us/index.dart';
import 'package:music_app/modules/more_page/downloader/index.dart';
import 'package:music_app/modules/more_page/information/index.dart';
import 'package:music_app/modules/more_page/list/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreList extends StatefulWidget {
  const MoreList({super.key});

  @override
  State<MoreList> createState() => MoreListState();
}

class MoreListState extends State<MoreList> {
  final Map<String, dynamic> ui = {
    'status': null,
    'nickName': '',
    'countUnreadChat': 0,
  };

  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
  // bool _isBannerAdReady = false;
  //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

  @override
  void initState() {
    super.initState();

    //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
    // _loadAdaptiveBanner();
    //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

    loadProfileData();
  }

  void loadProfileData() async {
    String? jsonData = SharedPreferencesManager().getProfile();
    if (jsonData.isNotEmpty) {
      Map<String, dynamic> profile = jsonDecode(jsonData);
      ui['nickName'] = profile['nickname'] ?? '';
      ui['status'] = profile['status'];
      ui['gender'] = profile['gender'];

      _fetchDataCountUnreadChat();
    }
  }

  //  ============= START LẤY THÔNG TIN CỦA APP =============

  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
  // void _loadAdaptiveBanner() {
  //   // Tải quảng cáo khi khởi tạo màn hình
  //   AdManager.loadBannerAd(
  //     onAdLoaded: () {
  //       setState(() {
  //         _isBannerAdReady = true;
  //       }); // Cập nhật giao diện khi quảng cáo đã sẵn sàng
  //     },
  //     onAdFailedToLoad: () {
  //       setState(() {
  //         AdManager.disposeAd(); // Dọn dẹp quảng cáo khi màn hình bị dispose
  //       }); // Xử lý khi quảng cáo thất bại
  //     },
  //   );
  // }
  //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

  Future<void> _fetchDataCountUnreadChat() async {
    try {
      final data = await fetchDataCountUnreadChat(context);
      if (data['code'] == ResStatus.success) {
        if (data['data'] != null) {
          setState(() {
            ui['countUnreadChat'] = data['data']['unReadCount'];
            ui['status'] = data['data']['userStatus'];
          });

          // START Gắn ngược lại userStatus từ API để nạp vào bộ nhớ đệm
          String? jsonData = SharedPreferencesManager().getProfile();
          if (jsonData.isNotEmpty) {
            Map<String, dynamic> profile = jsonDecode(jsonData);
            profile['status'] = ui['status'];

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString('profile', json.encode(profile));
          }
          // END Gắn ngược lại userStatus từ API để nạp vào bộ nhớ đệm
        }
      }
    } catch (error) {
      debugPrint('Error fetching items: $error');
    }
  }

  void _onDirectInformation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Information()),
    );

    // Nếu trang chi tiết trả về 'need_refresh', gọi API để refresh dữ liệu
    if (result == 'need_refresh') {
      loadProfileData();
    }
  }

  void _onDirectChatWithUs() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatWithUs()),
    );

    // Nếu trang chi tiết trả về 'need_refresh', gọi API để refresh dữ liệu
    if (result == 'need_refresh') {
      loadProfileData();
    }
  }

  void _onDirectInviteFriendOverview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InviteFriendOverview()),
    );
  }

  void _onDirectDownloader() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Downloader()),
    );
  }

  Future<void> _launchUrl(String urlScheme, String fallbackUrl) async {
    // Kiểm tra nếu ứng dụng đã được cài đặt
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme); // Mở app
    } else {
      await launch(fallbackUrl); // Mở trên trình duyệt
    }
  }

  @override
  void dispose() {
    //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
    // AdManager.disposeAd(); // Dọn dẹp quảng cáo khi màn hình bị dispose
    //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

    super.dispose();
  }

  // Xử lý khi quay lại từ LoginScreen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<AuthProvider>(context).isAuthenticated) {
      loadProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child: _buildBody(),
      ),
    );
  }

//     class EmailStatus {
//   static const int disable = 0;
//   static const int active = 1;
//   static const int waitForActive = 2;
//   static const int expired = 3;
// }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0, // Remove shadow if needed
      bottom: ui['status'] == EmailStatus.waitForActive
          ? PreferredSize(
              preferredSize: const Size.fromHeight(
                  kToolbarHeight), // Kích thước tối thiểu, nhưng sẽ mở rộng theo nội dung
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.redBg, // Màu nền của Container
                      borderRadius:
                          BorderRadius.circular(4.0), // Bo góc nếu cần
                    ),
                    child: Text(
                      'Verify email to active your account ${ui['status']}',
                      style: AppStyles.titleSmallBold.copyWith(
                        color: AppColors.redColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: const Color(0xFFD6D6D6), // Underline color
                height: 1.0,
              ),
            ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Stack(
        children: <Widget>[
          Positioned(
            top: 18.0,
            left: 16.0,
            child: Container(
              width: 46.0,
              height: 12.0,
              color: AppColors.orangeColor,
            ),
          ),
          const SizedBox(
            width: 200,
            child: Text(
              'More',
              style: AppStyles.title1Semi,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final authProvider = Provider.of<AuthProvider>(context);
    bool token = authProvider.isAuthenticated;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
                top: 22.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildRewardsMoneyCard(token),
                  // _buildUpgradeToPremiumCard(token),
                  _buildAccountCard(token),
                  _buildChatWithUsCard(token),
                  _buildFacebookCard(),
                  _buildTelegramCard(),
                  // _buildDownloaderCard(token),
                  _buildLogoutCard(token),

                  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
                  // const SizedBox(height: 16.0),
                  // _buildAds(),
                  //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============
                ],
              ),
            ),
          ),
        ),
        //  ============= START HIỂN THỊ PHIÊN BẢN Ở CUỐI TRANG =============
        SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            color: AppColors.whiteShadowColor,
            child: Center(
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final version = snapshot.data?.version ?? 'Unknown';
                    return Text(
                      'Version: $version',
                      style: AppStyles.bodyExtraMediumRegular,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        //  ============= END HIỂN THỊ PHIÊN BẢN Ở CUỐI TRANG =============
      ],
    );
  }

  // Widget _buildRewardsMoneyCard(token) {
  //   return token
  //       ? Container(
  //           margin: const EdgeInsets.only(top: 12.0, bottom: 12.0),
  //           decoration: BoxDecoration(
  //             color: AppColors.orangeLightColor, // Màu nền của container
  //             borderRadius: BorderRadius.circular(30.0),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.2),
  //                 spreadRadius: 0.0, // Độ lan rộng của bóng
  //                 blurRadius: 4.0, // Độ mờ của bóng
  //                 offset: const Offset(0, 0),
  //               ),
  //             ],
  //           ),
  //           child: InkWell(
  //             splashColor: Colors.transparent,
  //             hoverColor: Colors.transparent,
  //             onTap: () {
  //               _onDirectInviteFriendOverview();
  //             },
  //             child: SizedBox(
  //               width: MediaQuery.of(context).size.width,
  //               child: const Padding(
  //                 padding: EdgeInsets.only(
  //                   right: 26.0,
  //                   left: 26.0,
  //                   top: 22.0,
  //                   bottom: 22.0,
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Image(
  //                       image: AssetImage('assets/images/rewards_money.png'),
  //                       width: 42,
  //                       fit: BoxFit.cover,
  //                     ),
  //                     SizedBox(
  //                       width: 24,
  //                       height: 16,
  //                     ),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'Receiving money every month',
  //                             style: AppStyles.titleMediumBold,
  //                           ),
  //                           Text(
  //                             'Invite friends to get cool rewards, get it now!',
  //                             style: AppStyles.bodySmallRegular,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         )
  //       : Container();
  // }

  // Widget _buildUpgradeToPremiumCard(token) {
  //   return token
  //       ? Container(
  //           margin: const EdgeInsets.only(top: 12.0, bottom: 24.0),
  //           decoration: BoxDecoration(
  //             color: AppColors.orangeColor, // Màu nền của container
  //             borderRadius: BorderRadius.circular(30.0),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.2),
  //                 spreadRadius: 0.0, // Độ lan rộng của bóng
  //                 blurRadius: 4.0, // Độ mờ của bóng
  //                 offset: const Offset(0, 0),
  //               ),
  //             ],
  //           ),
  //           child: InkWell(
  //             splashColor: Colors.transparent,
  //             hoverColor: Colors.transparent,
  //             onTap: () => openFullScreenUpgradeToPremiumDrawer(
  //                 context), // Gọi hàm mở drawer
  //             child: Padding(
  //               padding: const EdgeInsets.only(
  //                 right: 30.0,
  //                 left: 30.0,
  //                 top: 12.0,
  //                 bottom: 12.0,
  //               ),
  //               child: Row(
  //                 children: [
  //                   SvgPicture.asset(
  //                     'assets/images/svg/no_ads.svg',
  //                     width: 28.0,
  //                     height: 28.0,
  //                   ),
  //                   const SizedBox(width: 24.0),
  //                   Text(
  //                     'Upgrade to PREMIUM',
  //                     style: AppStyles.titleMediumBold.copyWith(
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         )
  //       : Container();
  // }

  Widget _buildAccountCard(token) {
    void onSignIn(context) {
      showModalBottomSheetSignIn(context);
    }

    void onDirectUpgradeToPremium() {
      openFullScreenUpgradeToPremiumDrawer(context);
    }

    return token
        ? Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.white, // Màu nền của container
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0.0, // Độ lan rộng của bóng
                  blurRadius: 4.0, // Độ mờ của bóng
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                _onDirectInformation();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image(
                          image: AssetImage(ui['gender'] == Gender.male
                              ? 'assets/images/male_active.png'
                              : 'assets/images/female_active.png'),
                          width: 42,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          ui['nickName'],
                          style: AppStyles.bodyMediumRegular,
                        ),
                      ],
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     onDirectUpgradeToPremium();
                    //   },
                    //   borderRadius: BorderRadius.circular(30.0),
                    //   child: const PremiumTag(
                    //     text: 'Premium',
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          )
        : Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.white, // Màu nền của container
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0.0, // Độ lan rộng của bóng
                  blurRadius: 4.0, // Độ mờ của bóng
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                onSignIn(context);
              },
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Row(
                  children: [
                    Image(
                      image: AssetImage('assets/images/user.png'),
                      width: 42,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      'Login',
                      style: AppStyles.bodyLargeRegular,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  // ==============================
  // ===============================
  Widget _buildChatWithUsCard(token) {
    return token
        ? Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.white, // Màu nền của container
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0.0, // Độ lan rộng của bóng
                  blurRadius: 4.0, // Độ mờ của bóng
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                _onDirectChatWithUs();
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Image(
                          image: AssetImage('assets/images/chat_with_us.png'),
                          width: 42,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          'Chat with us',
                          style: AppStyles.bodyLargeSemi,
                        ),
                      ],
                    ),
                    Builder(
                      builder: (BuildContext context) {
                        if (ui['countUnreadChat'] != 0) {
                          return Container(
                            width: 26.0, // Kích thước hình tròn
                            height: 26.0,
                            decoration: const BoxDecoration(
                              color: Colors.red, // Màu nền bên trong
                              shape: BoxShape.circle, // Đường viền tròn
                            ),
                            child: Center(
                              child: Text(
                                '${ui['countUnreadChat']}',
                                style: AppStyles.titleExtraSmallBold.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  // ==============================
  // ===============================
  Widget _buildFacebookCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền của container
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0.0, // Độ lan rộng của bóng
            blurRadius: 4.0, // Độ mờ của bóng
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          // _launchUrl('fb://groups/justinbieberfandom',
          //     'https://www.facebook.com/groups/justinbieberfandom');
        },
        child: const Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 12.0,
            bottom: 12.0,
          ),
          child: Row(
            children: [
              Image(
                image: AssetImage('assets/images/facebook.png'),
                width: 42,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 16.0),
              Text(
                'Join our group',
                style: AppStyles.bodyLargeSemi,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // ===============================
  Widget _buildTelegramCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền của container
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0.0, // Độ lan rộng của bóng
            blurRadius: 4.0, // Độ mờ của bóng
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          _launchUrl('tg://resolve?domain=billie_eilish_app',
              'https://t.me/billie_eilish_app');
        },
        child: const Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 12.0,
            bottom: 12.0,
          ),
          child: Row(
            children: [
              Image(
                image: AssetImage('assets/images/telegram.png'),
                width: 42,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 16.0),
              Text(
                'Join our group',
                style: AppStyles.bodyLargeSemi,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // ===============================
  // Widget _buildDownloaderCard(token) {
  //   return token
  //       ? Container(
  //           margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
  //           decoration: BoxDecoration(
  //             color: Colors.white, // Màu nền của container
  //             borderRadius: BorderRadius.circular(20.0),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.2),
  //                 spreadRadius: 0.0, // Độ lan rộng của bóng
  //                 blurRadius: 4.0, // Độ mờ của bóng
  //                 offset: const Offset(0, 0),
  //               ),
  //             ],
  //           ),
  //           child: InkWell(
  //             splashColor: Colors.transparent,
  //             hoverColor: Colors.transparent,
  //             onTap: () {
  //               _onDirectDownloader();
  //             },
  //             child: const Padding(
  //               padding: EdgeInsets.only(
  //                 left: 24.0,
  //                 right: 24.0,
  //                 top: 12.0,
  //                 bottom: 12.0,
  //               ),
  //               child: Row(
  //                 children: [
  //                   Image(
  //                     image: AssetImage('assets/images/downloader.png'),
  //                     width: 42,
  //                     fit: BoxFit.cover,
  //                   ),
  //                   SizedBox(width: 16.0),
  //                   Text(
  //                     'Downloader',
  //                     style: AppStyles.bodyLargeSemi,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         )
  //       : Container();
  // }

  // ==============================
  // ===============================
  Widget _buildLogoutCard(token) {
    return token
        ? Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.white, // Màu nền của container
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0.0, // Độ lan rộng của bóng
                  blurRadius: 4.0, // Độ mờ của bóng
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                context.read<AuthProvider>().clearToken(context);
              },
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: Row(
                  children: [
                    Image(
                      image: AssetImage('assets/images/logout.png'),
                      width: 42,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      'Logout',
                      style: AppStyles.bodyLargeSemi,
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  // Widget _buildAds() {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       color: AppColors.whiteShadowColor,
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
  //       child: _isBannerAdReady
  //           ? SizedBox(
  //               width: double.infinity,
  //               child: AdManager.getBannerAdWidget(),
  //             )
  //           : const SizedBox.shrink(),
  //     ),
  //   );
  // }
}
