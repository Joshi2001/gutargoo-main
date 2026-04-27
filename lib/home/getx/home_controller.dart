import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/pop_up/model/pop_model.dart';
import 'package:gutrgoopro/home/pop_up/service/pop_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gutrgoopro/home/model/banner_model.dart';
import 'package:gutrgoopro/home/model/category_model.dart';
import 'package:gutrgoopro/home/model/continue_watching_model.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/repo/repo_home_section.dart';
import 'package:gutrgoopro/home/service/banner_service.dart';
import 'package:gutrgoopro/home/service/category_service.dart';
import 'package:gutrgoopro/home/service/continue_watching_service.dart';
import 'package:gutrgoopro/uitls/local_store.dart';

class HomeController extends GetxController {
  RxList<ContinueWatchingItem> continueWatchingList =
      <ContinueWatchingItem>[].obs;
  final RxBool isLoadingContinueWatching = false.obs;
  final ContinueWatchingService _continueWatchingService =
      ContinueWatchingService();
  final ScrollController scrollController = ScrollController();
  final RxBool isTopBarSolid = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final Rx<PopupModel?> homePopup = Rx<PopupModel?>(null);
  final RxString userToken = ''.obs;
  final RxBool isLoadingBanners = true.obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingSections = true.obs;
  final RxBool isLoadingTrending = false.obs;
  final RxString errorMessage = ''.obs;
  bool _isDataLoaded = false;
  final RxList<BannerMovie> allBanners = <BannerMovie>[].obs;
  final RxList<HomeSectionModel> allSections = <HomeSectionModel>[].obs;
  var isLoadingHome = true.obs;
  final RxList<HomeSectionModel> homeSections = <HomeSectionModel>[].obs;
  final RxList<BannerMovie> bannerMovies = <BannerMovie>[].obs;

  final RxList<MovieModel> featuredMovies = <MovieModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<Map<String, dynamic>> bannerLegacyList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> continueWatchingLegacy =
      <Map<String, dynamic>>[].obs;

  final HomeSectionRepository _sectionRepo = HomeSectionRepository();

  List<String> get categoryNames {
    if (categories.isEmpty) {
      return ['Home', 'Movies', 'TV Shows', 'Web Series'];
    }
    return ['Home', ...categories.map((c) => c.name)];
  }

  bool get shouldShowContinueWatching =>
      selectedCategoryIndex.value == 0 && continueWatchingList.isNotEmpty;

  CategoryModel? get selectedCategory {
    final idx = selectedCategoryIndex.value;
    if (idx == 0) return null;
    final dynamicIndex = idx - 1;
    if (dynamicIndex < categories.length) return categories[dynamicIndex];
    return null;
  }

  List<HomeSectionModel> get filteredSections {
    if (selectedCategoryIndex.value == 0) return homeSections.toList();
    final category = selectedCategory;
    if (category == null) return [];
    final targetType = category.type;
    if (targetType == null || targetType.isEmpty) {
      return homeSections.toList();
    }
    return homeSections.where((section) {
      if (section.type == null) return false;
      return section.type!.toLowerCase() == targetType.toLowerCase();
    }).toList();
  }
Future<void> fetchPopupData() async {
  final popup = await PopupService.fetchPopup();
  homePopup.value = popup;
}

  List<BannerMovie> get filteredBanners {
    if (selectedCategoryIndex.value == 0) return bannerMovies.toList();
    final category = selectedCategory;
    if (category == null) return [];
    final targetType = category.type;
    if (targetType == null || targetType.isEmpty) {
      return bannerMovies.toList();
    }
    return bannerMovies.where((banner) {
      if (banner.categoryType == null) return false;
      return banner.categoryType!.toLowerCase() == targetType.toLowerCase();
    }).toList();
  }

  List<SectionItem> get trendingMovies =>
    homeSections.expand((s) => s.allDisplayItems).toList();
  List<Map<String, dynamic>> get trendingList {
  final result = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (final section in homeSections) {
    for (final item in section.allDisplayItems) { // SectionItem type hai
      if (!seen.add(item.id)) continue;
      result.add(_sectionItemToMap(item)); // ✅ SectionItem ka map
    }
  }
  return result;
}
void debugCategoryFiltering() {
  final selectedType = selectedCategory?.type;
  debugPrint('=== CATEGORY FILTERING DEBUG ===');
  debugPrint('Selected category: ${selectedCategory?.name}');
  debugPrint('Selected type: $selectedType');
  
  for (var section in homeSections) {
    debugPrint('\nSection: ${section.title}');
    debugPrint('  Section type: ${section.type}');
    debugPrint('  Total items: ${section.allDisplayItems.length}');
    
    if (selectedType != null) {
      final filtered = section.itemsForType(selectedType);
      debugPrint('  Filtered items: ${filtered.length}');
      
      // Show first 3 items with their types
      for (var item in filtered.take(3)) {
        debugPrint('    - ${item.title} (type: ${item.type})');
      }
    }
  }
}
List<Map<String, dynamic>> trendingListByIndex(int index) {
  if (index < 0 || index >= homeSections.length) return [];
  return homeSections[index].allDisplayItems.map(_sectionItemToMap).toList();
}

// ✅ SectionItem se map banao
Map<String, dynamic> _sectionItemToMap(SectionItem item) => {
  '_id': item.id,
  'title': item.title,
  'image': item.verticalPosterUrl,
  'subtitle': item.genresString,
  'videoTrailer': item.movie?.trailerUrl ?? '',
  'videoMovies': item.movie?.playUrl ?? '',
  'dis': item.description,
  'logoImage': item.movie?.logoUrl ?? '',
  'imdbRating': item.imdbRating,
  'ageRating': item.movie?.ageRating ?? '',
};

