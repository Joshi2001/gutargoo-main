import 'package:get/get.dart';
import 'package:gutrgoopro/profile/screen/auth/service/otp_service.dart';
import 'package:gutrgoopro/uitls/local_store.dart';

class LoginController extends GetxController {
  final OtpService _otpService = OtpService();

  final RxBool isSending = false.obs;
  final RxBool isVerifying = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString phoneNumber = ''.obs;

  final RxString authToken = ''.obs;
  final Rx<Map<String, dynamic>> currentUser = Rx<Map<String, dynamic>>({});

  /// Send OTP
  Future<bool> sendOtp(String phone) async {
    isSending.value = true;
    errorMessage.value = '';
    print('📤 [Controller] sendOtp() → phone: $phone');

    final result = await _otpService.sendOtp(phone);
    isSending.value = false;

    if (result['success'] == true) {
      phoneNumber.value = phone;
      print('✅ [Controller] OTP sent');
      return true;
    } else {
      errorMessage.value = result['message'] ?? 'Something went wrong.';
      print('❌ [Controller] sendOtp failed: ${errorMessage.value}');
      return false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (phoneNumber.value.isEmpty) {
      errorMessage.value = 'Phone number is empty';
      return false;
    }

    isVerifying.value = true;
    errorMessage.value = '';
    print('📤 [Controller] verifyOtp() → phone: ${phoneNumber.value} | otp: $otp');

    final result = await _otpService.verifyOtp(phoneNumber.value, otp.trim());
    isVerifying.value = false;

    if (result['success'] == true) {
      final token = result['token'] ?? '';
      final user = result['user'] ?? {};

      authToken.value = token;
      currentUser.value = Map<String, dynamic>.from(user);

      // Persist token and mobile
      await LocalStore.setToken(token);
      await LocalStore.setMobile(user['mobile'] ?? '');

      print('✅ [Controller] OTP verified | token: $token');
      return true;
    } else {
      errorMessage.value = result['message'] ?? 'OTP verification failed.';
      print('❌ [Controller] verifyOtp failed: ${errorMessage.value}');
      return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (phoneNumber.value.isEmpty) return false;
    return await sendOtp(phoneNumber.value);
  }
}