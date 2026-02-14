import '../../../data/models/billboard_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/billboards_controller.dart';

class BillboardsView extends GetView<BillboardsController> {
  const BillboardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _StatsBar(controller: controller),
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
                          childAspectRatio: 0.72,
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

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.controller});

  final BillboardsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _StatChip(
            label: 'تعداد کل تابلوها: ${controller.totalBillboards.value}',
            color: const Color(0xFFE0E7FF),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'تعداد استان‌ها: ${controller.provinces.length}',
            color: const Color(0xFFDCFCE7),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'تعداد شهرها: ${controller.billboards.map((e) => e.city).toSet().length}',
            color: const Color(0xFFFFEDD5),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(label),
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
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.city} - ${item.area}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text('استان: ${item.provinceName}'),
                Text('کد تابلو: ${item.code}'),
                const SizedBox(height: 6),
                Text(
                  item.rentLabel,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
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
