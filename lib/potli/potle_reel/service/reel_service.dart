import 'dart:convert';
import 'package:gutrgoopro/potli/potle_reel/model/reel_model.dart';
import 'package:http/http.dart' as http;

class VideoService {
  static const String _baseUrl = 'https://your-api-base-url.com/api';

  // Fetch video details by ID
  Future<VideoModel?> fetchVideoById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/videos/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return VideoModel.fromJson(json);
      }
    } catch (e) {
      _log('fetchVideoById error: $e');
    }
    return null;
  }

  // Fetch episodes for a series
  Future<List<EpisodeModel>> fetchEpisodes(String seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/series/$seriesId/episodes'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List;
        return jsonList
            .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _log('fetchEpisodes error: $e');
    }
    return [];
  }

  // Like a video
  Future<bool> likeVideo(String videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/videos/$videoId/like'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      _log('likeVideo error: $e');
      return false;
    }
  }

  // Unlike a video
  Future<bool> unlikeVideo(String videoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/videos/$videoId/like'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      _log('unlikeVideo error: $e');
      return false;
    }
  }

  // Save/bookmark a video
  Future<bool> saveVideo(String videoId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/videos/$videoId/save'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      _log('saveVideo error: $e');
      return false;
    }
  }

  // Unsave a video
  Future<bool> unsaveVideo(String videoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/videos/$videoId/save'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      _log('unsaveVideo error: $e');
      return false;
    }
  }

  // Fetch similar/trending videos
  Future<List<VideoModel>> fetchSimilarVideos(String videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/videos/$videoId/similar'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List;
        return jsonList
            .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _log('fetchSimilarVideos error: $e');
    }
    return [];
  }

  // Parse HLS master playlist for quality levels
  List<HlsQuality> parseMasterPlaylist(String content, String baseUrl) {
    final lines = content.split('\n');
    final qualities = <HlsQuality>[
      HlsQuality(label: 'Auto', url: baseUrl, bitrate: 0),
    ];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXT-X-STREAM-INF')) {
        final bitrateMatch = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
        final resolutionMatch =
            RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(line);
        final bitrate =
            bitrateMatch != null ? int.parse(bitrateMatch.group(1)!) : 0;
        final resolution =
            resolutionMatch != null ? resolutionMatch.group(1)! : '';

        if (i + 1 < lines.length) {
          final urlLine = lines[i + 1].trim();
          final absoluteUrl = _makeAbsoluteUrl(baseUrl, urlLine);
          final label = resolution.isNotEmpty
              ? _resolutionToLabel(resolution)
              : '${(bitrate / 1000).round()} kbps';
          qualities.add(
              HlsQuality(label: label, url: absoluteUrl, bitrate: bitrate));
        }
      }
    }

    qualities.sort((a, b) => a.bitrate.compareTo(b.bitrate));
    return qualities;
  }

  String _makeAbsoluteUrl(String base, String path) {
    if (path.startsWith('http')) return path;
    final uri = Uri.parse(base);
    final basePath = uri.path.substring(0, uri.path.lastIndexOf('/') + 1);
    return '${uri.scheme}://${uri.host}$basePath$path';
  }

  String _resolutionToLabel(String resolution) {
    try {
      final parts = resolution.split('x');
      if (parts.length != 2) return resolution;
      final height = int.parse(parts[1]);
      if (height >= 2160) return '2160p';
      if (height >= 1440) return '1440p';
      if (height >= 1080) return '1080p';
      if (height >= 720) return '720p';
      if (height >= 480) return '480p';
      if (height >= 360) return '360p';
      if (height >= 240) return '240p';
      return '${height}p';
    } catch (_) {
      return resolution;
    }
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[VideoService] $message');
  }
}

class HlsQuality {
  final String label;
  final String url;
  final int bitrate;

  const HlsQuality({
    required this.label,
    required this.url,
    required this.bitrate,
  });
}