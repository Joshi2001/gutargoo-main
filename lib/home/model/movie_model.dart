import 'dart:convert';

import 'package:gutrgoopro/home/model/banner_model.dart';
class VideoFile {
  final String url;
  final String videoId;
  final String hlsUrl;
  final String mp4Url;
  final String directPlayUrl;
  final String thumbnailUrl;
  final int duration;
  final int size;
  final int status;

  const VideoFile({
    this.url = '',
    this.videoId = '',
    this.hlsUrl = '',
    this.mp4Url = '',
    this.directPlayUrl = '',
    this.thumbnailUrl = '',
    this.duration = 0,
    this.size = 0,
    this.status = 0,
  });

  factory VideoFile.fromJson(Map<String, dynamic> json) => VideoFile(
    url: json['url']?.toString() ?? '',
    videoId: json['videoId']?.toString() ?? '',
    hlsUrl: json['hlsUrl']?.toString() ?? '',
    mp4Url: json['mp4Url']?.toString() ?? '',
    directPlayUrl: json['directPlayUrl']?.toString() ?? '',
    thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
    duration: (json['duration'] as num?)?.toInt() ?? 0,
    size: (json['size'] as num?)?.toInt() ?? 0,
    status: (json['status'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'url': url,
    'videoId': videoId,
    'hlsUrl': hlsUrl,
    'mp4Url': mp4Url,
    'directPlayUrl': directPlayUrl,
    'thumbnailUrl': thumbnailUrl,
    'duration': duration,
    'size': size,
    'status': status,
  };
}

class MediaAsset {
  final String url;
  final String publicId;

  const MediaAsset({this.url = '', this.publicId = ''});

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
    url: json['url']?.toString() ?? '',
    publicId: json['publicId']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'url': url, 'publicId': publicId};
}

class CrewMember {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final String publicId;

