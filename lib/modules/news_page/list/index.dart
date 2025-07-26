import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/news_page/detail/index.dart';
import 'package:music_app/modules/news_page/list/api.dart';
import 'package:music_app/modules/news_page/list/layout_via_index.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  final Map<String, dynamic> queryParams = {
    'singerId': FamousPeople.singerId,
    'limit': '10',
    'page': '1',
  };
  final List<dynamic> _items = [];
  bool _isLoadingMore = false;

  bool _hasMoreData = true;
  int _page = 1;
  bool _skeletonEnabled = false;

  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============

  // late BannerAdManager _bannerAdManager;
  // List<BannerAd?> bannerAds = [];
  // int numberOfAds = 4; // Cách 4 item thì sẽ xuất hiện 1 quảng cáo
  //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

  @override
  void initState() {
    super.initState();
    _fetchItems();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchItems();
      }
    });
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      queryParams['page'] = '$_page';

      final response = await fetchDataNewsList(context, queryParams);
      setState(() {
        if (response['data'].isEmpty) {
          _hasMoreData = false; // No more data to load
        } else {
          _items.addAll(response['data']);
          _page++;
        }
        _skeletonEnabled = true;

        //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============

        // _bannerAdManager = BannerAdManager();
        // _bannerAdManager.loadAds(
        //     bannerAdUnitId, (_items.length / numberOfAds).ceil()); // Load ads
        //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============
      });
    } catch (error) {
      print('Error fetching items: $error');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _skeletonEnabled = false;
      _items.clear();
      _page = 1;
      queryParams['page'] = '$_page';
      _hasMoreData = true; // Reset the flag
      resetLayoutData(); // Reset lại Random UI
    });
    await _fetchItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
    // _bannerAdManager.dispose(); // Dispose of banner ads
    //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

    super.dispose();
  }

  void _onDirectNewsDetail(link, title) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewsDetail(link: link, title: title)),
    );
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

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0, // Remove shadow if needed
      bottom: PreferredSize(
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
              width: 62.0,
              height: 12.0,
              color: AppColors.orangeColor,
            ),
          ),
          const SizedBox(
            width: 200,
            child: Text(
              'News',
              style: AppStyles.title1Semi,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return !_skeletonEnabled
        ? const SkeletonWidget()
        : RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
            child: _items.isEmpty
                ? const Center(child: Text("No data"))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _items.length) {
                        return _isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }

                      //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
                      // Lazy load ads after every 4 items
                      // if ((index + 1) % (numberOfAds + 1) == 0) {
                      //   final adIndex = index ~/ (numberOfAds + 1);
                      //   if (adIndex < _bannerAdManager.bannerAds.length) {
                      //     final ad = _bannerAdManager.bannerAds[adIndex];
                      //     return ad != null
                      //         ? SizedBox(height: 50, child: AdWidget(ad: ad))
                      //         : const SizedBox.shrink();
                      //   }
                      // }
                      //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

                      final newsListData = _items[index];
                      return index == 0
                          ? _buildListItemGradView(newsListData)
                          : isVeriCalLayout(index)
                              ? _buildListItem(newsListData)
                              : _buildListItemSquareView(newsListData);
                    },
                  ),
          );
  }

  Widget _buildListItemGradView(dynamic newsListData) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        _onDirectNewsDetail(newsListData['link'], newsListData['title']);
      },
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Image.network(
                    newsListData['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(169, 169, 169, 0), // Màu đầu tiên
                          Color.fromRGBO(0, 0, 0, 1.0), // Màu thứ hai
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          offset: Offset(0, 0),
                          blurRadius: 12.0,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      bottom: 12.0,
                      top: 40.0,
                    ), // Padding cho text
                    child: Text(
                      newsListData['title'],
                      maxLines: 2, // Giới hạn tối đa 2 dòng
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodyMediumSemi
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItemSquareView(dynamic newsListData) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        _onDirectNewsDetail(newsListData['link'], newsListData['title']);
      },
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                newsListData['image'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 6.0,
                  bottom: 6.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsListData['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodyMediumSemi,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateUI(newsListData['time'], true),
                      style: AppStyles.bodySmallRegular,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(dynamic newsListData) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        _onDirectNewsDetail(newsListData['link'], newsListData['title']);
      },
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Màu nền của container
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2, // Độ lan rộng của bóng
                    blurRadius: 8, // Độ mờ của bóng
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6.0), // Bo góc trái trên
                        bottomLeft: Radius.circular(6.0), // Bo góc trái dưới
                      ),
                      child: Image.network(
                        newsListData['image'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            newsListData['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bodyMediumSemi,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDateUI(newsListData['time'], true),
                            style: AppStyles.bodySmallRegular,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      child: ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              height: 210,
              width: double
                  .infinity, // Makes the container take the full width of the screen
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
