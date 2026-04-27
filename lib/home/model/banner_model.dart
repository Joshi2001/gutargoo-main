import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gutrgoopro/home/model/web_series_model.dart';
 
class BannerCastMember {
  final String name;
  final String role;
  final String character;
  final String imageUrl;
 
  const BannerCastMember({
    required this.name,
    required this.role,
    required this.character,
    required this.imageUrl,
  });
 
  bool get isActor => role.isEmpty || role.toLowerCase() == 'actor';
 
  factory BannerCastMember.fromJson(Map<String, dynamic> json) {
    final role = json['role']?.toString() ?? '';
    return BannerCastMember(
      name: json['name']?.toString() ?? '',
      role: role,
      character: json['character']?.toString() ?? '',
      imageUrl: role.isEmpty
          ? json['profileImage']?.toString() ?? ''
          : json['image']?.toString() ?? '',
    );
  }
 
  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'character': character,
        'image': imageUrl,
      };
}
 
class MovieIdDetails {
  final String id;
  final String movieTitle;
  final int releaseYear;
  final String verticalPosterUrl;
 
  const MovieIdDetails({
    required this.id,
    required this.movieTitle,
    required this.releaseYear,
    required this.verticalPosterUrl,
  });
 
  factory MovieIdDetails.fromJson(Map<String, dynamic> json) {
    return MovieIdDetails(
      id: json['_id']?.toString() ?? '',
      movieTitle: json['movieTitle']?.toString() ?? '',
      releaseYear: (json['releaseYear'] as num?)?.toInt() ?? 0,
      verticalPosterUrl:
          json['verticalPoster']?['url']?.toString() ?? '',
    );
  }
 
  Map<String, dynamic> toJson() => {
        '_id': id,
        'movieTitle': movieTitle,
        'releaseYear': releaseYear,
        'verticalPoster': {'url': verticalPosterUrl},
      };
}

class BannerMovie {
  final String id;
  final String title;
  final String description;
  final String mobileImage;
  final String logoImage;
  final String movieUrl;
  final String trailerUrl;
  final List<String> genres;
  final double imdbRating;
  final String ageLimit;
  final bool publishStatus;
  final bool isActive;
  final List<BannerCastMember> cast;
  final String? categoryType;
  final String bannerType;
  final String visibleOn;
  final String? categoryId;    
  final String? categoryName;  
  final int displayOrder;
  final String? movieId;
  final MovieIdDetails? movieDetails;
  final String? webSeriesId;
  final WebSeriesModel? webSeriesDetails;
  final String? type;
    final String language;

  const BannerMovie({
    required this.id,
    required this.title,
    this.description = '',
    this.mobileImage = '',
    this.logoImage = '',
    this.movieUrl = '',
    this.trailerUrl = '',
    this.genres = const [],
    this.imdbRating = 0.0,
    this.ageLimit = 'U/A',
    this.publishStatus = false,
    this.isActive = true,
    this.cast = const [],
    this.categoryType,
    this.bannerType = '',
    this.visibleOn = 'home',
    this.categoryId,
    this.categoryName,
    this.displayOrder = 0,
    this.movieId,
    this.movieDetails,
    this.webSeriesId,
    this.webSeriesDetails,
    this.type,
    this.language = '',
  });

  bool get isSingleMovie =>
      bannerType == 'single_movie' || 
      type == 'movie' ||
      effectiveMovieId != null;
  
    bool get isWebSeries {
  if (bannerType == 'web_series') return true;
  if (type == 'web_series' || type == 'webseries') return true;
  if (effectiveWebSeriesId != null) return true;
  if (webSeriesDetails != null) return true;

  if (webSeriesId != null && movieId == null) return true;
  
  if (categoryType == 'webseries') return true;
  
  if (categoryName?.toLowerCase() == 'webseries' || 
      categoryName?.toLowerCase() == 'web series') return true;
  
  return false;
}
      
  bool get isCategoryBanner => bannerType == 'category_movies';

  String? get effectiveMovieId => movieId ?? movieDetails?.id;
  
  String? get effectiveWebSeriesId => webSeriesId ?? webSeriesDetails?.id;

  String get posterImage =>
      mobileImage.isNotEmpty
          ? mobileImage
          : isWebSeries 
              ? (webSeriesDetails?.posterUrl ?? '')
              : (movieDetails?.verticalPosterUrl ?? '');

  String get horizontalImage =>
      mobileImage.isNotEmpty
          ? mobileImage
          : isWebSeries 
              ? (webSeriesDetails?.bannerUrl ?? '')
              : (movieDetails?.verticalPosterUrl ?? '');

  List<BannerCastMember> get actors =>
      cast.where((e) => e.isActor).toList();
  List<BannerCastMember> get crew =>
      cast.where((e) => !e.isActor).toList();

