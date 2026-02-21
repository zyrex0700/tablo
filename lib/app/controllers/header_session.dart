import 'package:get/get.dart';

class HeaderSession extends GetxController {
  final isLoggedIn = false.obs;
  final mobile = '0912•••••••'.obs;
  final token = ''.obs;

  void login(String mobileNumber, {String authToken = ''}) {
    mobile.value = mobileNumber;
    token.value = authToken;
    isLoggedIn.value = true;
  }

  void logout() {
    isLoggedIn.value = false;
    token.value = '';
  }
}
