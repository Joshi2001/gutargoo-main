import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_banner.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_model.dart';
import 'package:gutrgoopro/potli/home/model/potli_home_section.dart';
import 'package:http/http.dart' as http;

class PotliService {
  static const String _bannersUrl =
      'https://gutargooplus.com/api/api//banners';
  static const String _moviesUrl =
      'https://gutargooplus.com/api/api//movies';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<List<PotliBannerModel>> fetchBanners() async {
    try {
      final uri = Uri.parse(_bannersUrl).replace(
        queryParameters: {'publishStatus': 'true', 'limit': '20'},
      );
      debugPrint('📡 fetchBanners: $uri');

      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 fetchBanners status: ${res.statusCode}');

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      debugPrint('📡 fetchBanners raw keys: ${data.keys}');

      final list = data['data'] as List<dynamic>? ??
          data['banners'] as List<dynamic>? ??
          [];

      debugPrint('📡 fetchBanners count: ${list.length}');

      final banners = list
          .map((e) => PotliBannerModel.fromJson(e as Map<String, dynamic>))
          .where((b) => b.publishStatus)
          .toList();

      debugPrint('📡 fetchBanners published: ${banners.length}');
      return banners;
    } catch (e) {
      debugPrint('fetchBanners ERROR: $e');
      return [];
    }
  }

  static Future<List<PotliSectionModel>> fetchSections() async {
    try {
      final uri = Uri.parse('$_moviesUrl');
      debugPrint('📡 fetchSections (movies): $uri');

      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 fetchSections status: ${res.statusCode}');

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final list = data['data'] as List<dynamic>? ??
          data['movies'] as List<dynamic>? ??
          [];

      debugPrint('📡 fetchSections movies count: ${list.length}');

      if (list.isEmpty) return [];

      final movies = list
          .map((e) => PotliMovieModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return [
        PotliSectionModel(
          id: 'all_movies',
          title: 'All Movies',
          displayStyle: 'standard',
          items: movies,
        ),
      ];
    } catch (e) {
      debugPrint('fetchSections ERROR: $e');
      return [];
    }
  }


  static Future<List<PotliMovieModel>> fetchFeaturedMovies() async {
    try {
      final uri = Uri.parse(_moviesUrl);
      debugPrint('📡 fetchFeaturedMovies: $uri');

      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final list = data['data'] as List<dynamic>? ??
          data['movies'] as List<dynamic>? ??
          [];

      return list
          .map((e) => PotliMovieModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('fetchFeaturedMovies ERROR: $e');
      return [];
    }
  }

  // ── Movie detail helpers ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> fetchMovieDetail(
      String movieId) async {
    try {
      // Fetch full movies list and find by ID (same approach as BannerMovieService)
      final uri = Uri.parse(_moviesUrl);
      debugPrint('📡 fetchMovieDetail for $movieId: $uri');

      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final list = data['data'] as List<dynamic>? ??
          data['movies'] as List<dynamic>? ??
          [];

      final movie = list.firstWhere(
        (m) => m['_id']?.toString() == movieId,
        orElse: () => null,
      );

      if (movie == null) {
        debugPrint('📡 Movie not found for ID: $movieId');
        return null;
      }

      debugPrint('📡 Found movie: ${movie['movieTitle']}');
      return movie as Map<String, dynamic>;
    } catch (e) {
      debugPrint('fetchMovieDetail ERROR: $e');
      return null;
    }
  }

  static Future<String> fetchMoviePlayUrl(String movieId) async {
    try {
      final detail = await fetchMovieDetail(movieId);
      if (detail == null) return '';

      final url =
          detail['videoStreamUrl']?.toString().isNotEmpty == true
              ? detail['videoStreamUrl'].toString()
          : detail['customVideoUrl']?.toString().isNotEmpty == true
              ? detail['customVideoUrl'].toString()
          : (detail['movieFile'] as Map?)?['hlsUrl']
                  ?.toString()
                  .isNotEmpty ==
                  true
              ? (detail['movieFile'] as Map)['hlsUrl'].toString()
          : (detail['movieFile'] as Map?)?['url']?.toString() ?? '';

      debugPrint('📡 Resolved playUrl: "$url"');
      return url;
    } catch (e) {
      debugPrint('fetchMoviePlayUrl ERROR: $e');
      return '';
    }
  }

  static Future<String> fetchMovieTrailerUrl(String movieId) async {
    try {
      final detail = await fetchMovieDetail(movieId);
      if (detail == null) return '';

      final url =
          detail['trailerStreamUrl']?.toString().isNotEmpty == true
              ? detail['trailerStreamUrl'].toString()
          : detail['customTrailerUrl']?.toString().isNotEmpty == true
              ? detail['customTrailerUrl'].toString()
          : (detail['trailer'] as Map?)?['hlsUrl']
                  ?.toString()
                  .isNotEmpty ==
                  true
              ? (detail['trailer'] as Map)['hlsUrl'].toString()
          : (detail['trailer'] as Map?)?['url']?.toString() ?? '';

      debugPrint('📡 Resolved trailerUrl: "$url"');
      return url;
    } catch (e) {
      debugPrint('fetchMovieTrailerUrl ERROR: $e');
      return '';
    }
  }
}