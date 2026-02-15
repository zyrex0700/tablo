import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  static const _menuItems = <_MenuItem>[
    _MenuItem(title: 'صفحه اصلی', route: AppRoutes.home),
    _MenuItem(title: 'تابلوها', route: AppRoutes.billboards),
    _MenuItem(title: 'مجله', route: AppRoutes.magazine),
    _MenuItem(title: 'تماس با ما', route: AppRoutes.contactUs),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
          Row(
            children: [
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
              const SizedBox(width: 24),
              ..._menuItems.map(
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
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Text('ورود / ثبت نام'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.title, required this.route});

  final String title;
  final String route;
}
