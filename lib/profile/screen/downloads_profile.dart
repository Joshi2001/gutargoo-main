import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/screen/video_screen.dart';
import 'package:gutrgoopro/profile/getx/download_controller.dart';
import 'package:gutrgoopro/profile/model/download_model.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class DownloadsScreen extends StatelessWidget {
  DownloadsScreen({super.key});

  final DownloadsController downloadsController =
      Get.put(DownloadsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Downloads",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Obx(
        () {
          if (downloadsController.downloads.isEmpty) {
            return _emptyState();
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _summaryCard(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "MY LIBRARY",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              ...List.generate(
                downloadsController.downloads.length,
                (index) => _downloadCard(
                  downloadsController.downloads[index],
                  index,
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.download_for_offline_outlined,
              size: 56,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Downloads Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Save videos to watch offline anytime",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blue.withOpacity(0.25),
            AppColors.blue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.download_done_rounded,
              color: AppColors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    "${downloadsController.downloads.length} Videos",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  )),
              const SizedBox(height: 2),
              const Text(
                "Ready to watch offline",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.green, size: 14),
                SizedBox(width: 5),
                Text(
                  "Offline",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Smart image widget — handles network URL, local file path, and asset
  Widget _buildThumbnail(String imagePath) {
    if (imagePath.startsWith('http')) {
      // 🌐 Network image
      return Image.network(
        imagePath,
        height: 120,
        width: 95,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderThumbnail(),
      );
    } else if (imagePath.startsWith('/')) {
      // 📁 Local file image
      final file = File(imagePath);
      return Image.file(
        file,
        height: 120,
        width: 95,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderThumbnail(),
      );
    } else {
      // 🗂 Asset image
      return Image.asset(
        imagePath,
        height: 120,
        width: 95,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderThumbnail(),
      );
    }
  }

  Widget _placeholderThumbnail() {
    return Container(
      height: 120,
      width: 95,
      color: Colors.grey.shade900,
      child: const Icon(Icons.movie_outlined, color: Colors.white30, size: 28),
    );
  }

  Widget _downloadCard(DownloadItem item, int index) {
    return Obx(() {
      final isDownloading = downloadsController.isDownloading(item.videoTrailer);

      // ✅ Check BOTH: reactive map AND persisted downloadedPath
      final isDownloaded = downloadsController.isItemDownloaded(item.videoTrailer) ||
          (item.downloadedPath != null && item.downloadedPath!.isNotEmpty);

      final progress = downloadsController.getProgress(item.videoTrailer);

      return GestureDetector(
        onTap: isDownloaded && item.downloadedPath != null
            ? () {
                Get.to(() => VideoScreen(
                      url: item.downloadedPath!, // ✅ Local file path
                      title: item.title,
                      image: item.image,
                      similarVideos: const [],
                      vastTagUrl: null,
                    ));
              }
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.blackCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // ✅ Thumbnail with smart loader
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    _buildThumbnail(item.image),

                    // ✅ Play overlay shown when downloaded
                    if (isDownloaded)
                      Positioned(
                        bottom: 8,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.background,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ✅ Progress bar while downloading
                      if (isDownloading)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                  Colors.greenAccent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${(progress * 100).toInt()}%",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                      // ✅ "Tap to play" badge when downloaded
                      if (!isDownloading && isDownloaded)
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.greenAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "Tap to play offline",
                              style: TextStyle(
                                color: Colors.greenAccent.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white38, size: 20),
                onPressed: () => _showDeleteDialog(index),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A2A4F).withOpacity(0.97),
                    const Color(0xFF000000).withOpacity(0.97),
                    const Color(0xFF2B0A3D).withOpacity(0.92),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_forever_rounded,
                      size: 36, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    "Delete Download",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This video will be removed from your offline library.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            downloadsController.deleteItem(index);
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEF4444),
                                  Color(0xFFDC2626)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}