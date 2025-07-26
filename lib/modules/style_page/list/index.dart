import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/style_page/detail/index.dart';
import 'package:music_app/modules/style_page/list/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StyleList extends StatefulWidget {
  final String imageUrl;
  final String text;
  final int styleCollectionId;

  const StyleList({
    super.key,
    required this.imageUrl,
    required this.text,
    required this.styleCollectionId,
  });

  @override
  State<StyleList> createState() => _StyleListState();
}

class _StyleListState extends State<StyleList> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, dynamic> queryParams = {
    'styleCollectionId': '1',
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
    _fetchItems();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // _fetchItems();
      }
    });
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      queryParams['styleCollectionId'] = '${widget.styleCollectionId}';
      queryParams['page'] = '$_page';

      final response = await fetchDataStyleList(context, queryParams);

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
      // queryParams['page'] = '$_page';
      _hasMoreData = true; // Reset the flag
    });
    await _fetchItems();
  }

  void _onDirectStyleDetail(item) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StyleDetail(
          image: item['image'],
          styleCollectionDetailId: item['id'],
          title: item['title'],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
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
        widget.text,
        style: AppStyles.title1Semi,
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return !_skeletonEnabled
        ? const SkeletonWidget()
        : RefreshIndicator(
            onRefresh: _refresh,
            child: !_skeletonEnabled
                ? const SkeletonWidget()
                : _items.isEmpty
                    ? const Center(child: Text("No data"))
                    : GridView.builder(
                        itemCount: _items.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, // 2 cột
                          crossAxisSpacing: 6.0, // Khoảng cách ngang giữa các ô
                          mainAxisSpacing: 16.0, // Khoảng cách dọc giữa các ô
                        ),
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return GestureDetector(
                            onTap: () {
                              // Chuyển đến trang chi tiết khi nhấn vào ảnh
                              _onDirectStyleDetail(item);
                            },
                            child: Container(
                              width: MediaQuery.of(context)
                                  .size
                                  .width, // Khung ảnh ngang bằng màn hình
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Stack(
                                children: [
                                  Image.network(
                                    item['image']!,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      height: 86.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(
                                                0.5), // Màu đen mờ ở dưới
                                            Colors.grey.withOpacity(
                                                0.0), // Màu xám mờ ở trên
                                          ],
                                          stops: const [
                                            0.1737,
                                            1.0
                                          ], // Vị trí màu gradient tương tự CSS
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 48.0,
                                      ), // Padding cho text
                                      child: Text(
                                        item['title']!,
                                        maxLines: 1, // Giới hạn tối đa 2 dòng
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppStyles.titleSmallBold.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
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

class SkeletonWidget extends StatelessWidget {
  const SkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      ignoreContainers: true,
      enabled: true,
      enableSwitchAnimation: true,
      child: GridView.builder(
        itemCount: 2,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Số ô trên mỗi hàng
          crossAxisSpacing: 6.0, // Khoảng cách ngang giữa các ô
          mainAxisSpacing: 12.0, // Khoảng cách dọc giữa các ô
        ),
        padding: const EdgeInsets.only(left: 16, right: 16),
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
