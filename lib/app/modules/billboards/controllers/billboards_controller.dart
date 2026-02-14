import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/billboard_item.dart';
import '../../../data/models/province_model.dart';

class BillboardsController extends GetxController {
  static const _billboardsApi = 'https://tablo.ir/my_api/billboards/list.php';
  static const _provincesApi = 'https://tablo.ir/my_api/provinces/list.php';

  final billboards = <BillboardItem>[].obs;
  final provinces = <ProvinceModel>[].obs;

  final isLoading = false.obs;
  final error = ''.obs;

  final selectedProvinceId = ''.obs;
  final selectedCity = ''.obs;

  final totalBillboards = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProvinces();
    fetchBillboards();
  }

  Future<void> fetchProvinces() async {
    try {
      final response = await http
          .get(Uri.parse(_provincesApi))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (decoded['success'] == true && data is List) {
        provinces.assignAll(
          data
              .whereType<Map<String, dynamic>>()
              .map(ProvinceModel.fromJson)
              .toList(),
        );
      }
    } catch (_) {}
  }

  Future<void> fetchBillboards() async {
    isLoading.value = true;
    error.value = '';

    try {
      final query = <String, String>{'limit': '120'};
      if (selectedProvinceId.value.isNotEmpty) {
        query['province_id'] = selectedProvinceId.value;
      }
      if (selectedCity.value.isNotEmpty) {
        query['city'] = selectedCity.value;
      }

      final uri = Uri.parse(_billboardsApi).replace(queryParameters: query);
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        error.value = 'خطا در دریافت لیست تابلوها.';
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (decoded['success'] != true || data is! List) {
        error.value = 'پاسخ API تابلوها معتبر نیست.';
        return;
      }

      final items = data
          .whereType<Map<String, dynamic>>()
          .map(BillboardItem.fromJson)
          .toList();

      billboards.assignAll(items);
      totalBillboards.value = items.length;
    } catch (_) {
      error.value = 'اتصال به سرور برقرار نشد.';
    } finally {
      isLoading.value = false;
    }
  }

  void applyProvinceFilter(String? provinceId) {
    selectedProvinceId.value = provinceId ?? '';
    fetchBillboards();
  }

  void applyCityFilter(String city) {
    selectedCity.value = city.trim();
    fetchBillboards();
  }
}
