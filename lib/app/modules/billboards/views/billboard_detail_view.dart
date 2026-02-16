import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/billboard_item.dart';
import '../../../widgets/app_page_scaffold.dart';

class BillboardDetailView extends StatelessWidget {
  const BillboardDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final item = args is BillboardItem ? args : null;

    if (item == null) {
      return const AppPageScaffold(
        child: Center(
          child: Text('اطلاعات این محصول در دسترس نیست.'),
        ),
      );
    }

    return AppPageScaffold(
      child: Container(
        color: const Color(0xFFECEFF1),
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                '${item.city} - ${item.code}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ),
              const SizedBox(height: 26),
              Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 360,
                    child: _DetailSidebar(item: item),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFDDE3E9)),
                            child: Center(child: Icon(Icons.image_not_supported_outlined)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    width: 320,
                    child: _LocationBox(item: item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSidebar extends StatelessWidget {
  const _DetailSidebar({required this.item});

  final BillboardItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BlueHeaderBox(text: 'کد تابلو:${item.code}'),
        const SizedBox(height: 12),
        _InfoItem(label: 'استان', value: item.provinceName),
        _InfoItem(label: 'شهر', value: item.city),
        _InfoItem(label: 'محور / منطقه', value: item.area),
        _InfoItem(label: 'ابعاد', value: '${item.length} × ${item.height}'),
        _InfoItem(label: 'دید', value: item.view),
        _InfoItem(label: 'روشنایی', value: item.lighting),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'اجاره ماهیانه طبق تعرفه:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                item.rentLabel,
                style: const TextStyle(
                  color: Color(0xFF253EC9),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BlueHeaderBox(text: 'شماره تماس : ${item.phone}'),
      ],
    );
  }
}

class _BlueHeaderBox extends StatelessWidget {
  const _BlueHeaderBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2838C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              '$label: $value',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_left, color: Color(0xFF8492A6)),
        ],
      ),
    );
  }
}

class _LocationBox extends StatelessWidget {
  const _LocationBox({required this.item});

  final BillboardItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFA9CFDF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF2E44DA),
              child: Icon(Icons.location_on, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              item.hasValidLocation
                  ? 'Lat: ${item.latitude}\nLng: ${item.longitude}'
                  : 'مختصات ثبت نشده',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
