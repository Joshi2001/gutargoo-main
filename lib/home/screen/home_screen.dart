import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/web_series_model.dart';
import 'package:gutrgoopro/home/screen/continue_watch_screen.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/home/service/banner_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/screen/view_all_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';
import 'package:gutrgoopro/widget/go_pro.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());
  final ScrollController scrollController = ScrollController();
  late final PageController heroController;
  final FavoritesController favoritesController =
      Get.find<FavoritesController>();
  bool _popupShown = false;
  int _currentIndex = 0;
  List<Color> _bannerTopColors = [];
  bool _isRefreshing = false;

  LinearGradient get _topGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_getCurrentColor(), _getCurrentColor()],
      );

  LinearGradient get _bannerGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _getCurrentColor(),
          _getCurrentColor(),
          const Color(0xFF000000),
          const Color(0xFF000000),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

  @override
  void initState() {
    super.initState();
    heroController = PageController(viewportFraction: 0.96, initialPage: 1);

    ever(controller.featuredMovies, (_) {
      if (controller.bannerMovies.isEmpty) _extractColors();
    });

    ever(controller.homePopup, (_) => _maybeShowPopup());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.bannerMovies.isNotEmpty ||
          controller.featuredMovies.isNotEmpty) {
        _extractColors();
      }
      _maybeShowPopup();
    });
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    setState(() => _bannerTopColors = []);
    await controller.fetchHomeData();
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _maybeShowPopup() {
    if (_popupShown) return;
    if (!mounted) return;

    final popup = controller.homePopup.value;
    if (popup == null || !popup.isActive || popup.image.isEmpty) return;

    _popupShown = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.0),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) =>
          _ImagePopupDialog(imageUrl: popup.image),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _extractColors() async {
    final List<Color> colors = [];
    final validBanners = controller.bannerMovies
        .where((b) => b.publishStatus && b.mobileImage.isNotEmpty)
        .toList();
debugPrint('🔍 VALID BANNERS (all): ${validBanners.length}');
    final sourceList = validBanners.isNotEmpty
        ? validBanners.cast<dynamic>()
        : controller.featuredMovies.cast<dynamic>();

    for (final item in sourceList) {
      try {
        String imageUrl = '';
        if (item is BannerMovie) {
          imageUrl =
              item.mobileImage.isNotEmpty ? item.mobileImage : item.logoImage;
        } else if (item is MovieModel) {
          imageUrl = item.verticalPosterUrl;
        }
        final color = imageUrl.isNotEmpty
            ? await _dominantColorFromNetwork(imageUrl)
            : const Color(0xFF000000);
        colors.add(color);
      } catch (_) {
        colors.add(const Color(0xFF000000));
      }
    }

    if (mounted) setState(() => _bannerTopColors = colors);
  }

  Future<Color> _dominantColorFromNetwork(String url) async {
    try {
      final imageProvider = NetworkImage(url);
      final completer = Completer<ui.Image>();
      final stream = imageProvider.resolve(const ImageConfiguration());
      late ImageStreamListener listener;
      listener = ImageStreamListener((info, _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      });
      stream.addListener(listener);
      final image = await completer.future;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return const Color(0xFF000000);
      final pixels = byteData.buffer.asUint8List();
      int r = 0, g = 0, b = 0, count = 0;
      for (int i = 0; i < pixels.length; i += 40) {
        r += pixels[i];
        g += pixels[i + 1];
        b += pixels[i + 2];
        count++;
      }
      return Color.fromARGB(
          255, (r / count).round(), (g / count).round(), (b / count).round());
    } catch (_) {
      return const Color(0xFF000000);
    }
  }

  Color _getCurrentColor() {
    if (_bannerTopColors.isEmpty) return const Color(0xFF000000);
    final index = (_currentIndex >= _bannerTopColors.length)
        ? _bannerTopColors.length - 1
        : _currentIndex;
    return _bannerTopColors[index];
  }

  @override
  void dispose() {
    scrollController.dispose();
    heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _getCurrentColor().computeLuminance() > 0.5
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            color: _getCurrentColor(),
            child: SafeArea(
              top: true,
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Colors.white,
                backgroundColor: Colors.grey.shade900,
                displacement: 20,
                edgeOffset: 160.h,
                strokeWidth: 2.5,
                child: CustomScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  slivers: [
                    SliverAppBar(
                      pinned: false,
                      floating: false,
                      snap: false,
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      flexibleSpace: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(gradient: _topGradient),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.w, right: 8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 10.w, top: 5.h),
                                child: Image.asset("assets/Bevel.png",
                                    height: 120.h, width: 140.w),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h, right: 10.w),
                                child: GoProButton(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: CategorySelectorDelegate(
                        child: _categorySelector(),
                        height: 52.h,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.zero,
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _heroBannerSection(),
                          _dynamicSections(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categorySelector() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(left: 10.w, right: 8.w),
        decoration: BoxDecoration(gradient: _topGradient),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(controller.categoryNames.length, (index) {
              final isSelected =
                  controller.selectedCategoryIndex.value == index;
              return GestureDetector(
                onTap: () => _onCategoryTap(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.categoryNames[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 14.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(int index) {
    controller.selectCategory(index);
    setState(() {
      _bannerTopColors = [];
      _currentIndex = 0;
    });
    ever(controller.bannerMovies, (_) => _extractColors());

    // Add debug
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.debugCategoryFiltering();
    });
  }

//   Widget _heroBannerSection() {
//     return Obx(() {
//        debugPrint('🔍 ALL BANNERS COUNT: ${controller.bannerMovies.length}');
//     for (var b in controller.bannerMovies) {
//       debugPrint('   Banner: "${b.title}" - hasImage: ${b.mobileImage.isNotEmpty} - publishStatus: ${b.publishStatus} - language: "${b.language}" - genres: ${b.genres}');
//     }
    
//     final bannersWithImages = controller.bannerMovies
//     .where((b) => b.publishStatus && b.mobileImage.isNotEmpty)
//     .toList();

// // Second: banners with content (language or genres) even without images
// final bannersWithContent = controller.bannerMovies
//     .where((b) => b.publishStatus && (b.language.isNotEmpty || b.genres.isNotEmpty))
//     .toList();

// // Use bannersWithImages if available, otherwise use bannersWithContent
// final validBanners = bannersWithImages.isNotEmpty ? bannersWithImages : bannersWithContent;

// debugPrint('🔍 VALID BANNERS: ${validBanners.length} (images: ${bannersWithImages.length}, content: ${bannersWithContent.length})');
//     debugPrint('🔍 VALID BANNERS COUNT: ${validBanners.length}');
//       // final validBanners = controller.bannerMovies
//       //     .where((b) => b.publishStatus && b.mobileImage.isNotEmpty)
//       //     .toList();
//       if (controller.isLoadingBanners.value) {
//         return SizedBox(height: 440.h, child: _heroBannerShimmer());
//       }
//       if (validBanners.isEmpty && controller.featuredMovies.isEmpty) {
//         return SizedBox(height: 20.h);
//       }

//       final sourceList = validBanners.isNotEmpty
//           ? validBanners.cast<dynamic>()
//           : controller.featuredMovies.cast<dynamic>();
//       final banners = _looping(sourceList);
Widget _heroBannerSection() {
  return Obx(() {
    debugPrint('🔍 ALL BANNERS COUNT: ${controller.bannerMovies.length}');
    for (var b in controller.bannerMovies) {
      debugPrint('   Banner: "${b.title}" - hasImage: ${b.mobileImage.isNotEmpty} - publishStatus: ${b.publishStatus} - language: "${b.language}" - genres: ${b.genres}');
    }

    // ✅ FIXED: Images wale banners PEHLE, content filter secondary
    final bannersWithImages = controller.bannerMovies
        .where((b) => b.publishStatus && b.mobileImage.isNotEmpty)
        .toList();

    final allPublished = controller.bannerMovies
        .where((b) => b.publishStatus)
        .toList();

    final validBanners = bannersWithImages.isNotEmpty 
        ? bannersWithImages 
        : allPublished;

    debugPrint('🔍 VALID BANNERS: ${validBanners.length} (withImages: ${bannersWithImages.length})');

    if (controller.isLoadingBanners.value) {
      return SizedBox(height: 440.h, child: _heroBannerShimmer());
    }
    if (validBanners.isEmpty && controller.featuredMovies.isEmpty) {
      return SizedBox(height: 20.h);
    }

    final sourceList = validBanners.isNotEmpty
        ? validBanners.cast<dynamic>()
        : controller.featuredMovies.cast<dynamic>();
    final banners = _looping(sourceList);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.bounceInOut,
      decoration: BoxDecoration(gradient: _bannerGradient),
      child: SizedBox(
        height: 450.h,
        child: PageView.builder(
          controller: heroController,
          itemCount: banners.length,
          physics: const PageScrollPhysics(),
          onPageChanged: (index) {
            final len = sourceList.length;
            _currentIndex = (index - 1 + len) % len;
            if (index == 0) {
              Future.delayed(
                const Duration(milliseconds: 300),
                () => heroController.jumpToPage(banners.length - 2),
              );
              setState(() => _currentIndex = len - 1);
            } else if (index == banners.length - 1) {
              Future.delayed(
                const Duration(milliseconds: 300),
                () => heroController.jumpToPage(1),
              );
              setState(() => _currentIndex = 0);
            } else {
              setState(() => _currentIndex = index - 1);
            }
          },
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: heroController,
              builder: (context, _) {
                double page = heroController.hasClients &&
                        heroController.position.haveDimensions
                    ? heroController.page!
                    : heroController.initialPage.toDouble();
                final pageOffset = page - index;
                return _heroCard(banners[index], pageOffset);
              },
            );
          },
        ),
      ),
    );
  });
}

  List<dynamic> _looping(List<dynamic> list) {
    if (list.isEmpty) return [];
    return [list.last, ...list, list.first];
  }

//   Widget _heroCard(dynamic item, double pageOffset) {
//     late String titleText;
//     late String logoUrl;
//     late String bannerUrl;
//     late VoidCallback onWatchNow;

//    if (item is BannerMovie) {
//   debugPrint('📺 BANNER: ${item.title} | language: "${item.language}" | genres: ${item.genres}');
//   titleText = item.title;
//   logoUrl = item.logoImage;
//   // Agar mobileImage nahi hai to logoImage use karo, nahi to default
//   bannerUrl = item.mobileImage.isNotEmpty 
//       ? item.mobileImage 
//       : (item.logoImage.isNotEmpty ? item.logoImage : '');
//   onWatchNow = () => _navigateToBannerDetail(item);
// } else if (item is MovieModel) {
//       titleText = item.movieTitle;
//       logoUrl = item.logoUrl;
//       bannerUrl = item.horizontalBannerUrl.isNotEmpty
//           ? item.horizontalBannerUrl
//           : item.verticalPosterUrl;
//       onWatchNow = () => _navigateToDetail(item);
//     } else {
//       return const SizedBox.shrink();
//     }

//     final bgParallax = pageOffset * 230;
//     final fgParallax = pageOffset * 20;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 3.w),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8.r),
//         child: Stack(
//           children: [
//             // Transform.translate(
//             //   offset: Offset(bgParallax, 0),
//             //   child: _buildBannerImage(bannerUrl),
//             // ),
//             Transform.translate(
//   offset: Offset(bgParallax, 0),
//   child: _buildBannerImage(bannerUrl, title: titleText, logoUrl: logoUrl),
// ),
//             Container(
//               height: 450.h,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.black54, Colors.transparent, Colors.black87],
//                 ),
//               ),
//             ),
//             // Positioned(
//             //   left: 20.w - fgParallax,
//             //   right: 20.w + fgParallax,
//             //   bottom: 20.h,
//             //   child: Column(
//             //     children: [
//             //       logoUrl.isNotEmpty
//             //           ? _cdnImage(logoUrl,
//             //               height: 50.h, width: 200.w, fit: BoxFit.contain)
//             //           : Text(titleText,
//             //               style:
//             //                   TextStyle(color: Colors.white, fontSize: 18.sp)),
//             //       SizedBox(height: 10.h),
//             //       GestureDetector(
//             //         onTap: onWatchNow,
//             //         child: Container(
//             //           padding: EdgeInsets.symmetric(
//             //               horizontal: 18.w, vertical: 10.h),
//             //           decoration: BoxDecoration(
//             //             color: Colors.white,
//             //             borderRadius: BorderRadius.circular(6),
//             //           ),
//             //           child: Row(
//             //             mainAxisSize: MainAxisSize.min,
//             //             children: [
//             //               const Icon(Icons.play_arrow, color: Colors.black),
//             //               SizedBox(width: 4.w),
//             //               const Text("Watch Now",
//             //                   style: TextStyle(color: Colors.black)),
//             //             ],
//             //           ),
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//          Positioned(
//   left: 20.w - fgParallax,
//   right: 20.w + fgParallax,
//   bottom: 20.h,
//   child: Column(
//     children: [
//       logoUrl.isNotEmpty
//           ? _cdnImage(logoUrl,
//               height: 50.h, width: 200.w, fit: BoxFit.contain)
//           : Text(titleText,
//               style: TextStyle(color: Colors.white, fontSize: 18.sp)),
//       SizedBox(height: 10.h),
//       // ✅ MOVED HERE - Show language and genre ABOVE watch now button
//       if (item is BannerMovie) _buildInfoRow(item),
//       SizedBox(height: 8.h), // Add small gap between info and button
//       GestureDetector(
//         onTap: onWatchNow,
//         child: Container(
//           padding: EdgeInsets.symmetric(
//               horizontal: 18.w, vertical: 10.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.play_arrow, color: Colors.black),
//               SizedBox(width: 4.w),
//               const Text("Watch Now",
//                   style: TextStyle(color: Colors.black)),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
//           ],
//         ),
//       ),
//     );
//   }
Widget _heroCard(dynamic item, double pageOffset) {
  late String titleText;
  late String logoUrl;
  late String bannerUrl;
  late VoidCallback onWatchNow;

  if (item is BannerMovie) {
    debugPrint('📺 BANNER: ${item.title} | mobileImage: "${item.mobileImage}" | logoImage: "${item.logoImage}"');
    titleText = item.title;
    logoUrl = item.logoImage;  
    bannerUrl = item.mobileImage.isNotEmpty
        ? item.mobileImage
        : '';  
    onWatchNow = () => _navigateToBannerDetail(item);
  } else if (item is MovieModel) {
    titleText = item.movieTitle;
    logoUrl = item.logoUrl;
    bannerUrl = item.horizontalBannerUrl.isNotEmpty
        ? item.horizontalBannerUrl
        : item.verticalPosterUrl;
    onWatchNow = () => _navigateToDetail(item);
  } else {
    return const SizedBox.shrink();
  }

  final bgParallax = pageOffset * 230;
  final fgParallax = pageOffset * 20;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 3.w),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(bgParallax, 0),
            child: _buildBannerImage(bannerUrl, title: titleText, logoUrl: logoUrl),
          ),
          Container(
            height: 450.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Positioned(
            left: 20.w - fgParallax,
            right: 20.w + fgParallax,
            bottom: 20.h,
            child: Column(
              children: [
                if (logoUrl.isNotEmpty)
                  _cdnImage(
                    logoUrl,
                    height: 40.h,
                    width: 220.w,
                    fit: BoxFit.contain,
                    errorWidget: Text(
                      titleText,
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Text(
                    titleText,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 2.h),
                if (item is BannerMovie) _buildInfoRow(item),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: onWatchNow,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow, color: Colors.black),
                        SizedBox(width: 4.w),
                        const Text("Watch Now",
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBannerImage(String url, {String? title, String? logoUrl}) {
  if (url.isNotEmpty) {
    return _cdnImage(
      url,
      height: 450.h,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingWidget: _heroBannerShimmer(),
      errorWidget: _buildFallbackContent(title, logoUrl),
    );
  }
  return _buildFallbackContent(title, logoUrl);
}

Widget _buildFallbackContent(String? title, String? logoUrl) {
  return Container(
    height: 450.h,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey.shade900, Colors.grey.shade800],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (logoUrl != null && logoUrl.isNotEmpty)
            _cdnImage(logoUrl, height: 80.h, width: 200.w, fit: BoxFit.contain)
          else
            Icon(Icons.movie_creation, color: Colors.white.withOpacity(0.3), size: 80.sp),
          SizedBox(height: 16.h),
          Text(
            title ?? 'Coming Soon',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Watch Now',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14.sp),
          ),
        ],
      ),
    ),
  );
}

  Widget _heroBannerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade800,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 420.h,
            width: double.infinity,
            color: Colors.grey.shade900,
          ),
        ),
      ),
    );
  }
// Widget _buildInfoRow(BannerMovie banner) {
//   final List<String> infoItems = [];

//   if (banner.language.isNotEmpty) {
//     infoItems.add(banner.language);
//   }

//   final validGenres = banner.genres.where((g) => g.trim().isNotEmpty).toList();
//   infoItems.addAll(validGenres);

//   if (infoItems.isEmpty) return const SizedBox.shrink();

//   return Wrap(
//     alignment: WrapAlignment.center,
//     spacing: 0,
//     children: [
//       for (int i = 0; i < infoItems.length; i++) ...[
//         if (i > 0)
//           Text(
//             ' • ',
//             style: TextStyle(color: Colors.white54, fontSize: 12.sp),
//           ),
//         Text(
//           infoItems[i],
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 11.sp,
//             fontWeight: FontWeight.w500,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ],
//     ],
//   );
// }
Widget _buildInfoRow(BannerMovie banner) {
  final List<String> infoItems = [];

  // Language — trim karke check karo
  final lang = banner.language.trim();
  if (lang.isNotEmpty) infoItems.add(lang);

  // Genres — filter empty + duplicates
  final genres = banner.genres
    .map((g) => g.trim())
    .where((g) => g.isNotEmpty)
    .toSet() // duplicates hatao
    .toList();
  infoItems.addAll(genres);

  if (infoItems.isEmpty) return const SizedBox.shrink();

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < infoItems.length; i++) ...[
        if (i > 0)
          Text(
            ' • ',
            style: TextStyle(color: Colors.white54, fontSize: 12.sp),
          ),
        Text(
          infoItems[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    ],
  );
}
  Widget _dynamicSections() {
    return Obx(() {
      if (controller.isLoadingHome.value) {
        return Column(
          children: List.generate(
            4,
            (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeaderShimmer(),
                _posterRowShimmer(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }

      final isHomeCategory = controller.selectedCategoryIndex.value == 0;
      final hasContinueWatching =
          isHomeCategory && controller.continueWatchingList.isNotEmpty;
      final selectedType = controller.selectedCategory?.type;

      // 🔍 DEBUGGING: Print category info
      debugPrint(
          '🔍 Selected Category: ${controller.selectedCategory?.name} (index: ${controller.selectedCategoryIndex.value})');
      debugPrint('🔍 Selected Type: $selectedType');
      debugPrint(
          '🔍 Total sections before filter: ${controller.homeSections.length}');

      final sections = controller.homeSections;

      final visibleSections = sections.where((s) {
        final filtered = s.itemsForType(selectedType);
        debugPrint('  📂 Section "${s.title}" - Filtered: ${filtered.length}');
        return filtered.isNotEmpty;
      }).toList();

// FALLBACK: If no sections with filter, show sections that have ANY items
      final sectionsToShow = visibleSections.isNotEmpty
          ? visibleSections
          : sections.where((s) => s.allDisplayItems.isNotEmpty).toList();

      if (sectionsToShow.isEmpty && selectedType != null) {
        // Second fallback: ignore type filter completely
        debugPrint(
            '⚠️ No sections found with type filter, showing all sections');
        final allSectionsWithItems =
            sections.where((s) => s.allDisplayItems.isNotEmpty).toList();
        if (allSectionsWithItems.isNotEmpty) {
          return Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allSectionsWithItems
                  .map((s) =>
                      _sectionBlock(s, null)) // Pass null to show all items
                  .toList(),
            ),
          );
        }
      }

      debugPrint('✅ Visible sections after filter: ${visibleSections.length}');

      final hasSections = visibleSections.isNotEmpty;

      if (!hasContinueWatching && !hasSections) {
        return Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_outlined, color: Colors.white54, size: 64.sp),
                SizedBox(height: 16.h),
                Text('No content available',
                    style: TextStyle(color: Colors.white54, fontSize: 14.sp)),
                SizedBox(height: 8.h),
                Text('Pull down to refresh',
                    style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
              ],
            ),
          ),
        );
      }

      return Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasContinueWatching) ...[
              ContinueWatchingSection(),
              SizedBox(height: 16.h),
            ],
            if (hasSections)
              ...visibleSections.map((s) => _sectionBlock(s, selectedType)),
            if (!hasSections && hasContinueWatching)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text('More content coming soon!',
                      style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _sectionBlock(HomeSectionModel section, String? selectedType) {
    final displayItems = section.itemsForType(selectedType);

    // 🔍 DEBUGGING: Print section details
    debugPrint('📦 Section: "${section.title}"');
    debugPrint('  - Display style: ${section.displayStyle}');
    debugPrint('  - Total items: ${section.allDisplayItems.length}');
    debugPrint('  - Filtered items: ${displayItems.length}');
    debugPrint('  - Selected type: $selectedType');

    if (displayItems.isEmpty) {
      debugPrint(
          '  ⚠️ Section "${section.title}" has no items after filtering');
      return const SizedBox.shrink();
    }

    // Show first 3 items for debugging
    for (final item in displayItems.take(3)) {
      debugPrint('  🎬 ${item.title} | poster: "${item.verticalPosterUrl}"');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(section.title),
        _buildSectionList(section, displayItems),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSectionList(HomeSectionModel section, List<SectionItem> items) {
    switch (section.displayStyle) {
      case 'index_vertical':
        return _indexVerticalList(items);
      case 'horizontal_banner':
        return _horizontalBannerList(items);
      case 'big_vertical':
        return _verticalList(items);
      default:
        return _standardPosterList(items);
    }
  }

  Widget _indexVerticalList(List<SectionItem> items) {
    final limited = items.take(10).toList();
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 40.w, right: 30.w),
        itemCount: limited.length,
        itemBuilder: (ctx, i) => _top10Card(item: limited[i], rank: i + 1),
      ),
    );
  }

  Widget _horizontalBannerList(List<SectionItem> items) {
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 15.w),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final imageUrl = item.horizontalBannerUrl.isNotEmpty
              ? item.horizontalBannerUrl
              : item.verticalPosterUrl;
          return GestureDetector(
            onTap: () => _navigateToSectionItem(item),
            child: Container(
              width: 180.w,
              margin: EdgeInsets.only(right: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: imageUrl.isNotEmpty
                    ? _cdnImage(imageUrl,
                        height: 100.h,
                        width: 200.w,
                        fit: BoxFit.cover,
                        loadingWidget:
                            _shimmerBase(child: Container(color: Colors.white)),
                        errorWidget: _imagePlaceholder())
                    : _imagePlaceholder(),
              ),
            ),
          );
        },
      ),
    );
  }

  final currentPage = 0.obs;

  Widget _verticalList(List<SectionItem> items) {
    return Column(
      children: [
        SizedBox(
          height: 450.h,
          child: PageView.builder(
            controller: PageController(viewportFraction: 1),
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (int page) {
              currentPage.value = page;
            },
            itemBuilder: (ctx, i) {
              final item = items[i];
              final imageUrl = item.bigVerticalUrl.isNotEmpty
                  ? item.bigVerticalUrl
                  : item.verticalPosterUrl;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: GestureDetector(
                  onTap: () => _navigateToSectionItem(item),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: imageUrl.isNotEmpty
                          ? _cdnImage(imageUrl,
                              height: 400.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingWidget: _shimmerBase(
                                  child: Container(color: Colors.white)),
                              errorWidget: _imagePlaceholder())
                          : _imagePlaceholder(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 4.h,
                  width: currentPage.value == index ? 24.w : 8.w,
                  decoration: BoxDecoration(
                    color: currentPage.value == index
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _standardPosterList(List<SectionItem> items) {
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 15.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => _navigateToSectionItem(item),
            child: Container(
              width: 120.w,
              margin: EdgeInsets.only(right: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: item.verticalPosterUrl.isNotEmpty
                    ? _cdnImage(item.verticalPosterUrl,
                        height: 170.h,
                        width: 120.w,
                        fit: BoxFit.cover,
                        loadingWidget: _shimmerBase(
                          child: Container(
                              height: 170.h,
                              width: 120.w,
                              color: Colors.grey.shade800),
                        ),
                        errorWidget: _imagePlaceholder())
                    : _imagePlaceholder(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _top10Card({required SectionItem item, required int rank}) {
    return GestureDetector(
      onTap: () => _navigateToSectionItem(item),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 50.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: -30.w, bottom: 5.h, child: _rankNumber(rank)),
            Positioned(
              left: 30.w,
              top: 5.h,
              bottom: 5.h,
              child: Hero(
                tag: 'top10_${item.id}_$rank',
                child: Container(
                  width: 120.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: item.verticalPosterUrl.isNotEmpty
                        ? _cdnImage(item.verticalPosterUrl,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingWidget: _shimmerBase(
                                child: Container(color: Colors.white)),
                            errorWidget: Container(color: Colors.grey.shade800))
                        : Container(color: Colors.grey.shade800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rankNumber(int rank) {
    final strokeStyle = (Paint p) => TextStyle(
          fontSize: 145.sp,
          fontWeight: FontWeight.w900,
          height: 0.82,
          letterSpacing: -5,
          fontFamily: 'Impact',
          foreground: p,
        );
    return Stack(
      children: [
        Text('$rank',
            style: strokeStyle(Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12.w
              ..color = Colors.black)),
        Text('$rank',
            style: strokeStyle(Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8.w
              ..color = Colors.grey.shade900)),
        Text(
          '$rank',
          style: TextStyle(
            fontSize: 145.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.82,
            letterSpacing: -5,
            fontFamily: 'Impact',
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.9),
                blurRadius: 25,
                offset: const Offset(3, 3),
              ),
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section header ───────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => Get.to(() => ViewAllScreen(title: title)),
            child: Text('View All',
                style: TextStyle(color: AppColors.orange, fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeaderShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: _shimmerBase(
        child: Container(
          width: 140.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }

  Widget _posterRowShimmer() {
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 15.w),
        itemCount: 6,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey.shade900,
          highlightColor: Colors.grey.shade800,
          child: Container(
            width: 100.w,
            height: 170.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _shimmerBase({required Widget child}) => Shimmer.fromColors(
        baseColor: Colors.grey.shade900,
        highlightColor: Colors.grey.shade700,
        child: child,
      );

  Widget _imagePlaceholder() => Container(
        color: Colors.grey.shade800,
        child: Icon(Icons.movie, color: Colors.white54, size: 24.sp),
      );

  Widget _cdnImage(
    String url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    if (url.isEmpty)
      return errorWidget ?? Container(color: Colors.grey.shade800);

    // Cap at 2× logical size, max 400px — prevents OOM on high-DPI screens
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio
        .clamp(1.0, 2.0); // cap DPR at 2x
    final cacheW = (width != null && width.isFinite)
        ? (width * dpr).round().clamp(1, 400)
        : null;
    final cacheH = (height != null && height.isFinite)
        ? (height * dpr).round().clamp(1, 800)
        : null;

    return CachedNetworkImage(
      imageUrl: url,
      height: height, width: width, fit: fit,
      memCacheWidth: cacheW,
      memCacheHeight: cacheH,
      maxWidthDiskCache: 400, // also cap disk cache
      filterQuality: FilterQuality.medium, // was high — saves memory
      httpHeaders: const {'Accept': 'image/webp,image/png,image/*'},
      placeholder: (_, __) =>
          loadingWidget ??
          _shimmerBase(child: Container(color: Colors.grey.shade800)),
      errorWidget: (ctx, url, err) {
        debugPrint('❌ Image error: $url → $err');
        return errorWidget ?? Container(color: Colors.grey.shade800);
      },
    );
  }

  void _navigateToSectionItem(SectionItem item) {
    debugPrint('🎯 Navigating to: ${item.title}');
    debugPrint('   Type: ${item.type}');
    debugPrint('   isMovie: ${item.isMovie}');
    debugPrint('   isWebSeries: ${item.isWebSeries}');
    debugPrint('   has webSeries object: ${item.webSeries != null}');

    if (item.isWebSeries && item.webSeries != null) {
      debugPrint('✅ Navigating to Web Series: ${item.webSeries!.title}');
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            VideoDetailScreen.fromWebSeries(item.webSeries!),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ));
    } else if (item.isMovie && item.movie != null) {
      debugPrint('✅ Navigating to Movie: ${item.movie!.movieTitle}');
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => VideoDetailScreen.fromModel(item.movie!,
            initialPosition: Duration.zero),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ));
    } else {
      debugPrint('⚠️ Cannot navigate: item has no valid content');
      debugPrint('   movie: ${item.movie}');
      debugPrint('   webSeries: ${item.webSeries}');
    }
  }

  void _navigateToDetail(MovieModel movie,
      {Duration resumePosition = Duration.zero}) async {
    if (movie.isPartial) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );
      try {
        final fullMovie = await BannerMovieService.fetchMovieDetail(movie.id);
        Get.back();
        if (fullMovie != null && mounted) {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => VideoDetailScreen.fromModel(
              fullMovie as MovieModel,
              initialPosition: resumePosition,
            ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ));
        }
      } catch (_) {
        Get.back();
        Get.snackbar('Error', 'Failed to load movie details',
            backgroundColor: Colors.grey.shade900, colorText: Colors.white);
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) =>
          VideoDetailScreen.fromModel(movie, initialPosition: resumePosition),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ));
  }

  void _navigateToBannerDetail(BannerMovie banner) async {
    debugPrint('🎬 Banner clicked: ${banner.title}');
    debugPrint('   isWebSeries: ${banner.isWebSeries}');
    debugPrint('   effectiveWebSeriesId: ${banner.effectiveWebSeriesId}');
    debugPrint('   webSeriesDetails: ${banner.webSeriesDetails != null}');

    // Check if it's a web series first
    if (banner.isWebSeries && banner.effectiveWebSeriesId != null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );

      final webSeriesId = banner.effectiveWebSeriesId!;

      try {
        // If we already have webSeriesDetails, use it directly
        if (banner.webSeriesDetails != null &&
            banner.webSeriesDetails!.firstEpisode != null) {
          Get.back();
          debugPrint('✅ Using cached web series details');
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                VideoDetailScreen.fromWebSeries(banner.webSeriesDetails!),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ));
          return;
        }

        final results = await Future.wait([
          BannerMovieService.fetchWebSeriesDetail(webSeriesId),
          BannerMovieService.fetchWebSeriesTrailerUrl(webSeriesId),
          BannerMovieService.fetchWebSeriesPlayUrl(webSeriesId),
        ]);
        Get.back();

        final detail = results[0] as Map<String, dynamic>?;
        final trailerUrl = results[1] as String;
        final playUrl = results[2] as String? ?? '';

        debugPrint('📺 webSeriesId: $webSeriesId');
        debugPrint('📺 playUrl: $playUrl');
        debugPrint('📺 trailerUrl: $trailerUrl');
        debugPrint('📺 detail: $detail');

        if (detail != null) {
          final webSeriesModel = WebSeriesModel.fromJson(detail);

          if (!mounted) return;
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                VideoDetailScreen.fromWebSeries(webSeriesModel),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ));
        } else {
          Get.snackbar(
            'Error',
            'Could not load web series details',
            backgroundColor: Colors.grey.shade900,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.back();
        debugPrint('❌ Error loading web series: $e');
        Get.snackbar(
          'Error',
          'Failed to load web series: $e',
          backgroundColor: Colors.grey.shade900,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
    // Handle single movie
    else if (banner.isSingleMovie && banner.effectiveMovieId != null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );

      final movieId = banner.effectiveMovieId!;

      try {
        final results = await Future.wait([
          BannerMovieService.fetchMovieDetail(movieId),
          BannerMovieService.fetchMovieTrailerUrl(movieId),
          BannerMovieService.fetchMoviePlayUrl(movieId),
        ]);
        Get.back();

        final detail = results[0] as Map<String, dynamic>?;
        final trailerUrl = results[1] as String;
        final playUrl = results[2] as String? ?? '';

        debugPrint('🎬 movieId: $movieId');
        debugPrint('🎬 playUrl: $playUrl');
        debugPrint('🎬 trailerUrl: $trailerUrl');

        if (playUrl.isNotEmpty) {
          final enrichedBanner = banner.copyWith(
            movieUrl: playUrl,
            trailerUrl: trailerUrl.isNotEmpty ? trailerUrl : banner.trailerUrl,
            description:
                detail?['description']?.toString() ?? banner.description,
            logoImage: banner.logoImage.isNotEmpty
                ? banner.logoImage
                : detail?['logoUrl']?.toString() ?? '',
            mobileImage: banner.mobileImage.isNotEmpty
                ? banner.mobileImage
                : detail?['horizontalBannerUrl']?.toString() ?? '',
          );

          if (!mounted) return;
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                VideoDetailScreen.fromBanner(enrichedBanner),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ));
        } else {
          Get.back();
          Get.snackbar(
            'Unavailable',
            'Video not available for this title',
            backgroundColor: Colors.grey.shade900,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.back();
        Get.snackbar('Error', 'Failed to load movie details: $e',
            backgroundColor: Colors.grey.shade900, colorText: Colors.white);
      }
    } else {
      if (!mounted) return;
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => VideoDetailScreen.fromBanner(banner),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ));
    }
  }
}

class _ImagePopupDialog extends StatelessWidget {
  final String imageUrl;
  const _ImagePopupDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred backdrop
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.black.withOpacity(0.82)),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                // ✅ Golden glow border
                border: Border.all(
                  color: Colors.amber.withOpacity(0.55),
                  width: 1.5,
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.amber.withOpacity(0.38),
                //     blurRadius: 28,
                //     spreadRadius: 6,
                //   ),
                //   BoxShadow(
                //     color: Colors.orange.withOpacity(0.18),
                //     blurRadius: 70,
                //     spreadRadius: 18,
                //   ),
                // ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Stack(
                  children: [
                    // Poster image
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: Colors.grey.shade900,
                          highlightColor: Colors.grey.shade700,
                          child: Container(color: Colors.grey.shade900),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.image, color: Colors.white54),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: const ui.Color.fromARGB(255, 180, 108, 0).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CategorySelectorDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const CategorySelectorDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox(height: height, child: child);

  @override
  bool shouldRebuild(CategorySelectorDelegate old) =>
      old.height != height || old.child != child;
}
