import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/billboard_item.dart';
import '../../../data/models/billboard_map_item.dart';
import '../../../data/models/brand_item.dart';
import '../../../data/models/province_model.dart';
import '../../../data/models/testimonial_item.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _mainBannerUrl =
      'http://tablo.ir/my_api/images/main%20banner%20desktop.jpg';
  static const _partyBannerUrl = 'http://tablo.ir/my_api/images/tablo-party.png';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;
    if (isMobile) {
      return _MobileHomeScaffold(controller: controller);
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('ورود / ثبت نام'),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      ...controller.menuItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: TextButton(
                            onPressed: () {
                              if (Get.currentRoute != item.route) {
                                Get.toNamed(item.route);
                              }
                            },
                            child: Text(item.title),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'T',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
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
          ],
        ),
      ),
    );
  }
}

class _MobileHomeScaffold extends StatelessWidget {
  const _MobileHomeScaffold({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    TextButton(onPressed: () {}, child: const Text('ورود')),
                    const Spacer(),
                    Text(
                      'تابلو',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.menu_rounded),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                height: 480,
                decoration: const BoxDecoration(
                  color: Color(0xFFA8D0DE),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'جستجو در تابلوها (شهر، کد، محور...)',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Color(0xFF2B38D2)),
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x332B38D2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '${controller.billboards.length}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'محبوب ترین مناطق',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 148,
                child: Obx(
                  () => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.provinces.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final province = controller.provinces[index];
                      return SizedBox(
                        width: 140,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                province.imageUrl,
                                width: 140,
                                height: 102,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const DecoratedBox(
                                  decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                                  child: SizedBox(
                                    width: 140,
                                    height: 102,
                                    child: Icon(Icons.image_not_supported_outlined),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              province.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 98),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    HomeView._mainBannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                      child: SizedBox(
                        height: 150,
                        child: Center(child: Text('خطا در بارگذاری بنر اصلی')),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _MobileBottomNavigation(currentRoute: AppRoutes.home),
    );
  }
}

class _MobileBottomNavigation extends StatelessWidget {
  const _MobileBottomNavigation({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, IconData icon, String route})>[
      (label: 'جستجو', icon: Icons.search, route: AppRoutes.contactUs),
      (label: 'تابلوها', icon: Icons.border_all_rounded, route: AppRoutes.billboards),
      (label: 'خانه', icon: Icons.home_outlined, route: AppRoutes.home),
      (label: 'علاقه‌مندی', icon: Icons.favorite_border, route: AppRoutes.magazine),
      (label: 'حساب', icon: Icons.person_outline, route: AppRoutes.contactUs),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map(
              (item) => InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (item.route != currentRoute) {
                    Get.toNamed(item.route);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: item.route == currentRoute
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: item.route == currentRoute
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 175,
            child: Image.network(
              item.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                child: Center(child: Icon(Icons.image_not_supported_outlined)),
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

class _BillboardsMap extends StatelessWidget {
  const _BillboardsMap({required this.items});

  final List<BillboardMapItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
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

    final center = LatLng(items.first.latitude, items.first.longitude);
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 420,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FlutterMap(
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
                markers: items
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
      ),
    );
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