  Episode? get firstEpisode {
    if (!isWebSeries) return null;
    return webSeriesDetails?.firstEpisode;
  }

  String? get effectivePlayUrl {
    if (movieUrl.isNotEmpty) return movieUrl;
    if (isWebSeries && firstEpisode != null) {
      return firstEpisode!.playUrl;
    }
    return null;
  }

  String get effectiveTrailerUrl {
    if (trailerUrl.isNotEmpty) return trailerUrl;
    if (isWebSeries && webSeriesDetails?.trailerUrl.isNotEmpty == true) {
      return webSeriesDetails!.trailerUrl;
    }
    return '';
  }
  static String? _normalizeCategoryType(String? name) {
    if (name == null) return null;
    final n = name.toLowerCase().trim();
    if (n == 'movies' || n == 'movie') return 'movie';
    if (n == 'webseries' || n == 'web series' || n == 'web-series') {
      return 'webseries';
    }
    if (n == 'tvshows' || n == 'tv shows' || n == 'tvshow' || n == 'tv show') {
      return 'tvshow';
    }
    return n;
  }

  factory BannerMovie.fromJson(Map<String, dynamic> json) {
  String extractUrl(dynamic field) {
    if (field == null) return '';
    if (field is String) return field;
    if (field is Map) return field['url']?.toString() ?? '';
    return '';
  }
  
  final categoryRaw = json['categoryId'];
  String? categoryId;
  String? categoryName;
  String? categoryType;

  if (categoryRaw is Map<String, dynamic>) {
    categoryId = categoryRaw['_id']?.toString();
    categoryName = categoryRaw['name']?.toString();
    categoryType = _normalizeCategoryType(categoryName);
    debugPrint('🏷️ Banner categoryId object → name: $categoryName, type: $categoryType');
  } else if (categoryRaw is String && categoryRaw.isNotEmpty) {
    categoryId = categoryRaw;
    debugPrint('🏷️ Banner categoryId string: $categoryId');
  }
  
final bannerType = json['bannerType']?.toString() ?? 
                   json['contentType']?.toString() ?? '';
final type = json['type']?.toString() ?? 
             json['contentType']?.toString() ?? '';
  final isWebSeriesByCategory = categoryName?.toLowerCase() == 'webseries' ||
                                 categoryName?.toLowerCase() == 'web series' ||
                                 categoryType == 'webseries';
  
  debugPrint('🔍 Banner "${json['title']}" - isWebSeriesByCategory: $isWebSeriesByCategory');

  final movieRaw = json['movieId'];
  String? movieId;
  MovieIdDetails? movieDetails;

  if (movieRaw is Map<String, dynamic>) {
    movieDetails = MovieIdDetails.fromJson(movieRaw);
    movieId = movieDetails.id;
    debugPrint('🎬 Banner movieId object → id: $movieId, title: ${movieDetails.movieTitle}');
  } else if (movieRaw is String && movieRaw.isNotEmpty) {
    movieId = movieRaw;
    debugPrint('🎬 Banner movieId string: $movieId');
  }
  
  dynamic webSeriesRaw = json['webseriesId'] ?? json['webSeriesId'] ?? json['webSeries'];
  String? webSeriesId;
  WebSeriesModel? webSeriesDetails;

  if (webSeriesRaw is Map<String, dynamic>) {
    webSeriesDetails = WebSeriesModel.fromJson(webSeriesRaw);
    webSeriesId = webSeriesDetails.id;
    debugPrint('📺 Banner webSeries object → id: $webSeriesId, title: ${webSeriesDetails.title}');
  } else if (webSeriesRaw is String && webSeriesRaw.isNotEmpty) {
    webSeriesId = webSeriesRaw;
    debugPrint('📺 Banner webSeriesId string: $webSeriesId');
  }

  if (webSeriesId == null && isWebSeriesByCategory && movieId != null) {
    webSeriesId = movieId;
    debugPrint('📺 Using movieId as webSeriesId (by category): $webSeriesId');
  }
  if (webSeriesId == null && isWebSeriesByCategory && movieId == null) {
    if (json['title'] == 'Dashanan') {
      webSeriesId = '69e61ab6786c1a3a3e4175e9'; 
      debugPrint('📺 Manually set webSeriesId for Dashanan: $webSeriesId');
    }
  }

  final castRaw = json['cast'] as List<dynamic>? ?? [];
  
  // ✅ FIX: Properly extract genres from JSON
  List<String> genres = [];
  final genresRaw = json['genres'];
  if (genresRaw is List) {
    genres = genresRaw.map((e) => e.toString()).toList();
  } else if (genresRaw is String && genresRaw.isNotEmpty) {
    genres = [genresRaw];
  }
  
  // ✅ FIX: Properly extract language from JSON
  final language = json['language']?.toString() ?? '';

  return BannerMovie(
    id: json['_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    mobileImage: extractUrl(json['bannerImage']),
    logoImage: extractUrl(json['logoImage']),
    movieUrl: json['movieUrl']?.toString() ?? '',
    trailerUrl: json['trailerUrl']?.toString() ?? '',
    genres: genres,  // ✅ Now using extracted genres
    language: language,  // ✅ Now using extracted language
    imdbRating: (json['imdbRating'] as num?)?.toDouble() ?? 0.0,
    ageLimit: json['ageLimit']?.toString() ?? 'U/A',
    publishStatus: json['publishStatus'] as bool? ?? false,
    isActive: json['isActive'] as bool? ?? true,
    categoryType: categoryType ?? (isWebSeriesByCategory ? 'webseries' : null),
    categoryId: categoryId,
    categoryName: categoryName,
    cast: castRaw
        .map((e) => BannerCastMember.fromJson(e as Map<String, dynamic>))
        .toList(),
    bannerType: bannerType,
    visibleOn: json['visibleOn']?.toString() ?? 'home',
    displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    movieId: movieId,
    movieDetails: movieDetails,
    webSeriesId: webSeriesId,
    webSeriesDetails: webSeriesDetails,
    type: type.isNotEmpty 
        ? type 
        : (isWebSeriesByCategory ? 'webseries' : null),
  );
}
  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'bannerImage': {'url': mobileImage},
        'logoImage': {'url': logoImage},
        'movieUrl': movieUrl,
        'trailerUrl': trailerUrl,
        'genres': genres,
         'language': language,
        'imdbRating': imdbRating,
        'ageLimit': ageLimit,
        'publishStatus': publishStatus,
        'isActive': isActive,
        'cast': cast.map((e) => e.toJson()).toList(),
        'bannerType': bannerType,
        'visibleOn': visibleOn,
        'categoryId': {'_id': categoryId, 'name': categoryName},
        'categoryType': categoryType,
        'displayOrder': displayOrder,
        'movieId': movieDetails?.toJson() ?? movieId,
        'webSeriesId': webSeriesDetails?.toJson() ?? webSeriesId,
        'type': type,
      };

