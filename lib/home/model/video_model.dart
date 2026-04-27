class Video {
  final String id;
  final String name;
  final String logo;
  final String category;
  final String streamUrl;
  final String status;
  final int viewers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Video({
    required this.id,
    required this.name,
    required this.logo,
    required this.category,
    required this.streamUrl,
    required this.status,
    required this.viewers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      category: json['category'] ?? 'Other',
      streamUrl: json['stream_url'] ?? '',
      status: json['status'] ?? 'inactive',
      viewers: json['viewers'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
