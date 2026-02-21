import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final companyNameController = TextEditingController();
  final managerNameController = TextEditingController();
  final startYearController = TextEditingController();
  final instagramController = TextEditingController();
  final mainPhoneController = TextEditingController();
  final websiteController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final brandDescController = TextEditingController();

  final license1 = ''.obs;
  final license2 = ''.obs;

  @override
  void onClose() {
    companyNameController.dispose();
    managerNameController.dispose();
    startYearController.dispose();
    instagramController.dispose();
    mainPhoneController.dispose();
    websiteController.dispose();
    emailController.dispose();
    addressController.dispose();
    brandDescController.dispose();
    super.onClose();
  }

  Future<void> pickLicense1() async {
    final name = await _pickDoc();
    if (name != null) {
      license1.value = name;
    }
  }

  Future<void> pickLicense2() async {
    final name = await _pickDoc();
    if (name != null) {
      license2.value = name;
    }
  }

  Future<String?> _pickDoc() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      return result.files.first.name;
    } catch (_) {
      return null;
    }
  }
}