  final RxInt selectedLiveMatchIndex = 0.obs;
  final RxInt currentBannerIndex = 0.obs;
  PageController? pageController;
  Timer? _timer;

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    _applyFilter();
    _applyBannerFilter();
    debugPrint('🔄 Category changed to: ${index == 0 ? 'Home' : categories[index - 1].name}');
  }

  void selectLiveMatch(int index) => selectedLiveMatchIndex.value = index;
  void clearContinueWatching() => continueWatchingLegacy.clear();
  void onBannerPageChanged(int index) => currentBannerIndex.value = index;

  // void _applyFilter() {
  //   homeSections.assignAll(allSections);
  //   debugPrint('📺 Sections loaded: ${homeSections.length}');
  // }

void _applyFilter() {
  homeSections.assignAll(allSections); // ✅ allSections se assign karo
  debugPrint('📺 Sections loaded: ${homeSections.length}');
  // Debug: Check kar lo data aa raha hai
  for (var s in homeSections) {
    debugPrint('Section: ${s.title} → ${s.items.length} items');
  }
}
  void _applyBannerFilter() {
    final category = selectedCategory;
    if (category == null) {
      bannerMovies.assignAll(allBanners);
      debugPrint('🏠 Home banners: ${bannerMovies.length}');
    } else {
      final targetType = category.type?.toLowerCase();
      if (targetType == null || targetType.isEmpty) {
        bannerMovies.assignAll(allBanners);
      } else {
        final filtered = allBanners.where((banner) {
          if (banner.categoryType == null) return false;
          return banner.categoryType!.toLowerCase() == targetType;
        }).toList();
        bannerMovies.assignAll(filtered);
        debugPrint('🎯 ${category.name} banners: ${filtered.length}');
      }
    }
    bannerLegacyList.assignAll(bannerMovies.map(_bannerToLegacyMap).toList());
  }

  // ── Continue Watching ────────────────────────────────────────────────────
  Future<void> fetchContinueWatching() async {
    try {
      isLoadingContinueWatching.value = true;
      final items = await _continueWatchingService.getContinueWatching();
      continueWatchingList.assignAll(items);
      debugPrint('✅ Loaded ${items.length} continue watching items');
    } catch (e) {
      debugPrint('❌ Error fetching continue watching: $e');
    } finally {
      isLoadingContinueWatching.value = false;
    }
  }

  Future<void> updateWatchProgress({
    required String movieId,
    required int watchedTime,
    required int duration,
    required bool isCompleted,
  }) async {
    if (userToken.value.isEmpty) return;
    final success = await _continueWatchingService.updateWatchProgress(
      token: userToken.value,
      movieId: movieId,
      watchedTime: watchedTime,
      duration: duration,
      isCompleted: isCompleted,
    );
    if (success) {
      await fetchContinueWatching();
    }
  }

  Future<void> removeFromContinueWatching(String movieId) async {
    if (movieId.isEmpty) {
      print("❌ Cannot remove: Invalid movieId");
      return;
    }
    ContinueWatchingItem? removedItem;
    final previousList = List<ContinueWatchingItem>.from(continueWatchingList);
    try {
      removedItem = continueWatchingList.firstWhereOrNull((item) => item.movie.id == movieId);
      if (removedItem != null) {
        continueWatchingList.removeWhere((item) => item.movie.id == movieId);
      }
      final success = await _continueWatchingService.removeFromContinueWatching(movieId);
      if (success) {
        await fetchContinueWatching();
      } else {
        if (removedItem != null && !continueWatchingList.contains(removedItem)) {
          continueWatchingList.add(removedItem);
          continueWatchingList.sort((a, b) => a.watchedTime.compareTo(b.watchedTime));
        }
        throw Exception("Failed to remove from server");
      }
    } catch (e) {
      print("❌ Error removing from continue watching: $e");
      continueWatchingList.value = previousList;
      Get.snackbar('Error', 'Failed to remove from continue watching',
          backgroundColor: Colors.red.shade900, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    }
  }

  Future<void> fetchHomeData() async {
  try {
    isLoadingHome.value = true;
    isLoadingSections.value = true;
    isLoadingBanners.value = true;
    isLoadingCategories.value = true;
    
    if (userToken.value.isEmpty) {
      await loadToken();
    }

    // Fetch all data in parallel
    await Future.wait([
      
      _fetchCategories(),
      _fetchBanners(),
      
      _fetchSectionsFromAPI(),
      // _fetchMoviesAndCreateSections()
       // ✅ CHANGED: Now using API sections
    ]);
_debugBannerData;
    await fetchContinueWatching();

    print('✅ Home data loaded successfully');
    print('📊 Categories: ${categories.length}');
    print('🎬 Banners: ${allBanners.length}');
    print('📺 Sections: ${allSections.length}');
    
  } catch (e) {
    print('❌ Error fetching home data: $e');
    errorMessage.value = e.toString();
  } finally {
    isLoadingHome.value = false;
    isLoadingSections.value = false;
    isLoadingBanners.value = false;
    isLoadingCategories.value = false;
  }
}
// ✅ NEW: Fetch sections from API using repository
Future<void> _fetchSectionsFromAPI() async {
  try {
    final sections = await _sectionRepo.fetchSections();
    
    if (sections.isNotEmpty) {
      allSections.assignAll(sections);
      _applyFilter();
      print('✅ Sections loaded from API: ${allSections.length}');
      
      // Print section titles to verify
      for (var section in sections) {
        print('📦 API Section: "${section.title}" - ${section.allDisplayItems.length} items');
      }
    } else {
      print('⚠️ No sections returned from API');
      allSections.clear();
    }
    
  } catch (e) {
    print('❌ Error fetching sections from API: $e');
    allSections.clear();
  }
}
  // ✅ Fetch categories from API
  Future<void> _fetchCategories() async {
    try {
      final result = await CategoryService.fetchCategories();
      categories.assignAll(result);
      debugPrint('✅ Categories loaded: ${categories.length}');
    } catch (e) {
      debugPrint('❌ _fetchCategories error: $e');
      categories.clear();
    }
  }

  // ✅ Fetch banners from API
  Future<void> _fetchBanners() async {
    try {
      final banners = await BannerMovieService.fetchAllBanners(limit: 50);
      allBanners.assignAll(banners);
      _applyBannerFilter();
      debugPrint('✅ Banners loaded: ${allBanners.length}');
    } catch (e) {
      debugPrint('❌ _fetchBanners error: $e');
    }
  }

void _debugBannerData(BannerMovie banner) {
  debugPrint('=== BANNER RAW DATA DEBUG ===');
  debugPrint('Title: ${banner.title}');
  debugPrint('ID: ${banner.id}');
  debugPrint('bannerType: ${banner.bannerType}');
  debugPrint('type: ${banner.type}');
  debugPrint('categoryType: ${banner.categoryType}');
  debugPrint('categoryName: ${banner.categoryName}');
  debugPrint('movieId: ${banner.movieId}');
  debugPrint('webSeriesId: ${banner.webSeriesId}');
  debugPrint('effectiveMovieId: ${banner.effectiveMovieId}');
  debugPrint('effectiveWebSeriesId: ${banner.effectiveWebSeriesId}');
  debugPrint('has webSeriesDetails: ${banner.webSeriesDetails != null}');
  debugPrint('isWebSeries (getter): ${banner.isWebSeries}');
  debugPrint('isSingleMovie (getter): ${banner.isSingleMovie}');
  debugPrint('bannerType == web_series: ${banner.bannerType == 'web_series'}');
  debugPrint('type == web_series: ${banner.type == 'web_series'}');
  debugPrint('type == webseries: ${banner.type == 'webseries'}');
}
  Map<String, dynamic> _bannerToLegacyMap(BannerMovie b) => {
    'id': b.id,
    'image': b.mobileImage,
    'title': b.title,
    'subtitle': b.genres.join(', '),
    'videoTrailer': b.trailerUrl.isNotEmpty ? b.trailerUrl : b.movieUrl,
    'videoMovies': b.movieUrl,
    'dis': b.description,
    'logoImage': b.logoImage,
    'live': false,
    'imdbRating': b.imdbRating,
    'ageRating': b.ageLimit,
  };

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (pageController == null || !pageController!.hasClients) return;
      final max = bannerMovies.isEmpty ? featuredMovies.length : bannerMovies.length;
      if (max == 0) return;
      final next = (currentBannerIndex.value + 1) % max;
      pageController!.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> loadToken() async {
    try {
      final token = await LocalStore.getToken();
      if (token != null && token.isNotEmpty) {
        userToken.value = token;
        print("🔑 Token loaded");
      } else {
        print("⚠️ No token found");
      }
    } catch (e) {
      print("❌ Error loading token: $e");
    }
  }

  Future<void> refreshHomeData() async {
    await fetchHomeData();
  }

  @override
  void onInit() {
    super.onInit();
    if (!_isDataLoaded) {
      _initializeData();
      _isDataLoaded = true;
    }
    _startAutoScroll();
    scrollController.addListener(() {
      isTopBarSolid.value = scrollController.offset > 0;
    });
  }

  Future<void> _initializeData() async {
    fetchPopupData();
    await loadToken();
    await fetchHomeData();
     
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController?.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
