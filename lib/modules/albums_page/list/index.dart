import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/albums_page/list/api.dart';
import 'package:music_app/modules/albums_page/purpose/index.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AlbumsList extends StatefulWidget {
  const AlbumsList({super.key});

  @override
  State<AlbumsList> createState() => _AlbumsListState();
}

class _AlbumsListState extends State<AlbumsList> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, dynamic> queryParams = {
    'singerId': FamousPeople.singerId,
  };
  bool _skeletonEnabled = false;
  final List<dynamic> _items = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _totalQuantity = 0; // Biến để lưu tổng số lượng

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
      final response = await fetchDataAlbumList(context, queryParams);
      setState(() {
        if (response.isEmpty) {
          _hasMoreData = false; // No more data to load
        } else {
          _items.addAll(response['data']);

          // Tính tổng số lượng của tất cả các phần tử trong _items
          _totalQuantity =
              _items.fold(0, (sum, item) => sum + (item['totalSong'] as int));

          // Chèn một đối tượng mới chứa _totalQuantity vào đầu mảng
          _items.insert(0, {
            'totalSong': _totalQuantity,
            'name': 'All of songs',
            'thumbnail': null,
            'albumId': null
          });
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
    _searchController.dispose();

    //  ============= START THIẾT LẬP QUẢNG CÁO TRONG APP =============
    // _bannerAdManager.dispose();
    //  ============= END THIẾT LẬP QUẢNG CÁO TRONG APP =============

    super.dispose();
  }

  void _onDirectPurpose(albumsListData) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PurposeList(
                albumId: albumsListData['id'] ?? 0,
                name: albumsListData['name'],
              )),
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
          : Stack(
              children: <Widget>[
                Positioned(
                  top: 16.0,
                  left: 12.0,
                  child: Container(
                    width: 84.0, // Kích thước rộng bằng kích thước ảnh
                    height: 12.0, // Chiều cao đường viền
                    color: AppColors.orangeColor,
                  ),
                ),
                const SizedBox(
                  width: 200,
                  child: Text(
                    'Albums',
                    style: AppStyles.title1Semi,
                  ),
                ),
              ],
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
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _filteredItems.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == _filteredItems.length) {
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

                final albumsListData = _filteredItems[index];
                return _buildListItem(albumsListData);
              },
            ),
          );
  }

  Widget _buildListItem(dynamic albumsListData) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        _onDirectPurpose(albumsListData);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: <Widget>[
                Align(
                  alignment:
                      Alignment.centerRight, // Căn chỉnh Card về bên phải
                  child: FractionallySizedBox(
                    widthFactor: 0.9, // Chiếm 90% chiều rộng màn hình
                    child: SizedBox(
                      height: 100, // Điều chỉnh chiều cao của Card
                      child: Container(
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
                          padding: const EdgeInsets.only(
                            left: 40,
                            top: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                albumsListData['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.title2Semi,
                              ),
                              Text(
                                '${albumsListData['totalSong'] ?? ''} songs',
                                style: AppStyles.bodySmallRegular,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Hình ảnh của album hoặc ảnh mặc định
                Positioned(
                  top: 20.0, // Điều chỉnh vị trí của hình ảnh so với Card
                  left: 0.0,
                  child: albumsListData['thumbnail'] != null
                      ? Image.network(
                          '${albumsListData['thumbnail']}',
                          height: 60,
                          width: 60, // Điều chỉnh kích thước hình ảnh
                          fit: BoxFit.cover,
                        )
                      : const Image(
                          image: AssetImage('assets/images/all_of_songs.png'),
                          height: 60,
                          width: 60, // Điều chỉnh kích thước hình ảnh
                          fit: BoxFit.cover,
                        ),
                ),
              ],
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
        itemCount: 10,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight, // Căn chỉnh Card về bên phải
                child: FractionallySizedBox(
                  widthFactor: 0.9, // Chiếm 4/5 chiều rộng màn hình
                  child: SizedBox(
                    height: 100, // Điều chỉnh chiều cao của Card
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.white,
                      child: const Padding(
                        padding: EdgeInsets.only(
                            left: 60,
                            top: 16,
                            right: 16,
                            bottom: 16), // Cách lề trái 150 pixel
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('================ ================'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20.0, // Điều chỉnh vị trí của hình ảnh
                left: 0.0,
                child: Container(
                  height: 60,
                  width:
                      80, // Makes the container take the full width of the screen
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
