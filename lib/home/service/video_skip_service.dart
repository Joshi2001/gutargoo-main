import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class SkipIntroData {
  final int start;
  final int end;

  SkipIntroData({required this.start, required this.end});

  factory SkipIntroData.fromJson(Map<String, dynamic> json) {
    return SkipIntroData(
      start: json['start']?.toInt() ?? 0,
      end: json['end']?.toInt() ?? 0,
    );
  }
}

class SkipIntroService {
  Future<SkipIntroData?> fetchSkipIntro(
    String videoId, {
    String? seriesId,
  }) async {
    try {
      debugPrint('fetchSkipIntro -> videoId: $videoId, seriesId: $seriesId');

      if (seriesId != null && seriesId.isNotEmpty) {
        return await _fetchEpisodeSkipIntro(seriesId, videoId);
      } else {
        return await _fetchMovieSkipIntro(videoId);
      }
    } catch (e, stack) {
      debugPrint('Error: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  // ================= MOVIE =================
  Future<SkipIntroData?> _fetchMovieSkipIntro(String videoId) async {
    final url = '${MyApi.movies}/$videoId';
    debugPrint('Movie URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint('Movie Status: ${response.statusCode}');
      debugPrint('Movie Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];

          List movies = data is List ? data : [data];

          for (var movie in movies) {
            if (movie['_id'].toString() == videoId.toString()) {
              final skipIntro = movie['skipIntro'];

              if (skipIntro != null &&
                  skipIntro['end'] > skipIntro['start']) {
                return SkipIntroData.fromJson(skipIntro);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Movie Error: $e');
    }

    return null;
  }

  // ================= WEB SERIES =================
  Future<SkipIntroData?> _fetchEpisodeSkipIntro(
      String seriesId, String episodeId) async {
    final url = '${MyApi.webseries}/$seriesId';
    debugPrint('Series URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint('Series Status: ${response.statusCode}');
      debugPrint('Series Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];

          List seriesList = data is List ? data : [data];

          // 👉 IMPORTANT: no need to match seriesId again
          for (var series in seriesList) {
            final seasons = series['seasons'] as List? ?? [];

            for (var season in seasons) {
              final episodes = season['episodes'] as List? ?? [];

              for (var episode in episodes) {
                debugPrint('Checking episode: ${episode['_id']}');

                if (episode['_id'].toString() ==
                    episodeId.toString()) {
                  debugPrint('✅ Episode matched');

                  final skipIntro = episode['skipIntro'];

                  if (skipIntro != null &&
                      skipIntro['end'] > skipIntro['start']) {
                    debugPrint('✅ Skip intro found');

                    return SkipIntroData.fromJson(skipIntro);
                  }
                }
              }
            }
          }
        }
      }
    } catch (e, stack) {
      debugPrint('Series Error: $e');
      debugPrint('Stack: $stack');
    }

    debugPrint('❌ No skip intro found');
    return null;
  }
}