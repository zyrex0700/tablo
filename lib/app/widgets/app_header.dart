import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  static const _menuItems = <_MenuItem>[
    _MenuItem(title: 'صفحه اصلی', route: AppRoutes.home),
    _MenuItem(title: 'تابلوها', route: AppRoutes.billboards),
    _MenuItem(title: 'مجله', route: AppRoutes.magazine),
    _MenuItem(title: 'تماس با ما', route: AppRoutes.contactUs),
  ];

  final _session = Get.isRegistered<_HeaderSession>()
      ? Get.find<_HeaderSession>()
      : Get.put(_HeaderSession(), permanent: true);

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
          Obx(() {
            if (!_session.isLoggedIn.value) {
              return OutlinedButton(
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
              );
            }

            return Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar('افزودن تابلو', 'این بخش به‌زودی تکمیل می‌شود.');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2544FF),
                    side: const BorderSide(color: Color(0xFF2544FF), width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  label: const Text(
                    'افزودن تابلو',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  onSelected: _onAccountMenuSelected,
                  position: PopupMenuPosition.under,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  constraints: const BoxConstraints(minWidth: 250),
                  itemBuilder: (context) => [
                    _menuItem('dashboard', 'داشبورد', Icons.dashboard_outlined),
                    _menuItem('myBoards', 'تابلوهای من', Icons.layers_outlined),
                    _menuItem('profile', 'پروفایل', Icons.person_outline),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: const [
                          Icon(Icons.power_settings_new, color: Color(0xFFEF4444)),
                          SizedBox(width: 10),
                          Text(
                            'خروج از حساب کاربری',
                            style: TextStyle(color: Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD9E1EC)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFE7ECFF),
                          child: Icon(Icons.person_outline, size: 17, color: Color(0xFF3A4BD7)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'حساب کاربری',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _session.mobile.value,
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String title, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: const Color(0xFF4B5563)),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }

  void _onAccountMenuSelected(String value) {
    if (value == 'logout') {
      _session.logout();
      return;
    }

    Get.snackbar('حساب کاربری', 'بخش $value به‌زودی تکمیل می‌شود.');
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
  _AuthStep _step = _AuthStep.mobile;

  @override
  void dispose() {
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
                onPressed: () => setState(() => _step = _AuthStep.mobile),
                child: const Text('ویرایش شماره موبایل'),
              ),
              const Text(
                'ارسال مجدد کد تا ۰۱:۵۸',
                style: TextStyle(color: Color(0xFFA2A7AE), fontSize: 15),
              ),
              const SizedBox(height: 12),
              _AuthButton(
                text: 'ادامه',
                loading: _isLoading,
                onPressed: _submitOtp,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitMobile() async {
    if (_mobileController.text.trim().length < 11) {
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _step = _AuthStep.otp;
      });
    }
  }

  Future<void> _submitOtp() async {
    if (_otpController.text.trim().length < 4) {
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    final session = Get.isRegistered<_HeaderSession>()
        ? Get.find<_HeaderSession>()
        : Get.put(_HeaderSession(), permanent: true);

    session.login(_mobileController.text.trim());
    Get.back();
  }
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

class _HeaderSession extends GetxController {
  final isLoggedIn = false.obs;
  final mobile = '0912•••••••'.obs;

  void login(String mobileNumber) {
    mobile.value = mobileNumber;
    isLoggedIn.value = true;
  }

  void logout() {
    isLoggedIn.value = false;
  }
}

class _MenuItem {
  const _MenuItem({required this.title, required this.route});

  final String title;
  final String route;
}
