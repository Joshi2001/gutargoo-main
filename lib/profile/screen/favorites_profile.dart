import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class FavoritesScreen extends StatelessWidget {
  final bool fromProfile;
  FavoritesScreen({super.key, this.fromProfile = false});

  final FavoritesController controller = Get.find<FavoritesController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
            onPressed: _goBack,
          ),
          title: Text(
            "My Favorites",
            style: TextStyle(color: Colors.white, fontSize: 20.sp),
          ),
        ),
        body: Obx(
          () {
            if (controller.favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border,
                        color: Colors.white24, size: 48.sp),
                    SizedBox(height: 12.h),
                    Text(
                      "No Favorites yet",
                      style:
                          TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.favorites.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16.w,
                crossAxisSpacing: 16.r,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return _favoriteCard(index);
              },
            );
          },
        ),
      ),
    );
  }
String getSafeImage(String url) {
  if (url.isEmpty) return '';

  if (url.startsWith('http')) {
    return url;
  }

  return '';
}
  void _goBack() {
    if (fromProfile) {
      Get.back();
    } else {
      Get.find<NavigationController>().changeTab(0);
    }
  }

  Widget _favoriteCard(int index) {
  if (index >= controller.favorites.length) return const SizedBox();

  final item = controller.favorites[index];
  final String imageUrl = item.image;

  return GestureDetector(
   onTap: () {
  final item = controller.favorites[index];

  print("🎬 Opening Movie: ${item.id}");

  
  Get.to(
  () => VideoDetailScreen(
     videoId: item.id, 
    key: ValueKey('video_${item.videoTrailer}'),

    videoTrailer: item.videoTrailer,
    videoMoives: item.videoMovies.isNotEmpty
        ? item.videoMovies
        : item.videoTrailer,

    image: item.image,
    subtitle: item.subtitle,
    videoTitle: item.title,
    dis: item.description.isNotEmpty
        ? item.description
        : item.subtitle,

    logoImage: item.logoImage,
    imdbRating: item.imdbRating,
    ageRating: item.ageRating,
    directorInfo: item.directorInfo,
    castInfo: item.castInfo,
    tagline: item.tagline,
    fullStoryline: item.fullStoryline,
    genres: item.genres,
    tags: item.tags,
    language: item.language,
    duration: item.duration,
    releaseYear: item.releaseYear,
  ),
  );
},
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
            ClipRRect(
  borderRadius: BorderRadius.circular(6),
  child: imageUrl.isNotEmpty
      ? Image.network(
          getSafeImage(imageUrl),
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey,
              child: Icon(
                Icons.broken_image,
                color: Colors.white24,
                size: 28.sp,
              ),
            );
          },
        )
      : Container(
          color: Colors.grey,
          child: Icon(
            Icons.movie,
            color: Colors.white24,
            size: 28.sp,
          ),
        ),
),

              Positioned(
                top: 5.h,
                right: 5.w,
                child: GestureDetector(
                onTap: () => controller.removeFavorite(item.id),
                  child: CircleAvatar(
                    radius: 14.r,
                    backgroundColor: Colors.black54,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}