  const CrewMember({
    this.id = '',
    this.name = '',
    this.role = '',
    this.imageUrl = '',
    this.publicId = '',
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) => CrewMember(
    id: json['_id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    role: json['role']?.toString() ?? '',
    imageUrl: json['imageUrl']?.toString() ?? '',
    publicId: json['publicId']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'role': role,
    'imageUrl': imageUrl,
    'publicId': publicId,
  };
}

class CastMember {
  final String id;
  final String name;
  final String character;
  final String imageUrl;
  final String publicId;

  const CastMember({
    this.id = '',
    this.name = '',
    this.character = '',
    this.imageUrl = '',
    this.publicId = '',
  });

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
    id: json['_id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    character: json['character']?.toString() ?? '',
    imageUrl: json['imageUrl']?.toString() ?? '',
    publicId: json['publicId']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'character': character,
    'imageUrl': imageUrl,
    'publicId': publicId,
  };
}

class MovieModel {
  final String id;
  final String categoryId;
  final String movieTitle;
  final String tagline;
  final String description;
  final String fullStoryline;
  final List<String> genres;
  final List<String> tags;
  final String language;
  final String selectedLanguage;
  final int duration;
  final String ageRating;
  final double imdbRating;
  final int releaseYear;
  final List<String> productionStudio;
  final List<String> countryOfOrigin;
  final String budget;
  final String awardsAndNominations;
  final String videoQuality;
  final String audioFormat;
  final List<Map<String, dynamic>> audioTracks;
  final List<Map<String, dynamic>> subtitles;
  final VideoFile? movieFile;
  final VideoFile? trailer;
  final MediaAsset horizontalBanner;
  final MediaAsset verticalPoster;
  final MediaAsset logo;
  final String customVideoUrl;
  final String customTrailerUrl;
  final List<CrewMember> director;
  final List<CrewMember> producer;
  final List<CrewMember> writer;
  final List<CrewMember> musicDirector;
  final List<CrewMember> cinematographer;
  final List<CrewMember> editor;
  final List<CastMember> castMembers;
  final bool publishStatus;
  final bool subscriptionRequired;
  final bool enableAds;
  final bool allowDownloads;
  final bool featuredMovie;
  final String contentVendor;
  final String vendorId;
  final String? publishDate;
  final String? expiryDate;
  final int viewCount;
  final String seoTitle;
  final String seoDescription;
  final List<String> seoKeywords;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  final bool isPartial;
  final MediaAsset bigVertical;

  const MovieModel({
    this.id = '',
    this.movieTitle = '',
    this.tagline = '',
    this.description = '',
    this.fullStoryline = '',
    this.genres = const [],
    this.tags = const [],
    this.language = '',
    this.selectedLanguage = '',
    this.duration = 0,
    this.ageRating = '',
    this.imdbRating = 0.0,
    this.releaseYear = 0,
    this.productionStudio = const [],
    this.countryOfOrigin = const [],
    this.budget = '',
    this.awardsAndNominations = '',
    this.videoQuality = '',
    this.audioFormat = '',
    this.audioTracks = const [],
    this.subtitles = const [],
    this.movieFile,
    this.trailer,
    this.horizontalBanner = const MediaAsset(),
    this.verticalPoster = const MediaAsset(),
    this.logo = const MediaAsset(),
    this.customVideoUrl = '',
    this.customTrailerUrl = '',
    this.director = const [],
    this.producer = const [],
    this.writer = const [],
    this.musicDirector = const [],
    this.cinematographer = const [],
    this.editor = const [],
    this.castMembers = const [],
    this.publishStatus = true,
    this.subscriptionRequired = false,
    this.enableAds = false,
    this.allowDownloads = false,
    this.featuredMovie = false,
    this.contentVendor = '',
    this.vendorId = '',
    this.publishDate,
    this.expiryDate,
    this.viewCount = 0,
    this.seoTitle = '',
    this.seoDescription = '',
    this.seoKeywords = const [],
    this.createdBy = '',
    this.createdAt = '',
    this.updatedAt = '',
    required this.categoryId,
    this.isPartial = false,
        this.bigVertical = const MediaAsset(), 
  });

  factory MovieModel.partial({
    required String id,
    required String verticalPosterUrl,
    required String horizontalBannerUrl,
  }) {
    return MovieModel(
      id: id,
      categoryId: '',
      horizontalBanner: MediaAsset(url: horizontalBannerUrl),
      verticalPoster: MediaAsset(url: verticalPosterUrl),
       bigVertical: const MediaAsset(),
      isPartial: true,
    );
  }
// In movie_model.dart - Add this method anywhere in MovieModel class

factory MovieModel.fromBanner(BannerMovie banner) {
  return MovieModel(
    id: banner.id,
    categoryId: banner.categoryId ?? '',
    movieTitle: banner.title,
    tagline: '',
    description: banner.description,
    fullStoryline: banner.description,
    genres: banner.genres,
    tags: [],
    language: '',
    selectedLanguage: '',
    duration: 0,
    ageRating: banner.ageLimit,
    imdbRating: banner.imdbRating,
    releaseYear: banner.movieDetails?.releaseYear ?? DateTime.now().year,
    productionStudio: [],
    countryOfOrigin: [],
    budget: '',
    awardsAndNominations: '',
    videoQuality: '',
    audioFormat: '',
    audioTracks: [],
    subtitles: [],
    movieFile: banner.movieUrl.isNotEmpty 
        ? VideoFile(hlsUrl: banner.movieUrl, mp4Url: banner.movieUrl)
        : null,
    trailer: banner.trailerUrl.isNotEmpty
        ? VideoFile(hlsUrl: banner.trailerUrl, mp4Url: banner.trailerUrl)
        : null,
    horizontalBanner: MediaAsset(url: banner.mobileImage),
    verticalPoster: MediaAsset(url: banner.posterImage),
    logo: MediaAsset(url: banner.logoImage),
    customVideoUrl: '',
    customTrailerUrl: '',
    director: [],
    producer: [],
    writer: [],
    musicDirector: [],
    cinematographer: [],
    editor: [],
    castMembers: banner.cast.map((c) => CastMember(
      name: c.name,
      character: c.character,
      imageUrl: c.imageUrl,
    )).toList(),
    publishStatus: banner.publishStatus,
    subscriptionRequired: false,
    enableAds: false,
    allowDownloads: true,
    featuredMovie: false,
    contentVendor: '',
    vendorId: '',
    publishDate: null,
    expiryDate: null,
    viewCount: 0,
    seoTitle: banner.title,
    seoDescription: banner.description,
    seoKeywords: banner.genres,
    createdBy: '',
    createdAt: '',
    updatedAt: '',
    isPartial: false,
  );
}
  factory MovieModel.fromJson(Map<String, dynamic> json) {
  List<String> _strings(String key) {
    final raw = json[key];
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }

  List<Map<String, dynamic>> _mapList(String key) {
    final raw = json[key];
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw.map((e) {
      if (e is Map) return Map<String, dynamic>.from(e);
      if (e is String) {
        try {
          final decoded = jsonDecode(e);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
      return <String, dynamic>{};
    }).toList();
  }

  // ✅ Nested object + flat URL fallback
  MediaAsset _assetWithFallback(String nestedKey, String flatKey) {
    final raw = json[nestedKey];
    if (raw is Map<String, dynamic>) {
      final url = raw['url']?.toString() ?? '';
      if (url.isNotEmpty) return MediaAsset.fromJson(raw);
    }
    final flatUrl = json[flatKey]?.toString() ?? '';
    return MediaAsset(url: flatUrl);
  }

  VideoFile? _video(String key) {
    final raw = json[key];
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return VideoFile.fromJson(raw);
    return null;
  }

  List<CrewMember> _crewByRole(String role) {
    final crewRaw = json['crew'] as List?;
    if (crewRaw == null || crewRaw.isEmpty) return [];
    String normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final target = normalize(role);
    return crewRaw
        .where((e) {
          if (e is! Map) return false;
          return normalize(Map<String, dynamic>.from(e)['role']?.toString() ?? '') == target;
        })
        .map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          return CrewMember(
            id: map['_id']?.toString() ?? '',
            name: map['name']?.toString() ?? '',
            role: map['role']?.toString() ?? '',
            imageUrl: map['imageUrl']?.toString() ?? '',
            publicId: map['publicId']?.toString() ?? '',
          );
        })
        .toList();
  }

  List<CastMember> _parseCast() {
    final castRaw = json['cast'] as List?;
    if (castRaw == null || castRaw.isEmpty) return [];
    return castRaw.map((e) {
      if (e is! Map) return const CastMember();
      final m = Map<String, dynamic>.from(e);
      return CastMember(
        id: m['_id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        character: m['character']?.toString() ?? '',
        imageUrl: m['imageUrl']?.toString() ?? '',
        publicId: m['publicId']?.toString() ?? '',
      );
    }).toList();
  }

  return MovieModel(
    categoryId: (json['categoryId'] ?? '').toString(),
    id: json['_id']?.toString() ?? '',
    movieTitle: json['movieTitle']?.toString() ?? '',
    tagline: json['tagline']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    fullStoryline: json['fullStoryline']?.toString() ?? '',
    genres: _strings('genres'),
    tags: _strings('tags'),
    // ✅ lang + language dono handle
    language: json['language']?.toString() ?? json['lang']?.toString() ?? '',
    selectedLanguage: json['selectedLanguage']?.toString() ?? '',
    duration: (json['duration'] as num?)?.toInt() ?? 0,
    ageRating: json['ageRating']?.toString() ?? '',
    imdbRating: (json['imdbRating'] as num?)?.toDouble() ?? 0.0,
    releaseYear: (json['releaseYear'] as num?)?.toInt() ?? 0,
    productionStudio: _strings('productionStudio'),
    countryOfOrigin: _strings('countryOfOrigin'),
    budget: json['budget']?.toString() ?? '',
    awardsAndNominations: json['awardsAndNominations']?.toString() ?? '',
    videoQuality: json['videoQuality']?.toString() ?? '',
    audioFormat: json['audioFormat']?.toString() ?? '',
    audioTracks: _mapList('audioTracks'),
    subtitles: _mapList('subtitles'),
    movieFile: _video('movieFile'),
    trailer: _video('trailer'),
    // ✅ Nested + flat URL fallback
    bigVertical: _assetWithFallback('bigVertical', 'bigVerticalUrl'),
    horizontalBanner: _assetWithFallback('horizontalBanner', 'horizontalBannerUrl'),
    verticalPoster: _assetWithFallback('verticalPoster', 'verticalPosterUrl'),
    logo: _assetWithFallback('logo', 'logoUrl'),
    customVideoUrl: json['customVideoUrl']?.toString() ?? '',
    customTrailerUrl: json['customTrailerUrl']?.toString() ?? '',
    director: _crewByRole('director'),
    producer: _crewByRole('producer'),
    writer: _crewByRole('writer'),
    musicDirector: _crewByRole('musicDirector'),
    cinematographer: _crewByRole('cinematographer'),
    editor: _crewByRole('editor'),
    castMembers: _parseCast(),
    publishStatus: json['publishStatus'] as bool? ?? true,
    subscriptionRequired: json['subscriptionRequired'] as bool? ?? false,
    enableAds: json['enableAds'] as bool? ?? false,
    allowDownloads: json['allowDownloads'] as bool? ?? false,
    featuredMovie: json['featuredMovie'] as bool? ?? false,
    contentVendor: json['contentVendor']?.toString() ?? '',
    vendorId: json['vendorId']?.toString() ?? '',
    publishDate: json['publishDate']?.toString(),
    expiryDate: json['expiryDate']?.toString(),
    viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    seoTitle: json['seoTitle']?.toString() ?? '',
    seoDescription: json['seoDescription']?.toString() ?? '',
    seoKeywords: _strings('seoKeywords'),
    createdBy: json['createdBy']?.toString() ?? '',
    createdAt: json['createdAt']?.toString() ?? '',
    updatedAt: json['updatedAt']?.toString() ?? '',
  );
}
  factory MovieModel.fromLegacyMap(Map<String, dynamic> item) {
    List<CrewMember> _crewByRole(String role) {
      final crewRaw = item['crew'] as List?;
      if (crewRaw == null || crewRaw.isEmpty) return [];

      String normalise(String s) => s.toLowerCase().trim();
      final targetNorm = normalise(role);

      final result = <CrewMember>[];
      for (final e in crewRaw) {
        if (e is! Map) continue;
        final map = Map<String, dynamic>.from(e);
        final apiRole = map['role']?.toString() ?? '';
        if (normalise(apiRole) == targetNorm) {
          result.add(
            CrewMember(
              id: map['_id']?.toString() ?? '',
              name: map['name']?.toString() ?? '',
              role: apiRole,
              imageUrl: map['imageUrl']?.toString() ?? '',
              publicId: map['publicId']?.toString() ?? '',
            ),
          );
        }
      }
      return result;
    }
    

    List<CastMember> _cast() {
      final castRaw = (item['cast'] ?? item['castMembers']) as List?;
      if (castRaw == null || castRaw.isEmpty) return [];
      return castRaw.map((e) {
        if (e is! Map) return const CastMember();
        final m = Map<String, dynamic>.from(e);
        return CastMember(
          id: m['_id']?.toString() ?? '',
          name: m['name']?.toString() ?? '',
          character: (m['character'] ?? m['role'])?.toString() ?? '',
          imageUrl: (m['imageUrl'] ?? m['image'])?.toString() ?? '',
          publicId: m['publicId']?.toString() ?? '',
        );
      }).toList();
    }

    return MovieModel(
      id: item['_id']?.toString() ?? item['id']?.toString() ?? '',
      movieTitle: item['movieTitle']?.toString() ?? item['title']?.toString() ?? '',
      description: item['description']?.toString() ?? item['dis']?.toString() ?? '',
      tagline: item['tagline']?.toString() ?? '',
      fullStoryline: item['fullStoryline']?.toString() ?? '',
      language: item['language']?.toString() ?? '',
      ageRating: item['ageRating']?.toString() ?? '',
      imdbRating: double.tryParse(item['imdbRating']?.toString() ?? '0') ?? 0.0,
      releaseYear: int.tryParse(item['releaseYear']?.toString() ?? '0') ?? 0,
      budget: item['budget']?.toString() ?? '',
      videoQuality: item['videoQuality']?.toString() ?? '',
      audioFormat: item['audioFormat']?.toString() ?? '',
      customVideoUrl: item['customVideoUrl']?.toString() ?? '',
      customTrailerUrl: item['customTrailerUrl']?.toString() ?? '',
      horizontalBanner: MediaAsset(
        url: item['horizontalBannerUrl']?.toString() ?? '',
      ),
      verticalPoster: MediaAsset(
        url: item['verticalPosterUrl']?.toString() ?? '',
      ),
      logo: MediaAsset(
        url: item['logoImage']?.toString() ?? item['logoUrl']?.toString() ?? '',
      ),
      movieFile: VideoFile(
        hlsUrl: item['videoMovies']?.toString() ?? '',
        mp4Url: item['mp4Url']?.toString() ?? '',
        thumbnailUrl: item['thumbnailUrl']?.toString() ?? '',
      ),
      trailer: VideoFile(
        hlsUrl: item['videoTrailer']?.toString() ?? '',
        mp4Url: item['trailerMp4Url']?.toString() ?? '',
        thumbnailUrl: item['trailerThumbnailUrl']?.toString() ?? '',
      ),
      director: _crewByRole('director'),
      producer: _crewByRole('producer'),
      writer: _crewByRole('writer'),
      musicDirector: _crewByRole('musicDirector'),
      cinematographer: _crewByRole('cinematographer'),
      editor: _crewByRole('editor'),
      castMembers: _cast(),
      subscriptionRequired: item['subscriptionRequired'] == true,
      allowDownloads: item['allowDownloads'] == true,
      publishStatus: item['publishStatus'] as bool? ?? true,
      enableAds: item['enableAds'] == true,
      featuredMovie: item['featuredMovie'] == true,
      contentVendor: item['contentVendor']?.toString() ?? '',
      viewCount: int.tryParse(item['viewCount']?.toString() ?? '0') ?? 0,
      categoryId: (item['categoryId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'movieTitle': movieTitle,
    'tagline': tagline,
    'description': description,
    'fullStoryline': fullStoryline,
    'genres': genres,
    'tags': tags,
    'language': language,
    'selectedLanguage': selectedLanguage,
    'duration': duration,
    'ageRating': ageRating,
    'imdbRating': imdbRating,
    'releaseYear': releaseYear,
    'productionStudio': productionStudio,
    'countryOfOrigin': countryOfOrigin,
    'budget': budget,
    'awardsAndNominations': awardsAndNominations,
    'videoQuality': videoQuality,
    'audioFormat': audioFormat,
    'audioTracks': audioTracks,
    'subtitles': subtitles,
    'movieFile': movieFile?.toJson(),
    'trailer': trailer?.toJson(),
    'horizontalBanner': horizontalBanner.toJson(),
    'verticalPoster': verticalPoster.toJson(),
    'logo': logo.toJson(),
    'customVideoUrl': customVideoUrl,
    'customTrailerUrl': customTrailerUrl,
    'crew': [
      ...director.map((e) => e.toJson()),
      ...producer.map((e) => e.toJson()),
      ...writer.map((e) => e.toJson()),
      ...musicDirector.map((e) => e.toJson()),
      ...cinematographer.map((e) => e.toJson()),
      ...editor.map((e) => e.toJson()),
    ],
    'cast': castMembers.map((e) => e.toJson()).toList(),
    'castMembers': castMembers.map((e) => e.toJson()).toList(),
    'publishStatus': publishStatus,
    'subscriptionRequired': subscriptionRequired,
    'enableAds': enableAds,
    'allowDownloads': allowDownloads,
    'featuredMovie': featuredMovie,
    'contentVendor': contentVendor,
    'vendorId': vendorId,
    'publishDate': publishDate,
    'expiryDate': expiryDate,
    'viewCount': viewCount,
    'seoTitle': seoTitle,
    'seoDescription': seoDescription,
    'seoKeywords': seoKeywords,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'bigVertical': bigVertical.toJson()
  };

  String get playUrl => customVideoUrl.isNotEmpty
      ? customVideoUrl
      : movieFile?.hlsUrl.isNotEmpty == true
      ? movieFile!.hlsUrl
      : movieFile?.mp4Url ?? '';

  String get trailerUrl => customTrailerUrl.isNotEmpty
      ? customTrailerUrl
      : trailer?.hlsUrl.isNotEmpty == true
      ? trailer!.hlsUrl
      : trailer?.mp4Url ?? '';

  String get horizontalBannerUrl => horizontalBanner.url;
  String get verticalPosterUrl => verticalPoster.url;
  String get logoUrl => logo.url;
  String get genresString => genres.join(', ');
  String get directorString => director.map((e) => e.name).join(', ');
  String get castString =>
      castMembers.map((e) => '${e.name} (${e.character})').join(', ');
String get bigVerticalUrl => bigVertical.url; 
  List<Map<String, String>> get allCastAndCrew => [
    ...castMembers.map(
      (e) => {
        'name': e.name,
        'role': 'Actor',
        'character': e.character,
        'image': e.imageUrl,
      },
    ),
    ...director.map(
      (e) => {
        'name': e.name,
        'role': 'Director',
        'character': '',
        'image': e.imageUrl,
      },
    ),
    ...producer.map(
      (e) => {
        'name': e.name,
        'role': 'Producer',
        'character': '',
        'image': e.imageUrl,
      },
    ),
    ...writer.map(
      (e) => {
        'name': e.name,
        'role': 'Writer',
        'character': '',
        'image': e.imageUrl,
      },
    ),
    ...musicDirector.map(
      (e) => {
        'name': e.name,
        'role': 'Music Director',
        'character': '',
        'image': e.imageUrl,
      },
    ),
    ...cinematographer.map(
      (e) => {
        'name': e.name,
        'role': 'Cinematographer',
        'character': '',
        'image': e.imageUrl,
      },
    ),
    ...editor.map(
      (e) => {
        'name': e.name,
        'role': 'Editor',
        'character': '',
        'image': e.imageUrl,
      },
    ),
  ];

  Map<String, dynamic> toLegacyMap() => {
    'id': id,
    '_id': id,
    'movieTitle': movieTitle,
    'title': movieTitle,
    'tagline': tagline,
    'description': description,
    'dis': description,
    'fullStoryline': fullStoryline,
    'genres': genres,
    'subtitle': genresString,
    'tags': tags,
    'language': language,
    'duration': duration,
    'ageRating': ageRating,
    'imdbRating': imdbRating,
    'releaseYear': releaseYear,
    'budget': budget,
    'awardsAndNominations': awardsAndNominations,
    'videoQuality': videoQuality,
    'audioFormat': audioFormat,
    'audioTracks': audioTracks,
    'subtitles': subtitles,
    'hlsUrl': movieFile?.hlsUrl ?? '',
    'mp4Url': movieFile?.mp4Url ?? '',
    'thumbnailUrl': movieFile?.thumbnailUrl ?? '',
    'directPlayUrl': movieFile?.directPlayUrl ?? '',
    'videoId': movieFile?.videoId ?? '',
    'videoFileSize': movieFile?.size ?? 0,
    'videoStatus': movieFile?.status ?? 0,
    'trailerHlsUrl': trailer?.hlsUrl ?? '',
    'trailerMp4Url': trailer?.mp4Url ?? '',
    'trailerThumbnailUrl': trailer?.thumbnailUrl ?? '',
    'trailerDirectPlayUrl': trailer?.directPlayUrl ?? '',
    'trailerVideoId': trailer?.videoId ?? '',
    'videoTrailer': trailerUrl,
    'videoMovies': playUrl,
    'customVideoUrl': customVideoUrl,
    'customTrailerUrl': customTrailerUrl,
    'horizontalBannerUrl': horizontalBannerUrl,
    'verticalPosterUrl': verticalPosterUrl,
    'image': verticalPosterUrl,
    'logoUrl': logoUrl,
    'logoImage': logoUrl,
    'publishStatus': publishStatus,
    'subscriptionRequired': subscriptionRequired,
    'enableAds': enableAds,
    'allowDownloads': allowDownloads,
    'featuredMovie': featuredMovie,
    'contentVendor': contentVendor,
    'vendorId': vendorId,
    'publishDate': publishDate,
    'expiryDate': expiryDate,
    'viewCount': viewCount,
    'seoTitle': seoTitle,
    'seoDescription': seoDescription,
    'seoKeywords': seoKeywords,
    'directorInfo': directorString,
    'castInfo': castString,
    'crew': [
      ...director.map((e) => e.toJson()),
      ...producer.map((e) => e.toJson()),
      ...writer.map((e) => e.toJson()),
      ...musicDirector.map((e) => e.toJson()),
      ...cinematographer.map((e) => e.toJson()),
      ...editor.map((e) => e.toJson()),
    ],
    'cast': castMembers.map((e) => e.toJson()).toList(),
    'castMembers': castMembers.map((e) => e.toJson()).toList(),
    'productionStudio': productionStudio,
    'countryOfOrigin': countryOfOrigin,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'bigVerticalUrl': bigVertical.url,
  };
}

class MoviePagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const MoviePagination({
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
  });

  factory MoviePagination.fromJson(Map<String, dynamic> json) =>
      MoviePagination(
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 20,
        total: (json['total'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'totalPages': totalPages,
  };
}

class MovieListResponse {
  final bool success;
  final List<MovieModel> data;
  final MoviePagination pagination;

  const MovieListResponse({
    this.success = false,
    this.data = const [],
    this.pagination = const MoviePagination(),
  });

  factory MovieListResponse.fromJson(Map<String, dynamic> json) =>
      MovieListResponse(
        success: json['success'] as bool? ?? false,
        data: (json['data'] as List? ?? [])
            .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagination: json['pagination'] != null
            ? MoviePagination.fromJson(
                json['pagination'] as Map<String, dynamic>,
              )
            : const MoviePagination(),
      );
      
  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}

class MovieArgument {
  final String id;
  final String title;
  final String hlsUrl;
  final String horizontalBannerUrl;
  final String subtitle;
  final String description;
  final String logoUrl;
  final double imdbRating;
  final String ageRating;
  final String directorString;
  final String castString;

  const MovieArgument({
    this.id = '',
    this.title = '',
    this.hlsUrl = '',
    this.horizontalBannerUrl = '',
    this.subtitle = '',
    this.description = '',
    this.logoUrl = '',
    this.imdbRating = 0.0,
    this.ageRating = '',
    this.directorString = '',
    this.castString = '',
  });

  factory MovieArgument.fromModel(MovieModel m) => MovieArgument(
    id: m.id,
    title: m.movieTitle,
    hlsUrl: m.trailerUrl,
    horizontalBannerUrl: m.horizontalBannerUrl,
    subtitle: m.genresString,
    description: m.description,
    logoUrl: m.logoUrl,
    imdbRating: m.imdbRating,
    ageRating: m.ageRating,
    directorString: m.directorString,
    castString: m.castString,
  );
}
