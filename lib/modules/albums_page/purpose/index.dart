import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/albums_page/lyric/index.dart';
import 'package:music_app/modules/albums_page/purpose/api.dart';
import 'package:music_app/modules/albums_page/purpose/colors_via_index.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeline_tile/timeline_tile.dart';

class PurposeList extends StatefulWidget {
  final String name;
  final int albumId;

  const PurposeList({super.key, required this.albumId, required this.name});

  @override
  State<PurposeList> createState() => _PurposeListState();
}

class _PurposeListState extends State<PurposeList>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, dynamic> queryParams = {
    'albumId': '',
  };
  bool _skeletonEnabled = false;
  final List<dynamic> _items = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredItems = [];

  //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
  // late BannerAdManager _bannerAdManager;
  // List<BannerAd?> bannerAds = [];
  // int numberOfAds = 4; // Cách 4 item thì sẽ xuất hiện 1 quảng cáo
  //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

  @override
  void initState() {
    super.initState();
    _fetchItems();

    _filterItems(); // Chạy lần đầu khi khởi tạo
    _searchController.addListener(_filterItems); // Gắn listener cho TextField
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      queryParams['albumId'] =
          '${widget.albumId}'; // Gắn giá trị albumId ban đầu
      final response = await fetchDataPurposeList(context, queryParams);
      setState(() {
        if (response.isEmpty) {
          _hasMoreData = false; // No more data to load
        } else {
          _items.addAll(response['data']);
        }
        _skeletonEnabled = true;

        //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
        // _bannerAdManager = BannerAdManager();
        // _bannerAdManager.loadAds(
        //     bannerAdUnitId, (_items.length / numberOfAds).ceil()); // Load ads
        //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============
      });

      setState(() {
        _isLoadingMore = false;
      });
    } catch (error) {
      print('Error fetching items: $error');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _skeletonEnabled = false;
      _items.clear();
      _hasMoreData = true; // Reset the flag
    });
    await _fetchItems();
  }

  // Hàm lọc album dựa trên từ khóa tìm kiếm
  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty || _isSearching == false) {
        _filteredItems = _items;
      } else {
        _filteredItems = _items
            .where((item) =>
                (item['name'] as String).toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
    // _bannerAdManager.dispose(); // Dispose of banner ads
    //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

    super.dispose();
  }

  void _onDirectLyric(item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Lyric(
          songId: item['id'],
        ),
      ),
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: const TextStyle(color: AppColors.blackColor),
            )
          : Text(
              widget.name,
              style: AppStyles.title1Semi,
            ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: AppColors.blackColor,
          ),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                // Khi nhấn dấu "x", không xóa giá trị của _searchController
                _isSearching = false;
                _filterItems(); // Khôi phục danh sách đầy đủ
              } else {
                // Khi nhấn vào search, hiển thị giá trị hiện tại của _searchController
                _isSearching = true;
                _filterItems(); // Filter lại
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return !_skeletonEnabled
        ? const SkeletonWidget()
        : RefreshIndicator(
            onRefresh: _refresh,
            child: !_skeletonEnabled
                ? const SkeletonWidget()
                : _filteredItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        controller: _scrollController,
                        itemCount:
                            _filteredItems.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == _filteredItems.length) {
                            return _isLoadingMore
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : const SizedBox.shrink();
                          }

                          //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============

                          // Lazy load ads after every 4 items
                          // if ((index + 1) % (numberOfAds + 1) == 0) {
                          //   final adIndex = index ~/ (numberOfAds + 1);
                          //   if (adIndex < _bannerAdManager.bannerAds.length) {
                          //     final ad = _bannerAdManager.bannerAds[adIndex];
                          //     return ad != null
                          //         ? SizedBox(
                          //             height: 50, child: AdWidget(ad: ad))
                          //         : const SizedBox.shrink();
                          //   }
                          // }

                          //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

                          final purposeList = _filteredItems[index];
                          return TimelineTile(
                            beforeLineStyle: const LineStyle(
                                color: AppColors.blackColor, thickness: 1.0),
                            indicatorStyle: IndicatorStyle(
                              width: 12,
                              color: getRandomColor(),
                            ),
                            endChild: _buildEventCardWidget(
                              purposeList,
                            ),
                          );
                        },
                      ),
          );
  }

  Widget _buildEventCardWidget(dynamic purposeList) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          _onDirectLyric(purposeList);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${purposeList['name']}',
              style: AppStyles.title2Semi,
            ),
            const SizedBox(height: 4.0),
            Text(
              '${purposeList['shortLyric']}',
              style: AppStyles.bodySmallRegular,
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
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 80.0,
                      width: 2.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 32.0),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 46.0),
                          Text('==============='),
                          Text('=============== ==============='),
                          SizedBox(height: 4.0),
                          Text('==============='),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
