import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/billboard_item.dart';
import '../../../data/models/billboard_map_item.dart';
import '../../../data/models/province_model.dart';

class HomeController extends GetxController {
  static const _provincesApi =
      'https://tablo.ir/my_api/provinces/list.php';
  static const _billboardMapApi =
      'https://tablo.ir/my_api/billboards/map.php';
  static const _billboardListApi =
      'https://tablo.ir/my_api/billboards/list.php?limit=5';

  final menuItems = const <String>[
    'صفحه اصلی',
    'تابلوها',
    'مجله',
    'تماس با ما',
  ];

  final isLoadingProvinces = false.obs;
  final provinces = <ProvinceModel>[].obs;
  final provincesError = ''.obs;

  final isLoadingBillboards = false.obs;
  final billboards = <BillboardMapItem>[].obs;
  final billboardsError = ''.obs;

  final isLoadingPartyBillboards = false.obs;
  final partyBillboards = <BillboardItem>[].obs;
  final partyBillboardsError = ''.obs;

  List<BillboardMapItem> get billboardsWithLocation =>
      billboards.where((item) => item.hasValidLocation).toList();

  @override
  void onInit() {
    super.onInit();
    fetchProvinces();
    fetchBillboardsMap();
    fetchPartyBillboards();
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

  Future<void> fetchBillboardsMap() async {
    isLoadingBillboards.value = true;
    billboardsError.value = '';

    try {
      final response = await http.get(Uri.parse(_billboardMapApi));

      if (response.statusCode != 200) {
        billboardsError.value = 'خطا در دریافت موقعیت بیلبوردها.';
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final success = decoded['success'] == true;
      final items = decoded['data'];

      if (!success || items is! List) {
        billboardsError.value = 'پاسخ API نقشه معتبر نیست.';
        return;
      }

      billboards.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map(BillboardMapItem.fromJson)
            .toList(),
      );
    } catch (_) {
      billboardsError.value = 'اتصال به سرور نقشه برقرار نشد.';
    } finally {
      isLoadingBillboards.value = false;
    }
  }

  Future<void> fetchPartyBillboards() async {
    isLoadingPartyBillboards.value = true;
    partyBillboardsError.value = '';

    try {
      final response = await http.get(Uri.parse(_billboardListApi));

      if (response.statusCode != 200) {
        partyBillboardsError.value = 'خطا در دریافت لیست تابلو پارتی.';
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final success = decoded['success'] == true;
      final items = decoded['data'];

      if (!success || items is! List) {
        partyBillboardsError.value = 'پاسخ API تابلو پارتی معتبر نیست.';
        return;
      }

      partyBillboards.assignAll(
        items
            .whereType<Map<String, dynamic>>()
            .map(BillboardItem.fromJson)
            .toList(),
      );
    } catch (_) {
      partyBillboardsError.value = 'اتصال به سرور تابلو پارتی برقرار نشد.';
    } finally {
      isLoadingPartyBillboards.value = false;
    }
  }
}
