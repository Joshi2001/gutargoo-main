class FavoriteItem {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String videoTrailer;
  final String description;
  final String logoImage;
  final String videoMovies;
  final double imdbRating;
  final String ageRating;
  final String directorInfo;
  final String castInfo;
  final String tagline;
  final String fullStoryline;
  final List<String> genres;
  final List<String> tags;
  final String language;
  final int duration;
  final int releaseYear;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.videoTrailer,
    this.description = '',
    this.logoImage = '',
    this.videoMovies = '',
    this.imdbRating = 0.0,
    this.ageRating = 'U/A',
    this.directorInfo = '',
    this.castInfo = '',
    this.tagline = '',
    this.fullStoryline = '',
    this.genres = const [],
    this.tags = const [],
    this.language = '',
    this.duration = 0,
    this.releaseYear = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'videoTrailer': videoTrailer,
      'description': description,
      'logoImage': logoImage,
      'videoMovies': videoMovies,
      'imdbRating': imdbRating,
      'ageRating': ageRating,
      'directorInfo': directorInfo,
      'castInfo': castInfo,
      'tagline': tagline,
      'fullStoryline': fullStoryline,
      'genres': genres,
      'tags': tags,
      'language': language,
      'duration': duration,
      'releaseYear': releaseYear,
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
  return FavoriteItem(
    id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    subtitle: json['subtitle']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
    videoTrailer: json['videoTrailer']?.toString() ?? '',

    description: json['description']?.toString() ?? '',
    logoImage: json['logoImage']?.toString() ?? '',
    videoMovies: json['videoMovies']?.toString() ?? '', 

    imdbRating: (json['imdbRating'] ?? 0.0) is int
        ? (json['imdbRating'] ?? 0).toDouble()
        : (json['imdbRating'] ?? 0.0).toDouble(),

    ageRating: json['ageRating']?.toString() ?? 'U/A',
    directorInfo: json['directorInfo']?.toString() ?? '',
    castInfo: json['castInfo']?.toString() ?? '',
    tagline: json['tagline']?.toString() ?? '',
    fullStoryline: json['fullStoryline']?.toString() ?? '',

    genres: json['genres'] != null
        ? List<String>.from(
            (json['genres'] as List).map((e) => e?.toString() ?? ''))
        : [],
    tags: json['tags'] != null
        ? List<String>.from(
            (json['tags'] as List).map((e) => e?.toString() ?? ''))
        : [],

    language: json['language']?.toString() ?? '',
    duration: (json['duration'] ?? 0) is String
        ? int.tryParse(json['duration']) ?? 0
        : (json['duration'] ?? 0),
    releaseYear: (json['releaseYear'] ?? 0) is String
        ? int.tryParse(json['releaseYear']) ?? 0
        : (json['releaseYear'] ?? 0),
  );
}
}