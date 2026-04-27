import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/search.dart/controller/search_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends StatefulWidget {
  final bool fromBottomNav;

  const SearchScreen({
    super.key,
    required this.fromBottomNav,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late final SearchControllerX _searchCtrl;
  late final HomeController _homeCtrl;
  late final FavoritesController _favCtrl;
  late stt.SpeechToText _speech;

  bool _isListening = false;
  bool get _hasText => _searchController.text.trim().isNotEmpty;

  // ── Typewriter
  final List<String> _hints = ['Web Series...', 'Movies...'];
  int _hintIndex = 0;
  int _charIndex = 0;
  String _currentHint = '';
  bool _isDeleting = false;
  Timer? _typeTimer;

  Timer? _searchDebounceTimer;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 600);

 @override
void initState() {
  super.initState();

  _searchController = TextEditingController();

  _searchCtrl = Get.put(SearchControllerX()); // FIX (safe)
  _homeCtrl = Get.find<HomeController>();
  _favCtrl = Get.find<FavoritesController>();

  _startTypewriter();
  // _initializeControllers();
}

  void _initializeControllers() {
    _searchController = TextEditingController();

    // ✅ Just find them - let GetX handle it
    try {
      _searchCtrl = Get.find<SearchControllerX>();
      _homeCtrl = Get.find<HomeController>();
      _favCtrl = Get.find<FavoritesController>();
      _speech = stt.SpeechToText();
      print('✅ All controllers initialized');
    } catch (e) {
      print('❌ Controller error: $e');
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  // SPEECH TO TEXT
  // ════════════════════════════════════════════════════════════

  Future<void> _toggleListening() async {
    _isListening ? await _stopListening() : await _startListening();
  }

  Future<void> _startListening() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            if (mounted) setState(() => _isListening = false);
            final text = _searchController.text.trim();
            if (text.isNotEmpty) _triggerSearch(text, immediate: true);
          }
        },
        onError: (error) {
          if (mounted) setState(() => _isListening = false);
          _showSnackbar('Microphone error: $error');
        },
      );

      if (!available) {
        _showSnackbar('Speech recognition not available on this device');
        return;
      }

      setState(() => _isListening = true);

      _speech.listen(
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          final text = result.recognizedWords;
          if (!mounted) return;
          setState(() {
            _searchController.text = text;
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: text.length),
            );
          });
          // ✅ Only update query display value, don't trigger search yet
          _searchCtrl.query.value = text;

          if (result.finalResult && text.trim().isNotEmpty) {
            _triggerSearch(text, immediate: true);
          }
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isListening = false);
      _showSnackbar('Error: Could not start microphone');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
    } catch (_) {}
  }

