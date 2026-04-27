import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/continue_watching_model.dart';
import 'package:gutrgoopro/home/screen/video_screen.dart';

class ContinueWatchingSection extends StatelessWidget {
  const ContinueWatchingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isLoadingContinueWatching.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.continueWatchingList.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
            child: Text(
              "CONTINUE WATCHING",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 10.w),
            child: SizedBox(
              height: 110.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                itemCount: controller.continueWatchingList.length,
                itemBuilder: (context, index) {
                  final item = controller.continueWatchingList[index];
                  return _SimpleContinueWatchingCard(item: item);
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _SimpleContinueWatchingCard extends StatelessWidget {
  final ContinueWatchingItem item;

  const _SimpleContinueWatchingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final movie = item.movie;

    final imageUrl = movie.horizontalBannerUrl.isNotEmpty
        ? movie.horizontalBannerUrl
        : movie.verticalPosterUrl;

    return GestureDetector(
    
        // Get.to(() => VideoScreen(
        //       url: movie.playUrl,
        //       title: movie.movieTitle,
        //       image: imageUrl,
        //       videoId: movie.id,
        //       movieDuration: item.duration,
              
        //       similarVideos: const [],
        //     ));
        onTap: () {
  Get.to(() => VideoScreen(
    url: movie.playUrl,
    title: movie.movieTitle,
    image: imageUrl,
    videoId: movie.id,
    movieDuration: item.duration,
    savedPosition: item.watchedTime, // ← ADD THIS
    similarVideos: const [],
  ));

      },
      child: Container(
        width: 180.w,
        margin: EdgeInsets.only(right: 12.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4.h,
                right: 4.w,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              width: 280.w,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 48,
                                    color: Colors.red.shade400,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    "Remove from Continue Watching?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "This will only remove it from your continue watching list. You can still find it in the app.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 24.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(vertical: 12.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.r),
                                              side: BorderSide(color: Colors.white24),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            controller.removeFromContinueWatching(movie.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Removed from continue watching",
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                backgroundColor: Colors.red.shade800,
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: EdgeInsets.symmetric(vertical: 12.h),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                          ),
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: item.progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.black.withOpacity(0.5),
                  color: Colors.red,
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}