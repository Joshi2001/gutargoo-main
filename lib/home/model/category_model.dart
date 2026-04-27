
class CategoryModel {
  final String id;
  final String name;

  final String? type;

  final int? displayOrder;
  final bool? isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.type,
    this.displayOrder,
    this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';

    String? type = json['categoryType']?.toString() ??
        json['type']?.toString();

    if (type == null || type.isEmpty) {
      final nameLower = name.toLowerCase().trim();
      if (nameLower == 'movies' || nameLower == 'movie') {
        type = 'movie';
      } else if (nameLower == 'webseries' ||
          nameLower == 'web series' ||
          nameLower == 'web-series') {
        type = 'webseries';
      } else if (nameLower == 'tvshows' ||
          nameLower == 'tv shows' ||
          nameLower == 'tv show' ||
          nameLower == 'tvshow') {
        type = 'tvshow';
      }
    }

    // normalize karo: 'movies' → 'movie', 'tvshows' → 'tvshow'
    if (type != null) {
      final t = type.toLowerCase().trim();
      if (t == 'movies') type = 'movie';
      else if (t == 'tvshows' || t == 'tv shows') type = 'tvshow';
      else if (t == 'web series') type = 'webseries';
      else type = t;
    }

    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: name,
      type: type,
      displayOrder: json['displayOrder'] as int?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}