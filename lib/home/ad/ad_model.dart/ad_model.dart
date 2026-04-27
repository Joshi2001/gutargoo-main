import 'package:flutter/material.dart';

class AdModel {
  final String? vastUrl;
  final int? showAt;
  final bool isActive;
  final int? duration;
  final String positionType; // 'start' | 'mid' | 'end' | 'custom' | 'multiple'
  final bool showAtStart;
  final bool showAtMid;
  final bool showAtEnd;
  final List<int> multiplePositions;

  AdModel({
    this.vastUrl,
    this.showAt,
    required this.isActive,
    this.duration,
    this.positionType = 'custom',
    this.showAtStart = false,
    this.showAtMid = false,
    this.showAtEnd = false,
    this.multiplePositions = const [],
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['vastUrl'];
    final fixedUrl = buildValidVastUrl(rawUrl);

    debugPrint("🔧 Raw VAST URL: $rawUrl");
    debugPrint("✅ Fixed VAST URL: $fixedUrl");

    return AdModel(
      vastUrl: fixedUrl,
      showAt: json['showAt'] as int?,
      isActive: json['isActive'] ?? false,
      duration: json['duration'] as int?,
      positionType: json['positionType']?.toString() ?? 'custom',
      showAtStart: json['showAtStart'] ?? false,
      showAtMid: json['showAtMid'] ?? false,
      showAtEnd: json['showAtEnd'] ?? false,
      multiplePositions: (json['multiplePositions'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}

String buildValidVastUrl(String? url) {
  if (url == null || url.isEmpty) return "";
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  if (url.contains(r'${DateTime.now().millisecondsSinceEpoch}')) {
    return url.replaceAll(
      r'${DateTime.now().millisecondsSinceEpoch}',
      timestamp,
    );
  }
  if (url.contains("correlator=") && url.endsWith("=")) {
    return "$url$timestamp";
  }
  if (!url.contains("correlator=")) {
    return "$url&correlator=$timestamp";
  }
  return url;
}
// class AdModel {
//   final String? vastUrl;
//   final int? showAt;
//   final bool isActive;
//   final int? duration;

//   AdModel({
//     this.vastUrl,
//     this.showAt,
//     required this.isActive,
//     this.duration,
//   });

//   factory AdModel.fromJson(Map<String, dynamic> json) {
//     final rawUrl = json['vastUrl'];

//     final fixedUrl = buildValidVastUrl(rawUrl);

//     print("🔧 Raw VAST URL: $rawUrl");
//     print("✅ Fixed VAST URL: $fixedUrl");

//     return AdModel(
//       vastUrl: fixedUrl,
//       showAt: json['showAt'],
//       isActive: json['isActive'] ?? false,
//       duration: json['duration'],
//     );
//   }
// }

// /// ✅ Fix VAST URL (important)
// String buildValidVastUrl(String? url) {
//   if (url == null || url.isEmpty) return "";

//   final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

//   // Replace Dart placeholder
//   if (url.contains(r'${DateTime.now().millisecondsSinceEpoch}')) {
//     return url.replaceAll(
//       r'${DateTime.now().millisecondsSinceEpoch}',
//       timestamp,
//     );
//   }

//   // If correlator exists but empty
//   if (url.contains("correlator=") && url.endsWith("=")) {
//     return "$url$timestamp";
//   }

//   // If correlator missing
//   if (!url.contains("correlator=")) {
//     return "$url&correlator=$timestamp";
//   }

//   return url;
// }