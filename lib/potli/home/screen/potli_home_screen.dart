import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/potli/home/controller/potli_home_controller.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_banner.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_model.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_section.dart';
import 'package:gutrgoopro/potli/home/service/potli_home_service.dart';
import 'package:gutrgoopro/potli/potle_reel/screen/reel_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gutrgoopro/home/screen/view_all_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/search.dart/screen/search_screen.dart';
import 'package:gutrgoopro/uitls/colors.dart';


class PotliHomeScreen extends StatefulWidget {
  const PotliHomeScreen({super.key});

  @override
  State<PotliHomeScreen> createState() => _PotliHomeScreenState();
}

class _PotliHomeScreenState extends State<PotliHomeScreen> {
  final PotliController controller = Get.put(PotliController());
  final ScrollController scrollController = ScrollController();
  late final PageController heroController;
  final FavoritesController favoritesController =
      Get.find<FavoritesController>();

  int _currentIndex = 0;
  List<Color> _bannerTopColors = [];
  bool _isRefreshing = false;

  // ── Gradients ──────────────────────────────────────────────────────────────
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

  Color _getCurrentColor() {
    if (_bannerTopColors.isEmpty || _currentIndex >= _bannerTopColors.length) {
      return Colors.black;
    }
    return _bannerTopColors[_currentIndex];
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    heroController = PageController(viewportFraction: 0.90, initialPage: 1);
// _loadStaticData();
    ever(controller.bannerMovies, (_) => _extractColors());
    ever(controller.featuredMovies, (_) {
      if (controller.bannerMovies.isEmpty) _extractColors();
    });
  }
  void _loadStaticData() {
  controller.bannerMovies.value = [
    PotliBannerModel(
      id: "1",
      title: "Pushpa 2",
      description: "Action blockbuster",
      mobileImage:
          "https://wallpapercave.com/wp/wp13163394.jpg",
      logoImage:
          "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Pushpa_The_Rise_logo.png/640px-Pushpa_The_Rise_logo.png",
      trailerUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      publishStatus: true,
      genres: ["Action"], movieUrl: '', isSingleMovie: false,
    ),
    PotliBannerModel(
      id: "2",
      title: "KGF 2",
      description: "Rocky Bhai 🔥",
      mobileImage:
          "https://wallpapercave.com/wp/wp12151227.jpg",
      logoImage: "",
      trailerUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      publishStatus: true,
      genres: ["Action"], movieUrl: '', isSingleMovie: true, effectiveMovieId: "m2",
    ),
  ];

  /// 🎬 STATIC MOVIES
  final movies = [
    PotliMovieModel(
      id: "m1",
      movieTitle: "RRR",
      description: "Epic action drama",
      verticalPosterUrl:
          "https://wallpapercave.com/wp/wp11581561.jpg",
      horizontalBannerUrl:
          "https://wallpapercave.com/wp/wp11581561.jpg",
      playUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      trailerUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      genresString: "Action, Drama",
      totalEpisodes: 1,
      likesCount: 120,
      savesCount: 40,
      logoUrl: "",
      episodes: [],
      vastTagUrl: "", genres: [ "Action", "Drama"],
    ),
    PotliMovieModel(
      id: "m2",
      movieTitle: "Salaar",
      description: "Prabhas 🔥",
      verticalPosterUrl:
          "https://wallpapercave.com/wp/wp12151230.jpg",
      horizontalBannerUrl:
          "https://wallpapercave.com/wp/wp12151230.jpg",
      playUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      trailerUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      genresString: "Action",
      totalEpisodes: 1,
      likesCount: 80,
      savesCount: 20,
      logoUrl: "",
      episodes: [],
      vastTagUrl: "", genres: ["Action"],
    ),
  ];

  /// 🎬 STATIC SECTIONS
  controller.homeSections.value = [
    PotliSectionModel(
      id: "s1",
      title: "Trending Now",
      displayStyle: "standard",
      items: movies,
    ),
    PotliSectionModel(
      id: "s2",
      title: "Top 10",
      displayStyle: "index_vertical",
      items: movies,
    ),
    PotliSectionModel(
      id: "s3",
      title: "Featured",
      displayStyle: "horizontal_banner",
      items: movies,
    ),
  ];

  controller.featuredMovies.value = movies;

  controller.isLoadingBanners.value = false;
  controller.isLoadingSections.value = false;

  _extractColors();
}

