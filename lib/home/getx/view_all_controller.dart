import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/model/web_series_model.dart';

class ViewAllController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  String _currentTitle = '';

  void loadSection(String title) {
    _currentTitle = title;
    _loadItems();
  }

  void _loadItems() {
    if (_currentTitle.isEmpty) return;

    if (homeController.isLoadingSections.value) {
      isLoading.value = true;
      return;
    }

    final section = homeController.homeSections.firstWhereOrNull(
      (s) => s.title.toLowerCase().trim() == _currentTitle.toLowerCase().trim(),
    );

    debugPrint('🔍 ViewAll: Looking for "$_currentTitle"');
    debugPrint('🔍 Sections: ${homeController.homeSections.map((s) => s.title).toList()}');

    if (section == null) {
      debugPrint('❌ Section not found');
      isLoading.value = false;
      items.clear();
      return;
    }

    // ✅ HomeController se selected category type lo
    final selectedType = homeController.selectedCategory?.type;
    debugPrint('🔍 selectedType: $selectedType');

    // ✅ Same filter jo HomeScreen use karta hai
    final allItems = section.itemsForType(selectedType);
    debugPrint('✅ Found ${allItems.length} items for type: $selectedType');

    if (allItems.isEmpty) {
      isLoading.value = false;
      items.clear();
      return;
    }

    items.assignAll(allItems.map((si) => _sectionItemToMap(si)).toList());
    isLoading.value = false;
  }

  Map<String, dynamic> _sectionItemToMap(SectionItem si) {
    // ✅ Movie
    if (si.movie != null) return _toMap(si.movie!);

    // ✅ WebSeries / TvShow
    if (si.webSeries != null) return _toMapWebSeries(si.webSeries!, si.type);

    // Fallback
    return {
      '_id': si.id,
      'id': si.id,
      'title': si.title,
      'image': si.verticalPosterUrl,
      'verticalPosterUrl': si.verticalPosterUrl,
      'horizontalBannerUrl': si.horizontalBannerUrl,
      'logoImage': '',
      'videoTrailer': '',
      'videoMovies': '',
      'isWebSeries': si.isWebSeries,
    };
  }

  Map<String, dynamic> _toMapWebSeries(WebSeriesModel ws, String type) => {
        '_id': ws.id,
        'id': ws.id,
        'title': ws.title,
        'image': ws.posterUrl,
        'verticalPosterUrl': ws.posterUrl,
        'horizontalBannerUrl': ws.bannerUrl,
        'logoImage': "",
        'description': ws.description,
        'dis': ws.description,
        'subtitle': ws.genresString,
        'videoTrailer': ws.trailerUrl,
        'videoMovies': '',
        'isWebSeries': type == 'webseries',
        'isTvShow': type == 'tvshow',
      };

  Map<String, dynamic> _toMap(MovieModel m) => {
        '_id': m.id,
        'id': m.id,
        'title': m.movieTitle,
        'movieTitle': m.movieTitle,
        'tagline': m.tagline,
        'description': m.description,
        'dis': m.description,
        'fullStoryline': m.fullStoryline,
        'genres': m.genres,
        'subtitle': m.genresString,
        'tags': m.tags,
        'language': m.language,
        'duration': m.duration,
        'ageRating': m.ageRating,
        'imdbRating': m.imdbRating,
        'releaseYear': m.releaseYear,
        'image': m.verticalPosterUrl,
        'verticalPosterUrl': m.verticalPosterUrl,
        'horizontalBannerUrl': m.horizontalBannerUrl,
        'logoImage': m.logoUrl,
        'logoUrl': m.logoUrl,
        'videoTrailer': m.trailerUrl.isNotEmpty ? m.trailerUrl : m.playUrl,
        'videoMovies': m.playUrl,
        'directorInfo': m.directorString,
        'castInfo': m.castString,
        'publishStatus': m.publishStatus,
        'subscriptionRequired': m.subscriptionRequired,
        'castMembers': m.castMembers
            .map((c) => {
                  'name': c.name,
                  'character': c.character,
                  'imageUrl': c.imageUrl,
                })
            .toList(),
      };

  @override
  void onInit() {
    super.onInit();

    ever(homeController.isLoadingSections, (bool loading) {
      if (!loading && _currentTitle.isNotEmpty) _loadItems();
    });

    ever(homeController.homeSections, (_) {
      if (_currentTitle.isNotEmpty) _loadItems();
    });

    // ✅ Category change hone pe bhi reload karo
    ever(homeController.selectedCategoryIndex, (_) {
      if (_currentTitle.isNotEmpty) _loadItems();
    });
  }
}