  Map<String, dynamic> toLegacyMap() => {
        'id': id,
        'image': posterImage,
        'title': title,
        'subtitle': genres.join(', '),
        'videoTrailer': effectiveTrailerUrl,
        'videoMovies': effectivePlayUrl ?? movieUrl,
        'dis': description,
        'logoImage': logoImage,
        'live': false,
        'imdbRating': imdbRating,
        'ageRating': ageLimit,
        'movieId': effectiveMovieId,
        'webSeriesId': effectiveWebSeriesId,
        'isSingleMovie': isSingleMovie,
        'isWebSeries': isWebSeries,
      };

  BannerMovie copyWith({
    String? id,
    String? title,
    String? description,
    String? mobileImage,
    String? logoImage,
    String? movieUrl,
    String? trailerUrl,
    List<String>? genres,
    double? imdbRating,
    String? ageLimit,
    bool? publishStatus,
    bool? isActive,
    List<BannerCastMember>? cast,
    String? categoryType,
    String? bannerType,
    String? visibleOn,
    String? categoryId,
    String? categoryName,
    int? displayOrder,
    String? movieId,
     String? language,
    MovieIdDetails? movieDetails,
    String? webSeriesId,
    WebSeriesModel? webSeriesDetails,
    String? type, 
  }) {
    return BannerMovie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mobileImage: mobileImage ?? this.mobileImage,
      logoImage: logoImage ?? this.logoImage,
      movieUrl: movieUrl ?? this.movieUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      genres: genres ?? this.genres,
      language: language ?? this.language,
      imdbRating: imdbRating ?? this.imdbRating,
      ageLimit: ageLimit ?? this.ageLimit,
      publishStatus: publishStatus ?? this.publishStatus,
      isActive: isActive ?? this.isActive,
      cast: cast ?? this.cast,
      categoryType: categoryType ?? this.categoryType,
      bannerType: bannerType ?? this.bannerType,
      visibleOn: visibleOn ?? this.visibleOn,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      displayOrder: displayOrder ?? this.displayOrder,
      movieId: movieId ?? this.movieId,
      movieDetails: movieDetails ?? this.movieDetails,
      webSeriesId: webSeriesId ?? this.webSeriesId,
      webSeriesDetails: webSeriesDetails ?? this.webSeriesDetails,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'BannerMovie(id: $id, title: "$title", type: $type, categoryType: $categoryType, movieId: $movieId, webSeriesId: $webSeriesId)';
}

class BannerMovieListResponse {
  final bool success;
  final List<BannerMovie> data;

  const BannerMovieListResponse({
    required this.success,
    required this.data,
  });

  factory BannerMovieListResponse.fromJson(Map<String, dynamic> json) {
    return BannerMovieListResponse(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BannerMovie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.map((e) => e.toJson()).toList(),
      };
}