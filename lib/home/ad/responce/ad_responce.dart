import 'package:gutrgoopro/home/ad/ad_model.dart/ad_model.dart';

class AdsResponse {
  final bool success;
  final int count;
  final List<AdModel> data;

  AdsResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory AdsResponse.fromJson(Map<String, dynamic> json) {
    return AdsResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((e) => AdModel.fromJson(e))
          .toList(),
    );
  }
}