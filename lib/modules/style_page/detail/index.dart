import 'package:flutter/material.dart';
import 'package:music_app/components/widgets/network_aware_widget.dart';
import 'package:music_app/modules/style_page/detail/api.dart';
import 'package:music_app/styles/custom_text.dart';
import 'package:music_app/utils/mixins.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StyleDetail extends StatefulWidget {
  final String title;
  final String image;
  final int styleCollectionDetailId;

  const StyleDetail({
    super.key,
    required this.image,
    required this.styleCollectionDetailId,
    required this.title,
  });

  @override
  State<StyleDetail> createState() => _StyleDetailState();
}

class _StyleDetailState extends State<StyleDetail>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final Map<String, dynamic> queryParams = {
    'styleCollectionDetailId': '',
    'page': '1',
  };
  final List<dynamic> _items = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _skeletonEnabled = false;

  @override
  void initState() {
    super.initState();

    _fetchItems();
  }

  Future<void> _fetchItems() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      queryParams['styleCollectionDetailId'] =
          '${widget.styleCollectionDetailId}';

      final response = await fetchDataStyleAccessoryList(context, queryParams);

      setState(() {
        if (response['data'].isEmpty) {
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        widget.title,
        style: AppStyles.title1Semi,
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                widget.image,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 300.0,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: !_skeletonEnabled
                ? const SkeletonWidget()
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                            "There aren't any Events on the horizon right now"))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _items.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _items.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final item = _items[index];
                          return _buildListItem(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                item['image'],
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 32.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      style: AppStyles.bodySmallSemi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      formatCurrency(item['price']),
                      style: AppStyles.bodySmallSemi,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 100.0,
                      width: 100.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 32.0),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('=============== ==============='),
                          Text('=============== ==============='),
                          SizedBox(height: 4.0),
                          Text('==============='),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          );
        },
      ),
    );
  }
}
