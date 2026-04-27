import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class FavoriteService {
 
  Future<bool> likeMovie(String movieId, String token) async {
    try {
      print("👉 LIKE API (GET) CALLED");
      print("📌 Movie ID: $movieId");
      final url = "${MyApi.like}/$movieId";
      print("🌐 URL: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      print("👍 LIKE STATUS: ${response.statusCode}");
      print("📦 RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Like API Error: $e");
      return false;
    }
  }
  Future<bool> unlikeMovie(String movieId, String token) async {
    try {
      print("👉 UNLIKE API (GET) CALLED");
      print("📌 Movie ID: $movieId");

      final url = "${MyApi.like}/$movieId"; 
      print("🌐 URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("👎 UNLIKE STATUS: ${response.statusCode}");
      print("📦 RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Unlike API Error: $e");
      return false;
    }
  }
}