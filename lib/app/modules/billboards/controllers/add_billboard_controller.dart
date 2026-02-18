import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../controllers/header_session.dart';
import '../../../data/models/province_model.dart';

class AddBillboardController extends GetxController {
  static const _provincesApi = 'https://tablo.ir/my_api/provinces/list.php';
  static const _addBillboardApi = 'https://tablo.ir/my_api/billboards/add.php';

  final provinces = <ProvinceModel>[].obs;
  final isLoadingProvinces = false.obs;
  final isSubmitting = false.obs;

  final selectedProvinceId = RxnString();
  final selectedType = RxnString();
  final selectedLighting = RxnString();

  final codeController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final lengthController = TextEditingController();
  final heightController = TextEditingController();
  final viewController = TextEditingController();
  final monthlyRentController = TextEditingController();
  final phoneController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final sellerController = TextEditingController();
  final imageUrlController = TextEditingController();

  static const billboardTypes = <String>[
    'بیلبورد',
    'پیشانی پل',
    'استرابورد',
    'عرشه پل',
  ];

  static const lightingOptions = <String>[
    'دارد',
    'ندارد',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProvinces();
  }

  @override
  void onClose() {
    codeController.dispose();
    cityController.dispose();
    areaController.dispose();
    lengthController.dispose();
    heightController.dispose();
    viewController.dispose();
    monthlyRentController.dispose();
    phoneController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    sellerController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }

  Future<void> fetchProvinces() async {
    isLoadingProvinces.value = true;

    try {
      final response = await http
          .get(Uri.parse(_provincesApi))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final data = decoded['data'];
      if (decoded['success'] == true && data is List) {
        provinces.assignAll(
          data
              .whereType<Map<String, dynamic>>()
              .map(ProvinceModel.fromJson)
              .toList(),
        );
      }
    } catch (_) {
      // intentionally ignored in UI (dropdown will stay empty)
    } finally {
      isLoadingProvinces.value = false;
    }
  }

  void setCoordinates(double latitude, double longitude) {
    latitudeController.text = latitude.toStringAsFixed(7);
    longitudeController.text = longitude.toStringAsFixed(7);
  }

  Future<void> submit() async {
    final session = Get.isRegistered<HeaderSession>()
        ? Get.find<HeaderSession>()
        : Get.put(HeaderSession(), permanent: true);

    final token = session.token.value.trim();
    if (token.isEmpty) {
      Get.snackbar('خطا', 'ابتدا وارد حساب کاربری شوید.');
      return;
    }

    if (selectedProvinceId.value == null ||
        cityController.text.trim().isEmpty ||
        areaController.text.trim().isEmpty) {
      Get.snackbar('خطا', 'استان، شهر و محور الزامی هستند.');
      return;
    }

    final payload = <String, dynamic>{
      'province_id': selectedProvinceId.value,
      'city': cityController.text.trim(),
      'area': areaController.text.trim(),
      'height': _nullableNumber(heightController.text),
      'length': _nullableNumber(lengthController.text),
      'view': viewController.text.trim(),
      'lighting': selectedLighting.value ?? '',
      'monthly_rent': _nullableNumber(monthlyRentController.text),
      'phone': phoneController.text.trim(),
      'latitude': _nullableNumber(latitudeController.text),
      'longitude': _nullableNumber(longitudeController.text),
      'seller': sellerController.text.trim(),
      'image_url': imageUrlController.text.trim().isEmpty
          ? null
          : imageUrlController.text.trim(),
      'code': codeController.text.trim(),
      'type': selectedType.value ?? '',
    };

    isSubmitting.value = true;
    try {
      final response = await http
          .post(
            Uri.parse(_addBillboardApi),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      final decoded = _safeDecode(response.body);
      if (decoded == null) {
        Get.snackbar('خطا', 'پاسخ نامعتبر از سرور دریافت شد.');
        return;
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        Get.snackbar('موفق', 'تابلو با موفقیت ثبت شد.');
        Get.back();
        return;
      }

      Get.snackbar('خطا', decoded['message']?.toString() ?? 'ثبت تابلو ناموفق بود.');
    } catch (_) {
      Get.snackbar('خطا', 'اتصال به سرور برقرار نشد.');
    } finally {
      isSubmitting.value = false;
    }
  }

  num? _nullableNumber(String input) {
    final trimmed = input.trim().replaceAll(',', '');
    if (trimmed.isEmpty) {
      return null;
    }

    return num.tryParse(trimmed);
  }

  Map<String, dynamic>? _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
