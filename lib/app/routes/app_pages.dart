import 'package:get/get.dart';

import '../bindings/billboards_binding.dart';
import '../bindings/home_binding.dart';
import '../modules/billboards/views/billboard_detail_view.dart';
import '../modules/billboards/views/billboards_view.dart';
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
      page: () => const BillboardsView(),
      binding: BillboardsBinding(),
    ),
    GetPage(
      name: '${AppRoutes.billboardDetail}/:id',
      page: () => const BillboardDetailView(),
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
