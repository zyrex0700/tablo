import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../widgets/app_page_scaffold.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _companyNameController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _startYearController = TextEditingController();
  final _instagramController = TextEditingController();
  final _mainPhoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _brandDescController = TextEditingController();

  String _license1 = '';
  String _license2 = '';

  @override
  void dispose() {
    _companyNameController.dispose();
    _managerNameController.dispose();
    _startYearController.dispose();
    _instagramController.dispose();
    _mainPhoneController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _brandDescController.dispose();
    super.dispose();
  }

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
                  _input(_companyNameController, 'نام شرکت'),
                  const SizedBox(height: 10),
                  _input(_managerNameController, 'نام مدیرعامل'),
                  const SizedBox(height: 10),
                  _input(_startYearController, 'سال شروع فعالیت (مثلاً ۱۳۸۵)'),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _input(
                    _instagramController,
                    'آدرس اینستاگرام (بدون @ یا با @، فرقی ندارد)',
                  ),
                  const SizedBox(height: 10),
                  _input(_mainPhoneController, 'شماره تماس اصلی'),
                  const SizedBox(height: 10),
                  _input(_websiteController, 'وبسایت (مثلاً https://example.com)'),
                  const SizedBox(height: 10),
                  _input(_emailController, 'ایمیل'),
                  const SizedBox(height: 10),
                  _input(_addressController, 'آدرس شرکت', minLines: 2),
                  const SizedBox(height: 10),
                  _input(_brandDescController, 'شعار برند / توضیح کوتاه', minLines: 2),
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
                  _docRow(
                    title: 'مجوز شماره ۱',
                    fileName: _license1,
                    onPick: () async {
                      final name = await _pickDoc();
                      if (name != null && mounted) {
                        setState(() => _license1 = name);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _docRow(
                    title: 'مجوز شماره ۲',
                    fileName: _license2,
                    onPick: () async {
                      final name = await _pickDoc();
                      if (name != null && mounted) {
                        setState(() => _license2 = name);
                      }
                    },
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
