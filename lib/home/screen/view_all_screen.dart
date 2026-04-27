import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/view_all_controller.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:shimmer/shimmer.dart';

class ViewAllScreen extends StatefulWidget {
  final String title;
  const ViewAllScreen({super.key, required this.title});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  late final ViewAllController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ViewAllController(), tag: widget.title);
    controller.loadSection(widget.title);
  }

  @override
  void dispose() {
    Get.delete<ViewAllController>(tag: widget.title);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.title.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No content available',
                  style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Section: "${widget.title}"',
                  style: TextStyle(color: Colors.white24, fontSize: 11.sp),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,  // Increased spacing
            mainAxisSpacing: 8.h,   // Increased spacing
            childAspectRatio: 0.65, // Changed from 0.55 for better proportion
          ),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            final String imageUrl = item['image']?.toString() ?? '';
            final String title = item['title']?.toString() ?? '';

            return GestureDetector(
              onTap: () {
                final MovieModel movie = MovieModel.fromLegacyMap(
                  Map<String, dynamic>.from(item),
                );
                Get.to(
                  () => VideoDetailScreen.fromModel(
                    movie,
                    initialPosition: Duration.zero,
                  ),
                  transition: Transition.fadeIn,
                );
              },
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover, // ✅ CHANGED: fill → cover
                                cacheWidth: 400,   // ✅ CHANGED: 120 → 400 (better quality)
                                cacheHeight: 600,  // ✅ ADDED: height cache
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade900,
                                    highlightColor: Colors.grey.shade700,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[850],
                                  child: Icon(
                                    Icons.movie,
                                    color: Colors.white30,
                                    size: 36.sp,
                                  ),
                                ),
                              )
                            : Shimmer.fromColors(
                                baseColor: Colors.grey.shade900,
                                highlightColor: Colors.grey.shade700,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}