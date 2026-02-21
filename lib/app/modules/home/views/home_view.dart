import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../data/models/billboard_item.dart';
import '../../../data/models/billboard_map_item.dart';
import '../../../data/models/brand_item.dart';
import '../../../data/models/province_model.dart';
import '../../../data/models/testimonial_item.dart';
import '../../../widgets/app_page_scaffold.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _mainBannerUrl =
      'http://tablo.ir/my_api/images/main%20banner%20desktop.jpg';
  static const _partyBannerUrl = 'http://tablo.ir/my_api/images/tablo-party.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 15, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Obx(() {
                    if (controller.isLoadingBillboards.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.billboardsError.value.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(controller.billboardsError.value),
                      );
                    }

                    return _BillboardsMap(
                      items: controller.billboardsWithLocation,
                    );
                  }),
                  const SizedBox(height: 38),
                  Text(
                    'محبوب ترین مناطق',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isLoadingProvinces.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.provincesError.value.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(controller.provincesError.value),
                      );
                    }

                    return SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.provinces.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final province = controller.provinces[index];
                          return _ProvinceCard(province: province);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      _mainBannerUrl,
                      fit: BoxFit.fitHeight,
                      errorBuilder: (_, __, ___) => const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                        child: Center(child: Text('خطا در بارگذاری بنر اصلی')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'تابلو پارتی',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isLoadingPartyBillboards.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.partyBillboardsError.value.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(controller.partyBillboardsError.value),
                      );
                    }

                    return SizedBox(
                      height: 350,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.partyBillboards.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _PartyBannerCard(imageUrl: _partyBannerUrl);
                          }

                          final item = controller.partyBillboards[index - 1];
                          return _PartyBillboardCard(item: item);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                  Text(
                    'برندهای همکار',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Obx(() {
                  //   final list = controller.brands;
                  //
                  //   return Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       _AutoBrandsRow(
                  //         brands: list,
                  //         moveRight: true,
                  //       ),
                  //       const SizedBox(height: 14),
                  //       _AutoBrandsRow(
                  //         brands: list,
                  //         moveRight: false,
                  //       ),
                  //       if (controller.isLoadingBrands.value)
                  //         const Padding(
                  //           padding: EdgeInsets.only(top: 10),
                  //           child: Center(child: CircularProgressIndicator()),
                  //         ),
                  //       if (controller.brandsError.value.isNotEmpty)
                  //         Padding(
                  //           padding: const EdgeInsets.only(top: 10),
                  //           child: Container(
                  //             width: double.infinity,
                  //             padding: const EdgeInsets.all(16),
                  //             decoration: BoxDecoration(
                  //               color: const Color(0xFFFFF1F2),
                  //               borderRadius: BorderRadius.circular(15),
                  //             ),
                  //             child: Text(controller.brandsError.value),
                  //           ),
                  //         ),
                  //     ],
                  //   );
                  // }),
                  const SizedBox(height: 40),
                  Text(
                    'نظرات مشتریان',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final isLoading = controller.isLoadingTestimonials.value;
                    final hasError = controller.testimonialsError.value.isNotEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 230,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.testimonials.isEmpty
                                ? 1
                                : controller.testimonials.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              if (controller.testimonials.isEmpty) {
                                return const _TestimonialCard(
                                  item: TestimonialItem(
                                    id: 'placeholder',
                                    companyName: 'نمونه',
                                    personName: 'کاربر نمونه',
                                    role: 'مدیر',
                                    quote:
                                        'در حال بارگذاری نظرات مشتریان هستیم. در صورت مشکل اتصال، کمی بعد دوباره تلاش کنید.',
                                    avatarUrl: '',
                                  ),
                                );
                              }

                              final item = controller.testimonials[index];
                              return _TestimonialCard(item: item);
                            },
                          ),
                        ),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(controller.testimonialsError.value),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartyBannerCard extends StatelessWidget {
  const _PartyBannerCard({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.fitHeight,
        errorBuilder: (_, __, ___) => const DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
          child: Center(child: Text('خطا در بارگذاری بنر تابلو پارتی')),
        ),
      ),
    );
  }
}

