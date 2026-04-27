import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/model/web_series_model.dart';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class HomeSectionRepository {

  Future<Map<String, MovieModel>> _fetchAllMovies({
    String? title,
    String? genres,
  }) async {
    try {
      String url = MyApi.movies;
      if (title != null && title.isNotEmpty) url += '?title=$title';
      if (genres != null && genres.isNotEmpty) {
        url += (title == null ? '?' : '&') + 'genres=$genres';
      }

      final res = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        debugPrint('❌ Movies API failed: ${res.statusCode}');
        return {};
      }

      final decoded = json.decode(res.body);
      final data = decoded['data'];
      if (data is! List) return {};

      final map = <String, MovieModel>{};
      for (var item in data) {
        try {
          Map<String, dynamic> movieData;
          if (item is String) {
            final d = json.decode(item);
            if (d is Map<String, dynamic>) {
              movieData = d;
            } else {
              continue;
            }
          } else if (item is Map<String, dynamic>) {
            movieData = item;
          } else {
            continue;
          }
          final movie = MovieModel.fromJson(movieData);
          if (movie.id.isNotEmpty) {
            map[movie.id] = movie;
            debugPrint('🎬 Movie: "${movie.movieTitle}" | poster: "${movie.verticalPosterUrl}"');
          }
        } catch (e) {
          debugPrint('❌ Movie parse error: $e');
        }
      }

      debugPrint('🎬 Total movies loaded: ${map.length}');
      return map;
    } catch (e) {
      debugPrint('❌ _fetchAllMovies error: $e');
      return {};
    }
  }

  Future<Map<String, WebSeriesModel>> _fetchAllWebSeries() async {
    try {
      final res = await http
          .get(
            Uri.parse(MyApi.webseries),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        debugPrint('❌ WebSeries API failed: ${res.statusCode}');
        return {};
      }

      final decoded = json.decode(res.body);
      final data = decoded['data'];
      if (data is! List) return {};

      final map = <String, WebSeriesModel>{};
      for (var item in data) {
        try {
          if (item is! Map<String, dynamic>) continue;
          final ws = WebSeriesModel.fromJson(item, contentType: 'webseries');
          if (ws.id.isNotEmpty) map[ws.id] = ws;
        } catch (e) {
          debugPrint('❌ WebSeries parse error: $e');
        }
      }

      debugPrint('📺 Total webseries loaded: ${map.length}');
      return map;
    } catch (e) {
      debugPrint('❌ _fetchAllWebSeries error: $e');
      return {};
    }
  }

  // ─────────────────────────────────────────────
  // Fetch ALL TV Shows → id → WebSeriesModel map
  // ─────────────────────────────────────────────
  Future<Map<String, WebSeriesModel>> _fetchAllTvShows() async {
    try {
      final res = await http
          .get(
            Uri.parse(MyApi.webseries),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        debugPrint('❌ TVShows API failed: ${res.statusCode}');
        return {};
      }

      final decoded = json.decode(res.body);
      final data = decoded['data'];
      if (data is! List) return {};

      final map = <String, WebSeriesModel>{};
      for (var item in data) {
        try {
          if (item is! Map<String, dynamic>) continue;
          final ws = WebSeriesModel.fromJson(item, contentType: 'tvshow');
          if (ws.id.isNotEmpty) map[ws.id] = ws;
        } catch (e) {
          debugPrint('❌ TVShow parse error: $e');
        }
      }

      debugPrint('📡 Total TV shows loaded: ${map.length}');
      return map;
    } catch (e) {
      debugPrint('❌ _fetchAllTvShows error: $e');
      return {};
    }
  }

  Future<List<dynamic>> fetchSectionsRaw({String? categoryId}) async {
    try {
      String url = MyApi.sections;
      if (categoryId != null && categoryId.isNotEmpty) {
        url += '?categoryId=$categoryId';
      }

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final decoded = json.decode(response.body);
      List<dynamic> rawList = [];

      if (decoded is Map<String, dynamic>) {
        rawList =
            (decoded['data'] ?? decoded['sections'] ?? []) as List<dynamic>;
      } else if (decoded is List) {
        rawList = decoded;
      }

      return rawList;
    } catch (e) {
      debugPrint('Error fetching sections raw: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // Main: fetchSections
  // ─────────────────────────────────────────────
  Future<List<HomeSectionModel>> fetchSections({
    String? categoryId,
    String? title,
    String? genres,
  }) async {
    try {
      String url = MyApi.sections;
      if (categoryId != null && categoryId.isNotEmpty) {
        url += '?categoryId=$categoryId';
      }

      debugPrint('🌐 Sections URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 STATUS: ${response.statusCode}');

      if (response.statusCode != 200) return [];

      final decoded = json.decode(response.body);
      List<dynamic> rawList = [];

      if (decoded is Map<String, dynamic>) {
        rawList =
            (decoded['data'] ?? decoded['sections'] ?? []) as List<dynamic>;
      } else if (decoded is List) {
        rawList = decoded;
      } else {
        return [];
      }

      debugPrint('📊 Raw sections count: ${rawList.length}');
      
      // 🔍 Debug: Print first raw section
      if (rawList.isNotEmpty) {
        debugPrint('📋 First raw section: ${rawList.first}');
      }

      final allParsed = rawList
          .map((e) {
            try {
              final section = HomeSectionModel.fromJson(e as Map<String, dynamic>);
              debugPrint('✅ Parsed section: "${section.title}" - sectionData: ${section.sectionData.length} items, movieIds: ${section.movieIds.length}');
              return section;
            } catch (err) {
              debugPrint('❌ Section parse error for ${e['title']}: $err');
              return null;
            }
          })
          .whereType<HomeSectionModel>()
          .where((s) => s.isActive)
          .toList();

      final seen = <String>{};
      final deduped = allParsed.where((s) {
        final key =
            '${s.title.trim().toLowerCase()}__${s.categoryId ?? 'null'}';
        return seen.add(key);
      }).toList();

      debugPrint('📊 After dedup: ${deduped.length} sections');

      final needsMovies =
          deduped.any((s) => s.sectionData.any((d) => d.isMovie));
      final needsWebSeries =
          deduped.any((s) => s.sectionData.any((d) => d.isWebSeries));
      final needsTvShows =
          deduped.any((s) => s.sectionData.any((d) => d.isTvShow));
      final hasLegacy =
          deduped.any((s) => s.sectionData.isEmpty && s.movieIds.isNotEmpty);

      debugPrint(
          '🔍 needsMovies: $needsMovies | needsWS: $needsWebSeries | needsTV: $needsTvShows | hasLegacy: $hasLegacy');

     final List<Map<String, dynamic>> futures = await Future.wait([
  (needsMovies || hasLegacy)
      ? _fetchAllMovies(title: title, genres: genres)
      : Future.value(<String, MovieModel>{}),
  needsWebSeries
      ? _fetchAllWebSeries()
      : Future.value(<String, WebSeriesModel>{}),
  needsTvShows
      ? _fetchAllTvShows()
      : Future.value(<String, WebSeriesModel>{}),
]);
      final movieMap = futures[0] as Map<String, MovieModel>;
      final webSeriesMap = futures[1] as Map<String, WebSeriesModel>;
      final tvShowMap = futures[2] as Map<String, WebSeriesModel>;

      debugPrint('🗺️ movieMap size: ${movieMap.length}');
      if (movieMap.isNotEmpty) {
        debugPrint('📝 First 5 movie IDs: ${movieMap.keys.take(5).toList()}');
      }

      final populated = deduped.map((section) {
        // ── New API: sectionData with types ──
        if (section.sectionData.isNotEmpty) {
          final resolvedItems = section.sectionData.map((item) {
            if (item.isMovie) {
              final movie = movieMap[item.id];
              if (movie == null) {
                debugPrint(
                    '⚠️ Movie not found in map: ${item.id}');
                return null;
              }
              return SectionItem.fromMovie(movie);
            } else if (item.isWebSeries) {
              final ws = webSeriesMap[item.id];
              if (ws == null) {
                debugPrint('⚠️ WebSeries not found: ${item.id}');
                return null;
              }
              return SectionItem.fromWebSeries(ws);
            } else if (item.isTvShow) {
              final tv = tvShowMap[item.id];
              if (tv == null) {
                debugPrint('⚠️ TVShow not found: ${item.id}');
                return null;
              }
              return SectionItem.fromTvShow(tv);
            }
            return null;
          }).whereType<SectionItem>().toList();

          if (resolvedItems.isEmpty) {
            debugPrint(
                '🚫 Section "${section.title}" — no items matched. '
                'sectionData ids: ${section.sectionData.map((e) => e.id).join(', ')}');
            return null;
          }

          debugPrint(
              '✅ Section "${section.title}" → ${resolvedItems.length} items | '
              'first poster: "${resolvedItems.first.verticalPosterUrl}"');
          return section.copyWith(mixedItems: resolvedItems);
        }
        
        // ── Legacy API: movieIds ──
        if (section.movieIds.isNotEmpty) {
          final movies = section.movieIds
              .map((id) => movieMap[id])
              .whereType<MovieModel>()
              .toList();

          if (movies.isEmpty) {
            debugPrint('🚫 Legacy section "${section.title}" — no movies found for IDs: ${section.movieIds}');
            return null;
          }

          debugPrint(
              '✅ Legacy section "${section.title}" → ${movies.length} movies');
          return section.copyWith(items: movies);
        }

        debugPrint('⚠️ Section "${section.title}" has no items');
        return null;
      }).toList();

      final result = populated
          .whereType<HomeSectionModel>()
          .where((s) => s.allDisplayItems.isNotEmpty)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      debugPrint('🔥 FINAL SECTIONS: ${result.length}');
      for (final s in result) {
        debugPrint(
            '  📦 "${s.title}" → ${s.allDisplayItems.length} items | displayStyle: ${s.displayStyle} | type: ${s.type}');
        if (s.allDisplayItems.isNotEmpty) {
          debugPrint('     First item: "${s.allDisplayItems.first.title}" - poster: "${s.allDisplayItems.first.verticalPosterUrl}"');
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ fetchSections EXCEPTION: $e');
      return [];
    }
  }
}
