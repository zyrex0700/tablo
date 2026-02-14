import 'package:get/get.dart';

import '../bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/simple_page_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.billboards,
      page: () => const SimplePageView(title: 'صفحه تابلوها'),
    ),
    GetPage(
      name: AppRoutes.magazine,
      page: () => const SimplePageView(title: 'صفحه مجله'),
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const SimplePageView(title: 'صفحه تماس با ما'),
    ),
  ];
}
