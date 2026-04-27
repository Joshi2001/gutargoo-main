import 'package:flutter/material.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/model/web_series_model.dart';

class HomeSectionModel {
  final String id;
  final String title;
  final String displayStyle;
  final String? categoryId;
  final String? type;
  final bool isActive;
  final int displayOrder;

  final List<SectionItem> sectionData;
  final List<SectionItem> mixedItems;
  final List<MovieModel> items;
  final List<String> movieIds;

  const HomeSectionModel({
    required this.id,
    required this.title,
    this.displayStyle = 'standard',
    this.categoryId,
    this.type,
    this.isActive = true,
    this.displayOrder = 0,
    this.sectionData = const [],
    this.mixedItems = const [],
    this.items = const [],
    this.movieIds = const [],
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final rawSectionData = json['sectionData'] as List?;
    final sectionData = rawSectionData != null
        ? rawSectionData
            .map((e) {
              try {
                return SectionItem.fromJson(e as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<SectionItem>()
            .toList()
        : <SectionItem>[];

    List<String> movieIds = [];
    if (sectionData.isNotEmpty) {
      movieIds = sectionData.where((s) => s.isMovie).map((s) => s.id).toList();
    } else {
      final raw = json['movieIds'] ?? json['movies'] ?? json['items'];
      if (raw is List) {
        movieIds = raw.map((e) => e.toString()).toList();
      }
    }

    return HomeSectionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      displayStyle: json['displayStyle']?.toString() ?? 'standard',
      categoryId: json['categoryId']?.toString(),
      type: json['type']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      sectionData: sectionData,
      movieIds: movieIds,
      mixedItems: [],
    );
  }

  HomeSectionModel copyWith({
    List<MovieModel>? items,
    List<SectionItem>? mixedItems,
    String? type,
  }) =>
      HomeSectionModel(
        id: id,
        title: title,
        displayStyle: displayStyle,
        categoryId: categoryId,
        type: type ?? this.type,
        isActive: isActive,
        displayOrder: displayOrder,
        sectionData: sectionData,
        movieIds: movieIds,
        items: items ?? this.items,
        mixedItems: mixedItems ?? this.mixedItems,
      );

  List<SectionItem> get allDisplayItems {
    if (mixedItems.isNotEmpty) return mixedItems;
    return items
        .map((m) => SectionItem(
              id: m.id,
              type: 'movie',
              movie: m,
              title: m.movieTitle,
              verticalPosterUrl: m.verticalPosterUrl,
              horizontalBannerUrl: m.horizontalBannerUrl,
              imdbRating: m.imdbRating,
              description: m.description,
              genresString: m.genresString,
            ))
        .toList();
  }

List<SectionItem> itemsForType(String? targetType) {
  debugPrint('🔍 itemsForType called with targetType: "$targetType"');
  debugPrint('📊 Total items: ${allDisplayItems.length}');
  
  if (targetType == null || targetType.isEmpty || targetType == 'home') {
    debugPrint('✅ Returning all items (home category)');
    return allDisplayItems;
  }
  
  final result = allDisplayItems
      .where((item) {
        final match = item.type.toLowerCase() == targetType.toLowerCase();
        if (!match) {
          debugPrint('  ❌ "${item.title}" type "${item.type}" != "$targetType"');
        }
        return match;
      })
      .toList();
      
  debugPrint('✅ Filtered to ${result.length} items');
  return result;
}
}

class SectionItem {
  final String id;
  final String type;
  final String title;
  final String verticalPosterUrl;
  final String horizontalBannerUrl;
  final double imdbRating;
  final String description;
  final String genresString;
  final String bigVerticalUrl;

  final MovieModel? movie;
  final WebSeriesModel? webSeries;

  SectionItem({
    required this.id,
    required this.type,
    required this.title,
    required this.verticalPosterUrl,
    required this.horizontalBannerUrl,
     this.bigVerticalUrl = '',
    this.imdbRating = 0.0,
    this.description = '',
    this.genresString = '',
    this.movie,
    this.webSeries,
  });
factory SectionItem.fromJson(Map<String, dynamic> json) => SectionItem(
  id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
  type: json['type']?.toString() ?? 'movie',
  title: json['title']?.toString() ?? '',
  verticalPosterUrl: json['verticalPosterUrl']?.toString() ?? '',
  horizontalBannerUrl: json['horizontalBannerUrl']?.toString() ?? '',
  imdbRating: (json['imdbRating'] ?? 0).toDouble(),
  description: json['description']?.toString() ?? '',
  genresString: (json['genre'] ?? []).join(', '),
);
factory SectionItem.fromMovie(MovieModel movie) => SectionItem(
      id: movie.id,
      type: 'movie',
      title: movie.movieTitle,
      verticalPosterUrl: movie.verticalPosterUrl,
      horizontalBannerUrl: movie.horizontalBannerUrl,
      bigVerticalUrl: movie.bigVerticalUrl, // ✅ ADD
      imdbRating: movie.imdbRating,
      description: movie.description,
      genresString: movie.genresString,
      movie: movie,
    );

 factory SectionItem.fromWebSeries(WebSeriesModel series) => SectionItem(
  id: series.id,
  type: 'webseries',
  title: series.title,
  verticalPosterUrl: series.posterUrl,
  horizontalBannerUrl: series.bannerUrl,
  description: series.description,
  genresString: series.genresString,
  webSeries: series,  // Make sure the full series object is passed
);
  factory SectionItem.fromTvShow(WebSeriesModel tvShow) => SectionItem(
        id: tvShow.id,
        type: 'tvshow',
        title: tvShow.title,
        verticalPosterUrl: tvShow.posterUrl,
        horizontalBannerUrl: tvShow.bannerUrl,
        description: tvShow.description,
        genresString: tvShow.genresString,
        webSeries: tvShow,
      );

  bool get isMovie => type == 'movie';
  bool get isWebSeries => type == 'webseries';
  bool get isTvShow => type == 'tvshow';

  String get displayTitle => title;
  String get posterUrl => verticalPosterUrl;
  String get bannerUrl => horizontalBannerUrl;

  // ✅ FIXED: movie/webSeries attach hone par URLs + title auto-populate
  SectionItem copyWith({
    String? id,
    String? type,
    String? title,
    String? verticalPosterUrl,
    String? horizontalBannerUrl,
    double? imdbRating,
    String? description,
    String? genresString,
    MovieModel? movie,
    WebSeriesModel? webSeries,
      String? bigVerticalUrl, // ✅ ADD
  }) {
    final resolvedMovie = movie ?? this.movie;
    final resolvedWebSeries = webSeries ?? this.webSeries;

    return SectionItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title
          ?? resolvedMovie?.movieTitle
          ?? resolvedWebSeries?.title
          ?? this.title,
      verticalPosterUrl: verticalPosterUrl
          ?? resolvedMovie?.verticalPosterUrl
          ?? resolvedWebSeries?.posterUrl
          ?? this.verticalPosterUrl,
      horizontalBannerUrl: horizontalBannerUrl
          ?? resolvedMovie?.horizontalBannerUrl
          ?? resolvedWebSeries?.bannerUrl
          ?? this.horizontalBannerUrl,
      imdbRating: imdbRating
          ?? resolvedMovie?.imdbRating
          ?? this.imdbRating,
           bigVerticalUrl: bigVerticalUrl          // ✅ ADD
        ?? resolvedMovie?.bigVerticalUrl
        ?? this.bigVerticalUrl,
      description: description
          ?? resolvedMovie?.description
          ?? resolvedWebSeries?.description
          ?? this.description,
      genresString: genresString
          ?? resolvedMovie?.genresString
          ?? resolvedWebSeries?.genresString
          ?? this.genresString,
      movie: resolvedMovie,
      webSeries: resolvedWebSeries,
    );
  }
}
