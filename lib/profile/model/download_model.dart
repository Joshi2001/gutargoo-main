class DownloadItem {
  final String videoId; // ✅ ADD THIS
  final String title;
  final String subtitle;
  final String image;
  final String videoTrailer;
  final String? downloadedPath;
  final DateTime downloadedAt;

  DownloadItem({
    required this.videoId, // ✅ ADD
    required this.title,
    required this.subtitle,
    required this.image,
    required this.videoTrailer,
    this.downloadedPath,
    required this.downloadedAt,
  });

  // ================= JSON =================
  Map<String, dynamic> toJson() => {
        'videoId': videoId, // ✅ ADD
        'title': title,
        'subtitle': subtitle,
        'image': image,
        'videoTrailer': videoTrailer,
        'downloadedPath': downloadedPath,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        videoId: json['videoId'] ?? "", // ✅ ADD
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        image: json['image'] ?? '',
        videoTrailer: json['videoTrailer'] ?? '',
        downloadedPath: json['downloadedPath'],
        downloadedAt: DateTime.tryParse(json['downloadedAt'] ?? '') ??
            DateTime.now(),
      );
}