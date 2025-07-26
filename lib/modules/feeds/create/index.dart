import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/feeds/create/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';

class FeedsCreate extends StatefulWidget {
  const FeedsCreate({super.key});

  @override
  State<FeedsCreate> createState() => _FeedsCreateState();
}

class _FeedsCreateState extends State<FeedsCreate>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();

  String errorMessage = '';
  final Map<String, dynamic> formData = {
    'singerId': FamousPeople.singerId,
    'message': '',
  };

  final Map<String, dynamic> ui = {
    'isSubmitting': false,

    // Info account to create
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
    _messageController.addListener(_validateInputs);

    super.initState();
  }

  void _validateInputs() {
    setState(() {
      formData['message'] = _messageController.text;
    });
  }

  void _onSubmit() async {
    if (_messageController.text.isEmpty) return;

    setState(() {
      ui['isSubmitting'] = true;
    });
    try {
      final data = await postDataFeeds(context, formData);
      if (data['code'] == ResStatus.success) {
        if (data != null &&
            data['data'] != null &&
            data['data']['isSuccess'] != null &&
            data['data']['isSuccess'] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Created successfully')));

          // Navigator.pop(context, formData); // Quay lại trang trước đó
          Navigator.pop(context, 'need_refresh'); // Quay lại trang trước đó
        }
      } else {
        // Trả lỗi
        setState(() {
          errorMessage = data['error']![0]!['message']!;
        });
      }
    } catch (e) {
      print('Lỗi trả về :$e');
    } finally {
      setState(() {
        ui['isSubmitting'] = false;
      });
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
        child: _buildBody(),
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
      title: const Text(
        'Post',
        style: AppStyles.titleLargeBold,
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: ui['isSubmitting']
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 2.0,
                  ),
                )
              : const Icon(Icons.send, color: Colors.blue),
          onPressed: ui['isSubmitting']
              ? null
              : _onSubmit, // Disable button when loading
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        maxLines: null,
        decoration: InputDecoration(
          labelText: 'Enter your thought or ask anything ...',
          hintStyle: AppStyles.bodyExtraMediumRegular.copyWith(
            color: AppColors.greyDivider,
          ),
          border: InputBorder.none,
        ),
        controller: _messageController,
      ),
    );
  }
}
