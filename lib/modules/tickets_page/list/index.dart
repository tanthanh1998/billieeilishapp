import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_app/apis/common/auth_provider.dart';
import 'package:music_app/apis/common/shared_preferences.dart';
import 'package:music_app/components/drawer/upgrade_to_premium.dart';
import 'package:music_app/components/request_login.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/tickets_page/detail/index.dart';
import 'package:music_app/modules/tickets_page/list/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/const.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TicketsList extends StatefulWidget {
  const TicketsList({super.key});

  @override
  State<TicketsList> createState() => _TicketsListState();
}

class _TicketsListState extends State<TicketsList>
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

  void _checkToken() async {
    if (await checkTokenExists()) {
      // Thực hiện hành động nếu token tồn tại
      _fetchItems();

      _scrollController.addListener(() async {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _fetchItems();
        }
      });
    } else {
      // Thực hiện hành động nếu token không tồn tại
      print('Token does not exist');
    }
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      queryParams['page'] = '$_page';

      final response = await fetchDataTicketsList(context, queryParams);
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
              'Tickets',
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
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                        "There aren't any Events on the horizon right now"))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == _items.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final ticket = _items[index];
                      return TicketCard(
                        formattedDate: ticket['formattedDate']!,
                        dayOfWeek: ticket['dayOfWeek']!,
                        formattedTime: ticket['formattedTime']!,
                        name: ticket['name']!,
                        venueLocation: ticket['venueLocation']!,
                        venueName: ticket['venueName']!,
                        venueCapaciy: ticket['venueCapaciy']!,
                        ticketLeft: ticket['ticketLeft']!,
                        url: ticket['url']!,
                      );
                    },
                  ),
          );
  }
}

class TicketCard extends StatelessWidget {
  final String formattedDate;
  final String dayOfWeek;
  final String formattedTime;

  final String name;
  final String venueLocation;
  final String venueName;
  final int venueCapaciy;
  final String ticketLeft;

  final String url;

  const TicketCard({
    super.key,
    required this.formattedDate,
    required this.dayOfWeek,
    required this.formattedTime,
    required this.name,
    required this.venueLocation,
    required this.venueName,
    required this.venueCapaciy,
    required this.ticketLeft,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    void onDirectTicketsDetail(url, venueLocation) {
      String isRoleUsePremium = SharedPreferencesManager().getRoleUsePremium();
      if (isRoleUsePremium.isEmpty) {
        showModalBottomSheetUpgradeToPremiumDrawer(context);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TicketsDetail(url: url, venueLocation: venueLocation),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () {
        onDirectTicketsDetail(url, venueLocation);
      },
      child: Container(
        margin: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
          bottom: 12.0,
        ),
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
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: AppStyles.titleSmallBold,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    dayOfWeek,
                    style: AppStyles.bodyItalic,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    formattedTime,
                    style: AppStyles.bodyItalic,
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
              const SizedBox(width: 16.0),
              CustomPaint(
                size: const Size(1, 120),
                painter: DashedLinePainter(),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppStyles.titleMediumBold,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/location.svg',
                          width: 14.0,
                          height: 14.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            venueLocation,
                            style: AppStyles.bodySmallRegular,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/venue.svg',
                          width: 14.0,
                          height: 14.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            venueName,
                            style: AppStyles.bodySmallRegular,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/tickets.svg',
                          width: 14.0,
                          height: 14.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '$venueCapaciy tickets $ticketLeft',
                          style: AppStyles.bodySmallSemi,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    var max = size.height;
    var dashHeight = 5.0;
    var dashSpace = 4.0;
    double startY = 0;

    while (startY < max) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 8.0,
              bottom: 12.0,
            ),
            color: Colors.white,
            elevation: 1.0,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '======',
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '=====',
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '=====',
                      ),
                      SizedBox(height: 12.0),
                    ],
                  ),
                  const SizedBox(width: 16.0),
                  CustomPaint(
                    size: const Size(1, 120),
                    painter: DashedLinePainter(),
                  ),
                  const SizedBox(width: 16.0),
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '================',
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16.0),
                            SizedBox(width: 8.0),
                            Text('================'),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16.0),
                            SizedBox(width: 8.0),
                            Text('================'),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16.0),
                            SizedBox(width: 8.0),
                            Text('================'),
                          ],
                        ),
                        SizedBox(height: 12.0),
                      ],
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
