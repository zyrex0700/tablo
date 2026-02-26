import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/billboard_item.dart';
import '../../../routes/app_routes.dart';
import '../controllers/billboards_controller.dart';

class BillboardsView extends GetView<BillboardsController> {
  const BillboardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 900;
    if (isMobile) {
      return _MobileBillboardsScaffold(controller: controller);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _StatsBar(controller: controller, isMobile: false),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.error.value.isNotEmpty) {
                        return Center(child: Text(controller.error.value));
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 0.92,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: controller.billboards.length,
                        itemBuilder: (context, index) {
                          final item = controller.billboards[index];
                          return _BillboardGridCard(item: item, isMobile: false);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 300,
              child: _FilterPanel(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileBillboardsScaffold extends StatelessWidget {
  const _MobileBillboardsScaffold({required this.controller});

  final BillboardsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
          child: Column(
            children: [
              _StatsBar(controller: controller, isMobile: true),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.error.value.isNotEmpty) {
                    return Center(child: Text(controller.error.value));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.57,
                    ),
                    itemCount: controller.billboards.length,
                    itemBuilder: (context, index) {
                      final item = controller.billboards[index];
                      return _BillboardGridCard(item: item, isMobile: true);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _MobileBottomNavigation(currentRoute: AppRoutes.billboards),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.controller, required this.isMobile});

  final BillboardsController controller;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalCities = controller.billboards.map((e) => e.city).toSet().length;

      if (!isMobile) {
        return Row(
          children: [
            _StatChip(
              label: 'تعداد کل تابلوها: ${controller.totalBillboards.value}',
              color: const Color(0xFFE0E7FF),
              dotColor: const Color(0xFF1E40AF),
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'تعداد استان‌ها: ${controller.provinces.length}',
              color: const Color(0xFFDCFCE7),
              dotColor: const Color(0xFF16A34A),
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: 'تعداد شهرها: $totalCities',
              color: const Color(0xFFFFEDD5),
              dotColor: const Color(0xFFF59E0B),
            ),
          ],
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'تعداد استان‌ها: ${controller.provinces.length}',
                  color: const Color(0xFFDCFCE7),
                  dotColor: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'تعداد کل تابلوها: ${controller.totalBillboards.value}',
                  color: const Color(0xFFE0E7FF),
                  dotColor: const Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: OutlinedButton.icon(
                    onPressed: () => _showFilterSheet(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('فیلترها'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'تعداد شهرها: $totalCities',
                  color: const Color(0xFFFFEDD5),
                  dotColor: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _FilterPanel(controller: controller),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.color,
    required this.dotColor,
  });

  final String label;
  final Color color;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.circle, size: 9, color: dotColor),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.controller});

  final BillboardsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('فیلتر بر اساس استان', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedProvinceId.value.isEmpty
                  ? null
                  : controller.selectedProvinceId.value,
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('همه استان‌ها'),
                ),
                ...controller.provinces.map(
                  (p) => DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(p.name),
                  ),
                ),
              ],
              onChanged: controller.applyProvinceFilter,
              decoration: const InputDecoration(hintText: 'انتخاب استان'),
            ),
          ),
          const SizedBox(height: 16),
          Text('فیلتر بر اساس شهر', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            onSubmitted: controller.applyCityFilter,
            decoration: const InputDecoration(
              hintText: 'مثلاً تهران',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              controller.selectedProvinceId.value = '';
              controller.selectedCity.value = '';
              controller.fetchBillboards();
            },
            child: const Text('حذف فیلترها'),
          ),
        ],
      ),
    );
  }
}

class _BillboardGridCard extends StatelessWidget {
  const _BillboardGridCard({required this.item, required this.isMobile});

  final BillboardItem item;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(isMobile ? 18 : 15);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: cardRadius,
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: isMobile ? 118 : 160,
                child: Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
                    child: Center(child: Icon(Icons.image_not_supported_outlined)),
                  ),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 10 : 12),
            Text(
              item.type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'استان: ${item.provinceName}، شهر: ${item.city}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'منطقه: ${item.area.isEmpty ? '-' : item.area}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              'کد تابلو: ${item.code.isEmpty ? '-' : item.code}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const Spacer(),
            Text(
              item.rentLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
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
      (label: 'تابلوها', icon: Icons.crop_square_rounded, route: AppRoutes.billboards),
      (label: 'خانه', icon: Icons.home_outlined, route: AppRoutes.home),
      (label: 'علاقه‌مندی', icon: Icons.favorite_border, route: AppRoutes.magazine),
      (label: 'حساب', icon: Icons.person_outline, route: AppRoutes.contactUs),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 1),
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
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
