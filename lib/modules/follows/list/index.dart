import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/wallpapers_page/overview/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FollowsList extends StatefulWidget {
  const FollowsList({super.key});

  @override
  State<FollowsList> createState() => _FollowsListState();
}

class _FollowsListState extends State<FollowsList>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final Map<String, dynamic> queryParams = {
    'singerId': FamousPeople.singerId,
    'limit': '10',
    'page': '1',
  };
  bool _skeletonEnabled = false;

  final List<dynamic> _items = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _page = 1;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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
      final data = await fetchDataWallpapersOverview(context, queryParams);
      setState(() {
        if (data['data'].isEmpty) {
          _hasMoreData = false; // No more data to load
        } else {
          _items.addAll(data['data']);
          _page++;
        }
      });
      _skeletonEnabled = true;
    } catch (error) {
      print('Error fetching items: $error');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  String _setLogoSocial(type) {
    switch (type) {
      case 'youtube':
        return 'assets/images/youtube.png';
      case 'facebook':
        return 'assets/images/facebook.png';
      case 'tiktok':
        return 'assets/images/tiktok.png';
      case 'instagram':
        return 'assets/images/instagram.png';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // END xử lý loadmore data

  Future<void> _refresh() async {
    setState(() {
      _skeletonEnabled = false;
      _items.clear();
      _page = 1;
      queryParams['page'] = '$_page';
      _hasMoreData = true; // Reset the flag
    });
    await _fetchItems();
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
              width: 72.0,
              height: 12.0,
              color: AppColors.orangeColor,
            ),
          ),
          const SizedBox(
            width: 200,
            child: Text(
              'Follows',
              style: AppStyles.title1Semi,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: !_skeletonEnabled
          ? const SkeletonWidget()
          : ListView.builder(
              key: _refreshIndicatorKey,
              controller: _scrollController,
              itemCount: _items.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == _items.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final promotionListData = _items[index];
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 8),
                      child: Card.outlined(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image(
                                image: NetworkImage(
                                    promotionListData['imageLink']),
                                fit: BoxFit.scaleDown,
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(bottom: 16)),
                              const Text(
                                'aaaaaaaaaaaaaaaaaaaaa',
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Thời gian phát hành'),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'llllllllllllllll',
                                      textAlign: TextAlign
                                          .right, // Đảm bảo văn bản căn phải
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Image(
                        image: AssetImage(_setLogoSocial('youtube')),
                        width: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                );
              },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 240,
                  width: double
                      .infinity, // Makes the container take the full width of the screen
                  color: Colors.white,
                ),
                const Padding(padding: EdgeInsets.only(bottom: 16)),
                const Text('================ ================'),
                const Text('================'),
                const SizedBox(height: 8),
                const Text('======='),
                const Padding(padding: EdgeInsets.all(16))
              ],
            ),
          );
        },
      ),
    );
  }
}
