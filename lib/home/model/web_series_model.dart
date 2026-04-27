
import 'package:flutter/material.dart';

class SkipIntro {
  final int start;
  final int end;

  const SkipIntro({this.start = 0, this.end = 0});

  factory SkipIntro.fromJson(Map<String, dynamic> json) => SkipIntro(
        start: (json['start'] as num?)?.toInt() ?? 0,
        end: (json['end'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'start': start, 'end': end};
}

class EpisodeVideoFile {
  final String url;
  final String thumbnailUrl;
  final int duration;
  final int status;

  const EpisodeVideoFile({
    this.url = '',
    this.thumbnailUrl = '',
    this.duration = 0,
    this.status = 0,
  });

  factory EpisodeVideoFile.fromJson(Map<String, dynamic> json) =>
      EpisodeVideoFile(
        url: json['url']?.toString() ?? '',
        thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
        duration: (json['duration'] as num?)?.toInt() ?? 0,
        status: (json['status'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'thumbnailUrl': thumbnailUrl,
        'duration': duration,
        'status': status,
      };
}

class Episode {
  final String id;
  final String title;
  final String description;
  final int episodeNumber;
  final String releaseDate;
  
  final bool isPublished;
  final EpisodeVideoFile videoFile;
  final SkipIntro skipIntro;
   String get playUrl => videoFile.url;
  bool get hasValidVideoUrl => videoFile.url.isNotEmpty;
  bool get hasSkipIntro => skipIntro.end > skipIntro.start;

  const Episode({
    this.id = '',
    this.title = '',
    this.description = '',
    this.episodeNumber = 1,
    this.releaseDate = '',
    this.isPublished = true,
    this.videoFile = const EpisodeVideoFile(),
    this.skipIntro = const SkipIntro(),
    
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        id: json['_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 1,
        releaseDate: json['releaseDate']?.toString() ?? '',
        isPublished: json['isPublished'] as bool? ?? true,
        videoFile: json['videoFile'] != null
            ? EpisodeVideoFile.fromJson(
                json['videoFile'] as Map<String, dynamic>)
            : const EpisodeVideoFile(),
        skipIntro: json['skipIntro'] != null
            ? SkipIntro.fromJson(json['skipIntro'] as Map<String, dynamic>)
            : const SkipIntro(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'episodeNumber': episodeNumber,
        'releaseDate': releaseDate,
        'isPublished': isPublished,
        'videoFile': videoFile.toJson(),
        'skipIntro': skipIntro.toJson(),
      };

}

class Season {
  final String id;
  final int seasonNumber;
  final String title;
  final String releaseDate;
  final List<Episode> episodes;

  const Season({
    this.id = '',
    this.seasonNumber = 1,
    this.title = '',
    this.releaseDate = '',
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        id: json['_id']?.toString() ?? '',
        seasonNumber: (json['seasonNumber'] as num?)?.toInt() ?? 1,
        title: json['title']?.toString() ?? '',
        releaseDate: json['releaseDate']?.toString() ?? '',
        episodes: (json['episodes'] as List? ?? [])
            .map((e) {
              try {
                return Episode.fromJson(e as Map<String, dynamic>);
              } catch (_) {
                return const Episode();
              }
            })
            .where((e) => e.isPublished)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'seasonNumber': seasonNumber,
        'title': title,
        'releaseDate': releaseDate,
        'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  List<Episode> get publishedEpisodes =>
      episodes.where((e) => e.isPublished).toList();
}

class WebSeriesModel {
  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final String lang;
  final String releaseDate;
  final bool isPublished;
  final String thumbnail;
  final String horizontalBanner;
  final String verticalPoster;
  final List<Season> seasons;
  final String createdAt;
  final String updatedAt;
  final String status;
  final int totalSeasons;
  final int totalEpisodes;
  final String contentType;
  final String trailerUrl;
  final String trailerThumbnailUrl;

  const WebSeriesModel({
    this.id = '',
    this.title = '',
    this.description = '',
    this.genres = const [],
    this.lang = '',
    this.releaseDate = '',
    this.isPublished = true,
    this.thumbnail = '',
    this.horizontalBanner = '',
    this.verticalPoster = '',
    this.seasons = const [],
    this.createdAt = '',
    this.updatedAt = '',
    this.status = '',
    this.totalSeasons = 0,
    this.totalEpisodes = 0,
    this.contentType = 'webseries',
    this.trailerUrl = '',           
    this.trailerThumbnailUrl = '',  
  });
factory WebSeriesModel.fromJson(Map<String, dynamic> json,
    {String contentType = 'webseries'}) {
  
  // ✅ FIXED: Better genre parsing that handles different formats
  List<String> _parseGenres(dynamic raw) {
    if (raw == null) return [];
    
    // If it's already a List<String>
    if (raw is List<String>) return raw;
    
    // If it's a List<dynamic>
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    
    // If it's a comma-separated string
    if (raw is String && raw.contains(',')) {
      return raw.split(',').map((e) => e.trim()).toList();
    }
    
    // If it's a single string
    if (raw is String && raw.isNotEmpty) {
      return [raw];
    }
    
    return [];
  }

  // Extract trailer data
  String trailerUrl = '';
  String trailerThumbnailUrl = '';
  if (json['trailer'] != null) {
    if (json['trailer'] is Map<String, dynamic>) {
      trailerUrl = json['trailer']['url']?.toString() ?? '';
      trailerThumbnailUrl = json['trailer']['thumbnailUrl']?.toString() ?? '';
    } else if (json['trailer'] is String) {
      trailerUrl = json['trailer'].toString();
    }
  }

  // ✅ Also check for genres in different possible field names
  List<String> genres = _parseGenres(json['genres']);
  if (genres.isEmpty && json['genre'] != null) {
    genres = _parseGenres(json['genre']);
  }
  if (genres.isEmpty && json['category'] != null) {
    genres = _parseGenres(json['category']);
  }

  // Debug print to see what we're getting
  debugPrint('📺 Parsing WebSeries: ${json['title']}');
  debugPrint('   Raw genres field: ${json['genres']}');
  debugPrint('   Parsed genres: $genres');

  return WebSeriesModel(
    id: json['_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    genres: genres,  
    lang: json['lang']?.toString() ?? '',
    releaseDate: json['releaseDate']?.toString() ?? '',
    isPublished: json['isPublished'] as bool? ?? true,
    thumbnail: json['thumbnail']?.toString() ?? '',
    horizontalBanner: json['horizontalBanner']?.toString() ?? '',
    verticalPoster: json['verticalPoster']?.toString() ?? '',
    seasons: (json['seasons'] as List? ?? [])
        .map((s) {
          try {
            return Season.fromJson(s as Map<String, dynamic>);
          } catch (_) {
            debugPrint('⚠️ Failed to parse season: $_');
            return const Season();
          }
        })
        .toList(),
    createdAt: json['createdAt']?.toString() ?? '',
    updatedAt: json['updatedAt']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    totalSeasons: (json['total_seasons'] as num?)?.toInt() ?? 0,
    totalEpisodes: (json['total_episodes'] as num?)?.toInt() ?? 0,
    contentType: contentType,
    trailerUrl: trailerUrl,
    trailerThumbnailUrl: trailerThumbnailUrl,
  );
}
  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'genres': genres,
        'lang': lang,
        'releaseDate': releaseDate,
        'isPublished': isPublished,
        'thumbnail': thumbnail,
        'horizontalBanner': horizontalBanner,
        'verticalPoster': verticalPoster,
        'seasons': seasons.map((s) => s.toJson()).toList(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'status': status,
        'total_seasons': totalSeasons,
        'total_episodes': totalEpisodes,
        'contentType': contentType,
      };

  String get genresString => genres.join(', ');

  /// First episode of Season 1
  Episode? get firstEpisode {
    if (seasons.isEmpty) return null;
    final s1 = seasons.firstWhere(
      (s) => s.seasonNumber == 1,
      orElse: () => seasons.first,
    );
    return s1.episodes.isNotEmpty ? s1.episodes.first : null;
  }

  String get posterUrl =>
      verticalPoster.isNotEmpty ? verticalPoster : thumbnail;
  String get bannerUrl =>
      horizontalBanner.isNotEmpty ? horizontalBanner : thumbnail;

  bool get isTvShow => contentType == 'tvshow';
  bool get isWebSeries => contentType == 'webseries';
}