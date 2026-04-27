import 'dart:convert';
import 'dart:io';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadService {
 

  Future<String?> getDownloadUrl(String videoId, String token) async {
    try {
      final url = "${MyApi.download}/$videoId";

      print("📡 URL: $url");

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['url'];
      }

      if (data['message'] == "Stream URL not available") {
        print("⏳ Video still processing...");
        return null;
      }

      print("❌ API Error: ${data['message']}");
    } catch (e) {
      print("❌ API error: $e");
    }

    return null;
  }
  Future<String?> downloadFile({
    required String downloadUrl,
    required String videoId,
    required void Function(double progress) onProgress,
  }) async {
    try {
      if (downloadUrl.endsWith(".m3u8")) {
        print("❌ HLS stream → cannot download");
        return null;
      }

      final request = http.Request('GET', Uri.parse(downloadUrl));

      final response =
          await http.Client().send(request).timeout(const Duration(minutes: 5));

      if (response.statusCode != 200) {
        print("❌ Download failed: ${response.statusCode}");
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();

      final filePath =
          "${appDir.path}/${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4";

      final file = File(filePath);
      final sink = file.openWrite();

      int received = 0;
      final total = response.contentLength ?? 0;

      print("📦 Total size: $total");

      await for (final chunk in response.stream) {
        received += chunk.length;

        if (total != 0) {
          onProgress(received / total);
        }

        sink.add(chunk);
      }

      await sink.close();

      final fileSize = await file.length();
      print("📁 FILE SIZE: $fileSize");

      if (fileSize < 500000) {
        print("❌ Invalid file → deleting");
        await file.delete();
        return null;
      }

      print("✅ Download success: $filePath");
      return filePath;
    } catch (e) {
      print("❌ Download error: $e");
      return null;
    }
  }


  Future<void> deleteFile(String? filePath) async {
    if (filePath == null) return;

    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print("🗑 Deleted: $filePath");
      }
    } catch (e) {
      print("❌ Delete error: $e");
    }
  }
}