void _triggerSearch(String query, {bool immediate = false}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return;

  _searchDebounceTimer?.cancel();

  if (immediate) {
    _searchCtrl.performSearch(trimmed);
  } else {
    _searchDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _searchCtrl.performSearch(trimmed),
    );
  }
}

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    _searchCtrl.clearSearch();
    _charIndex = 0;
    _currentHint = '';
    _isDeleting = false;
    _typeTimer?.cancel();
    _startTypewriter();
  }

  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    _searchCtrl.query.value = '';
    if (widget.fromBottomNav) {
      Get.find<NavigationController>().currentIndex.value = 0;
    } else {
      Get.back();
    }
  }

  void _openDetail(MovieModel movie) {
    _searchCtrl.addRecentSearch(movie.movieTitle);
    Get.to(() => VideoDetailScreen.fromModel(movie, initialPosition: Duration.zero));
  }

  void _startTypewriter() {
    if (_searchController.text.isNotEmpty) return;

    _typeTimer?.cancel();
    _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final fullText = _hints[_hintIndex];
      setState(() {
        if (!_isDeleting) {
          if (_charIndex < fullText.length) {
            _charIndex++;
            _currentHint = fullText.substring(0, _charIndex);
          } else {
            _isDeleting = true;
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) _startTypewriter();
            });
          }
        } else {
          if (_charIndex > 0) {
            _charIndex--;
            _currentHint = fullText.substring(0, _charIndex);
          } else {
            _isDeleting = false;
            _hintIndex = (_hintIndex + 1) % _hints.length;
            timer.cancel();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _startTypewriter();
            });
          }
        }
      });
    });
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.shade900,
      ),
    );
  }

  Widget _networkImage(
    String? url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    final src = url ?? '';
    if (src.isEmpty) return _imageFallback(height: height, width: width);
    return Image.network(
      src,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _shimmerBox(
            height: height ?? 120.h, width: width ?? double.infinity);
      },
      errorBuilder: (_, __, ___) =>
          _imageFallback(height: height, width: width),
    );
  }

  Widget _imageFallback({double? height, double? width}) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade900,
        child: Icon(Icons.movie, color: Colors.white24, size: 30.sp),
      );

  Widget _actionBtn(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 4.h),
          Text(label,
              style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
        ],
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

  Widget _shimmerBox({
    required double height,
    required double width,
    double radius = 8,
  }) {
    return _shimmerBase(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      ),
    );
  }

  Widget _recommendedGridShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        _shimmerBox(height: 16.h, width: 180.w, radius: 4),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 0.65,
          ),
          itemCount: 12,
          itemBuilder: (_, __) => _shimmerBase(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchResultCardShimmer() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBase(
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _shimmerBox(
                            height: 18.h,
                            width: double.infinity,
                            radius: 4)),
                    SizedBox(width: 8.w),
                    ...List.generate(
                      3,
                      (_) => Padding(
                        padding: EdgeInsets.only(left: 12.w),
                        child: _shimmerBase(
                          child: Container(
                            width: 34.w,
                            height: 34.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _shimmerBox(height: 12.h, width: double.infinity, radius: 4),
                SizedBox(height: 6.h),
                _shimmerBox(height: 12.h, width: double.infinity, radius: 4),
                SizedBox(height: 6.h),
                _shimmerBox(height: 12.h, width: 200.w, radius: 4),
                SizedBox(height: 10.h),
                _shimmerBox(height: 10.h, width: 120.w, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchResultsShimmer() {
    return Column(
      children: List.generate(3, (_) => _searchResultCardShimmer()),
    );
  }

  Widget _recentSearchesShimmer() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(height: 14.h, width: 120.w, radius: 4),
              _shimmerBox(height: 14.h, width: 60.w, radius: 4),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(
              5,
              (i) => _shimmerBase(
                child: Container(
                  width: [80.w, 100.w, 70.w, 90.w, 75.w][i],
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.white12, height: 1.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          body: Obx(() {
            if (!_searchCtrl.isInitialized.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.orange,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading search...',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),
                  _buildSearchBar(),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Obx(() {
                        final query = _searchCtrl.query.value.trim();
                        if (query.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRecentSearches(),
                              _buildRecommendedGrid(),
                            ],
                          );
                        }
                        return _buildSearchResults();
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _goBack,
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: TextField(
              controller: _searchController,
             onChanged: (value) {
  setState(() {});

  if (value.isEmpty) {
    _searchDebounceTimer?.cancel();
    _searchCtrl.clearSearch();

    _charIndex = 0;
    _currentHint = '';
    _isDeleting = false;
    _typeTimer?.cancel();
    _startTypewriter();
  } else {
    _typeTimer?.cancel();
    _currentHint = '';
    _searchCtrl.query.value = value;
    
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => _searchCtrl.performSearch(value),
    );
  }
},
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _searchDebounceTimer?.cancel();
                  _triggerSearch(value, immediate: true);
                }
              },
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search $_currentHint',
                hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon:
                    Icon(Icons.search, color: Colors.white54, size: 18.sp),
                suffixIcon: GestureDetector(
                  onTap: () {
                    if (_hasText) {
                      _clearSearch();
                    } else {
                      _toggleListening();
                    }
                  },
                  child: Icon(
                    _hasText
                        ? Icons.close
                        : (_isListening ? Icons.mic : Icons.mic_none),
                    color: _hasText
                        ? Colors.white
                        : (_isListening ? Colors.red : Colors.white54),
                    size: 20.sp,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 15.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                      BorderSide(color: Colors.transparent, width: 2.w),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                      BorderSide(color: Colors.transparent, width: 2.w),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                      BorderSide(color: Colors.transparent, width: 2.w),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Recent Searches ─────────────────────────────────────────

  Widget _buildRecentSearches() {
    return Obx(() {
      if (_homeCtrl.isLoadingSections.value &&
          _searchCtrl.recentSearches.isEmpty) {
        return _recentSearchesShimmer();
      }

      if (_searchCtrl.recentSearches.isEmpty) return const SizedBox();

      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: _searchCtrl.clearAll,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                        color: AppColors.orange, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _searchCtrl.recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    // ✅ Tap recent chip: fill field + immediate search
                    _typeTimer?.cancel();
                    _searchController.text = search;
                    _searchCtrl.query.value = search;
                    setState(() => _currentHint = '');
                    _triggerSearch(search, immediate: true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20.r),
                      border:
                          Border.all(color: Colors.white12, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history,
                            color: Colors.white38, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(search,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp)),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () =>
                              _searchCtrl.removeSearch(search),
                          child: Icon(Icons.close,
                              color: Colors.white38, size: 12.sp),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8.h),
            Divider(color: Colors.white12, height: 1.h),
          ],
        ),
      );
    });
  }

  // ── Recommended Grid ────────────────────────────────────────

  Widget _buildRecommendedGrid() {
    return Obx(() {
      if (_homeCtrl.isLoadingSections.value) {
        return _recommendedGridShimmer();
      }

      final movies = _getAllSectionMovies();
      if (movies.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            'Recommended for You',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.65,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => _openDetail(movie),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: _networkImage(movie.verticalPosterUrl),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (_searchCtrl.isSearching.value) {
        return _searchResultsShimmer();
      }

      if (_searchCtrl.searchError.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: Column(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.red.shade400, size: 40.sp),
                SizedBox(height: 12.h),
                Text(
                  _searchCtrl.searchError.value,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13.sp),
                ),
              ],
            ),
          ),
        );
      }

      final results = _searchCtrl.searchResults;

      if (results.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: Column(
              children: [
                Icon(Icons.search_off, color: Colors.white38, size: 50.sp),
                SizedBox(height: 16.h),
                Text(
                  'No results found for\n"${_searchCtrl.query.value}"',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final movie = results[index];
          return GestureDetector(
            onTap: () => _openDetail(movie),
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: _networkImage(
                      movie.horizontalBannerUrl,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                movie.movieTitle,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Obx(() {
                              final movieId = movie.id;
                              if (movieId.isEmpty) return const SizedBox();
                              final isFav = _favCtrl.isFavorite(movieId);
                              return _actionBtn(
                                isFav
                                    ? Icons.check_circle
                                    : Icons.add_outlined,
                                'Save',
                                onTap: () {
                                  _favCtrl.toggleFavorite(FavoriteItem(
                                    id: movieId,
                                    title: movie.movieTitle,
                                    image: movie.verticalPosterUrl,
                                    videoTrailer: movie.playUrl,
                                    subtitle: movie.genresString,
                                  ));
                                },
                                color: isFav ? Colors.red : Colors.white,
                              );
                            }),
                            SizedBox(width: 12.w),
                            _actionBtn(
                              Icons.info_outline,
                              'Detail',
                              onTap: () => _openDetail(movie),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () => _openDetail(movie),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.play_arrow,
                                        color: Colors.black, size: 20.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text('Play',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10.sp)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          movie.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              height: 1.5),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          movie.genresString,
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  List<MovieModel> _getAllSectionMovies() {
  final seen = <String>{};
  final result = <MovieModel>[];
  for (final section in _homeCtrl.homeSections) {
    // ✅ allDisplayItems use karo, items nahi
    for (final item in section.allDisplayItems) {
      if (item.movie != null && seen.add(item.id)) {
        result.add(item.movie!);
      }
    }
  }
  return result;
}
}