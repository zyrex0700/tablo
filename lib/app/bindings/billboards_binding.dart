import 'package:get/get.dart';

import '../modules/billboards/controllers/billboards_controller.dart';

class BillboardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillboardsController>(BillboardsController.new);
  }
}
