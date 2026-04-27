import 'dart:convert';
import 'dart:math';
import 'package:gutrgoopro/home/model/continue_watching_model.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:http/http.dart' as http;

class ContinueWatchingService {
  static const String baseUrl = 'https://admin.gutargooplus.com';

  static Future<String?> _getToken() async {
    final token = await LocalStore.getToken();
    if (token == null || token.isEmpty) {
      print("❌ No auth token found in LocalStore!");
    } else {
      print("✅ Token found: ${token.substring(0, min(10, token.length))}...");
    }
    return token;
  }
  Future<List<ContinueWatchingItem>> getContinueWatching() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/continue-watching'), 
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📡 GET status continue: ${response.statusCode}");
      print("📦 GET body continue: ${response.body}");

      if (response.statusCode != 200) return [];

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] != true) return [];

      final List<dynamic> data = jsonResponse['data'] ?? [];
      final List<ContinueWatchingItem> result = [];

      for (final item in data) {
        try {
          if (item['movie'] == null) {
            print("⚠️ Skipping null movie item: ${item['_id']}");
            continue;
          }
          result.add(ContinueWatchingItem.fromJson({'data': item}));
        } catch (e) {
          print("❌ Parse error: $e");
        }
      }

      print("✅ Final items: ${result.length}");
      return result;
    } catch (e) {
      print("❌ Service error: $e");
      return [];
    }
  }

  Future<bool> updateWatchProgress({
     String? token,         
    required String movieId,
    required int watchedTime,
    required int duration,
    bool isCompleted = false,
  }) async {
    try {
    String? authToken = token;
    if (authToken == null || authToken.isEmpty) {
      authToken = await LocalStore.getToken();
    }
    
    if (authToken == null || authToken.isEmpty) {
      print("❌ No token available");
      return false;
    }

      final url = Uri.parse('$baseUrl/api/continue-watching/save');     
      print("📡 POST to save: $url");
      print("📦 Body save: ${json.encode({
        'movieId': movieId,
        'watchedTime': watchedTime,
        'duration': duration,
        'isCompleted': isCompleted,
      })}");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'movieId': movieId,
          'watchedTime': watchedTime,
          'duration': duration,
          'isCompleted': isCompleted,
        }),
      );

      print("📡 SAVE status continue: ${response.statusCode}");
      print("📦 SAVE body: continue ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print("❌ Save error: $e");
      return false;
    }
  }

  Future<bool> removeFromContinueWatching(String movieId) async {
  try {
    final token = await LocalStore.getToken(); 
    if (token == null) return false;
    
    final response = await http.delete(
      Uri.parse('$baseUrl/api/continue-watching/$movieId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📡 DELETE status: ${response.statusCode}");
    print("📦 DELETE body: ${response.body}");

    if (response.statusCode != 200) return false;

    final data = json.decode(response.body);
    return data['success'] == true;
  } catch (e) {
    print("❌ delete error: $e");
    return false;
  }
}
}
