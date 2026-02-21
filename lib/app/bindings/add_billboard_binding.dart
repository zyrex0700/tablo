import 'package:get/get.dart';

import '../modules/billboards/controllers/add_billboard_controller.dart';

class AddBillboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddBillboardController>(AddBillboardController.new);
  }
}
