import 'package:gutrgoopro/home/model/movie_model.dart';

class ContinueWatchingResponse {
  final bool success;
  final List<ContinueWatchingItem> data;

  ContinueWatchingResponse({
    required this.success,
    required this.data,
  });

  factory ContinueWatchingResponse.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => ContinueWatchingItem.fromJson(item))
              .toList()
          : [],
    );
  }
}

class ContinueWatchingItem {
  final String id;
  final MovieModel movie;
  final int watchedTime;
  final int duration;

  ContinueWatchingItem({
    required this.id,
    required this.movie,
    required this.watchedTime,
    required this.duration,
  });

  double get progress => duration > 0 ? watchedTime / duration : 0.0;
  String get formattedProgress => "${(progress * 100).toInt()}%";

  // In continue_watching_model.dart

// In continue_watching_model.dart

factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) {
  final data = json['data'];

  if (data == null || data['movie'] == null) {
    throw Exception("Movie data is null");
  }

  return ContinueWatchingItem(
    id: data['_id'],
    movie: MovieModel.fromJson(data['movie']),
    watchedTime: data['watchedTime'] ?? 0,
    duration: data['duration'] ?? 0,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie': movie.toJson(),
      'watchedTime': watchedTime,
      'duration': duration,
    };
  }
}

class ContinueWatchingMovie {
  final String id;
  final String movieTitle;
  final String description;
  final List<String> genres;
  final int duration;
  final String ageRating;
  final double imdbRating;
  final int releaseYear;
  final ContinueWatchingMovieFile movieFile;
  final ContinueWatchingTrailer trailer;
  final ContinueWatchingMediaAsset horizontalBanner;
  final ContinueWatchingMediaAsset verticalPoster;
  final ContinueWatchingMediaAsset logo;
  final String customVideoUrl;
  final String customTrailerUrl;
  final bool publishStatus;
  final bool subscriptionRequired;
  final String contentVendor;
  final int viewCount;

  ContinueWatchingMovie({
    required this.id,
    required this.movieTitle,
    required this.description,
    required this.genres,
    required this.duration,
    required this.ageRating,
    required this.imdbRating,
    required this.releaseYear,
    required this.movieFile,
    required this.trailer,
    required this.horizontalBanner,
    required this.verticalPoster,
    required this.logo,
    required this.customVideoUrl,
    required this.customTrailerUrl,
    required this.publishStatus,
    required this.subscriptionRequired,
    required this.contentVendor,
    required this.viewCount,
  });

  factory ContinueWatchingMovie.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingMovie(
      id: json['_id'] ?? '',
      movieTitle: json['movieTitle'] ?? '',
      description: json['description'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      duration: json['duration'] ?? 0,
      ageRating: json['ageRating'] ?? '',
      imdbRating: (json['imdbRating'] ?? 0).toDouble(),
      releaseYear: json['releaseYear'] ?? 0,
      movieFile: ContinueWatchingMovieFile.fromJson(json['movieFile'] ?? {}),
      trailer: ContinueWatchingTrailer.fromJson(json['trailer'] ?? {}),
      horizontalBanner: ContinueWatchingMediaAsset.fromJson(json['horizontalBanner'] ?? {}),
      verticalPoster: ContinueWatchingMediaAsset.fromJson(json['verticalPoster'] ?? {}),
      logo: ContinueWatchingMediaAsset.fromJson(json['logo'] ?? {}),
      customVideoUrl: json['customVideoUrl'] ?? '',
      customTrailerUrl: json['customTrailerUrl'] ?? '',
      publishStatus: json['publishStatus'] ?? false,
      subscriptionRequired: json['subscriptionRequired'] ?? false,
      contentVendor: json['contentVendor'] ?? '',
      viewCount: json['viewCount'] ?? 0,
    );
  }

  String get playUrl {
    if (customVideoUrl.isNotEmpty) return customVideoUrl;
    if (movieFile.hlsUrl.isNotEmpty) return movieFile.hlsUrl;
    if (movieFile.mp4Url.isNotEmpty) return movieFile.mp4Url;
    if (movieFile.directPlayUrl.isNotEmpty) return movieFile.directPlayUrl;
    return '';
  }

  String get trailerUrl {
    if (customTrailerUrl.isNotEmpty) return customTrailerUrl;
    if (trailer.hlsUrl.isNotEmpty) return trailer.hlsUrl;
    if (trailer.mp4Url.isNotEmpty) return trailer.mp4Url;
    return '';
  }

  String get verticalPosterUrl => verticalPoster.url;
  String get horizontalBannerUrl => horizontalBanner.url;
  String get logoUrl => logo.url;
  String get genresString => genres.join(', ');
}

class ContinueWatchingMovieFile {
  final String directPlayUrl;
  final int status;
  final String url;
  final String videoId;
  final String hlsUrl;
  final String mp4Url;
  final String thumbnailUrl;
  final int duration;
  final int size;

  ContinueWatchingMovieFile({
    required this.directPlayUrl,
    required this.status,
    required this.url,
    required this.videoId,
    required this.hlsUrl,
    required this.mp4Url,
    required this.thumbnailUrl,
    required this.duration,
    required this.size,
  });

  factory ContinueWatchingMovieFile.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingMovieFile(
      directPlayUrl: json['directPlayUrl'] ?? '',
      status: json['status'] ?? 0,
      url: json['url'] ?? '',
      videoId: json['videoId'] ?? '',
      hlsUrl: json['hlsUrl'] ?? '',
      mp4Url: json['mp4Url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      duration: json['duration'] ?? 0,
      size: json['size'] ?? 0,
    );
  }
}

class ContinueWatchingTrailer {
  final String url;
  final String videoId;
  final String hlsUrl;
  final String mp4Url;
  final String directPlayUrl;
  final String thumbnailUrl;
  final int duration;
  final int size;
  final int status;

  ContinueWatchingTrailer({
    required this.url,
    required this.videoId,
    required this.hlsUrl,
    required this.mp4Url,
    required this.directPlayUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.size,
    required this.status,
  });

  factory ContinueWatchingTrailer.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingTrailer(
      url: json['url'] ?? '',
      videoId: json['videoId'] ?? '',
      hlsUrl: json['hlsUrl'] ?? '',
      mp4Url: json['mp4Url'] ?? '',
      directPlayUrl: json['directPlayUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      duration: json['duration'] ?? 0,
      size: json['size'] ?? 0,
      status: json['status'] ?? 0,
    );
  }
}

class ContinueWatchingMediaAsset {
  final String url;
  final String publicId;

  ContinueWatchingMediaAsset({
    required this.url,
    required this.publicId,
  });

  factory ContinueWatchingMediaAsset.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingMediaAsset(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
    );
  }
}