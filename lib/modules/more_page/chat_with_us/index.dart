import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/more_page/chat_with_us/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatWithUs extends StatefulWidget {
  const ChatWithUs({super.key});

  @override
  State<ChatWithUs> createState() => _ChatWithUsState();
}

class _ChatWithUsState extends State<ChatWithUs> {
  bool isButtonEnabled = false;
  final TextEditingController _contentController = TextEditingController();
  final List<dynamic> _items = [];
  final Map<String, dynamic> formData = {'message': ''};
  bool _skeletonEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _contentController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _contentController.text.isNotEmpty;
      formData['message'] = _contentController.text;
    });
  }

  Future<void> _fetchItems() async {
    try {
      final data = await fetchDataChatWithUs(context);
      if (data['code'] == ResStatus.success) {
        setState(() {
          _items.addAll(data['data']);
        });

        _skeletonEnabled = true;
      }
    } catch (error) {
      debugPrint('Error fetching items: $error');
    }
  }

  Future<void> _onReplyMsg() async {
    try {
      final data = await postDataSendChat(context, formData);
      if (data['code'] == ResStatus.success && data['data']['isSuccess'] == 1) {
        // Tạo đối tượng mới cần thêm
        Map<String, dynamic> newItem = {
          "message": formData['message'],
          "hostReply": 0,
        };

        setState(() {
          _items.add(newItem); // Push data mới vào cuối mảng
        });
        _reset();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _reset() {
    setState(() {
      formData['message'] = '';
      _contentController.clear();
    });
    // Đóng bàn phím
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: NetworkAwareBody(
        child: Stack(
          children: [
            !_skeletonEnabled
                ? const SkeletonWidget()
                : _items.isEmpty
                    ? const Center(child: Text("No data"))
                    : MessageList(items: _items),
            BottomInputBar(
              contentController: _contentController,
              isButtonEnabled: isButtonEnabled,
              onReplyMsg: _onReplyMsg,
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
      title: const Text('Chat with us', style: AppStyles.titleLargeBold),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: Colors.black), // Thay đổi màu sắc icon nếu cần
        onPressed: () {
          // Trả về 'need_refresh' khi nhấn nút back
          Navigator.pop(context, 'need_refresh');
        },
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  final List<dynamic> items;

  const MessageList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final message = items[index];
        return ChatMessage(
          message: message['message'],
          hostReply: message['hostReply'] == 1,
        );
      },
      padding: const EdgeInsets.only(bottom: 80),
    );
  }
}

class BottomInputBar extends StatelessWidget {
  final TextEditingController contentController;
  final bool isButtonEnabled;
  final VoidCallback onReplyMsg;

  const BottomInputBar({
    super.key,
    required this.contentController,
    required this.isButtonEnabled,
    required this.onReplyMsg,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.whiteShadowColor,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: TextField(
              controller: contentController,
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
                hintText: 'Enter your content...',
                hintStyle: AppStyles.bodyMediumRegular,
                contentPadding: const EdgeInsets.fromLTRB(
                  16.0, // left padding
                  16.0, // top padding
                  0, // right padding (cho phần icon)
                  0, // bottom padding
                ),
                // Thêm icon gửi vào bên trong TextField
                suffixIcon: IconButton(
                  onPressed: isButtonEnabled ? onReplyMsg : null,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool hostReply;

  const ChatMessage({
    super.key,
    required this.message,
    required this.hostReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Align(
        alignment: hostReply ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: hostReply ? AppColors.orangeBg : AppColors.greyBg,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Text(
            message,
            style: AppStyles.bodyExtraSmallRegular,
          ),
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
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Align(
              alignment:
                  index == 1 ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: index == 1 ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                child: Text(
                  '=================',
                  style: TextStyle(
                    color: index == 1 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
        padding: const EdgeInsets.only(bottom: 80),
      ),
    );
  }
}
