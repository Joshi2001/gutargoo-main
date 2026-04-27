class PotliBannerModel {
  final String id;
  final String title;
  final String mobileImage;
  final String logoImage;
  final String trailerUrl;
  final String movieUrl;
  final String description;
  final List<String> genres;
  final bool publishStatus;
  final bool isSingleMovie;
  final String? effectiveMovieId;

  PotliBannerModel({
    required this.id,
    required this.title,
    required this.mobileImage,
    required this.logoImage,
    required this.trailerUrl,
    required this.movieUrl,
    required this.description,
    required this.genres,
    required this.publishStatus,
    required this.isSingleMovie,
    this.effectiveMovieId,
  });

  factory PotliBannerModel.fromJson(Map<String, dynamic> json) {
    final genreList = (json['genres'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return PotliBannerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      mobileImage: json['mobileImage']?.toString() ??
          json['mobile_image']?.toString() ??
          '',
      logoImage: json['logoImage']?.toString() ??
          json['logo_image']?.toString() ??
          '',
      trailerUrl: json['trailerUrl']?.toString() ??
          json['trailer_url']?.toString() ??
          '',
      movieUrl: json['movieUrl']?.toString() ??
          json['movie_url']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
      genres: genreList,
      publishStatus: json['publishStatus'] == true ||
          json['publish_status'] == true,
      isSingleMovie: json['isSingleMovie'] == true ||
          json['is_single_movie'] == true,
      effectiveMovieId: json['movieId']?.toString() ??
          json['movie_id']?.toString(),
    );
  }

  PotliBannerModel copyWith({
    String? movieUrl,
    String? trailerUrl,
    String? description,
    String? logoImage,
    String? mobileImage,
  }) {
    return PotliBannerModel(
      id: id,
      title: title,
      mobileImage: mobileImage ?? this.mobileImage,
      logoImage: logoImage ?? this.logoImage,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      movieUrl: movieUrl ?? this.movieUrl,
      description: description ?? this.description,
      genres: genres,
      publishStatus: publishStatus,
      isSingleMovie: isSingleMovie,
      effectiveMovieId: effectiveMovieId,
    );
  }
}