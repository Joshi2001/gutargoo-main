import 'dart:async';
import 'dart:math';
import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/potli/potle_reel/model/reel_model.dart';
import 'package:gutrgoopro/potli/potle_reel/service/reel_service.dart';
import 'package:http/http.dart' as http;
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayerController extends GetxController {
  final VideoService _videoService = VideoService();

  final Rx<VideoModel?> videoModel = Rx<VideoModel?>(null);

  late BetterPlayerController betterPlayerController;
  bool _controllerDisposed = false;

  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = true.obs;
  final RxBool isVideoReady = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  final RxBool isLiked = false.obs;
  final RxBool isSaved = false.obs;
  final RxInt likeCount = 0.obs;
  final RxInt saveCount = 0.obs;

  final RxList<EpisodeModel> episodes = <EpisodeModel>[].obs;
  final RxInt currentEpisodeIndex = 0.obs;

  bool _isDisposed = false;

  // ✅ SAFE URL
  String getSafeUrl(String? url) {
    if (url == null || url.isEmpty) {
      return "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
    }
    return url;
  }

  // 🚀 INIT
  void init(VideoModel video) {
    videoModel.value = video;

    likeCount.value = video.likes;
    saveCount.value = video.saves;

    final safeUrl = getSafeUrl(video.url);

    _initPlayer(safeUrl);
    _loadInitialData(video);
  }

  // 🎬 PLAYER INIT
  void _initPlayer(String url) {
    WakelockPlus.enable();

    final config = BetterPlayerConfiguration(
      autoPlay: true,
      fit: BoxFit.cover,
      looping: false,
      controlsConfiguration:
          const BetterPlayerControlsConfiguration(showControls: false),
    );

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      cacheConfiguration:
          const BetterPlayerCacheConfiguration(useCache: false),
    );

    betterPlayerController = BetterPlayerController(config);
    betterPlayerController.setupDataSource(dataSource);
    betterPlayerController.addEventsListener(_onPlayerEvent);

    _controllerDisposed = false;
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (_isDisposed) return;

    final v = betterPlayerController.videoPlayerController?.value;
    if (v == null) return;

    position.value = v.position;
    duration.value = v.duration ?? Duration.zero;
    isBuffering.value = v.isBuffering;
    isPlaying.value = v.isPlaying;

    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      isVideoReady.value = true;
    }
  }

  // 📡 LOAD INITIAL DATA
  Future<void> _loadInitialData(VideoModel model) async {
    try {
      await _loadQualities(model.url);
    } catch (_) {}

    if (model.episodes.isNotEmpty) {
      episodes.assignAll(model.episodes);
    }
  }

  // 🎞 QUALITY
  final RxList<HlsQuality> qualities = <HlsQuality>[].obs;
  final Rx<HlsQuality?> selectedQuality = Rx<HlsQuality?>(null);

  Future<void> _loadQualities(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return;

      final masterText = String.fromCharCodes(res.bodyBytes);
      final parsed = _videoService.parseMasterPlaylist(masterText, url);
      qualities.assignAll(parsed);

      if (qualities.isNotEmpty) {
        selectedQuality.value = qualities.first;
      }
    } catch (e) {
      debugPrint("Quality error: $e");
    }
  }

  // ❤️ LIKE
  Future<void> toggleLike() async {
    isLiked.value = !isLiked.value;
    likeCount.value += isLiked.value ? 1 : -1;
  }

  // 🔖 SAVE
  Future<void> toggleSave() async {
    isSaved.value = !isSaved.value;
    saveCount.value += isSaved.value ? 1 : -1;
  }

  // 🔁 EPISODE SWITCH
  Future<void> switchEpisode(int index) async {
    if (index < 0 || index >= episodes.length) return;

    final episode = episodes[index];

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      getSafeUrl(episode.url), // ✅ FIXED
    );

    await betterPlayerController.setupDataSource(dataSource);
    betterPlayerController.play();

    currentEpisodeIndex.value = index;
  }

  // 📤 SHARE
 Future<void> shareVideo() async {
  final model = videoModel.value;
  if (model == null) return;

  await Share.share(
    '${model.title}\n\n'
    'Download App: https://play.google.com/store/apps/details?id=com.gutargooproo.application',
  );
}
  void togglePlayPause() {
    final playing = betterPlayerController.isPlaying() ?? false;

    if (playing) {
      betterPlayerController.pause();
    } else {
      betterPlayerController.play();
    }
  }

  // 🧹 DISPOSE
  void disposePlayer() {
    if (_controllerDisposed) return;

    _controllerDisposed = true;

    try {
      betterPlayerController.pause();
    } catch (_) {}

    try {
      betterPlayerController.dispose();
    } catch (_) {}
  }

  @override
  void onClose() {
    _isDisposed = true;
    disposePlayer();
    WakelockPlus.disable();
    super.onClose();
  }
}