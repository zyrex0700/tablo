import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/app_page_scaffold.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      child: Container(
        color: const Color(0xFFE9ECEF),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تکمیل پروفایل شرکت',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'این اطلاعات در صفحه معرفی شرکت و فاکتورهای شما نمایش داده می‌شود.',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  _input(controller.companyNameController, 'نام شرکت'),
                  const SizedBox(height: 10),
                  _input(controller.managerNameController, 'نام مدیرعامل'),
                  const SizedBox(height: 10),
                  _input(controller.startYearController, 'سال شروع فعالیت (مثلاً ۱۳۸۵)'),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _input(
                    controller.instagramController,
                    'آدرس اینستاگرام (بدون @ یا با @، فرقی ندارد)',
                  ),
                  const SizedBox(height: 10),
                  _input(controller.mainPhoneController, 'شماره تماس اصلی'),
                  const SizedBox(height: 10),
                  _input(controller.websiteController, 'وبسایت (مثلاً https://example.com)'),
                  const SizedBox(height: 10),
                  _input(controller.emailController, 'ایمیل'),
                  const SizedBox(height: 10),
                  _input(controller.addressController, 'آدرس شرکت', minLines: 2),
                  const SizedBox(height: 10),
                  _input(controller.brandDescController, 'شعار برند / توضیح کوتاه', minLines: 2),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'مجوزها و مدارک',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'دو فایل از مجوزهای رسمی (مثلاً پروانه کسب، مجوز تبلیغات محیطی و ...) بارگذاری کنید.',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => _docRow(
                      title: 'مجوز شماره ۱',
                      fileName: controller.license1.value,
                      onPick: controller.pickLicense1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => _docRow(
                      title: 'مجوز شماره ۲',
                      fileName: controller.license2.value,
                      onPick: controller.pickLicense2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2441DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'ذخیره پروفایل',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint, {int minLines = 1}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      minLines: minLines,
      maxLines: minLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE9ECEF),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8C93A3)),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8C93A3)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _docRow({
    required String title,
    required String fileName,
    required VoidCallback onPick,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.chevron_left, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  fileName.isEmpty ? 'فایلی انتخاب نشده است' : fileName,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: onPick,
            icon: const Icon(Icons.upload, color: Color(0xFF2441DB)),
          ),
        ],
      ),
    );
  }
}