class _PartyBillboardCard extends StatelessWidget {
  const _PartyBillboardCard({required this.item});

  final BillboardItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 165,
                width: double.infinity,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                    child: Center(child: Icon(Icons.image_not_supported_outlined)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text('${item.city} | ${item.area}'),
                const SizedBox(height: 4),
                Text('ابعاد: ${item.dimensionLabel}'),
                const SizedBox(height: 4),
                Text('کد تابلو: ${item.code}'),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اجاره ماهانه: ${item.rentLabel}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'نورپردازی: ${item.lighting.isEmpty ? 'ثبت نشده' : item.lighting}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoBrandsRow extends StatefulWidget {
  const _AutoBrandsRow({
    required this.brands,
    required this.moveRight,
  });

  final List<BrandItem> brands;
  final bool moveRight;

  @override
  State<_AutoBrandsRow> createState() => _AutoBrandsRowState();
}

class _AutoBrandsRowState extends State<_AutoBrandsRow> {
  final _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 35), (_) {
      if (!_controller.hasClients) {
        return;
      }

      const delta = 1.2;
      final direction = widget.moveRight ? -delta : delta;
      final next = _controller.offset + direction;
      final max = _controller.position.maxScrollExtent;

      if (next <= 0) {
        _controller.jumpTo(max > 0 ? max : 0);
        return;
      }

      if (next >= max) {
        _controller.jumpTo(0);
        return;
      }

      _controller.jumpTo(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.brands.isEmpty
        ? const <BrandItem>[
            BrandItem(id: 'p1', brandName: 'نمونه', logoUrl: ''),
            BrandItem(id: 'p2', brandName: 'نمونه', logoUrl: ''),
            BrandItem(id: 'p3', brandName: 'نمونه', logoUrl: ''),
            BrandItem(id: 'p4', brandName: 'نمونه', logoUrl: ''),
          ]
        : widget.brands;

    return SizedBox(
      height: 66,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: items.length * 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index % items.length];
          return _BrandLogoCard(item: item);
        },
      ),
    );
  }
}

class _BrandLogoCard extends StatelessWidget {
  const _BrandLogoCard({required this.item});

  final BrandItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: item.logoUrl.isNotEmpty
          ? Image.network(
              item.logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                item.brandName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : Text(
              item.brandName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.item});

