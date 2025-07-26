import 'package:flutter/material.dart';
import 'package:music_app/apis/common/auth_provider.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/request_login.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/style_page/list/index.dart';
import 'package:music_app/modules/style_page/overview/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StyleOverview extends StatefulWidget {
  const StyleOverview({super.key});

  @override
  State<StyleOverview> createState() => _StyleOverviewState();
}

class _StyleOverviewState extends State<StyleOverview>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<String, dynamic> queryParams = {
    'singerId': FamousPeople.singerId,
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
    _checkToken();
  }

  Future<void> _checkToken() async {
    String token = SharedPreferencesManager().getToken();

    if (token != '') {
      // Gọi API & Hiển thị dữ liệu hiện tại
      _fetchItems();

      _scrollController.addListener(() async {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _fetchItems();
        }
      });
    }
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      queryParams['page'] = '$_page';

      final response = await fetchDataStyleOverview(context, queryParams);
      setState(() {
        if (response['data'].isEmpty) {
          _hasMoreData = false; // No more data to load
        } else {
          _items.addAll(response['data']);
          _page++;
        }
        _skeletonEnabled = true;

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
      _page = 1;
      queryParams['page'] = '$_page';
      _hasMoreData = true; // Reset the flag
    });
    await _fetchItems();
  }

  void _onDirectStyleList(item) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StyleList(
          imageUrl: item['image']!,
          text: item['title']!,
          styleCollectionId: item['id']!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  // Xử lý khi quay lại từ LoginScreen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<AuthProvider>(context).isAuthenticated) {
      _checkToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child:
            authProvider.isAuthenticated ? _buildBody() : const RequestLogin(),
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
            top: 16.0,
            left: 12.0,
            child: Container(
              width: 54.0,
              height: 12.0,
              color: AppColors.orangeColor,
            ),
          ),
          const SizedBox(
            width: 200,
            child: Text(
              'Style',
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
            onRefresh: _refresh,
            child: !_skeletonEnabled
                ? const SkeletonWidget()
                : _items.isEmpty
                    ? const Center(child: Text("No data"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _items.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Số ô trên mỗi hàng
                          crossAxisSpacing:
                              12.0, // Khoảng cách ngang giữa các ô
                          mainAxisSpacing: 12.0, // Khoảng cách dọc giữa các ô
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return GestureDetector(
                            onTap: () {
                              _onDirectStyleList(item);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: AspectRatio(
                                aspectRatio:
                                    1, // Đảm bảo các ô có tỷ lệ vuông vắn
                                child: Stack(
                                  children: [
                                    Image.network(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                      width: double
                                          .infinity, // Đảm bảo ảnh lấp đầy chiều rộng
                                      height: double.infinity,
                                    ),
                                    // Nền tối ở dưới phần text
                                    Container(
                                      color: AppColors
                                          .greyShadowColor, // Nền tối với độ mờ
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                        top: 20.0,
                                        bottom: 20.0,
                                      ),
                                      alignment: Alignment
                                          .bottomCenter, // Text nằm dưới cùng
                                      child: Text(
                                        item['title']!,
                                        style: AppStyles.titleExtraLargeBold
                                            .copyWith(
                                          color: Colors.white, // Chữ màu trắng
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
        padding: const EdgeInsets.all(16.0),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số ô trên mỗi hàng
          crossAxisSpacing: 12.0, // Khoảng cách ngang giữa các ô
          mainAxisSpacing: 12.0, // Khoảng cách dọc giữa các ô
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20.0), // Bo tròn các góc
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
