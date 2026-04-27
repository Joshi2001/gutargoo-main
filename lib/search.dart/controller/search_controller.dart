import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';

class _ScoredMovie {
  final MovieModel movie;
  final int score;
  
  _ScoredMovie(this.movie, this.score);
}

class SearchControllerX extends GetxController {
  final query = ''.obs;
  final recentSearches = <String>[].obs;
  final searchResults = <MovieModel>[].obs;
  final isSearching = false.obs;
  final searchError = ''.obs;
  final isInitialized = false.obs;

  late HomeController _homeCtrl;
  late SharedPreferences _prefs;

  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  @override
  void onInit() {
    super.onInit();
    _initDependencies();
  }

  Future<void> _initDependencies() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (Get.isRegistered<HomeController>()) {
        _homeCtrl = Get.find<HomeController>();
      } else {
        _homeCtrl = Get.put(HomeController());
      }

    
      int retries = 0;
      while ((_homeCtrl.isLoadingSections.value || _homeCtrl.homeSections.isEmpty) && retries < 50) {
        await Future.delayed(const Duration(milliseconds: 200));
        retries++;
      }

      _prefs = await SharedPreferences.getInstance();
      await _loadRecentSearches();

      isInitialized.value = true;
      print('✅ SearchControllerX initialized with ${_getAllMovies().length} movies');
    } catch (e) {
      print('❌ SearchControllerX initialization error: $e');
      searchError.value = 'Initialization error: $e';
      isInitialized.value = true;
    }
  }

  void performSearch(String searchQuery) {
    final trimmed = searchQuery.trim();

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    if (!isInitialized.value) {
      searchError.value = 'Please wait, loading...';
      return;
    }

    final allMovies = _getAllMovies();

    if (allMovies.isEmpty) {
      searchResults.value = [];
      searchError.value = 'No movies available';
      print('⚠️ No movies found in sections');
      return;
    }

    isSearching.value = true;
    searchError.value = '';
    query.value = trimmed;

    // Add delay to show loading state
    Future.delayed(const Duration(milliseconds: 100), () {
      final results = _filterMovies(trimmed);
      searchResults.value = results;
      isSearching.value = false;

      print('🔍 Search for "$trimmed" found ${results.length} results');

      if (results.isEmpty) {
        searchError.value = 'No results found for "$trimmed"';
      }
    });
  }

  List<MovieModel> _filterMovies(String searchQuery) {
    final q = searchQuery.toLowerCase().trim();
    final allMovies = _getAllMovies();

    print('📊 Filtering ${allMovies.length} movies for: $q');

    final searchWords = q.split(' ');
    
    // Create a list of movies with relevance scores
    final List<_ScoredMovie> scoredMovies = [];
    
    for (final movie in allMovies) {
      final title = movie.movieTitle.toLowerCase();
      final genres = movie.genresString.toLowerCase();
      final description = movie.description.toLowerCase();
      
      int score = 0;
      
      for (String word in searchWords) {
        if (word.isEmpty) continue;
        
        // Title match - highest priority
        if (title.contains(word)) {
          score += 10;
          if (title.startsWith(word)) score += 5;

          if (title.split(' ').contains(word)) score += 3;
        }
        if (genres.contains(word)) {
          score += 5;
          if (genres.split(',').map((g) => g.trim()).contains(word)) score += 2;
        }
      
        if (description.contains(word)) {
          score += 2;
        }
      }
      if (q.contains('web') || q.contains('series')) {
        if (title.contains('web series') || genres.contains('web series')) {
          score += 8;
        }
      }
      
      if (q.contains('movie')) {
        if (genres.contains('movie') || title.contains('movie')) {
          score += 8;
        }
      }
      
      // Only include movies with at least some relevance
      if (score > 0) {
        scoredMovies.add(_ScoredMovie(movie, score));
      }
    }
    
    // Sort by score (highest first)
    scoredMovies.sort((a, b) => b.score.compareTo(a.score));
    
    // Return just the movies
    return scoredMovies.map((sm) => sm.movie).toList();
  }

  List<MovieModel> _getAllMovies() {
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

  print('📚 Total unique movies: ${result.length}');
  return result;
}

  void clearSearch() {
    searchResults.clear();
    searchError.value = '';
    query.value = '';
  }

  void addRecentSearch(String search) {
    final trimmed = search.trim();
    if (trimmed.isEmpty) return;

    recentSearches.removeWhere(
      (s) => s.toLowerCase() == trimmed.toLowerCase(),
    );

    recentSearches.insert(0, trimmed);

    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeLast();
    }

    _saveRecentSearches();
  }

  void removeSearch(String search) {
    recentSearches.remove(search);
    _saveRecentSearches();
  }

  void clearAll() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  Future<void> _saveRecentSearches() async {
    await _prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  Future<void> _loadRecentSearches() async {
    final saved = _prefs.getStringList(_recentSearchesKey) ?? [];
    recentSearches.value = saved;
  }
}