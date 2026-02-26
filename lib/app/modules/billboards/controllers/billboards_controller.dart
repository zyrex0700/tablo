import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/billboard_item.dart';
import '../../../data/models/province_model.dart';

class BillboardsController extends GetxController {
  static const _billboardsApi = 'https://tablo.ir/my_api/billboards/list.php';
  static const _provincesApi = 'https://tablo.ir/my_api/provinces/list.php';

  final billboards = <BillboardItem>[].obs;
  final allBillboards = <BillboardItem>[].obs;
  final provinces = <ProvinceModel>[].obs;

  final isLoading = false.obs;
  final error = ''.obs;

  final selectedProvinceId = ''.obs;
  final selectedCity = ''.obs;
  final selectedType = ''.obs;
  final selectedArea = ''.obs;
  final selectedCode = ''.obs;

  final totalBillboards = 0.obs;

  List<String> get availableTypes {
    return allBillboards
        .map((item) => item.type.trim())
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

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

      allBillboards.assignAll(items);
      _applyClientFilters();
    } catch (_) {
      error.value = 'اتصال به سرور برقرار نشد.';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyClientFilters() {
    final typeFilter = selectedType.value.trim().toLowerCase();
    final areaFilter = selectedArea.value.trim().toLowerCase();
    final codeFilter = selectedCode.value.trim().toLowerCase();

    final filtered = allBillboards.where((item) {
      final itemType = item.type.trim().toLowerCase();
      final itemArea = item.area.trim().toLowerCase();
      final itemCode = item.code.trim().toLowerCase();

      final matchType = typeFilter.isEmpty || itemType == typeFilter;
      final matchArea = areaFilter.isEmpty || itemArea.contains(areaFilter);
      final matchCode = codeFilter.isEmpty || itemCode.contains(codeFilter);

      return matchType && matchArea && matchCode;
    }).toList();

    billboards.assignAll(filtered);
    totalBillboards.value = filtered.length;
  }

  void applyProvinceFilter(String? provinceId) {
    selectedProvinceId.value = provinceId ?? '';
    fetchBillboards();
  }

  void applyCityFilter(String city) {
    selectedCity.value = city.trim();
    fetchBillboards();
  }

  void applyTypeFilter(String? type) {
    selectedType.value = type?.trim() ?? '';
    _applyClientFilters();
  }

  void applyAreaFilter(String area) {
    selectedArea.value = area.trim();
    _applyClientFilters();
  }

  void applyCodeFilter(String code) {
    selectedCode.value = code.trim();
    _applyClientFilters();
  }

  void clearAllFilters() {
    selectedProvinceId.value = '';
    selectedCity.value = '';
    selectedType.value = '';
    selectedArea.value = '';
    selectedCode.value = '';
    fetchBillboards();
  }
}
