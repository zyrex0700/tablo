import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
                            onPressed: () {},
                            child: Text(item),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
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
              padding: const EdgeInsets.fromLTRB(32, 56, 32, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بستر هوشمند رزرو بیلبورد در سراسر ایران',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'در این نسخه جدید، تابلوهای تبلیغاتی را مانند محصول نمایش می‌دهیم تا جستجو، مقایسه و انتخاب برای برندها سریع‌تر و دقیق‌تر انجام شود.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('مشاهده تابلوها'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
