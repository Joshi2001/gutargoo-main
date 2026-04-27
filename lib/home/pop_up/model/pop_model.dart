class PopupModel {
  final String id;
  final String title;
  final String image;
  final bool isActive;

  PopupModel({
    required this.id,
    required this.title,
    required this.image,
    required this.isActive,
  });

  factory PopupModel.fromJson(Map<String, dynamic> json) {
    return PopupModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}