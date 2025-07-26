import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/apis/common/auth_provider.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/request_login.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/feeds/create/index.dart';
import 'package:music_app/modules/feeds/detail/index.dart';
import 'package:music_app/modules/feeds/list/api.dart';
import 'package:music_app/modules/feeds/mixins.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FeedsList extends StatefulWidget {
  const FeedsList({super.key});

  @override
  State<FeedsList> createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> with TickerProviderStateMixin {
  bool _skeletonEnabled = false;
  final List<dynamic> _items = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  String errorMessage = '';
  final Map<String, dynamic> formData = {
    'feedsId': null,
    'like': null,
  };

  final Map<String, dynamic> queryParams = {
    'singerId': FamousPeople.singerId,
  };

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
    }
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await fetchDataFeedsList(context, queryParams);

      setState(() {
        if (response.isEmpty) {
          _hasMoreData = false; // No more data to load
        } else {
          _items.addAll(response['data']);
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

  void _onSubmitLike(int id) async {
    try {
      int index = _items.indexWhere((item) => item['id'] == id);
      setState(() {
        if (index != -1) {
          _items[index]['like'] = _items[index]['like'] == 0 ? 1 : 0;

          if (_items[index]['like'] == 1) {
            _items[index]['numLike']++;
          } else {
            _items[index]['numLike']--;
          }

          // Gắn giá trị vào formData để call API update
          formData['like'] = _items[index]['like'];
          formData['feedsId'] = _items[index]['id'];
        }
      });

      final data = await postDataLikeFeeds(context, formData);
      if (data['code'] == ResStatus.success) {
        if (data != null &&
            data['data'] != null &&
            data['data']['isSuccess'] != null &&
            data['data']['isSuccess'] == 1) {
          print('Đã submit like thành công');
        }
      } else {
        _items[index]['like'] = !formData['like'];
      }
    } catch (e) {
      print('Lỗi trả về :$e');
    } finally {
      // Reset lại sau khi đã gọi API
      formData['feedsId'] = null;
      formData['like'] = null;
    }
  }

  void _onDirectFeedsDetail(feedsListData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedsDetail(
          nickName: feedsListData['nickName'],
          content: feedsListData['content'],
          numLike: feedsListData['numLike'],
          numComment: feedsListData['numComment'],
          feedsId: feedsListData['id'],
          avatar: feedsListData['avatar'],
          like: feedsListData['like'],
        ),
      ),
    );

    // Nếu trang chi tiết trả về 'need_refresh', gọi API để refresh dữ liệu
    if (result != null) {
      int index = _items.indexWhere((item) => item['id'] == result['feedsId']);
      setState(() {
        if (index != -1) {
          _items[index]['like'] = result['like'];
          _items[index]['numLike'] = result['numLike'];
          _items[index]['numComment'] = result['numComment'];
        }
      });
    }
  }

  void _onDirectFeedsCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeedsCreate()),
    );

    // Nếu trang chi tiết trả về 'need_refresh', gọi API để refresh dữ liệu
    if (result == 'need_refresh') {
      _refresh();
    }
    // ======= KHÚC NÀY bên dưới THÌ KHÔNG CÓ ID NÊN KHÔNG TẠO DỮ LIỆU GIẢ LẬP ĐƯỢC =======

    // if (result != null) {
    // String? jsonData = SharedPreferencesManager().getProfile();
    // if (jsonData.isNotEmpty) {
    //   Map<String, dynamic> profile = jsonDecode(jsonData);
    //   setState(() {
    //     _items.insert(0, {
    //       "nickName": profile['nickname'],
    //       "avatar": profile['gender'],
    //       "content": result['message'],
    //       "createTime": getCurrentTimeFormatted(),
    //       "like": 0,
    //       "numLike": 0,
    //       "numComment": 0,
    //     }); // Đẩy item lên đầu mảng
    //   });
    // }
    // }
  }

  Future<void> _refresh() async {
    setState(() {
      formData['feedsId'] = null;
      formData['like'] = null;

      _reset();
    });
    await _fetchItems();
  }

  void _reset() {
    _skeletonEnabled = false;
    _items.clear();
    _hasMoreData = true; // Reset the flag
  }

  @override
  void dispose() {
    _reset();

    super.dispose();
  }

  // Xử lý khi quay lại từ LoginScreen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Provider.of<AuthProvider>(context).isAuthenticated) {
      _reset();

      _checkToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(authProvider.isAuthenticated),
      body: NetworkAwareBody(
        child:
            authProvider.isAuthenticated ? _buildBody() : const RequestLogin(),
      ),
    );
  }

  AppBar _buildAppBar(isAuthenticated) {
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
              'Feeds',
              style: AppStyles.title1Semi,
            ),
          ),
        ],
      ),
      actions: isAuthenticated
          ? <Widget>[
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () {
                  _onDirectFeedsCreate();
                },
              ),
            ]
          : null,
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
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: const Center(
                              child: Text("No data"),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == _items.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final feedsListData = _items[index];
                          return _buildListItem(feedsListData);
                        },
                      ),
          );
  }

  Widget _buildListItem(dynamic feedsListData) {
    return Column(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            _onDirectFeedsDetail(feedsListData);
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image(
                      image: AssetImage(getAvatar(feedsListData['avatar'])),
                      width: 38.0,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedsListData['nickName'],
                          style: AppStyles.bodyLargeSemi,
                        ),
                        Text(
                          timeAgo(feedsListData['createTime']),
                          style: AppStyles.bodySmallRegular.copyWith(
                            color: AppColors.greyItalicColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  feedsListData['content'],
                  style: AppStyles.bodyExtraMediumRegular,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _onSubmitLike(feedsListData['id']);
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            feedsListData['like'] == 1
                                ? 'assets/images/svg/like.svg'
                                : 'assets/images/svg/un_like.svg',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      '${feedsListData['numLike']}',
                      style: AppStyles.bodyItalic,
                    ),
                    const SizedBox(width: 14.0),
                    Column(
                      children: [
                        SvgPicture.asset('assets/images/svg/comment.svg'),
                      ],
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      '${feedsListData['numComment']}',
                      style: AppStyles.bodyItalic,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: AppColors.greyDivider,
          thickness: 0.5,
          indent: 26.0,
          endIndent: 26.0,
        ),
      ],
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
