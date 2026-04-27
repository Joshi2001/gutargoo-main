class PotliMovieModel {
  final String id;
  final String movieTitle;
  final String verticalPosterUrl;
  final String horizontalBannerUrl;
  final String logoUrl;
  final String playUrl;
  final String trailerUrl;
  final String genresString;
  final List<String> genres;
  final String description;

  // ── Fields required by VideoModel ─────────────────────────────────────────
  final int totalEpisodes;
  final int likesCount;
  final int savesCount;
  final String? vastTagUrl;
  final List<PotliEpisodeModel> episodes;

  const PotliMovieModel({
    required this.id,
    required this.movieTitle,
    required this.verticalPosterUrl,
    required this.horizontalBannerUrl,
    required this.logoUrl,
    required this.playUrl,
    this.trailerUrl = '',
    required this.genresString,
    required this.genres,
    this.description = '',
    this.totalEpisodes = 1,
    this.likesCount = 0,
    this.savesCount = 0,
    this.vastTagUrl,
    this.episodes = const [],
  });

  factory PotliMovieModel.fromJson(Map<String, dynamic> json) {
    final genreList = (json['genres'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Parse episodes list if present (for series)
    final episodeList = (json['episodes'] as List<dynamic>?)
            ?.map((e) => PotliEpisodeModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PotliMovieModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      movieTitle: json['title']?.toString() ?? '',
      verticalPosterUrl: json['verticalPoster']?.toString() ??
          json['vertical_poster']?.toString() ??
          '',
      horizontalBannerUrl: json['horizontalBanner']?.toString() ??
          json['horizontal_banner']?.toString() ??
          '',
      logoUrl: json['logoUrl']?.toString() ?? json['logo']?.toString() ?? '',
      playUrl:
          json['playUrl']?.toString() ?? json['play_url']?.toString() ?? '',
      trailerUrl: json['trailerUrl']?.toString() ??
          json['trailer_url']?.toString() ??
          '',
      genresString: genreList.join(', '),
      genres: genreList,
      description:
          json['description']?.toString() ?? json['dis']?.toString() ?? '',
      totalEpisodes:
          int.tryParse(json['totalEpisodes']?.toString() ?? '') ??
          int.tryParse(json['total_episodes']?.toString() ?? '') ??
          (episodeList.isNotEmpty ? episodeList.length : 1),
      likesCount:
          int.tryParse(json['likes']?.toString() ?? '') ??
          int.tryParse(json['likesCount']?.toString() ?? '') ??
          0,
      savesCount:
          int.tryParse(json['saves']?.toString() ?? '') ??
          int.tryParse(json['savesCount']?.toString() ?? '') ??
          0,
      vastTagUrl: json['vastTagUrl']?.toString() ??
          json['vast_tag_url']?.toString(),
      episodes: episodeList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': movieTitle,
        'verticalPoster': verticalPosterUrl,
        'horizontalBanner': horizontalBannerUrl,
        'logoUrl': logoUrl,
        'playUrl': playUrl,
        'trailerUrl': trailerUrl,
        'genres': genres,
        'description': description,
        'totalEpisodes': totalEpisodes,
        'likes': likesCount,
        'saves': savesCount,
        'vastTagUrl': vastTagUrl,
        'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  PotliMovieModel copyWith({
    String? id,
    String? movieTitle,
    String? verticalPosterUrl,
    String? horizontalBannerUrl,
    String? logoUrl,
    String? playUrl,
    String? trailerUrl,
    String? genresString,
    List<String>? genres,
    String? description,
    int? totalEpisodes,
    int? likesCount,
    int? savesCount,
    String? vastTagUrl,
    List<PotliEpisodeModel>? episodes,
  }) {
    return PotliMovieModel(
      id: id ?? this.id,
      movieTitle: movieTitle ?? this.movieTitle,
      verticalPosterUrl: verticalPosterUrl ?? this.verticalPosterUrl,
      horizontalBannerUrl: horizontalBannerUrl ?? this.horizontalBannerUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      playUrl: playUrl ?? this.playUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      genresString: genresString ?? this.genresString,
      genres: genres ?? this.genres,
      description: description ?? this.description,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      vastTagUrl: vastTagUrl ?? this.vastTagUrl,
      episodes: episodes ?? this.episodes,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Episode model — used when PotliMovieModel is a series
// ─────────────────────────────────────────────────────────────────────────────

class PotliEpisodeModel {
  final int number;
  final String title;
  final String url;
  final String? thumbnail;
  final String? duration;

  const PotliEpisodeModel({
    required this.number,
    required this.title,
    required this.url,
    this.thumbnail,
    this.duration,
  });

  factory PotliEpisodeModel.fromJson(Map<String, dynamic> json) {
    return PotliEpisodeModel(
      number: int.tryParse(json['number']?.toString() ??
              json['episodeNumber']?.toString() ??
              '1') ??
          1,
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ??
          json['playUrl']?.toString() ??
          json['play_url']?.toString() ??
          '',
      thumbnail: json['thumbnail']?.toString() ??
          json['thumbnailUrl']?.toString(),
      duration: json['duration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'duration': duration,
      };
}