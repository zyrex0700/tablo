import 'dart:convert';

import 'package:flutter/material.dart';
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
  final selectedPriceFilter = PriceFilter.all.obs;
  final quickSearch = ''.obs;

  final totalBillboards = 0.obs;

  final quickSearchController = TextEditingController();

  final _allBillboards = <BillboardItem>[];

  String _initialProvinceId = '';
  String _initialCity = '';

  List<String> get cityOptions {
    final filtered = selectedProvinceId.value.isEmpty
        ? _allBillboards
        : _allBillboards
            .where((item) => item.provinceId == selectedProvinceId.value)
            .toList();

    final cities = filtered
        .map((item) => item.city.trim())
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return cities;
  }

  @override
  void onInit() {
    super.onInit();
    _readInitialFilters();
    fetchProvinces();
    fetchBillboards();
  }

  @override
  void onClose() {
    quickSearchController.dispose();
    super.onClose();
  }

  void _readInitialFilters() {
    final args = Get.arguments;
    if (args is! Map) {
      return;
    }

    final map = Map<String, dynamic>.from(args);
    _initialProvinceId =
        (map['province_id'] ?? map['provinceId'] ?? '').toString().trim();
    _initialCity = (map['city'] ?? map['city_name'] ?? '').toString().trim();

    if (_initialProvinceId.isNotEmpty) {
      selectedProvinceId.value = _initialProvinceId;
    }
    if (_initialCity.isNotEmpty) {
      selectedCity.value = _initialCity;
    }
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
      final query = <String, String>{'limit': '200'};
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

      _allBillboards
        ..clear()
        ..addAll(
          data
              .whereType<Map<String, dynamic>>()
              .map(BillboardItem.fromJson)
              .toList(),
        );

      _applyInitialRouteFilters();
      applyFilters();
    } catch (_) {
      error.value = 'اتصال به سرور برقرار نشد.';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyInitialRouteFilters() {
    if (_initialProvinceId.isNotEmpty) {
      selectedProvinceId.value = _initialProvinceId;
    }

    if (_initialCity.isNotEmpty &&
        _allBillboards.any((item) => item.city.trim() == _initialCity)) {
      selectedCity.value = _initialCity;
    } else if (_initialProvinceId.isNotEmpty) {
      selectedCity.value = '';
    }

    _initialProvinceId = '';
    _initialCity = '';
  }

  void applyProvinceFilter(String? provinceId) {
    selectedProvinceId.value = provinceId ?? '';

    if (selectedCity.value.isNotEmpty &&
        !cityOptions.contains(selectedCity.value)) {
      selectedCity.value = '';
    }

    applyFilters();
  }

  void applyCityFilter(String? city) {
    selectedCity.value = city?.trim() ?? '';
    applyFilters();
  }

  void applyPriceFilter(PriceFilter? priceFilter) {
    selectedPriceFilter.value = priceFilter ?? PriceFilter.all;
    applyFilters();
  }

  void applyQuickSearch(String value) {
    quickSearch.value = value.trim();
    applyFilters();
  }

  void clearFilters() {
    selectedProvinceId.value = '';
    selectedCity.value = '';
    selectedPriceFilter.value = PriceFilter.all;
    quickSearch.value = '';
    quickSearchController.clear();
    applyFilters();
  }

  void applyFilters() {
    var filtered = List<BillboardItem>.from(_allBillboards);

    if (selectedProvinceId.value.isNotEmpty) {
      filtered = filtered
          .where((item) => item.provinceId == selectedProvinceId.value)
          .toList();
    }

    if (selectedCity.value.isNotEmpty) {
      filtered = filtered
          .where((item) => item.city.trim() == selectedCity.value)
          .toList();
    }

    if (selectedPriceFilter.value != PriceFilter.all) {
      filtered = filtered
          .where((item) =>
              selectedPriceFilter.value.contains(_toRentNumber(item.monthlyRent)))
          .toList();
    }

    if (quickSearch.value.isNotEmpty) {
      final query = quickSearch.value.toLowerCase();
      filtered = filtered.where((item) {
        final text = [
          item.city,
          item.area,
          item.code,
          item.type,
          item.provinceName,
        ].join(' ').toLowerCase();

        return text.contains(query);
      }).toList();
    }

    billboards.assignAll(filtered);
    totalBillboards.value = filtered.length;
  }

  int _toRentNumber(String rent) {
    final cleaned = rent.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
}

enum PriceFilter {
  all('همه قیمت‌ها', 0, null),
  under100('کمتر از ۱۰۰ میلیون', 1, 100000000),
  between100And300('از ۱۰۰ تا ۳۰۰ میلیون', 100000000, 300000000),
  above300('بیشتر از ۳۰۰ میلیون', 300000000, null);

  const PriceFilter(this.label, this.min, this.max);

  final String label;
  final int min;
  final int? max;

  bool contains(int value) {
    if (this == all) {
      return true;
    }

    if (max == null) {
      return value >= min;
    }

    return value >= min && value < max!;
  }
}
