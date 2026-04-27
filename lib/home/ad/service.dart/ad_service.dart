import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gutrgoopro/home/ad/ad_model.dart/ad_model.dart';
import 'package:gutrgoopro/home/ad/responce/ad_responce.dart';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class AdService {
  static Future<AdsResponse?> fetchAllAds() async {
    try {
      final response = await http
          .get(Uri.parse(MyApi.ads))
          .timeout(const Duration(seconds: 10));

      debugPrint('📡 HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        return AdsResponse.fromJson(jsonMap);
      } else {
        debugPrint('❌ Ads fetch failed');
        return null;
      }
    } catch (e) {
      debugPrint('❌ AdService error: $e');
      return null;
    }
  }

  /// ✅ SIMPLE + WORKING FILTER
  static AdModel? getActivePrerollAdFromList(List<AdModel> ads) {
    final filtered = ads.where((ad) {
      return ad.isActive == true &&
          ad.vastUrl != null &&
          ad.vastUrl!.isNotEmpty;
    }).toList();

    if (filtered.isEmpty) {
      debugPrint('❌ No valid ads found');
      return null;
    }

    final ad = filtered.first;

    debugPrint('🎬 Selected Ad: ${ad.vastUrl}');
    return ad;
  }
}