import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/province_model.dart';

class HomeController extends GetxController {
  static const _provincesApi =
      'https://tablo.ir/my_api/provinces/list.php';

  final menuItems = const <String>[
    'صفحه اصلی',
    'تابلوها',
    'مجله',
    'تماس با ما',
  ];

  final isLoadingProvinces = false.obs;
  final provinces = <ProvinceModel>[].obs;
  final provincesError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    isLoadingProvinces.value = true;
    provincesError.value = '';

    try {
      final response = await http.get(Uri.parse(_provincesApi));

      if (response.statusCode != 200) {
        provincesError.value = 'خطا در دریافت اطلاعات مناطق.';
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final success = decoded['success'] == true;
      final items = decoded['data'];

      if (!success || items is! List) {
        provincesError.value = 'پاسخ API معتبر نیست.';
        return;
      }

      provinces.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map(ProvinceModel.fromJson)
            .toList(),
      );
    } catch (_) {
      provincesError.value = 'اتصال به سرور برقرار نشد.';
    } finally {
      isLoadingProvinces.value = false;
    }
  }
}
