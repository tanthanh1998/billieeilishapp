import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_app/modules/albums_page/list/index.dart';
import 'package:music_app/modules/feeds/list/index.dart';
import 'package:music_app/modules/more_page/list/index.dart';
import 'package:music_app/modules/news_page/list/index.dart';
import 'package:music_app/modules/style_page/overview/index.dart';
import 'package:music_app/modules/tickets_page/list/index.dart';
import 'package:music_app/modules/wallpapers_page/overview/index.dart';

class Member extends StatefulWidget {
  const Member({super.key});

  @override
  State<Member> createState() => _MemberState();
}

class Menu {
  static const int album = 0;
  static const int news = 1;
  static const int wallpaper = 2;
  static const int social = 3;
  static const int fashion = 4;
  static const int ticket = 5;
  static const int more = 6;
}

class _MemberState extends State<Member> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<MoreListState> _moreListKey = GlobalKey<MoreListState>();

  final List<Widget?> _children =
      List.filled(7, null); // Khởi tạo tất cả widget là null

  int _selectedIndex = Menu.album; // Mặc định ở trang HomePage
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Gọi lại API khi chọn "More"
      if (index == Menu.more && _moreListKey.currentState != null) {
        _moreListKey.currentState!
            .loadProfileData(); // Gọi lại API trong MoreList
      }

      // Chỉ khởi tạo widget khi người dùng bấm vào
      if (_children[index] == null) {
        _children[index] = _createPage(index);
      }
    });
  }

  Widget _createPage(int index) {
    switch (index) {
      case Menu.album:
        return const AlbumsList();
      case Menu.news:
        return const NewsList();
      // return const AdList();
      case Menu.wallpaper:
        return const WallpapersOverview();
      case Menu.social:
        // return const FollowsList();
        return const FeedsList();
      case Menu.fashion:
        return const StyleOverview();
      case Menu.ticket:
        return const TicketsList();
      case Menu.more:
        // return const MoreList();
        return MoreList(key: _moreListKey); // Truyền GlobalKey vào MoreList
      default:
        return const AlbumsList();
    }
  }

  @override
  void initState() {
    super.initState();

    // Khởi tạo trang đầu tiên (Album)
    _children[Menu.album] = const AlbumsList();

    // Sau khi vào trang Member thì chỗ này sẽ chạy đầu tiên
    // // Xử lý tin nhắn khi ứng dụng đang chạy và nằm trên foreground
    // FirebaseApi.onMessageForeGround(context);
    // // End Xử lý tin nhắn khi ứng dụng đang chạy và nằm trên foreground
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Sử dụng IndexedStack để giữ trạng thái không load lại dữ liệu page
      body: IndexedStack(
        index: _selectedIndex,
        // children: _children,
        children:
            _children.map((widget) => widget ?? const SizedBox()).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[50], // Đặt màu nền là màu xám nhạt
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/svg/album.svg',
              color: _selectedIndex == Menu.album ? Colors.amber[600] : null,
              width: 24,
              height: 24,
            ),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/svg/news.svg',
              color: _selectedIndex == Menu.news ? Colors.amber[600] : null,
              width: 24,
              height: 24,
            ),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/svg/wallpaper.svg',
              color:
                  _selectedIndex == Menu.wallpaper ? Colors.amber[600] : null,
              width: 24,
              height: 24,
            ),
            label: 'Wallpaper',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/svg/social.svg',
              color: _selectedIndex == Menu.social ? Colors.amber[600] : null,
              width: 24,
              height: 24,
            ),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/svg/fashion.svg',
              color: _selectedIndex == Menu.fashion ? Colors.amber[600] : null,
              width: 24,
              height: 24,
            ),
            label: 'Fashion',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/svg/ticket.svg',
              color: _selectedIndex == Menu.ticket ? Colors.amber[600] : null,
              width: 24,
              height: 24,
            ),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/svg/more.svg',
              color: _selectedIndex == Menu.more ? Colors.amber[600] : null,
              width: 24,
              height: 24,
            ),
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[900],
        showSelectedLabels: false, // Ẩn label khi item được chọn
        showUnselectedLabels: false, // Ẩn label khi item không được chọn
        onTap: _onItemTapped,
      ),
    );
  }
}
