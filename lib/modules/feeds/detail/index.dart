import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/feeds/detail/api.dart';
import 'package:music_app/modules/feeds/list/api.dart';
import 'package:music_app/modules/feeds/mixins.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FeedsDetail extends StatefulWidget {
  final String nickName;
  final String content;
  final int numLike;
  final int numComment;
  final int feedsId;
  final int avatar;
  final int like;

  const FeedsDetail(
      {super.key,
      required this.nickName,
      required this.content,
      required this.numLike,
      required this.numComment,
      required this.feedsId,
      required this.avatar,
      required this.like});

  @override
  State<FeedsDetail> createState() => _FeedsDetailState();
}

class _FeedsDetailState extends State<FeedsDetail>
    with TickerProviderStateMixin {
  final Map<String, dynamic> queryParams = {
    'feedsId': null,
  };
  bool _skeletonEnabled = false;
  final List<dynamic> _items = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  final TextEditingController _messageController = TextEditingController();
  final Map<String, dynamic> formData = {
    'feedsId': null,
    'like': null,
    'message': '',
  };

  final Map<String, dynamic> ui = {
    'nickName': '',
    'content': '',
    'numLike': null,
    'numComment': null,
    'feedsId': null,
    'avatar': null,
    'like': null,
  };

  @override
  void initState() {
    super.initState();

    queryParams['feedsId'] = formData['feedsId'] = widget.feedsId;

    ui['nickName'] = widget.nickName;
    ui['content'] = widget.content;
    ui['numLike'] = widget.numLike;
    ui['numComment'] = widget.numComment;
    ui['feedsId'] = widget.feedsId;
    ui['avatar'] = widget.avatar;
    ui['like'] = widget.like;

    _fetchItems();
    _messageController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      formData['message'] = _messageController.text;
    });
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await fetchDataFeedsCommentList(context, queryParams);
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

  Future<void> _onCreateFeedsComment() async {
    if (_messageController.text.isEmpty) return;
    try {
      setState(() {
        _skeletonEnabled = false;
      });

      final data = await postDataCreateFeedsComment(context, formData);
      if (data['code'] == ResStatus.success) {
        if (data != null &&
            data['data'] != null &&
            data['data']['isSuccess'] != null &&
            data['data']['isSuccess'] == 1) {
          // Chỗ này hiển thị data ảo vừa tạo lên đầu danh sách

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Created successfully')));

          String? jsonData = SharedPreferencesManager().getProfile();
          if (jsonData.isNotEmpty) {
            Map<String, dynamic> profile = jsonDecode(jsonData);
            setState(() {
              _items.insert(0, {
                "nickName": profile['nickname'],
                "avatar": profile['gender'],
                "content": formData['message'],
                "createTime": getCurrentTimeFormatted()
              }); // Đẩy item lên đầu mảng
            });
          }

          formData['message'] = '';
          _messageController.clear(); // Xóa input sau khi thêm
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _skeletonEnabled = true;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _skeletonEnabled = false;
      _items.clear();
      _hasMoreData = true; // Reset the flag
      _messageController.clear();
    });
    await _fetchItems();
  }

  void _onSubmitLike() async {
    try {
      setState(() {
        ui['like'] = widget.like == 0 ? 1 : 0;

        if (ui['like'] == 1) {
          ui['numLike']++;
        } else {
          ui['numLike']--;
        }

        // Gắn giá trị vào formData để call API update
        formData['like'] = ui['like'];
      });

      final data = await postDataLikeFeeds(context, formData);
      if (data['code'] == ResStatus.success) {
        if (data != null &&
            data['data'] != null &&
            data['data']['isSuccess'] != null &&
            data['data']['isSuccess'] == 1) {}
      } else {
        ui['like'] = !formData['like'];
      }
    } catch (e) {
      print('Lỗi trả về :$e');
    } finally {
      // Reset lại sau khi đã gọi API
      formData['feedsId'] = null;
      formData['like'] = null;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child: Column(
          children: [
            _buildContent(),
            Expanded(
              child: _buildBody(),
            ),
          ],
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
      title: Text(
        widget.nickName,
        style: AppStyles.titleLargeBold,
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: Colors.black), // Thay đổi màu sắc icon nếu cần
        onPressed: () {
          // Trả về 'need_refresh' khi nhấn nút back
          // Navigator.pop(context, 'need_refresh');
          Navigator.pop(context, ui);
        },
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: !_skeletonEnabled
          ? const SkeletonWidget()
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: ListView.builder(
                    itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _items.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final feedsListData = _items[index];
                      return _buildListItem(feedsListData);
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.whiteShadowColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            hintText: 'Comments',
                            hintStyle: AppStyles.bodyMediumRegular,
                            contentPadding: const EdgeInsets.fromLTRB(
                              16.0,
                              16.0,
                              0,
                              0,
                            ),
                            // Thêm icon gửi vào bên trong TextField
                            suffixIcon: IconButton(
                              onPressed: _onCreateFeedsComment,
                              icon: const Icon(Icons.send, color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.content,
            style: AppStyles.bodyExtraMediumRegular,
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _onSubmitLike();
                },
                child: Column(
                  children: [
                    SvgPicture.asset(
                      ui['like'] == 1
                          ? 'assets/images/svg/like.svg'
                          : 'assets/images/svg/un_like.svg',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                '${ui['numLike']}',
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
                '${ui['numComment']}',
                style: AppStyles.bodyItalic,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Divider(
            color: AppColors.greyDivider,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(dynamic feedsListData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
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
            ],
          ),
        ),
        const Divider(
          color: AppColors.greyDivider,
          thickness: 0.5,
          indent: 32.0,
          endIndent: 32.0,
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
        itemCount: 5,
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
