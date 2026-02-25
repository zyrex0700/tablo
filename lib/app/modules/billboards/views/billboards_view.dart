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
                          return _BillboardGridCard(item: item);
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
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
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
                    padding: const EdgeInsets.only(bottom: 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: controller.billboards.length,
                    itemBuilder: (context, index) {
                      return _BillboardGridCard(item: controller.billboards[index]);
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
    return Obx(
      () {
        final chips = [
          _StatChip(
            label: 'تعداد کل تابلوها: ${controller.totalBillboards.value}',
            color: const Color(0xFFE0E7FF),
            dotColor: const Color(0xFF1E40AF),
          ),
          _StatChip(
            label: 'تعداد استان‌ها: ${controller.provinces.length}',
            color: const Color(0xFFDCFCE7),
            dotColor: const Color(0xFF16A34A),
          ),
          _StatChip(
            label: 'تعداد شهرها: ${controller.billboards.map((e) => e.city).toSet().length}',
            color: const Color(0xFFFFEDD5),
            dotColor: const Color(0xFFF59E0B),
          ),
        ];

        if (!isMobile) {
          return Row(
            children: [
              ...chips.expand((chip) => [chip, const SizedBox(width: 8)]),
            ]..removeLast(),
          );
        }

        return Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showFilterSheet(context, controller),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('فیلترها'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, BillboardsController controller) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
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
              decoration: const InputDecoration(
                hintText: 'انتخاب استان',
              ),
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
  const _BillboardGridCard({required this.item});

  final BillboardItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 126,
                width: double.infinity,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFFE5E7EB)),
                    child: Center(child: Icon(Icons.image_not_supported_outlined)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 3),
            Text('استان: ${item.provinceName}، شهر: ${item.city}', maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('منطقه: ${item.area}', maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('کد تابلو: ${item.code}'),
            const Spacer(),
            Center(
              child: Text(
                item.rentLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
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
