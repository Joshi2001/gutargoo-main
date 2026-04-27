import 'dart:convert';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class OtpService {
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    print('📤 [OtpService] sendOtp() called with phone: $phone');
    try {
      final url = Uri.parse('${MyApi.sendOtp}');
      final body = jsonEncode({'mobile': phone.trim()});
      print('🌐 [OtpService] POST $url');
      print('📦 [OtpService] Request body: $body');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );
      print('📥 [OtpService] Response status: ${response.statusCode}');
      print('📥 [OtpService] Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        print('✅ [OtpService] OTP sent successfully');
        return {'success': true, 'message': data['message'] ?? 'OTP sent'};
      } else {
        print('❌ [OtpService] Send failed: ${data['message']}');
        return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
      }
    } catch (e, stackTrace) {
      print('💥 [OtpService] sendOtp() exception: $e');
      print('🔍 StackTrace: $stackTrace');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    print('📤 [OtpService] verifyOtp() called — phone: $phone | otp: $otp');

    try {
     final String phoneWithCountryCode = phone.trim().startsWith('91')
    ? phone.trim()
    : '91${phone.trim()}';

      final url = Uri.parse('${MyApi.verifyOtp}');
     final body = jsonEncode({
  'mobile': phoneWithCountryCode, 
  'otp': otp.trim(),
});

      print('🌐 [OtpService] POST $url');
      print('📦 [OtpService] Request body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📥 [OtpService] Status: ${response.statusCode}');
      print('📥 [OtpService] Body: ${response.body}');

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        print('✅ [OtpService] OTP verified successfully');
        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        print('❌ [OtpService] OTP verification failed: ${data['message']}');
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e, stackTrace) {
      print('💥 [OtpService] verifyOtp() exception: $e');
      print('🔍 StackTrace: $stackTrace');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
