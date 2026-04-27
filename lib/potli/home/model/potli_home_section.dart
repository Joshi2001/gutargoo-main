import 'package:gutrgoopro/potli/home/model/potli_home_model.dart';


class PotliSectionModel {
  final String id;
  final String title;
  final String displayStyle;
  final List<PotliMovieModel> items;

  PotliSectionModel({
    required this.id,
    required this.title,
    required this.displayStyle,
    required this.items,
  });

  factory PotliSectionModel.fromJson(Map<String, dynamic> json) {
    final itemList = (json['items'] as List<dynamic>? ??
            json['movies'] as List<dynamic>? ??
            [])
        .map((e) => PotliMovieModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PotliSectionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      displayStyle: json['displayStyle']?.toString() ??
          json['display_style']?.toString() ??
          'standard',
      items: itemList,
    );
  }
}