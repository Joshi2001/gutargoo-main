import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gutrgoopro/profile/model/download_model.dart';
import 'package:gutrgoopro/profile/service/download_Service.dart';

class DownloadsController extends GetxController {
  final DownloadService _service = DownloadService();
  static const String _storageKey = 'saved_downloads';

  RxList<DownloadItem> downloads = <DownloadItem>[].obs;

  RxMap<String, RxDouble> downloadProgress = <String, RxDouble>{}.obs;
  RxMap<String, RxBool> downloadingItems = <String, RxBool>{}.obs;
  RxMap<String, RxBool> downloadedItems = <String, RxBool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedDownloads();
  }
  Future<void> _loadSavedDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_storageKey) ?? [];
      final loaded = jsonList
          .map((s) => DownloadItem.fromJson(jsonDecode(s)))
          .toList();
      downloads.assignAll(loaded);
      for (final item in loaded) {
        downloadedItems[item.videoId] = true.obs;
      }
      print("✅ Loaded ${loaded.length} downloads");
    } catch (e) {
      print("❌ Load error: $e");
    }
  }

  Future<void> _persistDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList =
          downloads.map((d) => jsonEncode(d.toJson())).toList();

      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print("❌ Persist error: $e");
    }
  }

  Future<String?> _getUrlWithRetry(String videoId, String token) async {
    for (int i = 0; i < 5; i++) {
      final url = await _service.getDownloadUrl(videoId, token);

      if (url != null) {
        print("✅ URL READY");
        return url;
      }

      print("⏳ Processing... retry ${i + 1}");
      await Future.delayed(const Duration(seconds: 3));
    }

    return null;
  }
  Future<void> downloadVideo({
    required String videoId,
    required String videoTitle,
    required String subtitle,
    required String image,
    required String videoTrailer,
    required String token,
  }) async {
    try {
      if (token.isEmpty) {
        print("❌ TOKEN EMPTY");
        return;
      }
      if (downloadingItems[videoId]?.value == true) return;

      downloadProgress[videoId] = 0.0.obs;
      downloadingItems[videoId] = true.obs;
      downloadedItems[videoId] = false.obs;

      Get.snackbar("Processing", "Preparing your video...");

      final downloadUrl = await _getUrlWithRetry(videoId, token);

      if (downloadUrl == null) {
        downloadingItems[videoId]?.value = false;

        Get.snackbar("Error", "Video not ready yet. Try again later.");
        return;
      }

      if (downloadUrl.endsWith(".m3u8")) {
        downloadingItems[videoId]?.value = false;

        Get.snackbar("Streaming Only", "Download not available for this video");
        return;
      }

      Get.snackbar("Downloading", "Download started...");

      final filePath = await _service.downloadFile(
        downloadUrl: downloadUrl,
        videoId: videoId,
        onProgress: (progress) {
          downloadProgress[videoId]?.value = progress;
        },
      );

      downloadingItems[videoId]?.value = false;

      if (filePath != null) {
        downloadedItems[videoId]?.value = true;
        downloadProgress[videoId]?.value = 1.0;

        _addDownload(DownloadItem(
          videoId: videoId, 
          title: videoTitle,
          subtitle: subtitle,
          image: image,
          videoTrailer: videoTrailer,
          downloadedPath: filePath,
          downloadedAt: DateTime.now(),
        ));

        Get.snackbar("Success", "Download completed");
      } else {
        downloadedItems[videoId]?.value = false;
        downloadProgress[videoId]?.value = 0.0;

        Get.snackbar("Error", "Download failed");
      }
    } catch (e) {
      print("❌ Download error: $e");

      downloadingItems[videoId]?.value = false;
      Get.snackbar("Error", "Something went wrong");
    }
  }

  void _addDownload(DownloadItem item) {
    if (!downloads.any((d) => d.videoId == item.videoId)) {
      downloads.add(item);
      _persistDownloads();
    }
  }

  Future<void> deleteItem(int index) async {
    if (index < 0 || index >= downloads.length) return;

    final item = downloads[index];

    await _service.deleteFile(item.downloadedPath);

    downloads.removeAt(index);

    downloadedItems.remove(item.videoId);
    downloadProgress.remove(item.videoId);
    downloadingItems.remove(item.videoId);

    await _persistDownloads();
  }

  double getProgress(String videoId) =>
      downloadProgress[videoId]?.value ?? 0.0;

  bool isDownloading(String videoId) =>
      downloadingItems[videoId]?.value ?? false;

  bool isItemDownloaded(String videoId) =>
      downloadedItems[videoId]?.value ?? false;

  bool isDownloaded(String videoId) =>
      downloads.any((e) => e.videoId == videoId);
}