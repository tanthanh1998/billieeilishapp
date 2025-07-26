import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/albums_page/lyric/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Lyric extends StatefulWidget {
  final int songId;

  const Lyric({super.key, required this.songId});

  @override
  State<Lyric> createState() => _LyricState();
}

class _LyricState extends State<Lyric> {
  late Map<String, dynamic> bookingDetail = {};
  late List translateList = [];
  final Map<String, dynamic> queryParams = {
    'songId': '',
    'translateId': '0',
  };
  int? selectedLanguageId;
  final ScrollController _scrollController = ScrollController();

  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
  // bool _isBannerAdReady = false;
  //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

  @override
  void initState() {
    super.initState();

    //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
    // _loadAdaptiveBanner();
    //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

    _fetchItems();
  }

  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============

  // void _loadAdaptiveBanner() {
  //   AdManager.loadBannerAd(
  //     onAdLoaded: () => setState(() => _isBannerAdReady = true),
  //     onAdFailedToLoad: () {
  //       setState(() => AdManager.disposeAd());
  //     },
  //   );
  // }
  //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

  Future<void> _fetchItems() async {
    try {
      queryParams['songId'] = '${widget.songId}';
      final data = await fetchDataLyric(context, queryParams);

      if (data['code'] == ResStatus.success) {
        setState(() {
          bookingDetail = data['data'];
          if (translateList.isEmpty) {
            translateList = data['data']['translateList'];
            selectedLanguageId = translateList[0]['id'];
          }
        });
      }
    } catch (error) {
      print('Error fetching items: $error');
    }
  }

  void _onHandleShareLyric() {
    String title = bookingDetail['name'];
    String content = bookingDetail['lyric'];
    String textToShare = '$title\n\n$content';

    Share.share(textToShare);
  }

  void _onChangeLanguageLyric(Map<String, dynamic> language) {
    setState(() {
      selectedLanguageId = language['id'];
      queryParams['translateId'] = '${language['id']}';
    });
    _fetchItems();
  }

  void _scrollToSelectedLanguage() {
    final selectedIndex = translateList
        .indexWhere((language) => language['id'] == selectedLanguageId);
    if (selectedIndex != -1) {
      _scrollController.animateTo(
        selectedIndex * 30.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
    // AdManager.disposeAd();
    //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

    super.dispose();
  }

  void _openBottomDrawer(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedLanguage();
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 230,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: translateList.length,
                itemBuilder: (context, index) {
                  final language = translateList[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setModalState(() => _onChangeLanguageLyric(language));
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            language['name'],
                            textAlign: TextAlign.center,
                            style: AppStyles.bodyLargeRegular.copyWith(
                              color: selectedLanguageId == language['id']
                                  ? AppColors.orangeColor
                                  : AppColors.blackColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child: Builder(
          builder: (BuildContext context) {
            return bookingDetail.isNotEmpty
                ? Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: _buildBody(),
                      ),
                      //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
                      // _buildAds(),
                      //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============
                    ],
                  )
                : const SkeletonWidget();
          },
        ),
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
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/svg/share.svg',
            width: 24.0,
            height: 24.0,
          ),
          onPressed: _onHandleShareLyric,
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/svg/translate.svg',
            width: 24.0,
            height: 24.0,
          ),
          onPressed: translateList.isNotEmpty
              ? () => _openBottomDrawer(context)
              : null,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      bottom: -2,
                      child: Container(
                        width: 84.0,
                        height: 12.0,
                        color: AppColors.orangeColor,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        '${bookingDetail['name']!}',
                        style: AppStyles.title2Semi,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${bookingDetail['lyric']}',
                  style: AppStyles.bodyLargeRegular,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============

  // Positioned _buildAds() {
  //   return Positioned(
  //     bottom: 0,
  //     left: 0,
  //     right: 0,
  //     child: SafeArea(
  //       child: Container(
  //         decoration: const BoxDecoration(
  //           color: AppColors.whiteShadowColor,
  //         ),
  //         child: Padding(
  //           padding:
  //               const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
  //           child: _isBannerAdReady
  //               ? SizedBox(
  //                   width: double.infinity,
  //                   child: AdManager.getBannerAdWidget(),
  //                 )
  //               : const SizedBox.shrink(),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class SkeletonWidget extends StatelessWidget {
  const SkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      ignoreContainers: true,
      enabled: true,
      enableSwitchAnimation: true,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const SizedBox(
                    width: 200,
                    child: Text(
                      '================',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: 80,
                    color: AppColors.orangeColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                width: 200,
                color: AppColors.greyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
