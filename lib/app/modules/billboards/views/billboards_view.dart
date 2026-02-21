import '../../../data/models/billboard_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'billboard_detail_view.dart';
import '../../../widgets/app_page_scaffold.dart';
import '../controllers/billboards_controller.dart';

class BillboardsView extends GetView<BillboardsController> {
  const BillboardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Row(
          textDirection: TextDirection.rtl,
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

                      if (controller.billboards.isEmpty) {
                        return const Center(
                          child: Text('موردی مطابق فیلترها پیدا نشد.'),
                        );
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
                          return _BillboardGridCard(
                            item: item,
                            onTap: () => Get.to(
                              () => const BillboardDetailView(),
                              arguments: item,
                            ),
                          );
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
        textDirection: TextDirection.rtl,
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
            label:
                'تعداد شهرها: ${controller.billboards.map((e) => e.city).toSet().length}',
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

class _FilterPanel extends StatefulWidget {
  const _FilterPanel({required this.controller});

  final BillboardsController controller;

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  bool _priceExpanded = false;
  bool _provinceExpanded = false;
  bool _cityExpanded = false;
  bool _quickSearchExpanded = true;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FilterAccordion(
              title: 'فیلتر بر اساس قیمت :',
              expanded: _priceExpanded,
              onToggle: () => setState(() => _priceExpanded = !_priceExpanded),
              child: DropdownButtonFormField<PriceFilter>(
                value: controller.selectedPriceFilter.value,
                items: PriceFilter.values
                    .map(
                      (price) => DropdownMenuItem<PriceFilter>(
                        value: price,
                        child: Text(price.label),
                      ),
                    )
                    .toList(),
                onChanged: controller.applyPriceFilter,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _FilterAccordion(
              title: 'فیلتر بر اساس استان :',
              expanded: _provinceExpanded,
              onToggle: () => setState(() => _provinceExpanded = !_provinceExpanded),
              child: DropdownButtonFormField<String>(
                value: controller.selectedProvinceId.value.isEmpty
                    ? ''
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _FilterAccordion(
              title: 'فیلتر بر اساس شهر :',
              expanded: _cityExpanded,
              onToggle: () => setState(() => _cityExpanded = !_cityExpanded),
              child: DropdownButtonFormField<String>(
                value: controller.selectedCity.value,
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('همه شهرها'),
                  ),
                  ...controller.cityOptions.map(
                    (city) => DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    ),
                  ),
                ],
                onChanged: controller.applyCityFilter,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _FilterAccordion(
              title: 'جستجوی سریع',
              expanded: _quickSearchExpanded,
              onToggle: () =>
                  setState(() => _quickSearchExpanded = !_quickSearchExpanded),
              iconColor: const Color(0xFF2B38D2),
              child: TextField(
                controller: controller.quickSearchController,
                onChanged: controller.applyQuickSearch,
                decoration: InputDecoration(
                  hintText: 'نام شهر، کد تابلو، منطقه ...',
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B38D2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: controller.clearFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('حذف همه فیلترها'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2544FF),
                side: const BorderSide(color: Color(0xFFC7C7C7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterAccordion extends StatelessWidget {
  const _FilterAccordion({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.iconColor = const Color(0xFF9CA3AF),
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E6E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: iconColor,
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            child,
          ],
        ],
      ),
    );
  }
}

class _BillboardGridCard extends StatelessWidget {
  const _BillboardGridCard({required this.item, required this.onTap});

  final BillboardItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
