import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class BannerMovieService {

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Future<BannerMovieListResponse> fetchBannerMovies({
    int page = 1,
    int limit = 20,
    bool? featured,
    String? sortBy,
    String order = 'desc',
  }) async {
    try {
      final uri = Uri.parse(MyApi.banner).replace(
        queryParameters: {
          'page': '$page',
          'limit': '$limit',
          if (featured != null) 'featured': '$featured',
          if (sortBy != null) 'sortBy': sortBy,
          'order': order,
        },
      );
      debugPrint('📋 fetchBannerMovies → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('📋 fetchBannerMovies ← status: ${response.statusCode}');
      debugPrint('📋 fetchBannerMovies ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final result = BannerMovieListResponse.fromJson(json);
      debugPrint('📋 fetchBannerMovies → parsed ${result.data.length} items');
      return result;
    } catch (e) {
      debugPrint('❌ fetchBannerMovies ERROR: $e');
      rethrow;
    }
  }
  // static Future<List<BannerMovie>> fetchAllBanners({int limit = 20}) async {
  //   try {
  //     final uri = Uri.parse(
  //       MyApi.banner,
  //     ).replace(queryParameters: {'limit': '$limit', 'publishStatus': 'true'});
  //     debugPrint('🏠 fetchAllBanners → GET $uri');
  //     final response = await http.get(uri, headers: _headers);
  //     debugPrint('🏠 fetchAllBanners ← status: ${response.statusCode}');
  //     debugPrint('🏠 fetchAllBanners ← body: ${response.body}');
  //     _checkStatus(response);
  //     final json = jsonDecode(response.body);
  //     final banners = BannerMovieListResponse.fromJson(
  //       json,
  //     ).data.where((b) => b.publishStatus).toList();
  //     debugPrint('🏠 fetchAllBanners → ${banners.length} published banners');
  //     return banners;
  //   } catch (e) {
  //     debugPrint('❌ fetchAllBanners ERROR: $e');
  //     return [];
  //   }
  // }
  static Future<List<BannerMovie>> fetchAllBanners({int limit = 20, bool enrich = true}) async {
  try {
    final uri = Uri.parse(
      MyApi.banner,
    ).replace(queryParameters: {'limit': '$limit', 'publishStatus': 'true'});
    debugPrint('🏠 fetchAllBanners → GET $uri');
    final response = await http.get(uri, headers: _headers);
    debugPrint('🏠 fetchAllBanners ← status: ${response.statusCode}');
    debugPrint('🏠 fetchAllBanners ← body: ${response.body}');
    _checkStatus(response);
    final json = jsonDecode(response.body);
    final banners = BannerMovieListResponse.fromJson(
      json,
    ).data.where((b) => b.publishStatus).toList();
    
    // Enrich banners if requested
    if (enrich && banners.isNotEmpty) {
      debugPrint('🏠 fetchAllBanners → enriching ${banners.length} banners...');
      final enrichedBanners = <BannerMovie>[];
      for (final banner in banners) {
        final enriched = await enrichBannerWithDetails(banner);
        enrichedBanners.add(enriched);
      }
      debugPrint('🏠 fetchAllBanners → ${enrichedBanners.length} enriched banners');
      return enrichedBanners;
    }
    
    debugPrint('🏠 fetchAllBanners → ${banners.length} published banners');
    return banners;
  } catch (e) {
    debugPrint('❌ fetchAllBanners ERROR: $e');
    return [];
  }
}
static Future<Map<String, dynamic>?> fetchWebSeriesDetail(String webSeriesId) async {
  try {
    final uri = Uri.parse('${MyApi.webseries}/$webSeriesId');
    debugPrint('📺 Fetching web series detail: $uri');

    final response = await http.get(uri, headers: _headers);
    _checkStatus(response);

    final json = jsonDecode(response.body);
    debugPrint('📺 Web series response: ${response.body}');
    
    if (json['data'] != null) {
      debugPrint('📺 Found web series: ${json['data']['title']}');
      return json['data'] as Map<String, dynamic>;
    } else if (json['_id'] != null) {
      debugPrint('📺 Found web series (direct): ${json['title']}');
      return json;
    }

    debugPrint('❌ Web series not found for ID: $webSeriesId');
    return null;
  } catch (e) {
    debugPrint('fetchWebSeriesDetail ERROR: $e');
    return null;
  }
}

static Future<String?> fetchWebSeriesPlayUrl(String webSeriesId, {int seasonIndex = 0, int episodeIndex = 0}) async {
  try {
    debugPrint('▶️ fetchWebSeriesPlayUrl → resolving for webSeriesId: $webSeriesId');
    final detail = await fetchWebSeriesDetail(webSeriesId);
    if (detail == null) {
      debugPrint('⚠️ fetchWebSeriesPlayUrl → no detail found for webSeriesId: $webSeriesId');
      return null;
    }

    debugPrint('📺 Web series detail keys: ${detail.keys}');
    
    // Try multiple possible field names for seasons
    final seasons = detail['seasons'] ?? detail['Seasons'];
    
    if (seasons != null && seasons is List && seasons.isNotEmpty) {
      final season = seasons[seasonIndex];
      final episodes = season['episodes'] ?? season['Episodes'];
      
      if (episodes != null && episodes is List && episodes.isNotEmpty) {
        final episode = episodes[episodeIndex];
        
        // Try multiple possible URL fields
        String? url = episode['videoStreamUrl']?.toString();
        url ??= episode['customVideoUrl']?.toString();
        url ??= episode['videoUrl']?.toString();
        url ??= (episode['movieFile'] as Map?)?['hlsUrl']?.toString();
        url ??= (episode['movieFile'] as Map?)?['url']?.toString();
        url ??= episode['playUrl']?.toString();
        
        if (url != null && url.isNotEmpty) {
          debugPrint('▶️ fetchWebSeriesPlayUrl → resolved playUrl: "$url"');
          return url;
        }
      }
    }

    debugPrint('❌ fetchWebSeriesPlayUrl → no valid play URL for web series $webSeriesId');
    return null;
  } catch (e) {
    debugPrint('❌ fetchWebSeriesPlayUrl ERROR: $e');
    return null;
  }
}
// Add this method to your BannerMovieService class
static Future<BannerMovie> enrichBannerWithDetails(BannerMovie banner) async {
  // If it's a movie and has movieId
  if (banner.isSingleMovie && banner.effectiveMovieId != null) {
    try {
      final movieDetail = await fetchMovieDetail(banner.effectiveMovieId!);
      if (movieDetail != null) {
        // Extract genres from movie detail
        List<String> genres = [];
        final movieGenres = movieDetail['genres'];
        if (movieGenres is List) {
          genres = movieGenres.map((g) => g.toString()).toList();
        } else if (movieGenres is String && movieGenres.isNotEmpty) {
          genres = [movieGenres];
        }
        
        // Extract language from movie detail
        final language = movieDetail['language']?.toString() ?? '';
        
        // Return enriched banner
        return banner.copyWith(
          genres: genres.isNotEmpty ? genres : banner.genres,
          language: language.isNotEmpty ? language : banner.language,
          description: movieDetail['description']?.toString() ?? banner.description,
          imdbRating: (movieDetail['imdbRating'] as num?)?.toDouble() ?? banner.imdbRating,
          ageLimit: movieDetail['ageLimit']?.toString() ?? banner.ageLimit,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to enrich movie banner: $e');
    }
  }
  
  // If it's a web series
  if (banner.isWebSeries && banner.effectiveWebSeriesId != null) {
    try {
      final webSeriesDetail = await fetchWebSeriesDetail(banner.effectiveWebSeriesId!);
      if (webSeriesDetail != null) {
        // Extract genres from web series detail
        List<String> genres = [];
        final webSeriesGenres = webSeriesDetail['genres'];
        if (webSeriesGenres is List) {
          genres = webSeriesGenres.map((g) => g.toString()).toList();
        } else if (webSeriesGenres is String && webSeriesGenres.isNotEmpty) {
          genres = [webSeriesGenres];
        }
        
        // Extract language from web series detail
        final language = webSeriesDetail['language']?.toString() ?? '';
        
        // Return enriched banner
        return banner.copyWith(
          genres: genres.isNotEmpty ? genres : banner.genres,
          language: language.isNotEmpty ? language : banner.language,
          description: webSeriesDetail['description']?.toString() ?? banner.description,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to enrich web series banner: $e');
    }
  }
  
  return banner;
}

// Add this method to fetch and enrich all banners
static Future<List<BannerMovie>> fetchEnrichedBanners({int limit = 20}) async {
  try {
    final banners = await fetchAllBanners(limit: limit);
    final enrichedBanners = <BannerMovie>[];
    
    for (final banner in banners) {
      final enriched = await enrichBannerWithDetails(banner);
      enrichedBanners.add(enriched);
    }
    
    return enrichedBanners;
  } catch (e) {
    debugPrint('❌ fetchEnrichedBanners ERROR: $e');
    return [];
  }
}
static Future<String> fetchWebSeriesTrailerUrl(String webSeriesId) async {
  try {
    debugPrint('🎞️ fetchWebSeriesTrailerUrl → resolving for webSeriesId: $webSeriesId');
    final detail = await fetchWebSeriesDetail(webSeriesId);
    if (detail == null) {
      debugPrint('⚠️ fetchWebSeriesTrailerUrl → no detail found for webSeriesId: $webSeriesId');
      return '';
    }

    final url = detail['trailerStreamUrl']?.toString().isNotEmpty == true
        ? detail['trailerStreamUrl'].toString()
        : detail['customTrailerUrl']?.toString().isNotEmpty == true
        ? detail['customTrailerUrl'].toString()
        : (detail['trailer'] as Map?)?['hlsUrl']?.toString().isNotEmpty == true
        ? (detail['trailer'] as Map)['hlsUrl'].toString()
        : (detail['trailer'] as Map?)?['url']?.toString() ?? '';

    if (url.isEmpty) {
      debugPrint('⚠️ fetchWebSeriesTrailerUrl → no trailer URL found for web series $webSeriesId');
    } else {
      debugPrint('🎞️ fetchWebSeriesTrailerUrl → resolved trailerUrl: "$url"');
    }

    return url;
  } catch (e) {
    debugPrint('❌ fetchWebSeriesTrailerUrl ERROR: $e');
    return '';
  }
}
  // ── Fetch featured banners ─────────────────────────────────────────────────
  // static Future<List<BannerMovie>> fetchFeaturedBanners({
  //   int limit = 20,
  // }) async {
  //   try {
  //     final uri = Uri.parse(
  //       MyApi.banner,
  //     ).replace(queryParameters: {'limit': '$limit', 'publishStatus': 'true'});
  //     debugPrint('⭐ fetchFeaturedBanners → GET $uri');
  //     final response = await http.get(uri, headers: _headers);
  //     debugPrint('⭐ fetchFeaturedBanners ← status: ${response.statusCode}');
  //     debugPrint('⭐ fetchFeaturedBanners ← body: ${response.body}');
  //     _checkStatus(response);
  //     final json = jsonDecode(response.body);
  //     final banners = BannerMovieListResponse.fromJson(
  //       json,
  //     ).data.where((b) => b.publishStatus).toList();
  //     debugPrint('⭐ fetchFeaturedBanners → ${banners.length} featured banners');
  //     return banners;
  //   } catch (e) {
  //     debugPrint('❌ fetchFeaturedBanners ERROR: $e');
  //     return [];
  //   }
  // }

static Future<List<BannerMovie>> fetchFeaturedBanners({
  int limit = 20,
  bool enrich = true,
}) async {
  try {
    final uri = Uri.parse(
      MyApi.banner,
    ).replace(queryParameters: {'limit': '$limit', 'publishStatus': 'true'});
    debugPrint('⭐ fetchFeaturedBanners → GET $uri');
    final response = await http.get(uri, headers: _headers);
    debugPrint('⭐ fetchFeaturedBanners ← status: ${response.statusCode}');
    debugPrint('⭐ fetchFeaturedBanners ← body: ${response.body}');
    _checkStatus(response);
    final json = jsonDecode(response.body);
    var banners = BannerMovieListResponse.fromJson(
      json,
    ).data.where((b) => b.publishStatus).toList();
    
    // Enrich banners if requested
    if (enrich && banners.isNotEmpty) {
      debugPrint('⭐ fetchFeaturedBanners → enriching ${banners.length} banners...');
      final enrichedBanners = <BannerMovie>[];
      for (final banner in banners) {
        final enriched = await enrichBannerWithDetails(banner);
        enrichedBanners.add(enriched);
      }
      banners = enrichedBanners;
    }
    
    debugPrint('⭐ fetchFeaturedBanners → ${banners.length} featured banners');
    return banners;
  } catch (e) {
    debugPrint('❌ fetchFeaturedBanners ERROR: $e');
    return [];
  }
}
  // ── Fetch trending banners ─────────────────────────────────────────────────
  static Future<List<BannerMovie>> fetchTrendingBanners({
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(MyApi.banner).replace(
        queryParameters: {
          'limit': '$limit',
          'sortBy': 'createdAt',
          'order': 'desc',
        },
      );
      debugPrint('🔥 fetchTrendingBanners → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('🔥 fetchTrendingBanners ← status: ${response.statusCode}');
      debugPrint('🔥 fetchTrendingBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(json).data;
      debugPrint(
        '🔥 fetchTrendingBanners → ${banners.length} trending banners',
      );
      return banners;
    } catch (e) {
      debugPrint('❌ fetchTrendingBanners ERROR: $e');
      return [];
    }
  }

  static Future<BannerMovie?> fetchBannerById(String id) async {
    try {
      final uri = Uri.parse('$MyApi.banner/$id');
      debugPrint('🔍 fetchBannerById → GET $uri (id: $id)');
      final response = await http.get(uri, headers: _headers);
      debugPrint('🔍 fetchBannerById ← status: ${response.statusCode}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      debugPrint('🔍 fetchBannerById response: $json');

      if (json['data'] != null) {
        debugPrint('🔍 fetchBannerById → parsed from json[data]');
        return BannerMovie.fromJson(json['data']);
      } else if (json['_id'] != null) {
        debugPrint('🔍 fetchBannerById → parsed directly from root json');
        return BannerMovie.fromJson(json);
      }

      debugPrint('⚠️ fetchBannerById → no data found for id: $id');
      return null;
    } catch (e) {
      debugPrint('❌ fetchBannerById ERROR: $e');
      return null;
    }
  }

  static Future<List<BannerMovie>> searchBanners(
    String query, {
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        MyApi.banner,
      ).replace(queryParameters: {'search': query, 'limit': '$limit'});
      debugPrint('🔎 searchBanners → GET $uri (query: "$query")');
      final response = await http.get(uri, headers: _headers);
      debugPrint('🔎 searchBanners ← status: ${response.statusCode}');
      debugPrint('🔎 searchBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(json).data;
      debugPrint('🔎 searchBanners → ${banners.length} results for "$query"');
      return banners;
    } catch (e) {
      debugPrint('❌ searchBanners ERROR: $e');
      return [];
    }
  }

  static Future<List<BannerMovie>> fetchPublishedBanners({
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        MyApi.banner,
      ).replace(queryParameters: {'publishStatus': 'true', 'limit': '$limit'});
      debugPrint('✅ fetchPublishedBanners → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('✅ fetchPublishedBanners ← status: ${response.statusCode}');
      debugPrint('✅ fetchPublishedBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(json).data;
      debugPrint(
        '✅ fetchPublishedBanners → ${banners.length} published banners',
      );
      return banners;
    } catch (e) {
      debugPrint('❌ fetchPublishedBanners ERROR: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchMovieDetail(String movieId) async {
    try {
      final uri = Uri.parse('${MyApi.movies}/$movieId'); // fetch by ID directly
      debugPrint('🎬 Fetching movie detail: $uri');

      final response = await http.get(uri, headers: _headers);
      _checkStatus(response);

      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        debugPrint('🎬 Found movie: ${json['data']['movieTitle']}');
        return json['data'] as Map<String, dynamic>;
      }

      debugPrint('❌ Movie not found for ID: $movieId');
      return null;
    } catch (e) {
      debugPrint('fetchMovieDetail ERROR: $e');
      return null;
    }
  }

  static Future<String?> fetchMoviePlayUrl(String movieId) async {
    try {
      debugPrint('▶️ fetchMoviePlayUrl → resolving for movieId: $movieId');
      final detail = await fetchMovieDetail(movieId);
      if (detail == null) {
        debugPrint(
          '⚠️ fetchMoviePlayUrl → no detail found for movieId: $movieId',
        );
        return null;
      }

      final url = detail['videoStreamUrl']?.toString().isNotEmpty == true
          ? detail['videoStreamUrl'].toString()
          : detail['customVideoUrl']?.toString().isNotEmpty == true
          ? detail['customVideoUrl'].toString()
          : (detail['movieFile'] as Map?)?['hlsUrl']?.toString().isNotEmpty ==
                true
          ? (detail['movieFile'] as Map)['hlsUrl'].toString()
          : (detail['movieFile'] as Map?)?['url']?.toString();

      if (url == null || url.isEmpty) {
        debugPrint(
          '❌ fetchMoviePlayUrl → no valid play URL for movie $movieId',
        );
        return null;
      }

      debugPrint('▶️ fetchMoviePlayUrl → resolved playUrl: "$url"');
      return url;
    } catch (e) {
      debugPrint('❌ fetchMoviePlayUrl ERROR: $e');
      return null;
    }
  }

  static Future<String> fetchMovieTrailerUrl(String movieId) async {
    try {
      debugPrint('🎞️ fetchMovieTrailerUrl → resolving for movieId: $movieId');
      final detail = await fetchMovieDetail(movieId);
      if (detail == null) {
        debugPrint(
          '⚠️ fetchMovieTrailerUrl → no detail found for movieId: $movieId',
        );
        return '';
      }

      final url = detail['trailerStreamUrl']?.toString().isNotEmpty == true
          ? detail['trailerStreamUrl'].toString()
          : detail['customTrailerUrl']?.toString().isNotEmpty == true
          ? detail['customTrailerUrl'].toString()
          : (detail['trailer'] as Map?)?['hlsUrl']?.toString().isNotEmpty ==
                true
          ? (detail['trailer'] as Map)['hlsUrl'].toString()
          : (detail['trailer'] as Map?)?['url']?.toString() ?? '';

      if (url.isEmpty) {
        debugPrint(
          '⚠️ fetchMovieTrailerUrl → no trailer URL found for movie $movieId',
        );
      } else {
        debugPrint('🎞️ fetchMovieTrailerUrl → resolved trailerUrl: "$url"');
      }

      return url;
    } catch (e) {
      debugPrint('❌ fetchMovieTrailerUrl ERROR: $e');
      return '';
    }
  }

  static void _checkStatus(http.Response response) {
    debugPrint(
      '🌐 _checkStatus → statusCode: ${response.statusCode}, reason: ${response.reasonPhrase}',
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '❌ _checkStatus → HTTP error: ${response.statusCode} ${response.reasonPhrase}',
      );
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