  @override
  void dispose() {
    scrollController.dispose();
    heroController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _bannerTopColors = [];
    });
    await controller.fetchHomeData();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _extractColors() async {
    final List<Color> colors = [];
    final validBanners = controller.bannerMovies
    .where((b) =>
        b.publishStatus &&
        (b.mobileImage.isNotEmpty || b.logoImage.isNotEmpty))
    .toList();

    final sourceList = validBanners.isNotEmpty
        ? validBanners.cast<dynamic>()
        : controller.featuredMovies.cast<dynamic>();

    for (final item in sourceList) {
      try {
        String imageUrl = '';
        if (item is PotliBannerModel) {
          imageUrl =
              item.mobileImage.isNotEmpty ? item.mobileImage : item.logoImage;
        } else if (item is PotliMovieModel) {
          imageUrl = item.verticalPosterUrl;
        }

        final color = imageUrl.isNotEmpty
            ? await _dominantColorFromNetwork(imageUrl)
            : const Color(0xFF1E3A5F);

        colors.add(color);
      } catch (_) {
        colors.add(const Color(0xFF1E3A5F));
      }
    }

    if (mounted) setState(() => _bannerTopColors = colors);
  }

  Future<Color> _dominantColorFromNetwork(String url) async {
    if (url.isEmpty) return Colors.black;
    final provider = NetworkImage(url);
    final stream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (e, _) {
        completer.completeError(e);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    final image = await completer.future;
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return Colors.black;
    final pixels = byteData.buffer.asUint8List();
    int rSum = 0, gSum = 0, bSum = 0, count = 0;
    final maxY = (image.height * 0.3).toInt();
    for (int y = 0; y < maxY; y++) {
      for (int x = 0; x < image.width; x++) {
        final i = (y * image.width + x) * 4;
        if (i + 2 >= pixels.length) continue;
        final r = pixels[i], g = pixels[i + 1], b = pixels[i + 2];
        final bright = (r + g + b) / 3;
        if (bright > 30 && bright < 225) {
          rSum += r;
          gSum += g;
          bSum += b;
          count++;
        }
      }
    }
    if (count == 0) return Colors.black;
    return Color.fromARGB(
      255,
      (rSum / count).round(),
      (gSum / count).round(),
      (bSum / count).round(),
    );
  }

  void _navigateToDetail(PotliMovieModel movie) async {
  Get.dialog(
    const Center(child: CircularProgressIndicator(color: Colors.white)),
    barrierDismissible: false,
  );

  final playUrl = await PotliService.fetchMoviePlayUrl(movie.id);

  Get.back();

  final videoModel = VideoModel(
    id: movie.id,
    title: movie.movieTitle,
    playUrl: playUrl.isNotEmpty ? playUrl : movie.trailerUrl,
    totalEpisodes: movie.totalEpisodes,
    likesCount: movie.likesCount,
    savesCount: movie.savesCount,
    episodes: movie.episodes.map((e) {
      return Episode(
        id: e.number.toString(),
        title: e.title,
        playUrl: e.url,
      );
    }).toList(),
  );

  Get.to(() => PotliReelScreen(video: videoModel));
}

 
 void _navigateToBannerDetail(PotliBannerModel banner) async {
  Get.dialog(
    const Center(child: CircularProgressIndicator(color: Colors.white)),
    barrierDismissible: false,
  );

  String playUrl = banner.trailerUrl;

  if (banner.isSingleMovie && banner.effectiveMovieId != null) {
    playUrl = await PotliService.fetchMoviePlayUrl(
      banner.effectiveMovieId!,
    );
  }

  Get.back();

  final videoModel = VideoModel(
    id: banner.id,
    title: banner.title,
    playUrl: playUrl,
    totalEpisodes: 1,
    likesCount: 0,
    savesCount: 0,
    episodes: [],
  );

  Get.to(() => PotliReelScreen(video: videoModel));
}

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.black,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.white,
            backgroundColor: Colors.grey.shade900,
            displacement: 60,
            strokeWidth: 2.5,
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  snap: false,
                  backgroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                  flexibleSpace: AnimatedContainer(
                    decoration: BoxDecoration(gradient: _topGradient),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 10.h,
                        left: 8.w,
                        right: 8.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.w, top: 20.h),
                            child: Image.asset(
                              "assets/white_logo.png",
                              height: 120.h,
                              width: 140.w,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.w, top: 20.h),
                            child: _searchButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.zero,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _heroBannerSection(),
                      SizedBox(height: Get.height * 0.02),
                      _dynamicSections(),
                      SizedBox(height: 24.h),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dynamic sections ───────────────────────────────────────────────────────
  Widget _dynamicSections() {
    return Obx(() {
      if (controller.isLoadingSections.value) {
        return Column(
          children: List.generate(
            2,
            (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeaderShimmer(),
                _posterRowShimmer(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      }

      if (controller.homeSections.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              'No content available',
              style: TextStyle(color: Colors.white54, fontSize: 14.sp),
            ),
          ),
        );
      }

      final seen = <String>{};
      final filteredSections =
          controller.homeSections.where((s) => seen.add(s.id)).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filteredSections.map(_sectionBlock).toList(),
      );
    });
  }

  Widget _sectionBlock(PotliSectionModel section) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    final uniqueMovies = {
      for (var m in section.items) m.id: m,
    }.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(section.title),
        _buildSectionListWithItems(section, uniqueMovies),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSectionListWithItems(
    PotliSectionModel section,
    List<PotliMovieModel> items,
  ) {
    switch (section.displayStyle) {
      case 'index_vertical':
        return _indexVerticalList(items, section.id);
      case 'horizontal_banner':
        return _horizontalBannerList(items);
      default:
        return _standardPosterList(items);
    }
  }

  // ── List variants ──────────────────────────────────────────────────────────
  Widget _indexVerticalList(List<PotliMovieModel> items, String sectionId) {
    final limited = items.take(10).toList();
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 40.w, right: 30.w),
        itemCount: limited.length,
        itemBuilder: (ctx, i) =>
            _top10Card(movie: limited[i], rank: i + 1, sectionId: sectionId),
      ),
    );
  }

  Widget _horizontalBannerList(List<PotliMovieModel> items) {
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 15.w),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final movie = items[i];
          final imageUrl = movie.horizontalBannerUrl.isNotEmpty
              ? movie.horizontalBannerUrl
              : movie.verticalPosterUrl;
          return GestureDetector(
            onTap: () => _navigateToDetail(movie), // ✅ PotliReelScreen
            child: Container(
              width: 180.w,
              margin: EdgeInsets.only(right: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) => prog == null
                            ? child
                            : _shimmerBase(
                                child: Container(color: Colors.white)),
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _standardPosterList(List<PotliMovieModel> items) {
    return SizedBox(
      height: 170.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: 15.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final movie = items[index];
          final cardImage = movie.verticalPosterUrl;
          return GestureDetector(
            onTap: () => _navigateToDetail(movie), // ✅ PotliReelScreen
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: cardImage.isNotEmpty
                    ? Image.network(
                        cardImage,
                        height: 170.h,
                        width: 100.w,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 170.h,
                            width: 100.w,
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : Container(
                        height: 170.h,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Top 10 card ────────────────────────────────────────────────────────────
  Widget _top10Card({
    required PotliMovieModel movie,
    required int rank,
    required String sectionId,
  }) {
    final cardImage = movie.verticalPosterUrl;
    return GestureDetector(
      onTap: () => _navigateToDetail(movie), // ✅ PotliReelScreen
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 50.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: -30.w, bottom: 5.h, child: _rankNumber(rank)),
            Positioned(
              left: 30,
              top: 5.h,
              bottom: 5.h,
              child: Hero(
                tag: 'potli_top10_${sectionId}_${movie.id}_$rank',
                child: Container(
                  width: 100.w,
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
                    child: cardImage.isNotEmpty
                        ? Image.network(
                            cardImage,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, prog) => prog == null
                                ? child
                                : _shimmerBase(
                                    child: Container(color: Colors.white)),
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey.shade800),
                          )
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
        Text(
          '$rank',
          style: strokeStyle(Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12.w
            ..color = Colors.black),
        ),
        Text(
          '$rank',
          style: strokeStyle(Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8.w
            ..color = Colors.grey.shade900),
        ),
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

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => ViewAllScreen(title: title)),
            child: Text(
              'View All',
              style: TextStyle(color: AppColors.orange, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBannerSection() {
    return Obx(() {
      final validBanners = controller.bannerMovies
          .where((b) => b.publishStatus && b.mobileImage.isNotEmpty)
          .toList();

      if (controller.isLoadingBanners.value) {
        return SizedBox(height: 420.h, child: _heroBannerShimmer());
      }

      if (validBanners.isEmpty && controller.featuredMovies.isEmpty) {
        return SizedBox(height: 20.h);
      }

      final sourceList = validBanners.isNotEmpty
          ? validBanners.cast<dynamic>()
          : controller.featuredMovies.cast<dynamic>();

      final banners = _looping(sourceList);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.bounceInOut,
        decoration: BoxDecoration(gradient: _bannerGradient),
        child: SizedBox(
          height: 420.h,
          child: PageView.builder(
            controller: heroController,
            itemCount: banners.length,
            physics: const PageScrollPhysics(),
            onPageChanged: (index) {
              final len = sourceList.length;
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
                builder: (context, child) {
                  final page = heroController.hasClients &&
                          heroController.position.haveDimensions
                      ? (heroController.page ??
                          heroController.initialPage.toDouble())
                      : heroController.initialPage.toDouble();
                  final distance = (page - index).abs();
                  final scale = (1 - distance * 0.04).clamp(0.96, 1.0);
                  final opacity = (1 - distance * 0.08).clamp(0.90, 1.0);
                  return Transform.translate(
                    offset: Offset(0, distance * 8),
                    child: Transform.scale(
                      scale: Curves.easeOutCubic.transform(scale),
                      child: Opacity(opacity: opacity, child: child),
                    ),
                  );
                },
                // child: _heroCard(banners[index]),
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

  // Widget _heroCard(dynamic item) {
  //   late String titleText;
  //   late String logoUrl;
  //   late String bannerUrl;
  //   late VoidCallback onWatchNow;
  //   late VoidCallback onSave;

  //   if (item is PotliBannerModel) {
  //     titleText = item.title;
  //     logoUrl = item.logoImage;
  //   bannerUrl = item.mobileImage.isNotEmpty
  //   ? item.mobileImage
  //   : (item.logoImage.isNotEmpty
  //       ? item.logoImage
  //       : '');
  //     onWatchNow = () => _navigateToBannerDetail(item);
  //     onSave = () {
  //       favoritesController.addFavorite(FavoriteItem(
  //         title: item.title,
  //         image: item.mobileImage,
  //         videoTrailer: item.trailerUrl,
  //         subtitle: item.genres.join(', '),
  //       ));
  //     };
  //   } else if (item is PotliMovieModel) {
  //     titleText = item.movieTitle;
  //     logoUrl = item.logoUrl;
  //     bannerUrl = item.horizontalBannerUrl.isNotEmpty
  //         ? item.horizontalBannerUrl
  //         : item.verticalPosterUrl;
  //     onWatchNow = () => _navigateToDetail(item); // ✅ PotliReelScreen
  //     onSave = () {
  //       favoritesController.addFavorite(FavoriteItem(
  //         title: item.movieTitle,
  //         image: item.verticalPosterUrl,
  //         videoTrailer: item.playUrl,
  //         subtitle: item.genresString,
  //       ));
  //     };
  //   } else {
  //     return const SizedBox.shrink();
  //   }

  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 6.w),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(12.r),
  //       child: Stack(
  //         children: [
  //           _buildBannerImage(bannerUrl),
  //           Container(
  //             height: 400.h,
  //             decoration: const BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [
  //                   Colors.black54,
  //                   Colors.transparent,
  //                   Colors.black87,
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             left: 20.w,
  //             right: 20.w,
  //             bottom: 20.h,
  //             child: Column(
  //               children: [
  //                 logoUrl.isNotEmpty
  //                     ? Image.network(
  //                         logoUrl,
  //                         height: 50.h,
  //                         width: 180.w,
  //                         fit: BoxFit.contain,
  //                       )
  //                     : Text(
  //                         titleText,
  //                         style:
  //                             TextStyle(color: Colors.white, fontSize: 18.sp),
  //                       ),
  //                 SizedBox(height: 5.h),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     GestureDetector(
  //                       onTap: onWatchNow,
  //                       child: Container(
  //                         padding: EdgeInsets.symmetric(
  //                           horizontal: 18.w,
  //                           vertical: 10.h,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(6),
  //                         ),
  //                         child: Row(
  //                           children: [
  //                             const Icon(Icons.play_arrow,
  //                                 color: Colors.black, size: 20),
  //                             const SizedBox(width: 3),
  //                             Text(
  //                               'Watch Now',
  //                               style: TextStyle(
  //                                 color: Colors.black,
  //                                 fontWeight: FontWeight.w600,
  //                                 fontSize: 13.sp,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // // ── Helpers ────────────────────────────────────────────────────────────────
  // Widget _buildBannerImage(String url) {
  //   if (url.isEmpty) {
  //     return Container(height: 400.h, color: Colors.grey.shade900);
  //   }
  //   return Image.network(
  //     url,
  //     height: 400.h,
  //     width: double.infinity,
  //     fit: BoxFit.cover,
  //     loadingBuilder: (_, child, prog) =>
  //         prog == null ? child : _heroBannerShimmer(),
  //     errorBuilder: (_, __, ___) =>
  //         Container(height: 400.h, color: Colors.grey.shade900),
  //   );
  // }

  Widget _searchButton() {
    return GestureDetector(
      onTap: () => Get.to(() => SearchScreen(fromBottomNav: false)),
      child: const Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.search_outlined, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _shimmerBase({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: child,
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
      height: 190.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 15.w),
        itemCount: 6,
        itemBuilder: (_, __) => _shimmerBase(
          child: Container(
            width: 100.w,
            height: 170.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroBannerShimmer() {
    return _shimmerBase(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 400.h,
            width: double.infinity,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: Colors.grey.shade800,
        child: Icon(Icons.movie, color: Colors.white54, size: 24.sp),
      );
}