import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/more_page/downloader/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';

class Downloader extends StatefulWidget {
  const Downloader({super.key});

  @override
  State<Downloader> createState() => _DownloaderState();
}

class _DownloaderState extends State<Downloader> {
  final Map<String, dynamic> queryParams = {
    'singerId': FamousPeople.singerId,
  };

  void _onDowloadMusic() {
    print('_onDowloadMusic');
  }

  void _onDowloadAllMusic() async {
    try {
      final data = await fetchDataDownloadAllMusic(context, queryParams);

      if (data['code'] == ResStatus.success) {}
    } catch (e) {
      print('Lỗi trả về :$e');
    }
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
      title: const Text(
        'Downloader',
        style: AppStyles.titleLargeBold,
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        // Nội dung chính của bạn được đặt trong SingleChildScrollView để cuộn khi cần thiết
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white, // Màu nền của Container
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000), // Màu shadow (0x14 là độ mờ)
                      offset: Offset(0, 2), // Độ dịch chuyển của shadow (x,y)
                      blurRadius: 15, // Độ mờ của shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20.0), // Bo góc nếu cần
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    hintText: "Input the link wants to download",
                    hintStyle: AppStyles.bodyMediumRegular.copyWith(
                      color: AppColors.greyExtraLightColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Nút Download được đặt cố định ở dưới cùng của màn hình
        Positioned(
          bottom: 0, // Position the row at the bottom
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52.0,
              child: FilledButton.tonal(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  // Xử lý sự kiện khi nhấn nút Download
                  _onDowloadMusic();
                },
                child: Text(
                  'Download',
                  style: AppStyles.titleLargeBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
