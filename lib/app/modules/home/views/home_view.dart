import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بازسازی Tablo.ir'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'شروع نسخه جدید سایت',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'این نسخه پایه با Flutter Web + GetX ساخته شده تا قدم‌به‌قدم امکانات قبلی tablo.ir را برگردانیم.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'بخش‌های اصلی:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.sections
                    .map((item) => Chip(label: Text(item)))
                    .toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Get.snackbar(
                    'گام بعدی',
                    'در مرحله بعد طراحی صفحه اصلی واقعی و اتصال API را انجام می‌دهیم.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text('ادامه مسیر بازسازی'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
