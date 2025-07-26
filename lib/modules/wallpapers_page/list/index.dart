import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/components/upgrade_to_premium.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/wallpapers_page/detail/index.dart';
import 'package:music_app/modules/wallpapers_page/list/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WallpapersList extends StatefulWidget {
  final String title;
  final int wallpaperCollectionId;
  const WallpapersList({
    super.key,
    required this.wallpaperCollectionId,
    required this.title,
  });

  @override
  State<WallpapersList> createState() => _WallpapersListState();
}

class _WallpapersListState extends State<WallpapersList>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  final Map<String, dynamic> queryParams = {
    'wallpaperCollectionId': '5',
    'limit': '10',
    'page': '1',
  };
  final List<dynamic> _items = [];
  bool _isLoadingMore = false;

  bool _hasMoreData = true;
  int _page = 1;
  bool _skeletonEnabled = false;

  @override
  void initState() {
    super.initState();

    queryParams['wallpaperCollectionId'] = '${widget.wallpaperCollectionId}';

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

      final response = await fetchDataWallpapersList(context, queryParams);
      setState(() {
        if (response['data'].isEmpty) {
          _hasMoreData = false; // No more data to load
        } else {
          _items.addAll(response['data']);
          _page++;
        }
        _skeletonEnabled = true;
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
    });
    await _fetchItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _downloadImage(imageUrl) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await _requestStoragePermission();
    }

    FileDownloader.downloadFile(
      url: imageUrl,
      onProgress: (name, progress) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image is downloading!')),
        );
      },
      onDownloadCompleted: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo downloaded successfully!')),
        );
      },
    );
  }

  void _onDirectUpgradeToPremium() {
    openFullScreenUpgradeToPremiumDrawer(context);
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
      title: Text(
        widget.title,
        style: AppStyles.title1Semi,
      ),
      centerTitle: true,
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
                : GridView.count(
                    crossAxisCount: 1, // Number of _items per row
                    childAspectRatio: 2,
                    children: _items.map(
                      (item) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to the detail page when an image is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WallpapersDetail(
                                    imageUrl: item['imageLink']!,
                                    text: item['imageLink']!),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              // Image with dark overlay
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(item['imageLink']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Text on top of the image
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment
                                    .bottomCenter, // Text nằm dưới cùng
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.white,
                                    //     borderRadius:
                                    //         BorderRadius.circular(30.0),
                                    //     gradient: const LinearGradient(
                                    //       colors: [
                                    //         Color.fromRGBO(39, 233, 157, 1),
                                    //         Color.fromRGBO(39, 227, 245, 1),
                                    //       ],
                                    //       begin: Alignment.topLeft,
                                    //       end: Alignment.bottomRight,
                                    //     ),
                                    //   ),
                                    //   child: InkWell(
                                    //     onTap: () {
                                    //       _onDirectUpgradeToPremium();
                                    //     },
                                    //     borderRadius:
                                    //         BorderRadius.circular(30.0),
                                    //     child: const Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.center,
                                    //       children: [
                                    //         PremiumTag(
                                    //           text: 'Premium',
                                    //         )
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    IconButton(
                                      icon: SvgPicture.asset(
                                        'assets/images/svg/download.svg',
                                        width: 30.0,
                                        height: 30.0,
                                      ),
                                      onPressed: () {
                                        _downloadImage(item['imageLink']);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
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
      child: GridView.builder(
        itemCount: 3,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Số ô trên mỗi hàng
          crossAxisSpacing: 1.0, // Khoảng cách ngang giữa các ô
          mainAxisSpacing: 1.0, // Khoảng cách dọc giữa các ô
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0), // Bo tròn các góc
            child: AspectRatio(
              aspectRatio: 1, // Đảm bảo các ô có tỷ lệ vuông vắn
              child: Stack(
                alignment:
                    Alignment.bottomCenter, // Đặt text ở dưới cùng của ảnh
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
