class VideoModel {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String url;
  final String? description;
  final int episodeNumber;
  final int totalEpisodes;
  final int likes;
  final int saves;
  final List<EpisodeModel> episodes;
  final List<VideoModel> similarVideos;
  final String? vastTagUrl;

  const VideoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.url,
    this.description,
    this.episodeNumber = 1,
    this.totalEpisodes = 1,
    this.likes = 0,
    this.saves = 0,
    this.episodes = const [],
    this.similarVideos = const [],
    this.vastTagUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      url: json['url']?.toString() ?? json['videoTrailer']?.toString() ?? '',
      description: json['description']?.toString() ?? json['dis']?.toString(),
      episodeNumber: int.tryParse(json['episodeNumber']?.toString() ?? '1') ?? 1,
      totalEpisodes: int.tryParse(json['totalEpisodes']?.toString() ?? '1') ?? 1,
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      saves: int.tryParse(json['saves']?.toString() ?? '0') ?? 0,
      episodes: (json['episodes'] as List<dynamic>? ?? [])
          .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      similarVideos: (json['similarVideos'] as List<dynamic>? ?? [])
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      vastTagUrl: json['vastTagUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'image': image,
        'url': url,
        'description': description,
        'episodeNumber': episodeNumber,
        'totalEpisodes': totalEpisodes,
        'likes': likes,
        'saves': saves,
        'episodes': episodes.map((e) => e.toJson()).toList(),
        'similarVideos': similarVideos.map((v) => v.toJson()).toList(),
        'vastTagUrl': vastTagUrl,
      };

  VideoModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? image,
    String? url,
    String? description,
    int? episodeNumber,
    int? totalEpisodes,
    int? likes,
    int? saves,
    List<EpisodeModel>? episodes,
    List<VideoModel>? similarVideos,
    String? vastTagUrl,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
      url: url ?? this.url,
      description: description ?? this.description,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      likes: likes ?? this.likes,
      saves: saves ?? this.saves,
      episodes: episodes ?? this.episodes,
      similarVideos: similarVideos ?? this.similarVideos,
      vastTagUrl: vastTagUrl ?? this.vastTagUrl,
    );
  }
}

class EpisodeModel {
  final int number;
  final String title;
  final String url;
  final String? thumbnail;
  final String? duration;
  final bool isWatched;

  const EpisodeModel({
    required this.number,
    required this.title,
    required this.url,
    this.thumbnail,
    this.duration,
    this.isWatched = false,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      number: int.tryParse(json['number']?.toString() ?? '1') ?? 1,
      title: json['title']?.toString() ?? 'Episode ${json['number']}',
      url: json['url']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      duration: json['duration']?.toString(),
      isWatched: json['isWatched'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'duration': duration,
        'isWatched': isWatched,
      };

  EpisodeModel copyWith({
    int? number,
    String? title,
    String? url,
    String? thumbnail,
    String? duration,
    bool? isWatched,
  }) {
    return EpisodeModel(
      number: number ?? this.number,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      isWatched: isWatched ?? this.isWatched,
    );
  }
}