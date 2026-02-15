import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../routes/app_routes.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  static const _menuItems = <_MenuItem>[
    _MenuItem(title: 'صفحه اصلی', route: AppRoutes.home),
    _MenuItem(title: 'تابلوها', route: AppRoutes.billboards),
    _MenuItem(title: 'مجله', route: AppRoutes.magazine),
    _MenuItem(title: 'تماس با ما', route: AppRoutes.contactUs),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'تابلو',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1F3FE0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              ..._menuItems.map(
                (item) {
                  final isActive = Get.currentRoute == item.route;
                  return Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: TextButton(
                      onPressed: () {
                        if (Get.currentRoute != item.route) {
                          Get.toNamed(item.route);
                        }
                      },
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF2544FF)
                              : const Color(0xFF7B8294),
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => _showAuthDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2544FF),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('ورود / ثبت نام'),
          ),
        ],
      ),
    );
  }

  void _showAuthDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => const _AuthDialog(),
    );
  }
}

class _AuthDialog extends StatefulWidget {
  const _AuthDialog();

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  _AuthStep _step = _AuthStep.mobile;
  Timer? _resendTimer;
  int _secondsToResend = 118;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFC),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'تابلو',
                  style: TextStyle(
                    color: Color(0xFF1F3FE0),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, size: 30, color: Color(0xFF575A64)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_step == _AuthStep.mobile) ...[
              const Text(
                'ورود / عضویت',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'موبایل خود را وارد کنید',
                style: TextStyle(color: Color(0xFF9AA0A8), fontSize: 15),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'شماره موبایل',
                  suffixIcon: const Icon(Icons.phone_in_talk_outlined),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _AuthButton(
                text: 'ورود / عضویت',
                loading: _isLoading,
                onPressed: _submitMobile,
              ),
              const SizedBox(height: 12),
              const Text(
                'با ورود یا ثبت‌نام در سایت، شما شرایط و قوانین استفاده از سرویس‌های تابلو و قوانین حریم خصوصی آن را می‌پذیرید.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA2A7AE),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ] else ...[
              const Text(
                'کد تایید را وارد کنید',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'کد تایید برای شماره ${_mobileController.text} ارسال شد.',
                style: const TextStyle(color: Color(0xFF9AA0A8), fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '● ● ● ● ● ●',
                  hintStyle: TextStyle(color: Colors.grey),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Color(0xFF6F7380)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Color(0xFF6F7380)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _otpController.clear();
                  setState(() {
                    _errorMessage = '';
                    _step = _AuthStep.mobile;
                  });
                },
                child: const Text('ویرایش شماره موبایل'),
              ),
              TextButton(
                onPressed: _secondsToResend == 0 && !_isLoading ? _resendOtp : null,
                child: Text(
                  _secondsToResend == 0
                      ? 'ارسال مجدد کد'
                      : 'ارسال مجدد کد تا ${_formatTime(_secondsToResend)}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 12),
              _AuthButton(
                text: 'ادامه',
                loading: _isLoading,
                onPressed: _submitOtp,
              ),
            ],
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitMobile() async {
    final mobile = _mobileController.text.trim();
    if (!_isValidIranMobile(mobile)) {
      setState(() => _errorMessage = 'شماره موبایل معتبر وارد کنید.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _AuthApi.sendOtp(mobile);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      if (result.success) {
        _step = _AuthStep.otp;
        _secondsToResend = 118;
        _startResendTimer();
      } else {
        _errorMessage = result.message;
      }
    });
  }

  Future<void> _submitOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _errorMessage = 'کد تایید معتبر وارد کنید.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _AuthApi.verifyOtp(
      _mobileController.text.trim(),
      otp,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    if (result.success) {
      _resendTimer?.cancel();
      Get.back();
      Get.snackbar(
        'ورود موفق',
        'با موفقیت وارد شدید.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _errorMessage = result.message);
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _AuthApi.sendOtp(_mobileController.text.trim());

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      if (result.success) {
        _secondsToResend = 118;
        _startResendTimer();
      } else {
        _errorMessage = result.message;
      }
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsToResend == 0) {
        timer.cancel();
        return;
      }

      setState(() => _secondsToResend -= 1);
    });
  }

  bool _isValidIranMobile(String mobile) {
    return RegExp(r'^09\d{9}$').hasMatch(mobile);
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}

class _AuthApi {
  static const _sendOtpApi = 'https://tablo.ir/my_api/auth/send_otp.php';
  static const _verifyOtpApi = 'https://tablo.ir/my_api/auth/verify_otp.php';

  static Future<_AuthResult> sendOtp(String mobile) async {
    try {
      final response = await http.post(
        Uri.parse(_sendOtpApi),
        body: {'mobile': mobile},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return const _AuthResult(false, 'خطا در ارسال کد تایید.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const _AuthResult(false, 'پاسخ سرویس نامعتبر است.');
      }

      final success = decoded['success'] == true;
      final message = decoded['message']?.toString();

      if (!success) {
        return _AuthResult(false, message ?? 'ارسال کد ناموفق بود.');
      }

      return _AuthResult(true, message ?? 'کد تایید ارسال شد.');
    } catch (_) {
      return const _AuthResult(false, 'اتصال به سرویس OTP برقرار نشد.');
    }
  }

  static Future<_AuthResult> verifyOtp(String mobile, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(_verifyOtpApi),
        body: {
          'mobile': mobile,
          'otp': otp,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return const _AuthResult(false, 'خطا در تایید کد.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const _AuthResult(false, 'پاسخ سرویس نامعتبر است.');
      }

      final success = decoded['success'] == true;
      final message = decoded['message']?.toString();

      if (!success) {
        return _AuthResult(false, message ?? 'کد تایید صحیح نیست.');
      }

      return _AuthResult(true, message ?? 'ورود با موفقیت انجام شد.');
    } catch (_) {
      return const _AuthResult(false, 'اتصال به سرویس OTP برقرار نشد.');
    }
  }
}

class _AuthResult {
  const _AuthResult(this.success, this.message);

  final bool success;
  final String message;
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.text,
    required this.onPressed,
    required this.loading,
  });

  final String text;
  final Future<void> Function() onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2947F0),
          disabledBackgroundColor: const Color(0xFF2947F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

enum _AuthStep { mobile, otp }

class _MenuItem {
  const _MenuItem({required this.title, required this.route});

  final String title;
  final String route;
}
