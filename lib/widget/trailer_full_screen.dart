import 'dart:async';
import 'dart:convert';
import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
 
class _HlsQuality {
  final String label;
  final String url;
  final int bitrate;
 
  _HlsQuality({required this.label, required this.url, required this.bitrate});
}
 
class TrailerFullScreen extends StatefulWidget {
  final String url;
  final String title;
 
  const TrailerFullScreen({
    super.key,
    required this.url,
    this.title = 'Trailer',
  });
 
  @override
  State<TrailerFullScreen> createState() => _TrailerFullScreenState();
}
 
class _TrailerFullScreenState extends State<TrailerFullScreen> {
  BetterPlayerController? _controller;
 
  bool _isDisposed = false;
  bool _controllerDisposed = false;
  bool _isHandlingBack = false;
 
  Timer? _hideTimer;
  Timer? _unlockHideTimer;
  Timer? _brightnessTimer;
  Timer? _volumeTimer;
 
  double _brightness = 0.5;
  double _volume = 0.5;
 
  bool _showControls = true;
  bool _isDragging = false;
  bool _isLocked = false;
  bool _showUnlockButton = false;
  bool _isFillMode = false;
  bool _isBuffering = true;
  bool _isSeeking = false;
  bool _isVideoReady = false;
 
  bool _showBrightnessUI = false;
  bool _showVolumeUI = false;
  bool _showSeekLeft = false;
  bool _showSeekRight = false;
 
  double _speed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
 
  DeviceOrientation _currentOrientation = DeviceOrientation.landscapeLeft;
 
