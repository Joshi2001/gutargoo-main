import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gutrgoopro/home/pop_up/model/pop_model.dart';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class PopupService {
  static Future<PopupModel?> fetchPopup() async {
    try {
      final response = await http.get(
        Uri.parse(MyApi.mainPopup),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final popup = PopupModel.fromJson(json['data']);
          if (popup.isActive && popup.image.isNotEmpty) {
            return popup;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Popup fetch error: $e');
    }
    return null;
  }
}