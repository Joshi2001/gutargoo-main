import 'dart:convert';
import 'package:gutrgoopro/profile/model/redeem_model.dart';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class RedeemService {
  static final RedeemService _instance = RedeemService._internal();
  factory RedeemService() => _instance;
  RedeemService._internal();

  Future<List<RedeemCode>> getRedeemList(String authToken) async {
    print('🔵 [RedeemService] getRedeemList() called');
    print('🔑 [RedeemService] authToken: $authToken');
    print('🌐 [RedeemService] URL: ${MyApi.redeemGet}');

    try {
      final response = await http.get(
        Uri.parse(MyApi.redeemGet),
        headers: _headers(authToken),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        List<dynamic> list = [];
        if (body is Map<String, dynamic>) {
          if (body['data'] != null && body['data'] is List) {
            list = body['data'];
          } else if (body['codes'] != null && body['codes'] is List) {
            list = body['codes'];
          }
        } else if (body is List) {
          list = body;
        }

        print('🔢 Total codes: ${list.length}');
        return list
            .map((item) => RedeemCode.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        // Specific handling for unauthorized
        throw RedeemException('Unauthorized: Invalid or expired token', 401);
      } else {
        final error = _parseError(response.body);
        throw RedeemException(error, response.statusCode);
      }
    } catch (e) {
      print('💥 getRedeemList EXCEPTION: $e');
      rethrow;
    }
  }

  Future<RedeemResult> redeemCode(String authToken, String code) async {
    print('🔵 [RedeemService] redeemCode() called');
    print('🔑 authToken: $authToken');
    print('🎟️ Code: $code');

    try {
      final response = await http.post(
        Uri.parse(MyApi.redeemPost),
        headers: _headers(authToken),
        body: json.encode({'code': code}),
      );
      
      print('📡 Status Code: ${response.statusCode}');
      print('📦 Raw Response: ${response.body}');

      final body = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RedeemResult(
          success: true,
          message: body['message'] ?? 'Code redeemed successfully!',
          data: body['data'],
        );
      } else if (response.statusCode == 401) {
        throw RedeemException('Unauthorized: Invalid or expired token', 401);
      } else {
        final error = _parseError(response.body);
        throw RedeemException(error, response.statusCode);
      }
    } catch (e) {
      print('💥 redeemCode EXCEPTION: $e');
      rethrow;
    }
  }
  Map<String, String> _headers(String authToken) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

  String _parseError(String responseBody) {
    try {
      final body = json.decode(responseBody);
      if (body is Map<String, dynamic>) {
        return body['message'] ?? body['error'] ?? 'Something went wrong';
      }
      return 'Something went wrong';
    } catch (_) {
      return 'Something went wrong';
    }
  }
}

/// Redeem result
class RedeemResult {
  final bool success;
  final String message;
  final dynamic data;

  RedeemResult({
    required this.success,
    required this.message,
    this.data,
  });
}

/// Redeem exception
class RedeemException implements Exception {
  final String message;
  final int statusCode;

  const RedeemException(this.message, this.statusCode);

  @override
  String toString() => 'RedeemException($statusCode): $message';
}