  List<_HlsQuality> _qualities = [];
  _HlsQuality? _selectedQuality;
 
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initPlayer();
    Future.microtask(() async {
      if (_isDisposed) return;
      _brightness = await ScreenBrightness().current;
      _volume = await VolumeController().getVolume();
    });
    _startHideTimer();
    _loadQualities();
  }

  void _initPlayer({String? overrideUrl}) {
    if (_controller != null && !_controllerDisposed) {
      _disposeController();
    }
 
    final url = overrideUrl ?? _selectedQuality?.url ?? widget.url;
 
    final config = BetterPlayerConfiguration(
      autoPlay: true,
      fit: BoxFit.contain,
      looping: false,
      allowedScreenSleep: false,
      handleLifecycle: false,
      autoDispose: true,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        showControls: false,
      ),
    );
 
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      videoFormat: BetterPlayerVideoFormat.hls,
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
    );
 
    _controllerDisposed = false;
    _controller = BetterPlayerController(config);
    _controller!.setupDataSource(dataSource);
    _controller!.addEventsListener(_onPlayerEvent);
 
    if (mounted) setState(() {});
  }
 
  void _onPlayerEvent(BetterPlayerEvent event) {
    if (_isDisposed) return;
 
    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      try {
        _controller?.seekTo(Duration.zero);
        _controller?.pause();
        if (mounted) {
          setState(() {
            _position = Duration.zero;
            _showControls = true;
          });
          _hideTimer?.cancel();
        }
      } catch (_) {}
      return;
    }
 
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (mounted) setState(() => _isVideoReady = true);
    }
 
    final v = _controller?.videoPlayerController?.value;
    if (v == null || !mounted) return;
 
    setState(() {
      _position = v.position;
      _duration = v.duration ?? Duration.zero;
      _isBuffering = v.isBuffering;
      if (v.isPlaying && !v.isBuffering) _isSeeking = false;
    });
  }
 
  // ─────────────────────────────────────────────
  // QUALITY
  // ─────────────────────────────────────────────
  Future<void> _loadQualities() async {
    if (!widget.url.startsWith('http')) return;
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (_isDisposed || !mounted) return;
      if (res.statusCode != 200) return;
      final masterText = utf8.decode(res.bodyBytes);
      final qualities = _parseMasterPlaylist(masterText, widget.url);
      if (mounted && !_isDisposed) {
        setState(() {
          _qualities = qualities;
          if (_qualities.isNotEmpty) {
            _selectedQuality = _qualities.firstWhere(
              (q) => q.label.toLowerCase().contains('auto'),
              orElse: () => _qualities.first,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Trailer quality load error: $e');
    }
  }
 
  List<_HlsQuality> _parseMasterPlaylist(String content, String baseUrl) {
    final lines = content.split('\n');
    final List<_HlsQuality> qualities = [
      _HlsQuality(label: 'Auto', url: baseUrl, bitrate: 0),
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
            _HlsQuality(label: label, url: absoluteUrl, bitrate: bitrate),
          );
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
 
  Future<void> _applyQuality(_HlsQuality quality) async {
    if (_isDisposed || _controller == null) return;
    final wasPlaying = _controller!.isPlaying() ?? false;
    final currentPos =
        _controller!.videoPlayerController?.value.position ?? _position;
 
    setState(() {
      _selectedQuality = quality;
      _isVideoReady = false;
    });
 
    try {
      await _controller!.setupDataSource(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          quality.url,
          videoFormat: BetterPlayerVideoFormat.hls,
          cacheConfiguration:
              const BetterPlayerCacheConfiguration(useCache: false),
        ),
      );
      if (_isDisposed) return;
      await _controller!.seekTo(currentPos);
      if (wasPlaying && !_isDisposed) _controller!.play();
    } catch (e) {
      debugPrint('Trailer quality apply error: $e');
    }
  }
 
  void _disposeController() {
    if (_controllerDisposed) return;
    _controllerDisposed = true;
 
    try {
      if (_controller != null) {
        _controller?.removeEventsListener(_onPlayerEvent);
        _controller?.pause();
        _controller?.clearCache();
        _controller?.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
    _controller = null;
  }
 
  Future<void> _handleBack() async {
    if (_isHandlingBack || _isDisposed) return;
    _isHandlingBack = true;
 
    _hideTimer?.cancel();
    _unlockHideTimer?.cancel();
    _brightnessTimer?.cancel();
    _volumeTimer?.cancel();
 
    if (_controller != null && !_controllerDisposed) {
      try {
        await _controller?.pause();
      } catch (_) {}
    }
 
    try {
      await WakelockPlus.disable();
    } catch (_) {}
 
    try {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } catch (_) {}
 
    _isDisposed = true;
 
    if (mounted) {
      Navigator.of(context).pop();
    }
 
    Future.delayed(const Duration(milliseconds: 100), () {
      _disposeController();
    });
  }
 
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isDragging && !_isLocked && !_isDisposed)
        setState(() => _showControls = false);
    });
  }
 
  void _startUnlockHideTimer() {
    _unlockHideTimer?.cancel();
    _unlockHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isLocked && !_isDisposed) {
        setState(() => _showUnlockButton = false);
      }
    });
  }
 
  void _toggleControls() {
    if (_isLocked) {
      setState(() => _showUnlockButton = true);
      _startUnlockHideTimer();
      return;
    }
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }
 
  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _showControls = false;
        _showUnlockButton = true;
        _startUnlockHideTimer();
      } else {
        _showControls = true;
        _showUnlockButton = false;
        _startHideTimer();
      }
    });
  }
 
  void _togglePlayPause() {
    if (_isLocked || _isDisposed) return;
    final isPlaying = _controller?.isPlaying() ?? false;
    isPlaying ? _controller?.pause() : _controller?.play();
    setState(() {});
    _startHideTimer();
  }
 
  void _toggleFillMode() {
    setState(() => _isFillMode = !_isFillMode);
    _startHideTimer();
  }
 
  Future<void> _toggleRotation() async {
    final next = _currentOrientation == DeviceOrientation.landscapeLeft
        ? DeviceOrientation.landscapeRight
        : DeviceOrientation.landscapeLeft;
    setState(() => _currentOrientation = next);
    await SystemChrome.setPreferredOrientations([next]);
    _startHideTimer();
  }
 
  Future<void> _seekBy(int seconds) async {
    if (_isLocked || _isDisposed) return;
    final v = _controller?.videoPlayerController?.value;
    if (v == null) return;
    final current = v.position;
    final total = v.duration ?? Duration.zero;
    final newMs = (current.inMilliseconds + seconds * 1000).clamp(
      0,
      total.inMilliseconds,
    );
    setState(() => _isSeeking = true);
    await _controller?.seekTo(Duration(milliseconds: newMs));
    if (!_isDisposed) _startHideTimer();
  }
 
  void _showSeekEffect(bool right) {
    if (_isLocked) return;
    if (right) {
      setState(() => _showSeekRight = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_isDisposed) setState(() => _showSeekRight = false);
      });
    } else {
      setState(() => _showSeekLeft = true);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted && !_isDisposed) setState(() => _showSeekLeft = false);
      });
    }
  }
 
  void _openSettingsDialog() {
    if (_isLocked) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => _TrailerSettingsDialog(
        qualities: _qualities,
        selectedQuality: _selectedQuality,
        speed: _speed,
        onQualitySelected: (q) async {
          Navigator.pop(context);
          await _applyQuality(q);
        },
        onSpeedSelected: (s) {
          setState(() => _speed = s);
          _controller?.setSpeed(s);
          Navigator.pop(context);
        },
      ),
    );
  }
 
  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }
 
  Widget _circleButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        if (_isLocked || _isDisposed) return;
        onTap();
        _startHideTimer();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
 
  Widget _seekOverlay(bool right) {
    final show = right ? _showSeekRight : _showSeekLeft;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: show ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  right ? Icons.fast_forward : Icons.fast_rewind,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                const Text(
                  '10 sec',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _sideIndicator(IconData icon, double value) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: RotatedBox(
              quarterTurns: -1,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.red),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
 
  // ─────────────────────────────────────────────
  // VIDEO WIDGET — FILL MODE FIX (BLACK SCREEN FIX)
  // ─────────────────────────────────────────────
  Widget _buildVideoWidget() {
    if (_controller == null || _controller!.videoPlayerController == null) {
      return const SizedBox.shrink();
    }
 
    final videoValue = _controller!.videoPlayerController!.value;
    // Use actual video size — fallback to 16:9 if not yet available
    final double videoWidth = videoValue.size?.width ?? 1920;
    final double videoHeight = videoValue.size?.height ?? 1080;
 
    return SizedBox.expand(
      child: FittedBox(
        fit: _isFillMode ? BoxFit.cover : BoxFit.contain,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: videoWidth,
          height: videoHeight,
          child: BetterPlayer(
            key: const Key('trailer_video_player'),
            controller: _controller!,
          ),
        ),
      ),
    );
  }
 
  @override
  void dispose() {
    _isDisposed = true;
 
    _hideTimer?.cancel();
    _unlockHideTimer?.cancel();
    _brightnessTimer?.cancel();
    _volumeTimer?.cancel();
 
    if (!_isHandlingBack) {
      _disposeController();
      try {
        WakelockPlus.disable();
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      } catch (_) {}
    }
 
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final isPlaying = _controller?.isPlaying() ?? false;
 
    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.red))
            : Stack(
                children: [
                  // ── VIDEO ──────────────────────────────
                  Positioned.fill(
                    child: _buildVideoWidget(), // <-- FIXED fill mode
                  ),
 
                  // ── LOADING OVERLAYS ───────────────────
                  if (!_isVideoReady)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  if (_isVideoReady && (_isBuffering || _isSeeking))
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
 
                  // ── GESTURE ZONES ──────────────────────
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        onDoubleTap: _isLocked
                            ? null
                            : () async {
                                _showSeekEffect(false);
                                await _seekBy(-10);
                              },
                        onVerticalDragUpdate: (details) async {
                          if (_isLocked || _isDisposed) return;
                          final delta = details.primaryDelta! / 300;
                          _brightness =
                              (_brightness - delta).clamp(0.0, 1.0);
                          await ScreenBrightness()
                              .setScreenBrightness(_brightness);
                          if (!_isDisposed)
                            setState(() => _showBrightnessUI = true);
                          _brightnessTimer?.cancel();
                          _brightnessTimer =
                              Timer(const Duration(milliseconds: 800), () {
                            if (mounted && !_isDisposed)
                              setState(() => _showBrightnessUI = false);
                          });
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        onDoubleTap: _isLocked
                            ? null
                            : () async {
                                _showSeekEffect(true);
                                await _seekBy(10);
                              },
                        onVerticalDragUpdate: (details) async {
                          if (_isLocked || _isDisposed) return;
                          final delta = details.primaryDelta! / 300;
                          _volume = (_volume - delta).clamp(0.0, 1.0);
                          VolumeController().setVolume(_volume);
                          if (!_isDisposed)
                            setState(() => _showVolumeUI = true);
                          _volumeTimer?.cancel();
                          _volumeTimer =
                              Timer(const Duration(milliseconds: 800), () {
                            if (mounted && !_isDisposed)
                              setState(() => _showVolumeUI = false);
                          });
                        },
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
 
                  // ── SEEK OVERLAYS ──────────────────────
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _seekOverlay(false)),
                  ),
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _seekOverlay(true)),
                  ),
 
                  // ── CENTER PLAY/PAUSE/SEEK BUTTONS ─────
                  if (_showControls && !_isLocked && _isVideoReady)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _circleButton(
                            Icons.replay_10,
                            onTap: () => _seekBy(-10),
                          ),
                          const SizedBox(width: 28),
                          _circleButton(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            onTap: _togglePlayPause,
                          ),
                          const SizedBox(width: 28),
                          _circleButton(
                            Icons.forward_10,
                            onTap: () => _seekBy(10),
                          ),
                        ],
                      ),
                    ),
 
                  // ── TOP BAR ────────────────────────────
                  if (_showControls && !_isLocked)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _handleBack,
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleFillMode,
                                icon: Icon(
                                  _isFillMode
                                      ? Icons.fit_screen
                                      : Icons.crop_free,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleLock,
                                icon: const Icon(
                                  Icons.lock_open,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: _openSettingsDialog,
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
 
                  // ── BOTTOM SEEK BAR ────────────────────
                  if (_showControls && !_isLocked && _isVideoReady)
                    Positioned(
                      bottom: 10,
                      left: 14,
                      right: 14,
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              activeColor: Colors.red,
                              inactiveColor: Colors.white24,
                              value: _position.inSeconds
                                  .toDouble()
                                  .clamp(
                                0,
                                _duration.inSeconds.toDouble() == 0
                                    ? 1
                                    : _duration.inSeconds.toDouble(),
                              ),
                              max: _duration.inSeconds.toDouble() == 0
                                  ? 1
                                  : _duration.inSeconds.toDouble(),
                              onChangeStart: (_) =>
                                  setState(() => _isDragging = true),
                              onChanged: (v) => setState(
                                () => _position =
                                    Duration(seconds: v.toInt()),
                              ),
                              onChangeEnd: (v) async {
                                setState(() => _isDragging = false);
                                await _controller?.seekTo(
                                  Duration(seconds: v.toInt()),
                                );
                                _startHideTimer();
                              },
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_format(_position)} / ${_format(_duration)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleRotation,
                                  child: Icon(
                                    _currentOrientation ==
                                            DeviceOrientation.landscapeLeft
                                        ? Icons.screen_rotation_alt
                                        : Icons.screen_rotation,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
 
                  // ── UNLOCK BUTTON (when locked) ────────
                  if (_isLocked && _showUnlockButton)
                    Positioned(
                      right: 18,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _toggleLock,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_open,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
 
                  // ── BRIGHTNESS INDICATOR ───────────────
                  if (_showBrightnessUI)
                    Positioned(
                      left: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _sideIndicator(
                            Icons.brightness_6, _brightness),
                      ),
                    ),
 
                  if (_showVolumeUI)
                    Positioned(
                      right: 20,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _sideIndicator(Icons.volume_up, _volume),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
 
class _TrailerSettingsDialog extends StatefulWidget {
  final List<_HlsQuality> qualities;
  final _HlsQuality? selectedQuality;
  final double speed;
  final Function(_HlsQuality) onQualitySelected;
  final Function(double) onSpeedSelected;
 
  const _TrailerSettingsDialog({
    required this.qualities,
    required this.selectedQuality,
    required this.speed,
    required this.onQualitySelected,
    required this.onSpeedSelected,
  });
 
  @override
  State<_TrailerSettingsDialog> createState() => _TrailerSettingsDialogState();
}
 
class _TrailerSettingsDialogState extends State<_TrailerSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double _selectedSpeed;
  _HlsQuality? _selectedQuality;
 
  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.speed;
    _selectedQuality = widget.selectedQuality;
    _tabController = TabController(length: 2, vsync: this);
  }
 
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
 
  Widget _rowItem(String title, {bool selected = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white60,
          fontSize: 17,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      leading: selected
          ? const Icon(Icons.check, color: Colors.blueAccent)
          : const SizedBox(width: 24),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Quality'),
                      Tab(text: 'Speed'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Quality Tab
                  widget.qualities.isEmpty
                      ? const Center(
                          child: Text(
                            'No quality options',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView(
                          children: widget.qualities.map((q) {
                            final selected = _selectedQuality?.url == q.url;
                            return _rowItem(
                              q.label,
                              selected: selected,
                              onTap: () {
                                setState(() => _selectedQuality = q);
                                widget.onQualitySelected(q);
                              },
                            );
                          }).toList(),
                        ),
 
                  // Speed Tab
                  ListView(
                    children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                      final selected = _selectedSpeed == s;
                      return _rowItem(
                        s == 1.0 ? '1x  Normal' : '${s}x',
                        selected: selected,
                        onTap: () {
                          setState(() => _selectedSpeed = s);
                          widget.onSpeedSelected(s);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
