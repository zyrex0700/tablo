import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../controllers/header_session.dart';
import '../../../data/models/province_model.dart';

class AddBillboardController extends GetxController {
  static const _provincesApi = 'https://tablo.ir/my_api/provinces/list.php';
  static const _citiesApi = 'https://tablo.ir/my_api/cities/list.php';
  static const _addBillboardApi = 'https://tablo.ir/my_api/billboards/add.php';

  final provinces = <ProvinceModel>[].obs;
  final cityOptions = <CityOption>[].obs;

  final isLoadingProvinces = false.obs;
  final isLoadingCities = false.obs;
  final isSubmitting = false.obs;
  final isPickingImage = false.obs;

  final selectedProvinceIds = <String>[].obs;
  final selectedCityNames = <String>[].obs;

  final selectedType = RxnString();
  final selectedLighting = RxnString();

  final codeController = TextEditingController();
  final areaController = TextEditingController();
  final lengthController = TextEditingController();
  final heightController = TextEditingController();
  final viewController = TextEditingController();
  final monthlyRentController = TextEditingController();
  final phoneController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  final selectedImageName = ''.obs;
  final selectedImageBytes = Rxn<List<int>>();

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
    areaController.dispose();
    lengthController.dispose();
    heightController.dispose();
    viewController.dispose();
    monthlyRentController.dispose();
    phoneController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
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
      // ignored, selection will remain empty
    } finally {
      isLoadingProvinces.value = false;
    }
  }

  Future<void> toggleProvinceSelection(String provinceId) async {
    if (selectedProvinceIds.contains(provinceId)) {
      selectedProvinceIds.remove(provinceId);
    } else {
      selectedProvinceIds.add(provinceId);
    }

    await fetchCitiesForSelectedProvinces();
  }

  void toggleCitySelection(String cityName) {
    if (selectedCityNames.contains(cityName)) {
      selectedCityNames.remove(cityName);
      return;
    }

    selectedCityNames.add(cityName);
  }

  Future<void> fetchCitiesForSelectedProvinces() async {
    if (selectedProvinceIds.isEmpty) {
      cityOptions.clear();
      selectedCityNames.clear();
      return;
    }

    isLoadingCities.value = true;

    try {
      final futures = selectedProvinceIds.map((provinceId) async {
        final uri = Uri.parse(_citiesApi).replace(
          queryParameters: {'province_id': provinceId},
        );

        final response = await http.get(uri).timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          return <CityOption>[];
        }

        final decoded = _safeDecode(response.body);
        if (decoded == null || decoded['success'] != true || decoded['data'] is! List) {
          return <CityOption>[];
        }

        final data = decoded['data'] as List<dynamic>;

        return data.whereType<Map<String, dynamic>>().map((json) {
          return CityOption(
            id: json['id']?.toString() ?? '',
            provinceId: json['province_id']?.toString() ?? provinceId,
            name: json['name']?.toString().trim() ?? '',
          );
        }).where((city) => city.name.isNotEmpty).toList();
      }).toList();

      final resultLists = await Future.wait(futures);
      final merged = <String, CityOption>{};
      for (final list in resultLists) {
        for (final city in list) {
          merged[city.name] = city;
        }
      }

      final newOptions = merged.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      cityOptions.assignAll(newOptions);

      selectedCityNames.removeWhere(
        (selected) => !newOptions.any((city) => city.name == selected),
      );
    } catch (_) {
      cityOptions.clear();
      selectedCityNames.clear();
    } finally {
      isLoadingCities.value = false;
    }
  }

  Future<void> pickImage() async {
    isPickingImage.value = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        return;
      }

      selectedImageName.value = file.name;
      selectedImageBytes.value = file.bytes;
    } finally {
      isPickingImage.value = false;
    }
  }

  String get selectedProvincesLabel {
    if (selectedProvinceIds.isEmpty) {
      return 'استان‌ ها را انتخاب کنید';
    }

    final selectedNames = provinces
        .where((province) => selectedProvinceIds.contains(province.id))
        .map((province) => province.name)
        .toList();

    return selectedNames.join('، ');
  }

  String get selectedCitiesLabel {
    if (selectedCityNames.isEmpty) {
      return 'شهرها را انتخاب کنید';
    }

    return selectedCityNames.join('، ');
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

    if (selectedProvinceIds.isEmpty ||
        selectedCityNames.isEmpty ||
        areaController.text.trim().isEmpty) {
      Get.snackbar('خطا', 'استان، شهر و محور الزامی هستند.');
      return;
    }

    final userId = _extractUserIdFromToken(token);
    final imageValue = _resolveImageUrlValue();

    final payload = <String, dynamic>{
      'province_id': selectedProvinceIds.join(','),
      'city': selectedCityNames.join(','),
      'area': areaController.text.trim(),
      'height': _nullableNumber(heightController.text),
      'length': _nullableNumber(lengthController.text),
      'view': viewController.text.trim(),
      'lighting': selectedLighting.value ?? '',
      'monthly_rent': _nullableNumber(monthlyRentController.text),
      'phone': phoneController.text.trim(),
      'latitude': _nullableNumber(latitudeController.text),
      'longitude': _nullableNumber(longitudeController.text),
      'seller': userId.isEmpty ? '0' : userId,
      'image_url': imageValue,
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

  String _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return '';
      }

      final payloadPart = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(payloadPart));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final userId = decoded['user_id'];
        return userId?.toString() ?? '';
      }

      return '';
    } catch (_) {
      return '';
    }
  }

  String? _resolveImageUrlValue() {
    if (selectedImageName.value.trim().isEmpty) {
      return null;
    }

    // Backend add.php currently stores image_url directly in DB.
    // To avoid failing inserts on oversized base64 payloads, send only filename here.
    return selectedImageName.value.trim();
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

class CityOption {
  const CityOption({
    required this.id,
    required this.provinceId,
    required this.name,
  });

  final String id;
  final String provinceId;
  final String name;
}