  final TestimonialItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '❞',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              item.quote,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.personName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.role} | ${item.companyName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: item.safeAvatarUrl.isNotEmpty
                      ? NetworkImage(item.safeAvatarUrl)
                      : null,
                  child: item.safeAvatarUrl.isEmpty
                      ? Icon(
                          Icons.person_outline,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProvinceCard extends StatelessWidget {
  const _ProvinceCard({required this.province});

  final ProvinceModel province;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              province.imageUrl,
              width: 150,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 110,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              province.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillboardsMap extends StatefulWidget {
  const _BillboardsMap({required this.items});

  final List<BillboardMapItem> items;

  @override
  State<_BillboardsMap> createState() => _BillboardsMapState();
}

class _BillboardsMapState extends State<_BillboardsMap> {
  static const _searchPreviewApi =
      'http://tablo.ir/my_api/cities/search_preview.php';

  final _searchController = TextEditingController();

  Timer? _searchDebounce;
  bool _isSearching = false;
  String _searchError = '';
  List<_SearchPreviewItem> _previewItems = const [];

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text('لوکیشن معتبر برای نمایش روی نقشه پیدا نشد.'),
      );
    }

    final query = _searchController.text.trim().toLowerCase();
    final filteredItems = query.isEmpty
        ? widget.items
        : widget.items.where((item) {
            final text = '${item.city} ${item.area} ${item.provinceId} ${item.id}'
                .toLowerCase();
            return text.contains(query);
          }).toList();

    final centerSource = filteredItems.isNotEmpty ? filteredItems : widget.items;
    final center = LatLng(centerSource.first.latitude, centerSource.first.longitude);
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 480,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 6,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tablo.rebuild',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 55,
                    size: const Size(44, 44),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(40),
                    maxZoom: 15,
                    markers: filteredItems
                        .map(
                          (item) => Marker(
                            point: LatLng(item.latitude, item.longitude),
                            width: 38,
                            height: 38,
                            child: GestureDetector(
                              onTap: () => _showBillboardInfo(context, item),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    builder: (context, markers) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 18,
              left: 22,
              right: 22,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(18),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'جستجو در تابلوها (شهر، کد، محور...)',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1D4ED8)),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            if (_searchController.text.trim().isNotEmpty)
              Positioned(
                top: 86,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFFE9ECEF),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'پیشنمایش نتایج',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                      ),
                      const SizedBox(height: 10),
                      if (_isSearching)
                        const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_searchError.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_searchError, textAlign: TextAlign.right),
                        )
                      else if (_previewItems.isEmpty)
                        const SizedBox(
                          height: 80,
                          child: Center(
                            child: Text('نتیجه‌ای برای پیش‌نمایش پیدا نشد.'),
                          ),
                        )
                      else
                        SizedBox(
                          height: 300,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _previewItems.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = _previewItems[index];
                              return _PreviewSearchCard(item: item);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {});

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadSearchPreview(value.trim());
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _previewItems = const [];
      _searchError = '';
      _isSearching = false;
    });
  }

  Future<void> _loadSearchPreview(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _previewItems = const [];
          _searchError = '';
          _isSearching = false;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = '';
    });

    try {
      final uri = Uri.parse(_searchPreviewApi).replace(
        queryParameters: {
          'q': query,
          'limit': '10',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        setState(() {
          _isSearching = false;
          _searchError = 'خطا در دریافت نتایج جست‌وجو (کد: ${response.statusCode})';
        });
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        setState(() {
          _isSearching = false;
          _searchError = 'پاسخ نامعتبر از سرور جست‌وجو.';
        });
        return;
      }

      final items = decoded['items'];
      if (decoded['success'] != true || items is! List) {
        setState(() {
          _isSearching = false;
          _searchError = decoded['message']?.toString() ?? 'جست‌وجو ناموفق بود.';
        });
        return;
      }

      final mapped = items
          .whereType<Map<String, dynamic>>()
          .map(_SearchPreviewItem.fromJson)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _previewItems = mapped;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _searchError = 'اتصال به سرویس جست‌وجو برقرار نشد.';
      });
    }
  }

  void _showBillboardInfo(BuildContext context, BillboardMapItem item) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مشخصات بیلبورد',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _InfoRow(title: 'شناسه', value: item.id),
              _InfoRow(title: 'شهر', value: item.city),
              _InfoRow(title: 'محدوده', value: item.area),
              _InfoRow(title: 'استان', value: item.provinceId),
              _InfoRow(title: 'عرض جغرافیایی', value: item.latitude.toString()),
              _InfoRow(title: 'طول جغرافیایی', value: item.longitude.toString()),
            ],
          ),
        );
      },
    );
  }
}

class _SearchPreviewItem {
  const _SearchPreviewItem({
    required this.id,
    required this.area,
    required this.code,
    required this.city,
    required this.imageUrl,
  });

  final String id;
  final String area;
  final String code;
  final String city;
  final String imageUrl;

  factory _SearchPreviewItem.fromJson(Map<String, dynamic> json) {
    return _SearchPreviewItem(
      id: json['id']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}

class _PreviewSearchCard extends StatelessWidget {
  const _PreviewSearchCard({required this.item});

  final _SearchPreviewItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 145,
              child: item.imageUrl.isEmpty
                  ? const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
                      child: Icon(Icons.image_not_supported_outlined),
                    )
                  : Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.area.isEmpty ? '-' : item.area,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'شهر: ${item.city.isEmpty ? '-' : item.city}',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          Text(
            'کد تابلو: ${item.code.isEmpty ? '-' : item.code}',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
