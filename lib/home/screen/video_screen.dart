// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:better_player_enhanced/better_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_chrome_cast/_session_manager/cast_session_manager.dart';
// import 'package:flutter_chrome_cast/entities/cast_session.dart';
// import 'package:flutter_chrome_cast/enums/connection_state.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/home/ad/ads_screen.dart';
// import 'package:gutrgoopro/home/ad/controller/ad_controller.dart';
// import 'package:gutrgoopro/home/ad/responce/ad_scheduler.dart';
// import 'package:gutrgoopro/home/cast/cast.dart';
// import 'package:gutrgoopro/home/getx/details_controller.dart';
// import 'package:gutrgoopro/home/model/web_series_model.dart';
// import 'package:gutrgoopro/home/screen/details_screen.dart';
// import 'package:gutrgoopro/home/service/continue_watching_service.dart';
// import 'package:gutrgoopro/home/service/video_skip_service.dart';
// import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
// import 'package:gutrgoopro/profile/model/favorite_model.dart';
// import 'package:http/http.dart' as http;
// import 'package:pip/pip.dart';
// import 'package:screen_brightness/screen_brightness.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:volume_controller/volume_controller.dart';
// import 'package:gutrgoopro/home/getx/home_controller.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// class VideoScreen extends StatefulWidget {
//   final String url;
//   final String title;
//   final String image;
//   final List<Map<String, String>> similarVideos;
//   final String? vastTagUrl;
//   final String? videoId;
//   final String? seriesId;
//   final VoidCallback? onBackPressed;
//   final Map<String, dynamic>? nextEpisodeData;
//   final int movieDuration;
//   final bool isWebSeries;
//   final List<Map<String, dynamic>> seasons;
//     final SkipIntroData? skipIntroData; 
//   final bool startInFullscreen;

//   const VideoScreen({
//     super.key,
//     required this.url,
//     required this.title,
//     this.similarVideos = const [],
//     required this.image,
//     this.vastTagUrl,
//     this.videoId,
//     this.seriesId,
//     this.movieDuration = 0,
//     this.onBackPressed,
//     this.nextEpisodeData,
//     this.isWebSeries = false,
//     this.seasons = const [],
//      this.skipIntroData,
//      this.startInFullscreen = false,
//   });

//   @override
//   State<VideoScreen> createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen>
//     with RouteAware, WidgetsBindingObserver {
      
//    late BetterPlayerController _controller;
//   bool _isPlayerInitialized = false;
//   final _pip = Pip();
//   late final FavoritesController favoritesController;
//   Timer? _progressSaveTimer;
//   final ContinueWatchingService _cwService = ContinueWatchingService();
//   // AdController? _adController;
//   // String? _resolvedVastUrl;
//   late AdController _adController;
// String? _resolvedVastUrl;
//   bool _isDisposed = false;
//   bool _controllerDisposed = false;
//   bool _isBackPressed = false;
//   bool _showAd = false;
//   bool _adShownOnce = false;
//   SkipIntroData? _skipIntroData;
//   bool _showSkipIntroButton = false;
//   Timer? _skipIntroCheckTimer;
//   bool _skipIntroShown = false;
//   Timer? _hideTimer;
//   Timer? _unlockHideTimer;
//   bool _showControls = true;
//   bool _isDragging = false;
//   bool _isLocked = false;
//   bool _showUnlockButton = false;
//   double brightness = 0.5;
//   double volume = 0.5;
//   bool showBrightnessUI = false;
//   bool showVolumeUI = false;
//   Timer? brightnessTimer;
//   Timer? volumeTimer;
//   int _selectedSeasonIndex = 0;
//   final Map<int, int> _visibleEpisodesCount = {};
//   static const int _initialEpisodeCount = 5;
//   double _speed = 1.0;
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;
//   bool _isBuffering = true;
//   bool _isSeeking = false;
//   bool _isVideoReady = false;
//   bool _isReturningFromFullscreen = false; 
//   bool _isInFullscreen = false;
//   bool _showSeekLeft = false;
//   bool _showSeekRight = false;
//   List<HlsQuality> _qualities = [];
//   HlsQuality? _selectedQuality;
//   int _playerKey = 0;
// AdScheduler? _adScheduler;
// bool _adInProgress = false;
//   late final HomeController _homeController;
//   static final RouteObserver<ModalRoute<void>> routeObserver =
//       RouteObserver<ModalRoute<void>>();

//   @override
  
// @override
// void initState() {
//   super.initState();
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//   _loadSkipIntroData();
//   _initPlayer();
//   _isPlayerInitialized = true;

//   if (widget.videoId == null || widget.videoId!.isEmpty) {
//     debugPrint('⚠️ WARNING: videoId is null or empty!');
//   }

//   _startProgressSaveTimer();
//   favoritesController = Get.find<FavoritesController>();
//   WidgetsBinding.instance.addObserver(this);
//   WakelockPlus.enable();
//   _homeController = Get.find<HomeController>();
//   _adController = Get.find<AdController>();

//   WidgetsBinding.instance.addPostFrameCallback((_) async {
//     await _adController.ensureLoaded();
//     // Create a fresh scheduler for this video session
//     _adScheduler = _adController.createScheduler();
//     _loadQualities();
//     _startHideTimer();
//     _triggerStartAd();  // <-- replaces _handleAdsAfterInit
//   });
// }
// void _triggerStartAd() {
//   debugPrint('🔍 Checking for start ad...');
//   final startAd = _adScheduler?.getStartAd();
//   if (startAd != null) {
//     debugPrint('📺 Start ad found: ${startAd.vastUrl}');
//     _showAdOverlay(startAd.vastUrl!);
//   } else {
//     debugPrint('▶️ No start ad, playing video directly');
//     _startVideoPlayback();
//   }
// }
// void _showAdOverlay(String vastUrl) {
//   if (_isDisposed || !mounted) return;
//   _adInProgress = true;
//   _resolvedVastUrl = vastUrl;

//   // Pause & mute video while ad plays
//   try {
//     _controller.pause();
//     _controller.setVolume(0);
//   } catch (_) {}

//   setState(() => _showAd = true);
// }

//  Future<void> _loadSkipIntroData() async {
//   debugPrint('🚀 _loadSkipIntroData called');
//   debugPrint('📦 widget.skipIntroData = ${widget.skipIntroData}');
//   debugPrint('📦 widget.seriesId = ${widget.seriesId}');
//   debugPrint('📦 widget.videoId = ${widget.videoId}');
//   debugPrint('📦 widget.isWebSeries = ${widget.isWebSeries}');
  
//   // First priority: passed data
//   if (widget.skipIntroData != null && widget.skipIntroData!.end > widget.skipIntroData!.start) {
//     debugPrint('✅ Using passed skipIntroData: ${widget.skipIntroData!.start} to ${widget.skipIntroData!.end}');
//     setState(() {
//       _skipIntroData = widget.skipIntroData;
//     });
//     return;
//   }
  
//   debugPrint('❌ No skipIntroData passed or invalid');
  
//   // For web series episodes (has seriesId)
//   if (widget.seriesId != null && widget.seriesId!.isNotEmpty) {
//     debugPrint('📡 This is a web series episode, seriesId: ${widget.seriesId}');
//     debugPrint('📡 Episode ID: ${widget.videoId}');
    
//     final service = SkipIntroService();
//     final data = await service.fetchSkipIntro(
//       widget.videoId ?? '', 
//       seriesId: widget.seriesId,
//     );
//     if (mounted && data != null && data.end > data.start) {
//       debugPrint('✅ Fetched skip intro for episode: ${data.start}-${data.end}');
//       setState(() => _skipIntroData = data);
//     } else {
//       debugPrint('❌ No skip intro found for this episode');
//     }
//     return;
//   }
  
//   // For movies (no seriesId)
//   if (widget.seriesId == null || widget.seriesId!.isEmpty) {
//     debugPrint('📡 Trying to fetch skip intro for movie: ${widget.videoId}');
//     final service = SkipIntroService();
//     final data = await service.fetchSkipIntro(widget.videoId ?? '');
//     if (mounted && data != null && data.end > data.start) {
//       debugPrint('✅ Fetched skip intro from API: ${data.start}-${data.end}');
//       setState(() => _skipIntroData = data);
//     } else {
//       debugPrint('❌ No skip intro from API');
//     }
//   }
// }
//   Widget _buildWebSeriesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 8.h),
//         _buildSeasonSelector(),
//         SizedBox(height: 4.h),
//         _buildEpisodesListHotstar(),
//       ],
//     );
//   }

//   Widget _buildSeasonSelector() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Row(
//         children: List.generate(widget.seasons.length, (i) {
//           final season = widget.seasons[i];
//           final seasonNumber = season['season'] ?? (i + 1);
//           final label = 'Season $seasonNumber';
//           final isSelected = _selectedSeasonIndex == i;
//           return GestureDetector(
//             onTap: () => setState(() {
//               _selectedSeasonIndex = i;
//               _visibleEpisodesCount.remove(i);
//             }),
//             child: Container(
//               margin: EdgeInsets.only(right: 24.w),
//               padding: EdgeInsets.only(bottom: 10.h),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: isSelected ? Colors.white : Colors.transparent,
//                     width: 2.5,
//                   ),
//                 ),
//               ),
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : Colors.white38,
//                   fontSize: 15.sp,
//                   fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildEpisodesListHotstar() {
//     if (widget.seasons.isEmpty) {
//       return Padding(
//         padding: EdgeInsets.all(20.h),
//         child: Center(
//           child: Text(
//             'Episodes coming soon...',
//             style: TextStyle(color: Colors.white54, fontSize: 14.sp),
//           ),
//         ),
//       );
//     }

//     final currentSeason = widget.seasons[_selectedSeasonIndex];
//     final episodes = (currentSeason['episodes'] as List<dynamic>? ?? []);

//     if (episodes.isEmpty) {
//       return Padding(
//         padding: EdgeInsets.all(20.h),
//         child: Center(
//           child: Text(
//             'No episodes available',
//             style: TextStyle(color: Colors.white54, fontSize: 14.sp),
//           ),
//         ),
//       );
//     }

//     final visibleCount =
//         _visibleEpisodesCount[_selectedSeasonIndex] ?? _initialEpisodeCount;
//     final showingAll = visibleCount >= episodes.length;
//     final displayEpisodes = episodes.take(visibleCount).toList();

//     return Column(
//       children: [
//         ...displayEpisodes.asMap().entries.map((entry) {
//           final index = entry.key;
//           final ep = entry.value as Map<String, dynamic>;
//           final epNumber = ep['episodeNumber'] ?? (index + 1);
//           return _buildHotstarEpisodeCard(ep, epNumber);
//         }),

//         if (episodes.length > _initialEpisodeCount)
//           Center(
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (showingAll) {
//                     _visibleEpisodesCount[_selectedSeasonIndex] =
//                         _initialEpisodeCount;
//                   } else {
//                     _visibleEpisodesCount[_selectedSeasonIndex] =
//                         episodes.length;
//                   }
//                 });
//               },
//               child: Container(
//                 margin: EdgeInsets.symmetric(vertical: 12.h),
//                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//                 decoration: BoxDecoration(
//                   color: Colors.white10,
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       showingAll
//                           ? Icons.keyboard_arrow_up_rounded
//                           : Icons.keyboard_arrow_down_rounded,
//                       color: Colors.white,
//                       size: 18.sp,
//                     ),
//                     SizedBox(width: 4.w),
//                     Text(
//                       showingAll ? 'View Less' : 'View More',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//         SizedBox(height: 16.h),
//       ],
//     );
//   }

//   Widget _buildHotstarEpisodeCard(
//   Map<String, dynamic> episode,
//   int episodeNumber,
// ) {
//   // ✅ FIXED: Extract from correct nested structure
//   final title = episode['title']?.toString() ?? '';
//   final description = episode['description']?.toString() ?? '';
//   final duration = episode['videoFile'] != null 
//       ? (episode['videoFile']['duration'] as int? ?? 0)
//       : 0;
  
//   // ✅ FIXED: Get thumbnail from videoFile
//   String thumbnail = '';
//   if (episode['videoFile'] != null) {
//     thumbnail = episode['videoFile']['thumbnailUrl']?.toString() ?? '';
//   }
//   if (thumbnail.isEmpty) {
//     thumbnail = widget.image; // Fallback to series thumbnail
//   }
  
//   // ✅ FIXED: Get playUrl from videoFile
//   String playUrl = '';
//   if (episode['videoFile'] != null) {
//     playUrl = episode['videoFile']['url']?.toString() ?? '';
//   }
  
//   // ✅ EXTRACT SKIP INTRO FROM EPISODE DATA
//   final skipIntroRaw = episode['skipIntro'];
//   SkipIntro? skipIntro;
//   if (skipIntroRaw != null && skipIntroRaw is Map<String, dynamic>) {
//     skipIntro = SkipIntro(
//       start: (skipIntroRaw['start'] as num?)?.toInt() ?? 0,
//       end: (skipIntroRaw['end'] as num?)?.toInt() ?? 0,
//     );
//     debugPrint('📦 Episode $episodeNumber has skipIntro: ${skipIntro.start}-${skipIntro.end}');
//   }

//   final hasValidVideo = playUrl.isNotEmpty;

//   return GestureDetector(
//     onTap: () {
//       if (!hasValidVideo) return;
//       final epId = episode['_id']?.toString() ?? episode['id']?.toString() ?? '';
//       debugPrint('🎬 Playing episode: $episodeNumber, URL: $playUrl');
//       _playEpisode(
//         playUrl, 
//         title, 
//         thumbnail, 
//         epId, 
//         duration,
//         skipIntro,
//       );
//     },
//     child: Container(
//       margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
//       padding: EdgeInsets.symmetric(vertical: 10.h),
//       decoration: const BoxDecoration(
//         border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Thumbnail
//               SizedBox(
//                 width: 130.w,
//                 height: 80.h,
//                 child: Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(6.r),
//                       child: thumbnail.isNotEmpty
//                           ? Image.network(
//                               thumbnail,
//                               width: 130.w,
//                               height: 80.h,
//                               fit: BoxFit.cover,
//                               cacheWidth: 260,
//                               cacheHeight: 160,
//                               errorBuilder: (_, __, ___) => _episodeThumbnailPlaceholder(),
//                             )
//                           : _episodeThumbnailPlaceholder(),
//                     ),
//                     if (!hasValidVideo)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(6.r),
//                             color: Colors.black.withOpacity(0.7),
//                           ),
//                           child: Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.access_time_filled, color: Colors.orange, size: 24.sp),
//                                 SizedBox(height: 4.h),
//                                 Text('Coming Soon', style: TextStyle(color: Colors.orange, fontSize: 10.sp, fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (hasValidVideo)
//                       Positioned(
//                         bottom: 6.h,
//                         left: 6.w,
//                         child: Container(
//                           width: 22.w,
//                           height: 22.w,
//                           decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
//                           child: Icon(Icons.play_arrow, color: Colors.white, size: 14.sp),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               // Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             title,
//                             style: TextStyle(
//                               color: hasValidVideo ? Colors.white : Colors.white54,
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         if (!hasValidVideo)
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(4.r),
//                               border: Border.all(color: Colors.orange.withOpacity(0.5)),
//                             ),
//                             child: Text('Coming Soon', style: TextStyle(color: Colors.orange, fontSize: 8.sp, fontWeight: FontWeight.w600)),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 4.h),
//                     // ✅ FIXED: Show episode number with season
//                     Text(
//                       'Episode $episodeNumber',
//                       style: TextStyle(color: Colors.white54, fontSize: 11.sp),
//                     ),
//                     // ✅ ADDED: Show duration if available
//                     if (duration > 0)
//                       Padding(
//                         padding: EdgeInsets.only(top: 2.h),
//                         child: Text(
//                           '${duration ~/ 60} min',
//                           style: TextStyle(color: Colors.white38, fontSize: 10.sp),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (description.isNotEmpty) ...[
//             SizedBox(height: 8.h),
//             Text(
//               description,
//               style: TextStyle(color: hasValidVideo ? Colors.white60 : Colors.white38, fontSize: 11.sp, height: 1.4),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }
//   Widget _episodeThumbnailPlaceholder() => Container(
//     width: 130.w,
//     height: 80.h,
//     decoration: BoxDecoration(
//       color: Colors.grey.shade800,
//       borderRadius: BorderRadius.circular(6.r),
//     ),
//     child: Icon(Icons.play_circle_outline, color: Colors.white38, size: 28.sp),
//   );

// void _playEpisode(String url, String title, String thumbnail, String? episodeId, int duration, SkipIntro? skipIntro) {
//   debugPrint('🎬 _playEpisode called');
//   debugPrint('   Episode ID: $episodeId');
//   debugPrint('   Series ID: ${widget.videoId}');
  
//   Map<String, dynamic>? nextEpisodeData;
  
//   if (widget.seasons.isNotEmpty && episodeId != null) {
//     for (int seasonIdx = 0; seasonIdx < widget.seasons.length; seasonIdx++) {
//       final season = widget.seasons[seasonIdx];
//       final episodes = season['episodes'] as List? ?? [];
      
//       for (int epIdx = 0; epIdx < episodes.length; epIdx++) {
//         final ep = episodes[epIdx] as Map<String, dynamic>;
//         if (ep['id']?.toString() == episodeId) {
//           if (epIdx + 1 < episodes.length) {
//             final nextEp = episodes[epIdx + 1];
//             nextEpisodeData = {
//               'id': nextEp['id'],
//               'title': nextEp['title'],
//               'url': nextEp['playUrl'],
//               'image': nextEp['thumbnailUrl'],
//               'duration': nextEp['duration'],
//               'episodeNumber': nextEp['episodeNumber'],
//               'nextEpisode': epIdx + 2 < episodes.length ? {
//                 'id': episodes[epIdx + 2]['id'],
//                 'title': episodes[epIdx + 2]['title'],
//                 'url': episodes[epIdx + 2]['playUrl'],
//               } : null,
//             };
//             debugPrint('✅ Next episode found: ${nextEp['title']}');
//           }
//           // Check next season if no next episode in current season
//           else if (seasonIdx + 1 < widget.seasons.length) {
//             final nextSeason = widget.seasons[seasonIdx + 1];
//             final nextSeasonEpisodes = nextSeason['episodes'] as List? ?? [];
//             if (nextSeasonEpisodes.isNotEmpty) {
//               final nextEp = nextSeasonEpisodes[0];
//               nextEpisodeData = {
//                 'id': nextEp['id'],
//                 'title': nextEp['title'],
//                 'url': nextEp['playUrl'],
//                 'image': nextEp['thumbnailUrl'],
//                 'duration': nextEp['duration'],
//                 'episodeNumber': nextEp['episodeNumber'],
//               };
//               debugPrint('✅ Next season first episode found: ${nextEp['title']}');
//             }
//           }
//           break;
//         }
//       }
//       if (nextEpisodeData != null) break;
//     }
//   }
  
//   _isDisposed = true;
//   _progressSaveTimer?.cancel();
//   _hideTimer?.cancel();
//   _disposeController();

//   if (!mounted) return;
  
//   SkipIntroData? skipIntroData;
//   if (skipIntro != null && skipIntro.end > skipIntro.start) {
//     skipIntroData = SkipIntroData(start: skipIntro.start, end: skipIntro.end);
//   }
  
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (_) => VideoScreen(
//         url: url,
//         title: '${widget.title} - $title',
//         image: thumbnail.isNotEmpty ? thumbnail : widget.image,
//         similarVideos: widget.similarVideos,
//         vastTagUrl: widget.vastTagUrl,
//         videoId: episodeId,
//         seriesId: widget.videoId,
//         movieDuration: duration,
//         isWebSeries: true,
//         seasons: widget.seasons,
//         nextEpisodeData: nextEpisodeData,  // Pass the next episode data
//         skipIntroData: skipIntroData,
//       ),
//     ),
//   );
// }
//   void _checkForSkipIntro() {
//     if (_skipIntroData == null) return;
//     if (_skipIntroShown) return;

//     final currentSec = _position.inSeconds;
//     final isInSkipRange =
//         currentSec >= _skipIntroData!.start && currentSec < _skipIntroData!.end;

//     if (isInSkipRange != _showSkipIntroButton && mounted) {
//       setState(() {
//         _showSkipIntroButton = isInSkipRange;
//       });
//       debugPrint(
//         'Skip button visibility: $_showSkipIntroButton (current: ${currentSec}s, range: ${_skipIntroData!.start}-${_skipIntroData!.end})',
//       );
//     }

//     if (currentSec >= _skipIntroData!.end && _showSkipIntroButton) {
//       setState(() {
//         _showSkipIntroButton = false;
//         _skipIntroShown = true;
//       });
//       debugPrint('Auto-hiding skip button - passed intro end time');
//     }
//   }

//   Future<void> _skipIntro() async {
//     debugPrint('🎯 SKIP INTRO CALLED');
//     if (_skipIntroData == null) {
//       debugPrint('Skip data is null!');
//       return;
//     }

//     debugPrint('Seeking to ${_skipIntroData!.end} seconds');

//     setState(() {
//       _showSkipIntroButton = false;
//       _skipIntroShown = true;
//     });

//     try {
//       if (_isSeeking) return;

//       await _controller.seekTo(Duration(seconds: _skipIntroData!.end));
//       debugPrint('Seek completed successfully');

//       if (_controller.isPlaying() == true) {
//         await _controller.play();
//       }

//       _startHideTimer();
//     } catch (e) {
//       debugPrint('Error seeking: $e');
//     }
//   }

//   void _startProgressSaveTimer() {
//     _progressSaveTimer?.cancel();
//     _progressSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
//       if (!_isDisposed && mounted) _saveWatchProgress();
//     });
//   }

//   Future<void> _saveWatchProgress() async {
//     final id = widget.videoId ?? '';
//     if (id.isEmpty) {
//       debugPrint('❌ [SAVE] No videoId - THIS IS THE PROBLEM!');
//       return;
//     }
//     final v = _controller.videoPlayerController?.value;
//     if (v == null) return;

//     final watchedSec = v.position.inSeconds;
//     final totalSec = v.duration?.inSeconds ?? widget.movieDuration;

//     debugPrint('📊 [SAVE] Saving progress: $watchedSec / $totalSec seconds');
//     debugPrint('📊 [SAVE] Video ID: ${widget.videoId}');
//     debugPrint('📊 [SAVE] Movie Duration: ${widget.movieDuration}');
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setInt("continue_${widget.videoId}", watchedSec);
//     if (watchedSec < 5 || totalSec < 10) {
//       debugPrint('📊 [SAVE] Skipping - too short');
//       return;
//     }

//     try {
//       final token = _homeController.userToken.value;
//       if (token.isEmpty) {
//         debugPrint('❌ [SAVE] No token');
//         return;
//       }

//       final id = widget.videoId ?? '';
//       if (id.isEmpty) {
//         debugPrint('❌ [SAVE] No videoId - THIS IS THE PROBLEM!');
//         return;
//       }

//       debugPrint('📊 [SAVE] Calling API with movieId: $id');

//       final success = await _cwService.updateWatchProgress(
//         token: token,
//         movieId: id,
//         watchedTime: watchedSec,
//         duration: totalSec,
//         isCompleted: (watchedSec / totalSec) > 0.9,
//       );

//       debugPrint('✅ [SAVE] Result: $success');
//     } catch (e) {
//       debugPrint('❌ [SAVE] Error: $e');
//     }
//   }

//    void _resolveAdUrl() {
//     debugPrint('🔍 [AD] Resolving ad URL...');

//     if (widget.vastTagUrl != null && widget.vastTagUrl!.isNotEmpty) {
//       _resolvedVastUrl = widget.vastTagUrl;
//       debugPrint('✅ [AD] URL from widget: $_resolvedVastUrl');
//       return;
//     }

//     final activeAd = _adController.activePrerollAd.value;

//     if (activeAd == null) {
//       debugPrint('❌ [AD] No active ad');
//       _resolvedVastUrl = null;
//       return;
//     }

//     if (activeAd.isActive == true && 
//         activeAd.vastUrl != null && 
//         activeAd.vastUrl!.isNotEmpty) {
//       _resolvedVastUrl = activeAd.vastUrl;
//       debugPrint('✅ [AD] URL from AdController: $_resolvedVastUrl');
//       return;
//     }

//     _resolvedVastUrl = null;
//     debugPrint('❌ [AD] No valid ad');
//   }


// void _startVideoAfterAd() {
//   if (_isDisposed) return;
//   _adInProgress = false;
//   debugPrint('🎬 Ad finished, resuming video');

//   setState(() => _showAd = false);

//   Future.delayed(const Duration(milliseconds: 100), () {
//     if (_isDisposed || !mounted) return;
//     try {
//       _controller.setVolume(1.0);
//       _controller.play();
//       if (widget.startInFullscreen) {
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted && !_isDisposed) _openFullscreen();
//         });
//       }
//     } catch (e) {
//       debugPrint('Error resuming video: $e');
//     }
//   });
// }
// // void _onPlayerEvent(BetterPlayerEvent event) {
// //   if (!mounted || _isDisposed) return;

// //   if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
// //     // Check for end-position ad before looping
// //     _checkScheduledAds(isFinished: true);
// //     try {
// //       _controller.seekTo(Duration.zero);
// //       _controller.pause();
// //       if (mounted) {
// //         setState(() {
// //           _position = Duration.zero;
// //           _showControls = true;
// //         });
// //         _hideTimer?.cancel();
// //       }
// //     } catch (_) {}
// //     return;
// //   }

// //   if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
// //     if (mounted) setState(() => _isVideoReady = true);
// //     return;
// //   }

// //   if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
// //     final v = _controller.videoPlayerController?.value;
// //     if (v != null) {
// //       setState(() {
// //         _position = v.position;
// //         _duration = v.duration ?? Duration.zero;
// //         _isBuffering = v.isBuffering;
// //         if (v.isPlaying && !v.isBuffering) _isSeeking = false;
// //       });
// //       _checkForSkipIntro();
// //       // ✅ Check mid/custom/multiple ad positions
// //       if (!_adInProgress) _checkScheduledAds();
// //     }
// //     return;
// //   }

// //   final v = _controller.videoPlayerController?.value;
// //   if (v == null || !mounted || _isDisposed) return;
// //   setState(() {
// //     _position = v.position;
// //     _duration = v.duration ?? Duration.zero;
// //     _isBuffering = v.isBuffering;
// //     if (v.isPlaying && !v.isBuffering) _isSeeking = false;
// //   });
// //   _checkForSkipIntro();
// // }
// void _onPlayerEvent(BetterPlayerEvent event) {
//   if (!mounted || _isDisposed) return;

//   if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
//     if (mounted) {
//       debugPrint('✅ Player initialized');
//       setState(() => _isVideoReady = true);
//     }
//     return;
//   }

//   if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
//     _checkScheduledAds(isFinished: true);
//     try {
//       _controller.seekTo(Duration.zero);
//       _controller.pause();
//       if (mounted) {
//         setState(() {
//           _position = Duration.zero;
//           _showControls = true;
//         });
//         _hideTimer?.cancel();
//       }
//     } catch (_) {}
//     return;
//   }

//   if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
//     final v = _controller.videoPlayerController?.value;
//     if (v != null) {
//       // Don't override _isVideoReady if already true from fullscreen return
//       if (!_isVideoReady && mounted) {
//         setState(() => _isVideoReady = true);
//       }
//       setState(() {
//         _position = v.position;
//         _duration = v.duration ?? Duration.zero;
//         _isBuffering = v.isBuffering;
//         if (v.isPlaying && !v.isBuffering) _isSeeking = false;
//       });
//       _checkForSkipIntro();
//       if (!_adInProgress) _checkScheduledAds();
//     }
//     return;
//   }

//   final v = _controller.videoPlayerController?.value;
//   if (v == null || !mounted || _isDisposed) return;
  
//   // Only update if needed
//   setState(() {
//     _position = v.position;
//     _duration = v.duration ?? Duration.zero;
//     _isBuffering = v.isBuffering;
//     if (v.isPlaying && !v.isBuffering) _isSeeking = false;
//   });
//   _checkForSkipIntro();
// }
// void _checkScheduledAds({bool isFinished = false}) {
//   if (_adScheduler == null || _adInProgress) return;

//   final currentSec = isFinished
//       ? (_duration.inSeconds)
//       : _position.inSeconds;
//   final totalSec = _duration.inSeconds;

//   final ad = _adScheduler!.checkPosition(
//     currentSeconds: currentSec,
//     totalSeconds: totalSec,
//   );

//   if (ad != null && ad.vastUrl != null && ad.vastUrl!.isNotEmpty) {
//     debugPrint('⚡ Scheduled ad triggered at ${currentSec}s');
//     _showAdOverlay(ad.vastUrl!);
//   }
// }
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final route = ModalRoute.of(context);
//     if (route != null) routeObserver.subscribe(this, route);
//   }
// // ignore: unused_element
// void _resolveAdUrlWithRetry({int retryCount = 0}) {
//   const maxRetries = 10;

//   debugPrint('🔍 [AD] Attempt ${retryCount + 1} to get ad');

//   if (widget.vastTagUrl != null && widget.vastTagUrl!.isNotEmpty) {
//     _resolvedVastUrl = widget.vastTagUrl;
//     debugPrint('✅ [AD] URL set from widget: $_resolvedVastUrl');
//     return;
//   }

//   final activeAd = _adController.activePrerollAd.value;

//   if (activeAd != null &&
//       activeAd.isActive == true &&
//       activeAd.vastUrl != null &&
//       activeAd.vastUrl!.isNotEmpty) {
//     _resolvedVastUrl = activeAd.vastUrl;
//     debugPrint('✅ [AD] Ad found: $_resolvedVastUrl');
//     return;
//   }

//   if (_adController.isLoading.value && retryCount < maxRetries) {
//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (mounted && !_isDisposed) {
//         _resolveAdUrlWithRetry(retryCount: retryCount + 1);
//       }
//     });
//     return;
//   }

//   _resolvedVastUrl = null;
//   debugPrint('❌ [AD] No ad available after ${retryCount + 1} attempts');
// }
//   @override
//   void didPushNext() {
//     super.didPushNext();
//     if (!_controllerDisposed) {
//       try {
//         _controller.pause();
//         _controller.setVolume(1.0);
//       } catch (_) {}
//     }
//     _hideTimer?.cancel();
//     brightnessTimer?.cancel();
//     volumeTimer?.cancel();
//     _unlockHideTimer?.cancel();
//   }

//   // @override
//   // void didPopNext() {
//   //   super.didPopNext();
//   //   if (!_controllerDisposed && !_isDisposed) {
//   //     try {
//   //       _controller.setVolume(1.0);
//   //       _controller.play();
//   //     } catch (_) {}
//   //     setState(() => _showControls = true);
//   //     _startHideTimer();
//   //   }
//   // }
//  @override
// void didPopNext() {
//   super.didPopNext();
  
//   // Agar fullscreen se wapas aa rahe ho, skip - already handled in _openFullscreen
//   if (_isReturningFromFullscreen) return;
 
//   // Normal back (e.g., settings, dialog) ke liye
//   if (!_controllerDisposed && !_isDisposed) {
//     try {
//       _controller.setVolume(1.0);
//       _controller.play();
//     } catch (_) {}
//     setState(() => _showControls = true);
//     _startHideTimer();
//   }
// }
 

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_isInFullscreen) return;
//     if (state == AppLifecycleState.inactive && !_isBackPressed) {
//       _enterPipMode();
//     }
//   }

//   void _initPlayer() {
//   final config = BetterPlayerConfiguration(
//     autoPlay: false,  // Keep this false
//     fit: BoxFit.contain,
//     looping: true,
//     allowedScreenSleep: false,
//     handleLifecycle: false,
//     autoDispose: true,
//     controlsConfiguration: const BetterPlayerControlsConfiguration(
//       showControls: false,
//       enableAudioTracks: true,
//     ),
//   );
  
//   final BetterPlayerDataSource dataSource;
//   if (widget.url.endsWith(".m3u8")) {
//     dataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       widget.url,
//       videoFormat: BetterPlayerVideoFormat.hls,
//       cacheConfiguration: const BetterPlayerCacheConfiguration(
//         useCache: false,
//         maxCacheSize: 0,
//       ),
//     );
//   } else {
//     dataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       widget.url,
//       cacheConfiguration: const BetterPlayerCacheConfiguration(
//         useCache: false,
//         maxCacheSize: 0,
//       ),
//     );
//   }

//   _controller = BetterPlayerController(config);
//   _controllerDisposed = false;

//   _controller.setupDataSource(dataSource).then((_) async {
//     if (_isDisposed || _controllerDisposed) return;
    
//     // Set volume to 0 initially
//     _controller.setVolume(0);
    
//     // Load saved position if any
//     final savedSeconds = await _getSavedPosition();
//     if (_isDisposed || _controllerDisposed) return;
//     if (savedSeconds > 0) {
//       await _controller.seekTo(Duration(seconds: savedSeconds));
//     }
    
//     // ✅ Mark video as ready
//     if (mounted) {
//       setState(() => _isVideoReady = true);
//     }
    
//     // ✅ Start ad flow AFTER video is ready
//     _startAdFlow();
//   });

//   _controller.addEventsListener(_onPlayerEvent);
// }

// // ✅ New method to handle ad flow
// void _startAdFlow() async {
//   debugPrint('🎬 Starting ad flow...');
  
//   // Wait a bit for everything to settle
//   await Future.delayed(const Duration(milliseconds: 500));
  
//   if (_isDisposed || !mounted) return;
  
//   // Resolve ad URL
//   _resolveAdUrl();
  
//   final hasValidAd = _resolvedVastUrl != null && _resolvedVastUrl!.isNotEmpty;
  
//   if (!_adShownOnce && hasValidAd) {
//     debugPrint('📺 Showing ad...');
//     setState(() {
//       _showAd = true;
//       _adShownOnce = true;
//     });
//   } else {
//     debugPrint('🎬 No ad to show, starting video directly');
//     _startVideoPlayback();
//   }
// }

// // ✅ New method to start video playback
// void _startVideoPlayback() {
//   if (_isDisposed || !mounted) return;
  
//   debugPrint('🎬 Starting video playback');
  
//   setState(() {
//     _showAd = false;
//   });
  
//   Future.delayed(const Duration(milliseconds: 100), () {
//     if (_isDisposed || !mounted) return;
//     try {
//       _controller.setVolume(1.0);
//       _controller.play();
//       debugPrint('✅ Video playing');
      
//       if (widget.startInFullscreen) {
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted && !_isDisposed) _openFullscreen();
//         });
//       }
//     } catch (e) {
//       debugPrint('Error starting video: $e');
//     }
//   });
// }

//   Future<int> _getSavedPosition() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final key = "continue_${widget.videoId}";
//       return prefs.getInt(key) ?? 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   void _disposeController() {
//     if (_controllerDisposed) return;
//     _controllerDisposed = true;
//     try {
//       _controller.removeEventsListener(_onPlayerEvent);
//     } catch (_) {}
//     try {
//       _controller.pause();
//     } catch (_) {}
//     try {
//       _controller.dispose();
//     } catch (e) {
//       debugPrint("Controller dispose error: $e");
//     }
//   }

//   Future<void> _enterPipMode() async {
//     if (!(_controller.isPlaying() ?? false)) return;
//     try {
//       final supported = await _pip.isSupported();
//       if (!supported) {
//         try {
//           _controller.pause();
//         } catch (_) {}
//         return;
//       }
//       await _pip.setup(
//         PipOptions(autoEnterEnabled: false, aspectRatioX: 16, aspectRatioY: 9),
//       );
//       await _pip.start();
//     } catch (e) {
//       debugPrint("PiP error: $e");
//       try {
//         _controller.pause();
//       } catch (_) {}
//     }
//   }

//   Future<bool> _handleBackPress() async {
//     _isBackPressed = true;
//     _hideTimer?.cancel();
//     brightnessTimer?.cancel();
//     volumeTimer?.cancel();
//     _unlockHideTimer?.cancel();

//     try {
//       _controller.pause();
//       _controller.setVolume(0.0);
//     } catch (_) {}

//     await Future.delayed(const Duration(milliseconds: 100));

//     if (widget.onBackPressed != null) {
//       widget.onBackPressed!();
//     }

//     if (mounted) Navigator.pop(context);
//     return true;
//   }

//   Future<void> _loadQualities() async {
//     if (!widget.url.startsWith("http")) return;
//     try {
//       final res = await http.get(Uri.parse(widget.url));
//       if (_isDisposed || !mounted) return;
//       if (res.statusCode != 200) return;
//       final masterText = utf8.decode(res.bodyBytes);
//       final qualities = _parseMasterPlaylist(masterText, widget.url);
//       if (mounted && !_isDisposed) {
//         setState(() {
//           _qualities = qualities;
//           if (_qualities.isNotEmpty) {
//             _selectedQuality = _qualities.firstWhere(
//               (q) => q.label.toLowerCase().contains("auto"),
//               orElse: () => _qualities.first,
//             );
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint("Quality load error: $e");
//     }
//   }

//   List<HlsQuality> _parseMasterPlaylist(String content, String baseUrl) {
//     final lines = content.split("\n");
//     final Map<String, HlsQuality> uniqueQualities = {};

//     uniqueQualities["Auto"] = HlsQuality(
//       label: "Auto",
//       url: baseUrl,
//       bitrate: 0,
//     );

//     for (int i = 0; i < lines.length; i++) {
//       final line = lines[i].trim();
//       if (line.startsWith("#EXT-X-STREAM-INF")) {
//         final resolutionMatch = RegExp(
//           r"RESOLUTION=(\d+x\d+)",
//         ).firstMatch(line);
//         final resolution = resolutionMatch != null
//             ? resolutionMatch.group(1)!
//             : "";

//         if (i + 1 < lines.length && resolution.isNotEmpty) {
//           final urlLine = lines[i + 1].trim();
//           final absoluteUrl = _makeAbsoluteUrl(baseUrl, urlLine);

//           final key = resolution;

//           if (!uniqueQualities.containsKey(key)) {
//             final label = _resolutionToLabel(resolution);
//             uniqueQualities[key] = HlsQuality(
//               label: label,
//               url: absoluteUrl,
//               bitrate: 0,
//             );
//           }
//         }
//       }
//     }
//     List<HlsQuality> qualities = uniqueQualities.values.toList();

//     qualities.sort((a, b) {
//       int getHeight(String label) {
//         if (label == "Auto") return 9999;
//         final match = RegExp(r'(\d+)p').firstMatch(label);
//         return match != null ? int.parse(match.group(1)!) : 0;
//       }

//       return getHeight(b.label).compareTo(getHeight(a.label));
//     });

//     qualities.sort((a, b) {
//       if (a.label == "Auto") return -1;
//       if (b.label == "Auto") return 1;
//       return 0;
//     });

//     debugPrint(
//       '✅ Unique qualities: ${qualities.map((q) => q.label).join(", ")}',
//     );

//     return qualities;
//   }

//   String _makeAbsoluteUrl(String base, String path) {
//     if (path.startsWith("http")) return path;
//     final uri = Uri.parse(base);
//     final basePath = uri.path.substring(0, uri.path.lastIndexOf("/") + 1);
//     return "${uri.scheme}://${uri.host}$basePath$path";
//   }

//   String _resolutionToLabel(String resolution) {
//     try {
//       final parts = resolution.split("x");
//       if (parts.length != 2) return resolution;
//       final height = int.parse(parts[1]);
//       if (height >= 2160) return "2160p";
//       if (height >= 1440) return "1440p";
//       if (height >= 1080) return "1080p";
//       if (height >= 720) return "720p";
//       if (height >= 480) return "480p";
//       if (height >= 360) return "360p";
//       if (height >= 240) return "240p";
//       return "${height}p";
//     } catch (_) {
//       return resolution;
//     }
//   }


//   Future<void> _applyQuality(HlsQuality quality) async {
//     if (!widget.url.startsWith("http") || _isDisposed) return;

//     final wasPlaying = _controller.isPlaying() ?? false;
//     final currentPos =
//         _controller.videoPlayerController?.value.position ?? _position;

//     setState(() => _selectedQuality = quality);

//     try {
//       if (wasPlaying) _controller.pause();
//     } catch (e) {
//       debugPrint("Pause error: $e");
//     }

//     await Future.delayed(const Duration(milliseconds: 150));

//     await _controller.setupDataSource(
//       BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         quality.url,
//         videoFormat: BetterPlayerVideoFormat.hls,
//         cacheConfiguration: const BetterPlayerCacheConfiguration(
//           useCache: false,
//           maxCacheSize: 0,
//         ),
//       ),
//     );

//     if (_isDisposed) return;

//     await Future.delayed(const Duration(milliseconds: 300));
//     if (!_isDisposed) await _controller.seekTo(currentPos);
//     if (wasPlaying && !_isDisposed) _controller.play();
//   }

//   void _startHideTimer() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted && !_isDragging && !_isLocked && !_isDisposed) {
//         setState(() => _showControls = false);
//       }
//     });
//   }

//   void _startUnlockHideTimer() {
//     _unlockHideTimer?.cancel();
//     _unlockHideTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted && _isLocked && !_isDisposed) {
//         setState(() => _showUnlockButton = false);
//       }
//     });
//   }

//   void _toggleControls() {
//     if (_isLocked) {
//       setState(() => _showUnlockButton = true);
//       _startUnlockHideTimer();
//       return;
//     }
//     setState(() => _showControls = !_showControls);
//     if (_showControls) _startHideTimer();
//   }

//   void _togglePlayPause() {
//     if (_isLocked) return;
//     final isPlaying = _controller.isPlaying() ?? false;
//     isPlaying ? _controller.pause() : _controller.play();
//     setState(() {});
//     _startHideTimer();
//   }

//   void _toggleLock() {
//     setState(() {
//       _isLocked = !_isLocked;
//       if (_isLocked) {
//         _showControls = false;
//         _showUnlockButton = true;
//         _startUnlockHideTimer();
//       } else {
//         _showControls = true;
//         _showUnlockButton = false;
//         _startHideTimer();
//       }
//     });
//   }

//   Future<void> _seekBy(int seconds) async {
//     if (_isLocked || _isDisposed) return;
//     final v = _controller.videoPlayerController?.value;
//     if (v == null) return;
//     setState(() => _isSeeking = true);
//     final current = v.position;
//     final total = v.duration ?? Duration.zero;
//     Duration target = current + Duration(seconds: seconds);
//     if (target < Duration.zero) target = Duration.zero;
//     if (target > total) target = total;
//     await _controller.seekTo(target);
//     if (!_isDisposed) _startHideTimer();
//   }

//   void _showSeekEffect(bool right) {
//     if (_isLocked) return;
//     if (right) {
//       setState(() => _showSeekRight = true);
//       Future.delayed(const Duration(milliseconds: 450), () {
//         if (mounted && !_isDisposed) setState(() => _showSeekRight = false);
//       });
//     } else {
//       setState(() => _showSeekLeft = true);
//       Future.delayed(const Duration(milliseconds: 450), () {
//         if (mounted && !_isDisposed) setState(() => _showSeekLeft = false);
//       });
//     }
//   }

//   void _openCastDialog() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF1A1A1A),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => CastDeviceSheet(
//         videoUrl: _selectedQuality?.url ?? widget.url,
//         title: widget.title,
//       ),
//     );
//   }

//   void _openSettingsDialog() {
//     if (_isLocked) return;
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.85),
//       builder: (_) => HotstarSettingsDialog(
//         qualities: _qualities,
//         selectedQuality: _selectedQuality,
//         speed: _speed,
//         onQualitySelected: (q) async {
//           Navigator.pop(context);
//           await _applyQuality(q);
//         },
//         onSpeedSelected: (s) {
//           setState(() => _speed = s);
//           _controller.setSpeed(s);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

// // Future<void> _openFullscreen() async {
// //   if (_isLocked || _isDisposed) return;

// //   final wasPlaying = _controller.isPlaying() ?? false;
// //   final livePos = _controller.videoPlayerController?.value.position ?? _position;

// //   _controller.removeEventsListener(_onPlayerEvent);

// //   await SystemChrome.setPreferredOrientations([
// //     DeviceOrientation.landscapeLeft,
// //     DeviceOrientation.landscapeRight,
// //   ]);
// //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// //   final Map<String, dynamic>? result = await Navigator.push<Map<String, dynamic>>(
// //     context,
// //     PageRouteBuilder(
// //       transitionDuration: Duration.zero,
// //       reverseTransitionDuration: Duration.zero,
// //       pageBuilder: (_, __, ___) => HotstarFullscreenPage(
// //         // ✅ PASS EXISTING CONTROLLER
// //         existingController: _controller,
// //         videoUrl: _selectedQuality?.url ?? widget.url,
// //         title: widget.title,
// //         speed: _speed,
// //         qualities: _qualities,
// //         selectedQuality: _selectedQuality,
// //         initialPosition: livePos,
// //         videoId: widget.videoId,
// //         movieDuration: widget.movieDuration,
// //         skipIntroData: _skipIntroData,
// //         nextEpisodeData: widget.nextEpisodeData,
// //         isWebSeries: widget.isWebSeries,
// //         seasons: widget.seasons,
// //         wasPlaying: wasPlaying,
// //         seriesId: widget.seriesId,
// //         onQualityChanged: (q) async {
// //           setState(() => _selectedQuality = q);
// //           await _applyQuality(q);
// //         },
// //         onSpeedChanged: (s) {
// //           if (!_isDisposed) setState(() => _speed = s);
// //           _controller.setSpeed(s);
// //         },
// //       ),
// //     ),
// //   );

// //   await SystemChrome.setPreferredOrientations([
// //     DeviceOrientation.portraitUp,
// //     DeviceOrientation.portraitDown,
// //   ]);
// //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

// //   if (!mounted || _isDisposed) return;

// //   // ✅ Re-attach listener - controller already has correct position
// //   _controller.addEventsListener(_onPlayerEvent);

// //   // ✅ Sync state from result
// //   final shouldPlay = result != null ? result['wasPlaying'] as bool : wasPlaying;
// //   final returnedPos = result != null ? result['position'] as Duration? : null;

// //   if (returnedPos != null) {
// //     final currentPos = _controller.videoPlayerController?.value.position ?? Duration.zero;
// //     if ((returnedPos - currentPos).abs() > const Duration(seconds: 1)) {
// //       try { await _controller.seekTo(returnedPos); } catch (_) {}
// //     }
// //   }

// //   if (shouldPlay) {
// //     try { await _controller.play(); } catch (_) {}
// //   }

// //   setState(() => _showControls = true);
// //   _startHideTimer();
// // }
// Future<void> _openFullscreen() async {
//   if (_isLocked || _isDisposed) return;

//   final wasPlaying = _controller.isPlaying() ?? false;
//   final livePos = _controller.videoPlayerController?.value.position ?? _position;
//   _isReturningFromFullscreen = true;
//   _isInFullscreen = true;

//   // Remove listener BEFORE push (already doing this — good)
//   _controller.removeEventsListener(_onPlayerEvent);

//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);
//   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//   final Map<String, dynamic>? result = await Navigator.push<Map<String, dynamic>>(
//     context,
//     PageRouteBuilder(
//       transitionDuration: Duration.zero,
//       reverseTransitionDuration: Duration.zero,
//       pageBuilder: (_, __, ___) => HotstarFullscreenPage(
//         existingController: _controller,
//         videoUrl: _selectedQuality?.url ?? widget.url,
//         title: widget.title,
//         speed: _speed,
//         qualities: _qualities,
//         selectedQuality: _selectedQuality,
//         initialPosition: livePos,
//         videoId: widget.videoId,
//         movieDuration: widget.movieDuration,
//         skipIntroData: _skipIntroData,
//         nextEpisodeData: widget.nextEpisodeData,
//         isWebSeries: widget.isWebSeries,
//         seasons: widget.seasons,
//         wasPlaying: wasPlaying,
//         seriesId: widget.seriesId,
//         onQualityChanged: (q) async {
//           setState(() => _selectedQuality = q);
//           await _applyQuality(q);
//         },
//         onSpeedChanged: (s) {
//           if (!_isDisposed) setState(() => _speed = s);
//           _controller.setSpeed(s);
//         },
//       ),
//     ),
//   );

//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

//   if (!mounted || _isDisposed) {
//     _isReturningFromFullscreen = false;
//     _isInFullscreen = false;
//     return;
//   }

//   final returnedPos = result?['position'] as Duration?;
//   final shouldPlay = result?['wasPlaying'] as bool? ?? wasPlaying;
//   final seekTo = returnedPos ?? livePos;

//   // Let orientation animation settle
//   await Future.delayed(const Duration(milliseconds: 400));
//   if (!mounted || _isDisposed) {
//     _isReturningFromFullscreen = false;
//     _isInFullscreen = false;
//     return;
//   }

//   // Re-attach listener FIRST, before any operations
//   _controller.addEventsListener(_onPlayerEvent);

//   // Update UI to loading state
//   if (mounted) {
//     setState(() {
//       _isVideoReady = false;
//       _isBuffering = true;
//       _showControls = false;
//     });
//   }

//   try {
//     final String videoUrl = _selectedQuality?.url ?? widget.url;
//     final BetterPlayerDataSource dataSource = videoUrl.endsWith(".m3u8")
//         ? BetterPlayerDataSource(
//             BetterPlayerDataSourceType.network,
//             videoUrl,
//             videoFormat: BetterPlayerVideoFormat.hls,
//             cacheConfiguration: const BetterPlayerCacheConfiguration(
//               useCache: false,
//               maxCacheSize: 0,
//             ),
//           )
//         : BetterPlayerDataSource(
//             BetterPlayerDataSourceType.network,
//             videoUrl,
//             cacheConfiguration: const BetterPlayerCacheConfiguration(
//               useCache: false,
//               maxCacheSize: 0,
//             ),
//           );

//     // setupDataSource disposes old VideoPlayerController internally.
//     // We MUST wait for the 'initialized' event before calling play().
//     await _controller.setupDataSource(dataSource);

//     if (!mounted || _isDisposed) {
//       _isReturningFromFullscreen = false;
//       _isInFullscreen = false;
//       return;
//     }

//     // ✅ KEY FIX: Wait for the new VideoPlayerController to be initialized
//     // before seeking or playing, using a Completer tied to the event listener.
//     final initCompleter = Completer<void>();
    
//     void initListener(BetterPlayerEvent event) {
//       if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
//         if (!initCompleter.isCompleted) initCompleter.complete();
//       }
//     }
    
//     _controller.addEventsListener(initListener);
    
//     // Timeout safety: don't wait forever
//     await initCompleter.future.timeout(
//       const Duration(seconds: 8),
//       onTimeout: () {
//         debugPrint('⚠️ Init timeout — proceeding anyway');
//       },
//     );
    
//     _controller.removeEventsListener(initListener);

//     if (!mounted || _isDisposed) {
//       _isReturningFromFullscreen = false;
//       _isInFullscreen = false;
//       return;
//     }

//     // Now it's safe to seek and play
//     if (seekTo.inSeconds > 0) {
//       try {
//         await _controller.seekTo(seekTo);
//         debugPrint('✅ Sought to: ${seekTo.inSeconds}s');
//       } catch (e) {
//         debugPrint('Seek error: $e');
//       }
//     }

//     try { _controller.setVolume(1.0); } catch (_) {}
//     try { _controller.setSpeed(_speed); } catch (_) {}

//     if (shouldPlay) {
//       try {
//         await _controller.play();
//         debugPrint('✅ Video playing after fullscreen return');
//       } catch (e) {
//         debugPrint('Play error: $e');
//       }
//     }

//     if (mounted) {
//       setState(() {
//         _showControls = true;
//         _isVideoReady = true;
//         _isBuffering = false;
//       });
//     }
//   } catch (e) {
//     debugPrint('❌ Error reinitializing after fullscreen: $e');
//     if (mounted) {
//       setState(() {
//         _isVideoReady = true;
//         _isBuffering = false;
//         _showControls = true;
//       });
//     }
//   }

//   _startHideTimer();
//   await Future.delayed(const Duration(milliseconds: 300));
//   _isReturningFromFullscreen = false;
//   _isInFullscreen = false;
// }
//   Widget _trendingSection2(HomeController controller) {
//     return Obx(() {
//       if (controller.isLoadingTrending.value) {
//         return SizedBox(
//           height: 170.h,
//           child: const Center(
//             child: CircularProgressIndicator(color: Colors.white),
//           ),
//         );
//       }

//       final items = controller.trendingListByIndex(1).take(10).toList();

//       if (items.isEmpty) {
//         return const SizedBox();
//       }

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: Text(
//               'EXPLORE MORE',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           SizedBox(
//             height: 190.h,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 return _trendingCardWithWatchlist(context, items[index]);
//               },
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _trendingCardWithWatchlist(BuildContext context, dynamic item) {
//     final FavoritesController favoritesController =
//         Get.find<FavoritesController>();

//     Map<String, dynamic> data = {};

//     try {
//       data = item is Map<String, dynamic>
//           ? item
//           : Map<String, dynamic>.from(item);
//     } catch (e) {
//       return const SizedBox();
//     }

//     final String id = '${data['_id'] ?? data['id']}';
//     final String title = data['title'] ?? data['movieTitle'] ?? 'No Title';
//     final String imageUrl =
//         data['verticalPosterUrl'] ??
//         data['horizontalBannerUrl'] ??
//         data['image'] ??
//         data['poster'] ??
//         '';
//     final String trailerUrl = data['trailerUrl'] ?? data['videoTrailer'] ?? '';
//     final String movieUrl = data['playUrl'] ?? data['videoMovies'] ?? '';
//     final String subtitle = data['subtitle'] ?? data['genresString'] ?? '';
//     final String dis = data['description'] ?? '';

//     void onCardTap() {
//       debugPrint('🎯 Trending card tapped: $title');

//       if (Get.isRegistered<DetailsController>()) {
//         Get.delete<DetailsController>(force: true);
//       }

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => VideoDetailScreen(
//             key: ValueKey(id),
//             videoId: id,
//             videoTitle: title,
//             image: imageUrl,
//             videoTrailer: trailerUrl.isNotEmpty ? trailerUrl : movieUrl,
//             videoMoives: movieUrl.isNotEmpty ? movieUrl : trailerUrl,
//             subtitle: subtitle,
//             dis: dis,
//             logoImage: data['logoImage'] ?? data['logoUrl'] ?? '',
//             imdbRating:
//                 double.tryParse(data['imdbRating']?.toString() ?? '0') ?? 0,
//             ageRating: data['ageRating'] ?? 'U/A',
//             directorInfo: data['directorInfo'] ?? '',
//             castInfo: data['castInfo'] ?? '',
//             genres:
//                 (data['genres'] as List?)?.map((e) => e.toString()).toList() ??
//                 [],
//             tags:
//                 (data['tags'] as List?)?.map((e) => e.toString()).toList() ??
//                 [],
//           ),
//         ),
//       );
//     }

//     return GestureDetector(
//       onTap: onCardTap,
//       child: Container(
//         width: 110.w,
//         height: 190.h,
//         margin: EdgeInsets.only(right: 12.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8.r),
//               child: SizedBox(
//                 width: 110.w,
//                 height: 150.h,
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(
//                     color: Colors.grey,
//                     child: const Icon(Icons.error),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 6.h),
//             Obx(() {
//               final isFav2 =
//                   id.isNotEmpty && favoritesController.isFavorite(id);
//               return GestureDetector(
//                 onTap: () {
//                   if (id.isEmpty) return;
//                   favoritesController.toggleFavorite(
//                     FavoriteItem(
//                       id: id,
//                       title: title,
//                       image: imageUrl,
//                       videoTrailer: trailerUrl,
//                       subtitle: subtitle,
//                       videoMovies: movieUrl,
//                       logoImage: imageUrl,
//                       description: dis,
//                     ),
//                   );
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(4),
//                     color: isFav2
//                         ? Colors.green.withOpacity(0.2)
//                         : Colors.white.withOpacity(0.05),
//                     border: Border.all(
//                       color: isFav2 ? Colors.green : Colors.white24,
//                       width: 0.8,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         isFav2 ? Icons.check : Icons.add,
//                         size: 14,
//                         color: isFav2 ? Colors.greenAccent : Colors.white,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         isFav2 ? "Added" : "Watchlist",
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: isFav2 ? Colors.greenAccent : Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _similarVideosSection() {
//     final FavoritesController favoritesController =
//         Get.find<FavoritesController>();

//     Widget watchlistButton({
//       required String videoId,
//       required String title,
//       required String imageUrl,
//       required String videoTrailer,
//       required String videoMovies,
//       required String subtitle,
//       required String dis,
//     }) {
//       return Obx(() {
//         final isFav =
//             videoId.isNotEmpty && favoritesController.isFavorite(videoId);

//         return GestureDetector(
//           onTap: () {
//             if (videoId.isEmpty) return;

//             favoritesController.toggleFavorite(
//               FavoriteItem(
//                 id: videoId,
//                 title: title,
//                 image: imageUrl,
//                 videoTrailer: videoTrailer,
//                 subtitle: subtitle,
//                 videoMovies: videoMovies,
//                 logoImage: imageUrl,
//                 description: dis,
//               ),
//             );
//           },
//           child: AnimatedContainer(
//             width: double.infinity,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(4),
//               gradient: isFav
//                   ? LinearGradient(
//                       colors: [
//                         Colors.green.withOpacity(0.25),
//                         Colors.green.withOpacity(0.1),
//                       ],
//                     )
//                   : LinearGradient(
//                       colors: [
//                         Colors.white.withOpacity(0.08),
//                         Colors.white.withOpacity(0.02),
//                       ],
//                     ),
//               border: Border.all(
//                 color: isFav
//                     ? Colors.green.withOpacity(0.6)
//                     : Colors.white.withOpacity(0.2),
//                 width: 0.8,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 250),
//                   transitionBuilder: (child, animation) {
//                     return ScaleTransition(
//                       scale: animation,
//                       child: FadeTransition(opacity: animation, child: child),
//                     );
//                   },
//                   child: Icon(
//                     isFav ? Icons.check_rounded : Icons.add_rounded,
//                     key: ValueKey(isFav),
//                     color: isFav ? Colors.greenAccent : Colors.white,
//                     size: 16,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 AnimatedDefaultTextStyle(
//                   duration: const Duration(milliseconds: 250),
//                   style: TextStyle(
//                     color: isFav ? Colors.greenAccent : Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.3,
//                   ),
//                   child: Text(isFav ? "Added" : "Watchlist"),
//                 ),
//               ],
//             ),
//           ),
//         );
//       });
//     }

//     void navigateToDetailsScreen({
//       required String videoId,
//       required String title,
//       required String imageUrl,
//       required String videoTrailer,
//       required String videoMovies,
//       required String subtitle,
//       required String dis,
//       String logoImage = '',
//       double imdbRating = 0.0,
//       String ageRating = 'U/A',
//       String directorInfo = '',
//       String castInfo = '',
//       List<String> genres = const [],
//       List<String> tags = const [],
//       String language = '',
//       int duration = 0,
//       int releaseYear = 0,
//       String tagline = '',
//       String fullStoryline = '',
//     }) {
//       try {
//         _controller.pause();
//         _controller.setVolume(0);
//       } catch (_) {}

//       if (Get.isRegistered<DetailsController>()) {
//         Get.delete<DetailsController>(force: true);
//       }

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => VideoDetailScreen(
//             key: ValueKey(videoId),
//             videoId: videoId,
//             videoTitle: title,
//             image: imageUrl,
//             videoTrailer: videoTrailer.isNotEmpty ? videoTrailer : videoMovies,
//             videoMoives: videoMovies.isNotEmpty ? videoMovies : videoTrailer,
//             subtitle: subtitle,
//             dis: dis,
//             logoImage: logoImage,
//             imdbRating: imdbRating,
//             ageRating: ageRating,
//             directorInfo: directorInfo,
//             castInfo: castInfo,
//             genres: genres,
//             tags: tags,
//             language: language,
//             duration: duration,
//             releaseYear: releaseYear,
//             tagline: tagline,
//             fullStoryline: fullStoryline,
//           ),
//         ),
//       );
//     }

//     if (widget.similarVideos.isNotEmpty) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 14, top: 14, bottom: 8),
//             child: Text(
//               "Similar Videos",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 190,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.only(left: 14),
//               itemCount: widget.similarVideos.length,
//               itemBuilder: (context, index) {
//                 final item = widget.similarVideos[index];

//                 final title = item['title']?.toString() ?? '';
//                 final imageUrl = item['image']?.toString() ?? '';
//                 final videoId = item['_id']?.toString() ?? '';

//                 final videoTrailer =
//                     (item['videoTrailer']?.toString().isNotEmpty == true
//                             ? item['videoTrailer']
//                             : item['hlsUrl'] ??
//                                   item['playUrl'] ??
//                                   item['url'] ??
//                                   '')
//                         .toString();

//                 final videoMovies =
//                     (item['videoMovies']?.toString().isNotEmpty == true
//                             ? item['videoMovies']
//                             : item['playUrl'] ?? item['hlsUrl'] ?? videoTrailer)
//                         .toString();

//                 final subtitle = item['subtitle']?.toString() ?? '';
//                 final dis = item['dis']?.toString() ?? '';

//                 return GestureDetector(
//                   onTap: () {
//                     debugPrint('🎯 Similar video tapped: $title');

//                     try {
//                       _controller.pause();
//                       _controller.setVolume(0);
//                     } catch (_) {}

//                     if (Get.isRegistered<DetailsController>()) {
//                       Get.delete<DetailsController>(force: true);
//                     }

//                     final urlToPlay = videoMovies.isNotEmpty
//                         ? videoMovies
//                         : videoTrailer;

//                     if (urlToPlay.isEmpty) {
//                       debugPrint('❌ No URL for similar video');
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Video URL not available'),
//                         ),
//                       );
//                       return;
//                     }
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => VideoScreen(
//                           url: urlToPlay,
//                           title: title,
//                           image: imageUrl,
//                           videoId: videoId,
//                           movieDuration:
//                               int.tryParse(
//                                 item['duration']?.toString() ?? '0',
//                               ) ??
//                               0,
//                           similarVideos: widget.similarVideos,
//                           vastTagUrl: _resolvedVastUrl,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     width: 110,
//                     margin: const EdgeInsets.only(right: 10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: _buildImage(imageUrl, 170, 110),
//                         ),
//                         const SizedBox(height: 6),
//                         watchlistButton(
//                           videoId: videoId,
//                           title: title,
//                           imageUrl: imageUrl,
//                           videoTrailer: videoTrailer,
//                           videoMovies: videoMovies,
//                           subtitle: subtitle,
//                           dis: dis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     }
//     return Obx(() {
//       final list = _homeController.trendingList;

//       if (list.isEmpty) {
//         return const Padding(
//           padding: EdgeInsets.all(16),
//           child: Text(
//             "No videos available",
//             style: TextStyle(color: Colors.white54),
//           ),
//         );
//       }
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 14, top: 14, bottom: 8),
//             child: Text(
//               "Trending Videos",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 220,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.only(left: 14),
//               itemCount: list.length,
//               itemBuilder: (context, index) {
//                 final item = list[index];
//                 final title = item['title']?.toString() ?? '';
//                 final imageUrl = item['image']?.toString() ?? '';
//                 final videoId = item['_id']?.toString() ?? '';
//                 final videoTrailer =
//                     (item['videoTrailer']?.toString().isNotEmpty == true
//                             ? item['videoTrailer']
//                             : item['hlsUrl'] ??
//                                   item['playUrl'] ??
//                                   item['url'] ??
//                                   '')
//                         .toString();
//                 final videoMovies =
//                     (item['videoMovies']?.toString().isNotEmpty == true
//                             ? item['videoMovies']
//                             : item['playUrl'] ?? item['hlsUrl'] ?? videoTrailer)
//                         .toString();
//                 final subtitle = item['subtitle']?.toString() ?? '';
//                 final dis = item['dis']?.toString() ?? '';
//                 return GestureDetector(
//                   onTap: () {
//                     navigateToDetailsScreen(
//                       videoId: videoId,
//                       title: title,
//                       imageUrl: imageUrl,
//                       videoTrailer: videoTrailer,
//                       videoMovies: videoMovies,
//                       subtitle: subtitle,
//                       dis: dis,
//                       logoImage: item['logoImage']?.toString() ?? imageUrl,
//                       imdbRating:
//                           double.tryParse(
//                             item['imdbRating']?.toString() ?? '0',
//                           ) ??
//                           0.0,
//                       ageRating: item['ageRating']?.toString() ?? 'U/A',
//                       directorInfo: item['directorInfo']?.toString() ?? '',
//                       castInfo: item['castInfo']?.toString() ?? '',
//                       genres:
//                           (item['genres'] as List<dynamic>?)?.cast<String>() ??
//                           [],
//                       tags:
//                           (item['tags'] as List<dynamic>?)?.cast<String>() ??
//                           [],
//                       language: item['language']?.toString() ?? '',
//                       duration:
//                           int.tryParse(item['duration']?.toString() ?? '0') ??
//                           0,
//                       releaseYear:
//                           int.tryParse(
//                             item['releaseYear']?.toString() ?? '0',
//                           ) ??
//                           0,
//                       tagline: item['tagline']?.toString() ?? '',
//                       fullStoryline: item['fullStoryline']?.toString() ?? '',
//                     );
//                   },
//                   child: Container(
//                     width: 110,
//                     margin: const EdgeInsets.only(right: 10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: _buildImage(imageUrl, 170, 110),
//                         ),
//                         const SizedBox(height: 6),
//                         watchlistButton(
//                           videoId: videoId,
//                           title: title,
//                           imageUrl: imageUrl,
//                           videoTrailer: videoTrailer,
//                           videoMovies: videoMovies,
//                           subtitle: subtitle,
//                           dis: dis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _buildImage(String url, double height, double width) {
//     final placeholder = Container(
//       height: height,
//       width: width,
//       color: Colors.grey[850],
//       child: const Icon(Icons.movie, color: Colors.white54, size: 32),
//     );

//     if (url.startsWith('http')) {
//       return Image.network(
//         url,
//         height: height,
//         width: width,
//         fit: BoxFit.cover,
//         cacheHeight: height.toInt() * 2,
//         cacheWidth: width.toInt() * 2,
//         errorBuilder: (_, __, ___) => placeholder,
//         loadingBuilder: (_, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return placeholder;
//         },
//       );
//     }
//     return placeholder;
//   }

//   Widget _seekOverlay(bool right) {
//     final show = right ? _showSeekRight : _showSeekLeft;
//     return IgnorePointer(
//       child: AnimatedOpacity(
//         opacity: show ? 1 : 0,
//         duration: const Duration(milliseconds: 120),
//         child: AnimatedScale(
//           scale: show ? 1 : 0.9,
//           duration: const Duration(milliseconds: 120),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.55),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   right ? Icons.fast_forward : Icons.fast_rewind,
//                   color: Colors.white,
//                   size: 22,
//                 ),
//                 const SizedBox(width: 6),
//                 const Text(
//                   "10 sec",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _circleButton(IconData icon, {required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: () {
//         if (_isLocked || _isDisposed) return;
//         onTap();
//         _startHideTimer();
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.65),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.white, size: 28),
//       ),
//     );
//   }

//   String _format(Duration d) {
//     String two(int n) => n.toString().padLeft(2, "0");
//     final h = d.inHours;
//     final m = d.inMinutes.remainder(60);
//     final s = d.inSeconds.remainder(60);
//     if (h > 0) return "${two(h)}:${two(m)}:${two(s)}";
//     return "${two(m)}:${two(s)}";
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _progressSaveTimer?.cancel();
//     _hideTimer?.cancel();
//     brightnessTimer?.cancel();
//     volumeTimer?.cancel();
//     _unlockHideTimer?.cancel();
//     _skipIntroCheckTimer?.cancel();

//     WidgetsBinding.instance.removeObserver(this);
//     routeObserver.unsubscribe(this);
//     WakelockPlus.disable();
//     VolumeController().showSystemUI = true;

//     _disposeController();

//     super.dispose();
//   }

//   @override
//   void deactivate() {
//     // try {
//     //   if (!_controllerDisposed) {
//     //     _controller.removeEventsListener(_onPlayerEvent);
//     //   }
//     // } catch (e) {
//     //   debugPrint("Deactivation error: $e");
//     // }
//     super.deactivate();
//   }

//   @override
//   Widget build(BuildContext context) {
//      if (!_isPlayerInitialized) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(color: Colors.red),
//         ),
//       );
//     }
//     final isPlaying = _controller.isPlaying() ?? false;

//     return WillPopScope(
//       onWillPop: () async {
//         await _handleBackPress();
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Column(
//             children: [
//               AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: Stack(
//                   children: [
//                     BetterPlayer(controller: _controller),
//                     if (!_isVideoReady)
//                       Positioned.fill(
//                         child: Container(
//                           color: Colors.black,
//                           child: const Center(
//                             child: CircularProgressIndicator(
//                               strokeWidth: 3,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ),
//                       ),

//                     if (_isBackPressed || !mounted)
//                       Positioned.fill(child: Container(color: Colors.black)),
//                     if (_showAd)
//                       Positioned.fill(
//                         child: AdMobRewardOverlay(
//                           onAdFinished: _startVideoAfterAd,
//                           vastTagUrl: _resolvedVastUrl,
//                         ),
//                       ),
//                     if (!_showAd) ...[
//                       Positioned.fill(
//                         child: GestureDetector(
//                           behavior: HitTestBehavior.translucent,
//                           onTap: _toggleControls,
//                           child: Container(color: Colors.transparent),
//                         ),
//                       ),
//                       if (!_isLocked)
//                         Positioned.fill(
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: GestureDetector(
//                                   behavior: HitTestBehavior.translucent,
//                                   onDoubleTap: () async {
//                                     _showSeekEffect(false);
//                                     await _seekBy(-10);
//                                   },
//                                   child: const SizedBox.expand(),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: GestureDetector(
//                                   behavior: HitTestBehavior.translucent,
//                                   onDoubleTap: () async {
//                                     _showSeekEffect(true);
//                                     await _seekBy(10);
//                                   },
//                                   child: const SizedBox.expand(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       Positioned.fill(
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: GestureDetector(
//                                 behavior: HitTestBehavior.translucent,
//                                 onVerticalDragUpdate: (details) async {
//                                   if (!_isVideoReady) return;
//                                   double delta = details.primaryDelta! / 300;
//                                   brightness = (brightness - delta).clamp(
//                                     0.0,
//                                     1.0,
//                                   );
//                                   await ScreenBrightness().setScreenBrightness(
//                                     brightness,
//                                   );
//                                   if (!_isDisposed)
//                                     setState(() => showBrightnessUI = true);
//                                   brightnessTimer?.cancel();
//                                   brightnessTimer = Timer(
//                                     const Duration(milliseconds: 800),
//                                     () {
//                                       if (mounted && !_isDisposed)
//                                         setState(
//                                           () => showBrightnessUI = false,
//                                         );
//                                     },
//                                   );
//                                 },
//                                 child: const SizedBox.expand(),
//                               ),
//                             ),
//                             Expanded(
//                               child: GestureDetector(
//                                 behavior: HitTestBehavior.translucent,
//                                 onVerticalDragUpdate: (details) async {
//                                   if (!_isVideoReady) return;
//                                   double delta = details.primaryDelta! / 300;
//                                   volume = (volume - delta).clamp(0.0, 1.0);
//                                   VolumeController().setVolume(volume);
//                                   if (!_isDisposed)
//                                     setState(() => showVolumeUI = true);
//                                   volumeTimer?.cancel();
//                                   volumeTimer = Timer(
//                                     const Duration(milliseconds: 800),
//                                     () {
//                                       if (mounted && !_isDisposed)
//                                         setState(() => showVolumeUI = false);
//                                     },
//                                   );
//                                 },
//                                 child: const SizedBox.expand(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//     //                    if (_showControls && !_isLocked && widget.isWebSeries)
//     // _buildNextEpisodeButton(),
//                       //  _buildNextEpisodeButton(),
//           if (_isBuffering || _isSeeking)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.4),
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     color: Colors.red,
//                   ),
//                 ),
//               ),
//             ),
//                       Positioned(
//                         left: 20,
//                         top: 0,
//                         bottom: 0,
//                         child: Center(child: _seekOverlay(false)),
//                       ),
//                       Positioned(
//                         right: 20,
//                         top: 0,
//                         bottom: 0,
//                         child: Center(child: _seekOverlay(true)),
//                       ),
//                       if (_isVideoReady && (_isBuffering || _isSeeking))
//                         Positioned.fill(
//                           child: Container(
//                             color: Colors.black.withOpacity(0.4),
//                             child: const Center(
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 3,
//                                 color: Colors.red,
//                               ),
//                             ),
//                           ),
//                         ),
//                       if (_showControls && !_isLocked && _isVideoReady)
//                         Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               _circleButton(
//                                 Icons.replay_10,
//                                 onTap: () => _seekBy(-10),
//                               ),
//                               const SizedBox(width: 28),
//                               _circleButton(
//                                 isPlaying ? Icons.pause : Icons.play_arrow,
//                                 onTap: _togglePlayPause,
//                               ),
//                               const SizedBox(width: 28),
//                               _circleButton(
//                                 Icons.forward_10,
//                                 onTap: () => _seekBy(10),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (_showControls && !_isLocked)
//                         Positioned(
//                           top: 0,
//                           left: 0,
//                           right: 0,
//                           child: SafeArea(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 6,
//                               ),
//                               child: Row(
//                                 children: [
//                                   IconButton(
//                                     onPressed: _handleBackPress,
//                                     icon: const Icon(
//                                       Icons.arrow_back,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       widget.title,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   StreamBuilder<GoogleCastSession?>(
//                                     stream: GoogleCastSessionManager
//                                         .instance
//                                         .currentSessionStream,
//                                     builder: (context, snapshot) {
//                                       final connected =
//                                           GoogleCastSessionManager
//                                               .instance
//                                               .connectionState ==
//                                           GoogleCastConnectState.connected;
//                                       return IconButton(
//                                         onPressed: connected
//                                             ? GoogleCastSessionManager
//                                                   .instance
//                                                   .endSessionAndStopCasting
//                                             : _openCastDialog,
//                                         icon: Icon(
//                                           connected
//                                               ? Icons.cast_connected
//                                               : Icons.cast,
//                                           color: connected
//                                               ? Colors.blue
//                                               : Colors.white,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   IconButton(
//                                     onPressed: _toggleLock,
//                                     icon: const Icon(
//                                       Icons.lock_open,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: _openSettingsDialog,
//                                     icon: const Icon(
//                                       Icons.settings,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: _openFullscreen,
//                                     icon: const Icon(
//                                       Icons.fullscreen,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       if (_showControls && !_isLocked && _isVideoReady)
//                         Positioned(
//                           bottom: 8,
//                           left: 14,
//                           right: 14,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Slider(
//                                 activeColor: Colors.red,
//                                 inactiveColor: Colors.white24,
//                                 value: min(
//                                   _position.inSeconds.toDouble(),
//                                   _duration.inSeconds == 0
//                                       ? 1
//                                       : _duration.inSeconds.toDouble(),
//                                 ),
//                                 max: _duration.inSeconds == 0
//                                     ? 1
//                                     : _duration.inSeconds.toDouble(),
//                                 onChangeStart: (_) =>
//                                     setState(() => _isDragging = true),
//                                 onChanged: (value) => setState(
//                                   () => _position = Duration(
//                                     seconds: value.toInt(),
//                                   ),
//                                 ),
//                                 onChangeEnd: (value) async {
//                                   setState(() => _isDragging = false);
//                                   await _controller.seekTo(
//                                     Duration(seconds: value.toInt()),
//                                   );
//                                   _startHideTimer();
//                                 },
//                               ),
//                               Text(
//                                 "${_format(_position)} / ${_format(_duration)}",
//                                 style: const TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (_isLocked && _showUnlockButton)
//                         Positioned(
//                           right: 18,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: GestureDetector(
//                               onTap: _toggleLock,
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.7),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.lock_open,
//                                   color: Colors.white,
//                                   size: 28,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       if (showBrightnessUI)
//                         Positioned(
//                           left: 20,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: _sideIndicator(
//                               Icons.brightness_6,
//                               brightness,
//                             ),
//                           ),
//                         ),
//                       if (showVolumeUI)
//                         Positioned(
//                           right: 20,
//                           top: 0,
//                           bottom: 0,
//                           child: Center(
//                             child: _sideIndicator(Icons.volume_up, volume),
//                           ),
//                         ),
//                     ],
//                     if (_showSkipIntroButton &&
//                         !_isLocked &&
//                         _skipIntroData != null)
//                       Positioned(
//                         bottom: 20.h,
//                         right: 20.w,
//                         child: GestureDetector(
//                           onTap: () {
//                             debugPrint('Skip button tapped!');
//                             _skipIntro();
//                           },
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 10.w,
//                               vertical: 5.h,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFFC1BDBD), Color(0xFFECEAEA)],
//                               ),
//                               borderRadius: BorderRadius.circular(30.r),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.skip_next,
//                                   color: Colors.black,
//                                   size: 15.sp,
//                                 ),
//                                 SizedBox(width: 8.w),
//                                 Text(
//                                   'Skip Intro',
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 10.sp,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
          
// Expanded(
//   child: SingleChildScrollView(
//     physics: const BouncingScrollPhysics(),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         widget.isWebSeries
//             ? _buildWebSeriesSection()
//             : _similarVideosSection(),
//         if (!widget.isWebSeries)
//           _trendingSection2(_homeController),
//         SizedBox(height: 20.h), // Add bottom padding
//       ],
//     ),
//   ),
// ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/_session_manager/cast_session_manager.dart';
import 'package:flutter_chrome_cast/entities/cast_session.dart';
import 'package:flutter_chrome_cast/enums/connection_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/ad/ads_screen.dart';
import 'package:gutrgoopro/home/ad/controller/ad_controller.dart';
import 'package:gutrgoopro/home/ad/responce/ad_scheduler.dart';
import 'package:gutrgoopro/home/cast/cast.dart';
import 'package:gutrgoopro/home/getx/details_controller.dart';
import 'package:gutrgoopro/home/model/web_series_model.dart';
import 'package:gutrgoopro/home/screen/details_screen.dart';
import 'package:gutrgoopro/home/service/continue_watching_service.dart';
import 'package:gutrgoopro/home/service/video_skip_service.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:http/http.dart' as http;
import 'package:pip/pip.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  final String title;
  final String image;
  final List<Map<String, String>> similarVideos;
  final String? vastTagUrl;
  final String? videoId;
  final String? seriesId;
  final VoidCallback? onBackPressed;
  final Map<String, dynamic>? nextEpisodeData;
  final int movieDuration;
  final bool isWebSeries;
  final List<Map<String, dynamic>> seasons;
  final SkipIntroData? skipIntroData;
  final bool startInFullscreen;
  final int savedPosition; 

  const VideoScreen({
    super.key,
    required this.url,
    required this.title,
    this.similarVideos = const [],
    required this.image,
    this.vastTagUrl,
    this.videoId,
    this.seriesId,
     this.savedPosition = 0,
    this.movieDuration = 0,
    this.onBackPressed,
    this.nextEpisodeData,
    this.isWebSeries = false,
    this.seasons = const [],
    this.skipIntroData,
    this.startInFullscreen = false,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with RouteAware, WidgetsBindingObserver {
  late BetterPlayerController _controller;
  bool _isPlayerInitialized = false;
  final _pip = Pip();
  late final FavoritesController favoritesController;
  Timer? _progressSaveTimer;
  final ContinueWatchingService _cwService = ContinueWatchingService();
  late AdController _adController;
  String? _resolvedVastUrl;
  bool _isDisposed = false;
  bool _controllerDisposed = false;
  bool _isBackPressed = false;
  bool _showAd = false;
  bool _adShownOnce = false;
  SkipIntroData? _skipIntroData;
  bool _showSkipIntroButton = false;
  Timer? _skipIntroCheckTimer;
  bool _skipIntroShown = false;
  Timer? _hideTimer;
  Timer? _unlockHideTimer;
  bool _showControls = true;
  bool _isDragging = false;
  bool _isLocked = false;
  bool _showUnlockButton = false;
  double brightness = 0.5;
  double volume = 0.5;
  bool showBrightnessUI = false;
  bool showVolumeUI = false;
  Timer? brightnessTimer;
  Timer? volumeTimer;
  int _selectedSeasonIndex = 0;
  final Map<int, int> _visibleEpisodesCount = {};
  static const int _initialEpisodeCount = 5;
  double _speed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isBuffering = true;
  bool _isSeeking = false;
  bool _isVideoReady = false;
  bool _isReturningFromFullscreen = false;
  bool _isInFullscreen = false;
  bool _showSeekLeft = false;
  bool _showSeekRight = false;
  List<HlsQuality> _qualities = [];
  HlsQuality? _selectedQuality;
  AdScheduler? _adScheduler;
  bool _adInProgress = false;
  late final HomeController _homeController;
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    _loadSkipIntroData();
    _initPlayer();
    _isPlayerInitialized = true;

    if (widget.videoId == null || widget.videoId!.isEmpty) {
      debugPrint('⚠️ WARNING: videoId is null or empty!');
    }

    _startProgressSaveTimer();
    favoritesController = Get.find<FavoritesController>();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _homeController = Get.find<HomeController>();
    _adController = Get.find<AdController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _adController.ensureLoaded();
      _adScheduler = _adController.createScheduler();
      _loadQualities();
      _startHideTimer();
      _triggerStartAd();
    });
  }

  void _triggerStartAd() {
    debugPrint('🔍 Checking for start ad...');
    final startAd = _adScheduler?.getStartAd();
    if (startAd != null) {
      debugPrint('📺 Start ad found: ${startAd.vastUrl}');
      _showAdOverlay(startAd.vastUrl!);
    } else {
      debugPrint('▶️ No start ad, playing video directly');
      _startVideoPlayback();
    }
  }

  void _showAdOverlay(String vastUrl) {
  if (_isDisposed || !mounted) {
    debugPrint('Cannot show ad - disposed or not mounted');
    _startVideoPlayback();
    return;
  }
  
  _adInProgress = true;
  _resolvedVastUrl = vastUrl;

  // Pause video while ad plays
  try {
    if (_controller.isPlaying() == true) {
      _controller.pause();
    }
    _controller.setVolume(0);
  } catch (e) {
    debugPrint('Error pausing video for ad: $e');
  }

  setState(() => _showAd = true);
}
  Future<void> _loadSkipIntroData() async {
    if (widget.skipIntroData != null &&
        widget.skipIntroData!.end > widget.skipIntroData!.start) {
      setState(() {
        _skipIntroData = widget.skipIntroData;
      });
      return;
    }

    if (widget.seriesId != null && widget.seriesId!.isNotEmpty) {
      final service = SkipIntroService();
      final data = await service.fetchSkipIntro(
        widget.videoId ?? '',
        seriesId: widget.seriesId,
      );
      if (mounted && data != null && data.end > data.start) {
        setState(() => _skipIntroData = data);
      }
      return;
    }

    if (widget.seriesId == null || widget.seriesId!.isEmpty) {
      final service = SkipIntroService();
      final data = await service.fetchSkipIntro(widget.videoId ?? '');
      if (mounted && data != null && data.end > data.start) {
        setState(() => _skipIntroData = data);
      }
    }
  }

  Widget _buildWebSeriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        _buildSeasonSelector(),
        SizedBox(height: 4.h),
        _buildEpisodesListHotstar(),
      ],
    );
  }

  Widget _buildSeasonSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: List.generate(widget.seasons.length, (i) {
          final season = widget.seasons[i];
          final seasonNumber = season['season'] ?? (i + 1);
          final label = 'Season $seasonNumber';
          final isSelected = _selectedSeasonIndex == i;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedSeasonIndex = i;
              _visibleEpisodesCount.remove(i);
            }),
            child: Container(
              margin: EdgeInsets.only(right: 24.w),
              padding: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEpisodesListHotstar() {
    if (widget.seasons.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20.h),
        child: Center(
          child: Text(
            'Episodes coming soon...',
            style: TextStyle(color: Colors.white54, fontSize: 14.sp),
          ),
        ),
      );
    }

    final currentSeason = widget.seasons[_selectedSeasonIndex];
    final episodes = (currentSeason['episodes'] as List<dynamic>? ?? []);

    if (episodes.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20.h),
        child: Center(
          child: Text(
            'No episodes available',
            style: TextStyle(color: Colors.white54, fontSize: 14.sp),
          ),
        ),
      );
    }

    final visibleCount =
        _visibleEpisodesCount[_selectedSeasonIndex] ?? _initialEpisodeCount;
    final showingAll = visibleCount >= episodes.length;
    final displayEpisodes = episodes.take(visibleCount).toList();

    return Column(
      children: [
        ...displayEpisodes.asMap().entries.map((entry) {
          final index = entry.key;
          final ep = entry.value as Map<String, dynamic>;
          final epNumber = ep['episodeNumber'] ?? (index + 1);
          return _buildHotstarEpisodeCard(ep, epNumber);
        }),
        if (episodes.length > _initialEpisodeCount)
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (showingAll) {
                    _visibleEpisodesCount[_selectedSeasonIndex] =
                        _initialEpisodeCount;
                  } else {
                    _visibleEpisodesCount[_selectedSeasonIndex] =
                        episodes.length;
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showingAll
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      showingAll ? 'View Less' : 'View More',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildHotstarEpisodeCard(
    Map<String, dynamic> episode,
    int episodeNumber,
  ) {
    final title = episode['title']?.toString() ?? '';
    final description = episode['description']?.toString() ?? '';
    final duration = episode['videoFile'] != null
        ? (episode['videoFile']['duration'] as int? ?? 0)
        : 0;

    String thumbnail = '';
    if (episode['videoFile'] != null) {
      thumbnail = episode['videoFile']['thumbnailUrl']?.toString() ?? '';
    }
    if (thumbnail.isEmpty) {
      thumbnail = widget.image;
    }

    String playUrl = '';
    if (episode['videoFile'] != null) {
      playUrl = episode['videoFile']['url']?.toString() ?? '';
    }

    final skipIntroRaw = episode['skipIntro'];
    SkipIntro? skipIntro;
    if (skipIntroRaw != null && skipIntroRaw is Map<String, dynamic>) {
      skipIntro = SkipIntro(
        start: (skipIntroRaw['start'] as num?)?.toInt() ?? 0,
        end: (skipIntroRaw['end'] as num?)?.toInt() ?? 0,
      );
    }

    final hasValidVideo = playUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!hasValidVideo) return;
        final epId = episode['_id']?.toString() ?? episode['id']?.toString() ?? '';
        _playEpisode(
          playUrl,
          title,
          thumbnail,
          epId,
          duration,
          skipIntro,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130.w,
                  height: 80.h,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: thumbnail.isNotEmpty
                            ? Image.network(
                                thumbnail,
                                width: 130.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                                cacheWidth: 260,
                                cacheHeight: 160,
                                errorBuilder: (_, __, ___) =>
                                    _episodeThumbnailPlaceholder(),
                              )
                            : _episodeThumbnailPlaceholder(),
                      ),
                      if (!hasValidVideo)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              color: Colors.black.withOpacity(0.7),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time_filled,
                                      color: Colors.orange, size: 24.sp),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Coming Soon',
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (hasValidVideo)
                        Positioned(
                          bottom: 6.h,
                          left: 6.w,
                          child: Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: Icon(Icons.play_arrow,
                                color: Colors.white, size: 14.sp),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: hasValidVideo
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!hasValidVideo)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                    color: Colors.orange.withOpacity(0.5)),
                              ),
                              child: Text(
                                'Coming Soon',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Episode $episodeNumber',
                        style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                      ),
                      if (duration > 0)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            '${duration ~/ 60} min',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 10.sp),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                description,
                style: TextStyle(
                    color: hasValidVideo ? Colors.white60 : Colors.white38,
                    fontSize: 11.sp,
                    height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _episodeThumbnailPlaceholder() => Container(
        width: 130.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(Icons.play_circle_outline,
            color: Colors.white38, size: 28.sp),
      );

  void _playEpisode(String url, String title, String thumbnail, String? episodeId,
      int duration, SkipIntro? skipIntro) {
    Map<String, dynamic>? nextEpisodeData;

    if (widget.seasons.isNotEmpty && episodeId != null) {
      for (int seasonIdx = 0; seasonIdx < widget.seasons.length; seasonIdx++) {
        final season = widget.seasons[seasonIdx];
        final episodes = season['episodes'] as List? ?? [];

        for (int epIdx = 0; epIdx < episodes.length; epIdx++) {
          final ep = episodes[epIdx] as Map<String, dynamic>;
          if (ep['id']?.toString() == episodeId) {
            if (epIdx + 1 < episodes.length) {
              final nextEp = episodes[epIdx + 1];
              nextEpisodeData = {
                'id': nextEp['id'],
                'title': nextEp['title'],
                'url': nextEp['playUrl'],
                'image': nextEp['thumbnailUrl'],
                'duration': nextEp['duration'],
                'episodeNumber': nextEp['episodeNumber'],
                'nextEpisode': epIdx + 2 < episodes.length
                    ? {
                        'id': episodes[epIdx + 2]['id'],
                        'title': episodes[epIdx + 2]['title'],
                        'url': episodes[epIdx + 2]['playUrl'],
                      }
                    : null,
              };
            } else if (seasonIdx + 1 < widget.seasons.length) {
              final nextSeason = widget.seasons[seasonIdx + 1];
              final nextSeasonEpisodes = nextSeason['episodes'] as List? ?? [];
              if (nextSeasonEpisodes.isNotEmpty) {
                final nextEp = nextSeasonEpisodes[0];
                nextEpisodeData = {
                  'id': nextEp['id'],
                  'title': nextEp['title'],
                  'url': nextEp['playUrl'],
                  'image': nextEp['thumbnailUrl'],
                  'duration': nextEp['duration'],
                  'episodeNumber': nextEp['episodeNumber'],
                };
              }
            }
            break;
          }
        }
        if (nextEpisodeData != null) break;
      }
    }

    _isDisposed = true;
    _progressSaveTimer?.cancel();
    _hideTimer?.cancel();
    _disposeController();

    if (!mounted) return;

    SkipIntroData? skipIntroData;
    if (skipIntro != null && skipIntro.end > skipIntro.start) {
      skipIntroData = SkipIntroData(start: skipIntro.start, end: skipIntro.end);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VideoScreen(
          url: url,
          title: '${widget.title} - $title',
          image: thumbnail.isNotEmpty ? thumbnail : widget.image,
          similarVideos: widget.similarVideos,
          vastTagUrl: widget.vastTagUrl,
          videoId: episodeId,
          seriesId: widget.videoId,
          movieDuration: duration,
          isWebSeries: true,
          seasons: widget.seasons,
          nextEpisodeData: nextEpisodeData,
          skipIntroData: skipIntroData,
        ),
      ),
    );
  }

  void _checkForSkipIntro() {
    if (_skipIntroData == null) return;
    if (_skipIntroShown) return;

    final currentSec = _position.inSeconds;
    final isInSkipRange =
        currentSec >= _skipIntroData!.start && currentSec < _skipIntroData!.end;

    if (isInSkipRange != _showSkipIntroButton && mounted) {
      setState(() {
        _showSkipIntroButton = isInSkipRange;
      });
    }

    if (currentSec >= _skipIntroData!.end && _showSkipIntroButton) {
      setState(() {
        _showSkipIntroButton = false;
        _skipIntroShown = true;
      });
    }
  }

  Future<void> _skipIntro() async {
    if (_skipIntroData == null) return;

    setState(() {
      _showSkipIntroButton = false;
      _skipIntroShown = true;
    });

    try {
      if (_isSeeking) return;
      await _controller.seekTo(Duration(seconds: _skipIntroData!.end));
      if (_controller.isPlaying() == true) {
        await _controller.play();
      }
      _startHideTimer();
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  void _startProgressSaveTimer() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isDisposed && mounted) _saveWatchProgress();
    });
  }

  Future<void> _saveWatchProgress() async {
    final id = widget.videoId ?? '';
    if (id.isEmpty) return;

    final v = _controller.videoPlayerController?.value;
    if (v == null) return;

    final watchedSec = v.position.inSeconds;
    final totalSec = v.duration?.inSeconds ?? widget.movieDuration;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("continue_${widget.videoId}", watchedSec);

    if (watchedSec < 5 || totalSec < 10) return;

    try {
      final token = _homeController.userToken.value;
      if (token.isEmpty) return;

      await _cwService.updateWatchProgress(
        token: token,
        movieId: id,
        watchedTime: watchedSec,
        duration: totalSec,
        isCompleted: (watchedSec / totalSec) > 0.9,
      );
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _resolveAdUrl() {
    if (widget.vastTagUrl != null && widget.vastTagUrl!.isNotEmpty) {
      _resolvedVastUrl = widget.vastTagUrl;
      return;
    }

    final activeAd = _adController.activePrerollAd.value;
    if (activeAd != null &&
        activeAd.isActive == true &&
        activeAd.vastUrl != null &&
        activeAd.vastUrl!.isNotEmpty) {
      _resolvedVastUrl = activeAd.vastUrl;
    } else {
      _resolvedVastUrl = null;
    }
  }

  void _startVideoAfterAd() {
    if (_isDisposed) return;
    _adInProgress = false;

    setState(() => _showAd = false);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isDisposed || !mounted) return;
      try {
        _controller.setVolume(1.0);
        _controller.play();
        if (widget.startInFullscreen) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_isDisposed) _openFullscreen();
          });
        }
      } catch (e) {
        debugPrint('Error resuming video: $e');
      }
    });
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (!mounted || _isDisposed) return;

    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (mounted) {
        setState(() => _isVideoReady = true);
      }
      return;
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      _checkScheduledAds(isFinished: true);
      try {
        _controller.seekTo(Duration.zero);
        _controller.pause();
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

    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      final v = _controller.videoPlayerController?.value;
      if (v != null) {
        if (!_isVideoReady && mounted) {
          setState(() => _isVideoReady = true);
        }
        setState(() {
          _position = v.position;
          _duration = v.duration ?? Duration.zero;
          _isBuffering = v.isBuffering;
          if (v.isPlaying && !v.isBuffering) _isSeeking = false;
        });
        _checkForSkipIntro();
        if (!_adInProgress) _checkScheduledAds();
      }
      return;
    }

    final v = _controller.videoPlayerController?.value;
    if (v == null || !mounted || _isDisposed) return;

    setState(() {
      _position = v.position;
      _duration = v.duration ?? Duration.zero;
      _isBuffering = v.isBuffering;
      if (v.isPlaying && !v.isBuffering) _isSeeking = false;
    });
    _checkForSkipIntro();
  }

  void _checkScheduledAds({bool isFinished = false}) {
    if (_adScheduler == null || _adInProgress) return;

    final currentSec = isFinished ? _duration.inSeconds : _position.inSeconds;
    final totalSec = _duration.inSeconds;

    final ad = _adScheduler!.checkPosition(
      currentSeconds: currentSec,
      totalSeconds: totalSec,
    );

    if (ad != null && ad.vastUrl != null && ad.vastUrl!.isNotEmpty) {
      _showAdOverlay(ad.vastUrl!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void didPushNext() {
    super.didPushNext();
    if (!_controllerDisposed) {
      try {
        _controller.pause();
        _controller.setVolume(1.0);
      } catch (_) {}
    }
    _hideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();
    _unlockHideTimer?.cancel();
  }

  @override
  void didPopNext() {
    super.didPopNext();

    if (_isReturningFromFullscreen) return;

    if (!_controllerDisposed && !_isDisposed) {
      try {
        _controller.setVolume(1.0);
        _controller.play();
      } catch (_) {}
      setState(() => _showControls = true);
      _startHideTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isInFullscreen) return;
    if (state == AppLifecycleState.inactive && !_isBackPressed) {
      _enterPipMode();
    }
  }

  void _initPlayer() {
  if (_controllerDisposed) return;
  
  final config = BetterPlayerConfiguration(
    autoPlay: false,
    fit: BoxFit.contain,
    looping: true,
    allowedScreenSleep: false,
    handleLifecycle: false,
    autoDispose: false,  
    controlsConfiguration: const BetterPlayerControlsConfiguration(
      showControls: false,
      enableAudioTracks: true,
    ),
  );
  
  final BetterPlayerDataSource dataSource;
  if (widget.url.toLowerCase().contains(".m3u8")) {
    dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      videoFormat: BetterPlayerVideoFormat.hls,
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false, maxCacheSize: 0),
    );
  } else {
    dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.url,
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false, maxCacheSize: 0),
    );
  }

  // if (_controllerDisposed == false) {
  //   try {
  //     _controller.dispose();
  //   } catch (_) {}
  // }
  
  _controller = BetterPlayerController(config);
  _controllerDisposed = false;
  
  // ✅ Add listener BEFORE setting up data source
  _controller.addEventsListener(_onPlayerEvent);

  _controller.setupDataSource(dataSource).then((_) async {
    if (_isDisposed || _controllerDisposed || !mounted) return;
    
    // ✅ Set volume to 0 initially (will be set to 1 after ad)
    _controller.setVolume(0);
    
    // ✅ Load saved position
    final savedSeconds = await _getSavedPosition();
    if (savedSeconds > 0 && mounted) {
      try {
        await _controller.seekTo(Duration(seconds: savedSeconds));
        debugPrint('✅ Loaded saved position: $savedSeconds seconds');
      } catch (e) {
        debugPrint('Seek error: $e');
      }
    }
    
    // ✅ Mark video as ready
    if (mounted && !_isDisposed) {
      setState(() => _isVideoReady = true);
    }
    
    // ✅ Start ad flow AFTER everything is ready
    _startAdFlow();
  }).catchError((e) {
    debugPrint("Player setup error: $e");
    if (mounted && !_isDisposed) {
      setState(() => _isVideoReady = false);
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading video: $e')),
      );
    }
  });
}

 void _startAdFlow() async {
  await Future.delayed(const Duration(milliseconds: 300)); // Slightly longer delay
  if (_isDisposed || !mounted) return;

  _resolveAdUrl();

  final hasValidAd = _resolvedVastUrl != null && _resolvedVastUrl!.isNotEmpty;

  if (!_adShownOnce && hasValidAd) {
    debugPrint('📺 Showing pre-roll ad: $_resolvedVastUrl');
    setState(() {
      _showAd = true;
      _adShownOnce = true;
    });
  } else {
    debugPrint('🎬 No ad to show, playing video directly');
    _startVideoPlayback();
  }
}
  void _startVideoPlayback() {
  if (_isDisposed || !mounted) return;

  debugPrint('🎬 Starting video playback');
  
  setState(() {
    _showAd = false;
  });

  // ✅ Small delay to ensure UI is updated
  Future.delayed(const Duration(milliseconds: 100), () {
    if (_isDisposed || !mounted) return;
    try {
      // ✅ Set volume to 1.0 for normal playback
      _controller.setVolume(1.0);
      _controller.play();
      debugPrint('✅ Video playback started');

      if (widget.startInFullscreen) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isDisposed) _openFullscreen();
        });
      }
    } catch (e) {
      debugPrint('Error starting video: $e');
      // Try to play anyway
      try {
        _controller.play();
      } catch (_) {}
    }
  });
}

  // Future<int> _getSavedPosition() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final key = "continue_${widget.videoId}";
  //     return prefs.getInt(key) ?? 0;
  //   } catch (e) {
  //     return 0;
  //   }
  // }
  Future<int> _getSavedPosition() async {
  try {
    // First priority: use savedPosition passed from Continue Watching
    if (widget.savedPosition > 0) {
      debugPrint('✅ Using passed savedPosition: ${widget.savedPosition} seconds');
      return widget.savedPosition;
    }
    
    // Fallback: read from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = "continue_${widget.videoId}";
    final saved = prefs.getInt(key) ?? 0;
    debugPrint('📊 Loaded saved position from prefs: $saved seconds');
    return saved;
  } catch (e) {
    debugPrint('Error getting saved position: $e');
    return 0;
  }
}

  void _disposeController() {
    if (_controllerDisposed) return;
    _controllerDisposed = true;
    try {
      _controller.removeEventsListener(_onPlayerEvent);
    } catch (_) {}
    try {
      _controller.pause();
    } catch (_) {}
    try {
      _controller.dispose();
    } catch (e) {
      debugPrint("Controller dispose error: $e");
    }
  }

  Future<void> _enterPipMode() async {
    if (!(_controller.isPlaying() ?? false)) return;
    try {
      final supported = await _pip.isSupported();
      if (!supported) {
        try {
          _controller.pause();
        } catch (_) {}
        return;
      }
      await _pip.setup(
        PipOptions(autoEnterEnabled: false, aspectRatioX: 16, aspectRatioY: 9),
      );
      await _pip.start();
    } catch (e) {
      debugPrint("PiP error: $e");
      try {
        _controller.pause();
      } catch (_) {}
    }
  }

  Future<bool> _handleBackPress() async {
    _isBackPressed = true;
    _hideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();
    _unlockHideTimer?.cancel();

    try {
      _controller.pause();
      _controller.setVolume(0.0);
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 100));

    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    }

    if (mounted) Navigator.pop(context);
    return true;
  }

  Future<void> _loadQualities() async {
    if (!widget.url.startsWith("http")) return;
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
              (q) => q.label.toLowerCase().contains("auto"),
              orElse: () => _qualities.first,
            );
          }
        });
      }
    } catch (e) {
      debugPrint("Quality load error: $e");
    }
  }

  List<HlsQuality> _parseMasterPlaylist(String content, String baseUrl) {
    final lines = content.split("\n");
    final Map<String, HlsQuality> uniqueQualities = {};

    uniqueQualities["Auto"] = HlsQuality(
      label: "Auto",
      url: baseUrl,
      bitrate: 0,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith("#EXT-X-STREAM-INF")) {
        final resolutionMatch =
            RegExp(r"RESOLUTION=(\d+x\d+)").firstMatch(line);
        final resolution =
            resolutionMatch != null ? resolutionMatch.group(1)! : "";

        if (i + 1 < lines.length && resolution.isNotEmpty) {
          final urlLine = lines[i + 1].trim();
          final absoluteUrl = _makeAbsoluteUrl(baseUrl, urlLine);

          final key = resolution;

          if (!uniqueQualities.containsKey(key)) {
            final label = _resolutionToLabel(resolution);
            uniqueQualities[key] = HlsQuality(
              label: label,
              url: absoluteUrl,
              bitrate: 0,
            );
          }
        }
      }
    }
    List<HlsQuality> qualities = uniqueQualities.values.toList();

    qualities.sort((a, b) {
      int getHeight(String label) {
        if (label == "Auto") return 9999;
        final match = RegExp(r'(\d+)p').firstMatch(label);
        return match != null ? int.parse(match.group(1)!) : 0;
      }
      return getHeight(b.label).compareTo(getHeight(a.label));
    });

    qualities.sort((a, b) {
      if (a.label == "Auto") return -1;
      if (b.label == "Auto") return 1;
      return 0;
    });

    return qualities;
  }

  String _makeAbsoluteUrl(String base, String path) {
    if (path.startsWith("http")) return path;
    final uri = Uri.parse(base);
    final basePath = uri.path.substring(0, uri.path.lastIndexOf("/") + 1);
    return "${uri.scheme}://${uri.host}$basePath$path";
  }

  String _resolutionToLabel(String resolution) {
    try {
      final parts = resolution.split("x");
      if (parts.length != 2) return resolution;
      final height = int.parse(parts[1]);
      if (height >= 2160) return "2160p";
      if (height >= 1440) return "1440p";
      if (height >= 1080) return "1080p";
      if (height >= 720) return "720p";
      if (height >= 480) return "480p";
      if (height >= 360) return "360p";
      if (height >= 240) return "240p";
      return "${height}p";
    } catch (_) {
      return resolution;
    }
  }

  Future<void> _applyQuality(HlsQuality quality) async {
    if (!widget.url.startsWith("http") || _isDisposed) return;

    final wasPlaying = _controller.isPlaying() ?? false;
    final currentPos =
        _controller.videoPlayerController?.value.position ?? _position;

    setState(() => _selectedQuality = quality);

    try {
      if (wasPlaying) _controller.pause();
    } catch (e) {
      debugPrint("Pause error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 150));

    await _controller.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        quality.url,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration:
            const BetterPlayerCacheConfiguration(useCache: false, maxCacheSize: 0),
      ),
    );

    if (_isDisposed) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!_isDisposed) await _controller.seekTo(currentPos);
    if (wasPlaying && !_isDisposed) _controller.play();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isDragging && !_isLocked && !_isDisposed) {
        setState(() => _showControls = false);
      }
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

  void _togglePlayPause() {
    if (_isLocked) return;
    final isPlaying = _controller.isPlaying() ?? false;
    isPlaying ? _controller.pause() : _controller.play();
    setState(() {});
    _startHideTimer();
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

  Future<void> _seekBy(int seconds) async {
    if (_isLocked || _isDisposed) return;
    final v = _controller.videoPlayerController?.value;
    if (v == null) return;
    setState(() => _isSeeking = true);
    final current = v.position;
    final total = v.duration ?? Duration.zero;
    Duration target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > total) target = total;
    await _controller.seekTo(target);
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

  void _openCastDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CastDeviceSheet(
        videoUrl: _selectedQuality?.url ?? widget.url,
        title: widget.title,
      ),
    );
  }

  void _openSettingsDialog() {
    if (_isLocked) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => HotstarSettingsDialog(
        qualities: _qualities,
        selectedQuality: _selectedQuality,
        speed: _speed,
        onQualitySelected: (q) async {
          Navigator.pop(context);
          await _applyQuality(q);
        },
        onSpeedSelected: (s) {
          setState(() => _speed = s);
          _controller.setSpeed(s);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _openFullscreen() async {
    if (_isLocked || _isDisposed) return;

    final wasPlaying = _controller.isPlaying() ?? false;
    final livePos =
        _controller.videoPlayerController?.value.position ?? _position;
    _isReturningFromFullscreen = true;
    _isInFullscreen = true;

    _controller.removeEventsListener(_onPlayerEvent);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final Map<String, dynamic>? result = await Navigator.push<
        Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => HotstarFullscreenPage(
          existingController: _controller,
          videoUrl: _selectedQuality?.url ?? widget.url,
          title: widget.title,
          speed: _speed,
          qualities: _qualities,
          selectedQuality: _selectedQuality,
          initialPosition: livePos,
          videoId: widget.videoId,
          movieDuration: widget.movieDuration,
          skipIntroData: _skipIntroData,
          nextEpisodeData: widget.nextEpisodeData,
          isWebSeries: widget.isWebSeries,
          seasons: widget.seasons,
          wasPlaying: wasPlaying,
          seriesId: widget.seriesId,
          onQualityChanged: (q) async {
            setState(() => _selectedQuality = q);
            await _applyQuality(q);
          },
          onSpeedChanged: (s) {
            if (!_isDisposed) setState(() => _speed = s);
            _controller.setSpeed(s);
          },
        ),
      ),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (!mounted || _isDisposed) {
      _isReturningFromFullscreen = false;
      _isInFullscreen = false;
      return;
    }

    final returnedPos = result?['position'] as Duration?;
    final shouldPlay = result?['wasPlaying'] as bool? ?? wasPlaying;
    final seekTo = returnedPos ?? livePos;

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _isDisposed) {
      _isReturningFromFullscreen = false;
      _isInFullscreen = false;
      return;
    }

    _controller.addEventsListener(_onPlayerEvent);

    if (mounted) {
      setState(() {
        _isVideoReady = false;
        _isBuffering = true;
        _showControls = false;
      });
    }

    try {
      final String videoUrl = _selectedQuality?.url ?? widget.url;
      final BetterPlayerDataSource dataSource = videoUrl.endsWith(".m3u8")
          ? BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              videoUrl,
              videoFormat: BetterPlayerVideoFormat.hls,
              cacheConfiguration: const BetterPlayerCacheConfiguration(
                  useCache: false, maxCacheSize: 0),
            )
          : BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              videoUrl,
              cacheConfiguration: const BetterPlayerCacheConfiguration(
                  useCache: false, maxCacheSize: 0),
            );

      await _controller.setupDataSource(dataSource);

      if (!mounted || _isDisposed) {
        _isReturningFromFullscreen = false;
        _isInFullscreen = false;
        return;
      }

      if (seekTo.inSeconds > 0) {
        try {
          await _controller.seekTo(seekTo);
          debugPrint('✅ Sought to: ${seekTo.inSeconds}s');
        } catch (e) {
          debugPrint('Seek error: $e');
        }
      }

      try {
        _controller.setVolume(1.0);
      } catch (_) {}
      try {
        _controller.setSpeed(_speed);
      } catch (_) {}

      if (shouldPlay) {
        try {
          await _controller.play();
          debugPrint('✅ Video resumed after fullscreen');
        } catch (e) {
          debugPrint('Play error: $e');
        }
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _showControls = true;
          _isVideoReady = true;
          _isBuffering = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error reinitializing after fullscreen: $e');
      if (mounted) {
        setState(() {
          _isVideoReady = true;
          _isBuffering = false;
          _showControls = true;
        });
      }
    }

    _startHideTimer();
    await Future.delayed(const Duration(milliseconds: 100));
    _isReturningFromFullscreen = false;
    _isInFullscreen = false;
  }

  Widget _trendingSection2(HomeController controller) {
    return Obx(() {
      if (controller.isLoadingTrending.value) {
        return SizedBox(
          height: 170.h,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      final items = controller.trendingListByIndex(1).take(10).toList();

      if (items.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'EXPLORE MORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 190.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _trendingCardWithWatchlist(context, items[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _trendingCardWithWatchlist(BuildContext context, dynamic item) {
    final FavoritesController favoritesController =
        Get.find<FavoritesController>();

    Map<String, dynamic> data = {};

    try {
      data = item is Map<String, dynamic>
          ? item
          : Map<String, dynamic>.from(item);
    } catch (e) {
      return const SizedBox();
    }

    final String id = '${data['_id'] ?? data['id']}';
    final String title = data['title'] ?? data['movieTitle'] ?? 'No Title';
    final String imageUrl = data['verticalPosterUrl'] ??
        data['horizontalBannerUrl'] ??
        data['image'] ??
        data['poster'] ??
        '';
    final String trailerUrl = data['trailerUrl'] ?? data['videoTrailer'] ?? '';
    final String movieUrl = data['playUrl'] ?? data['videoMovies'] ?? '';
    final String subtitle = data['subtitle'] ?? data['genresString'] ?? '';
    final String dis = data['description'] ?? '';

    void onCardTap() {
      if (Get.isRegistered<DetailsController>()) {
        Get.delete<DetailsController>(force: true);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VideoDetailScreen(
            key: ValueKey(id),
            videoId: id,
            videoTitle: title,
            image: imageUrl,
            videoTrailer: trailerUrl.isNotEmpty ? trailerUrl : movieUrl,
            videoMoives: movieUrl.isNotEmpty ? movieUrl : trailerUrl,
            subtitle: subtitle,
            dis: dis,
            logoImage: data['logoImage'] ?? data['logoUrl'] ?? '',
            imdbRating:
                double.tryParse(data['imdbRating']?.toString() ?? '0') ?? 0,
            ageRating: data['ageRating'] ?? 'U/A',
            directorInfo: data['directorInfo'] ?? '',
            castInfo: data['castInfo'] ?? '',
            genres:
                (data['genres'] as List?)?.map((e) => e.toString()).toList() ??
                    [],
            tags:
                (data['tags'] as List?)?.map((e) => e.toString()).toList() ??
                    [],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        width: 110.w,
        height: 190.h,
        margin: EdgeInsets.only(right: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 110.w,
                height: 150.h,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Obx(() {
              final isFav2 = id.isNotEmpty && favoritesController.isFavorite(id);
              return GestureDetector(
                onTap: () {
                  if (id.isEmpty) return;
                  favoritesController.toggleFavorite(
                    FavoriteItem(
                      id: id,
                      title: title,
                      image: imageUrl,
                      videoTrailer: trailerUrl,
                      subtitle: subtitle,
                      videoMovies: movieUrl,
                      logoImage: imageUrl,
                      description: dis,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isFav2
                        ? Colors.green.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: isFav2 ? Colors.green : Colors.white24,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFav2 ? Icons.check : Icons.add,
                        size: 14,
                        color: isFav2 ? Colors.greenAccent : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFav2 ? "Added" : "Watchlist",
                        style: TextStyle(
                          fontSize: 10,
                          color: isFav2 ? Colors.greenAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _similarVideosSection() {
    final FavoritesController favoritesController =
        Get.find<FavoritesController>();

    Widget watchlistButton({
      required String videoId,
      required String title,
      required String imageUrl,
      required String videoTrailer,
      required String videoMovies,
      required String subtitle,
      required String dis,
    }) {
      return Obx(() {
        final isFav = videoId.isNotEmpty && favoritesController.isFavorite(videoId);

        return GestureDetector(
          onTap: () {
            if (videoId.isEmpty) return;

            favoritesController.toggleFavorite(
              FavoriteItem(
                id: videoId,
                title: title,
                image: imageUrl,
                videoTrailer: videoTrailer,
                subtitle: subtitle,
                videoMovies: videoMovies,
                logoImage: imageUrl,
                description: dis,
              ),
            );
          },
          child: AnimatedContainer(
            width: double.infinity,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: isFav
                  ? LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.25),
                        Colors.green.withOpacity(0.1),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
              border: Border.all(
                color: isFav
                    ? Colors.green.withOpacity(0.6)
                    : Colors.white.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isFav ? Icons.check_rounded : Icons.add_rounded,
                    key: ValueKey(isFav),
                    color: isFav ? Colors.greenAccent : Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: isFav ? Colors.greenAccent : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  child: Text(isFav ? "Added" : "Watchlist"),
                ),
              ],
            ),
          ),
        );
      });
    }

    void navigateToDetailsScreen({
      required String videoId,
      required String title,
      required String imageUrl,
      required String videoTrailer,
      required String videoMovies,
      required String subtitle,
      required String dis,
      String logoImage = '',
      double imdbRating = 0.0,
      String ageRating = 'U/A',
      String directorInfo = '',
      String castInfo = '',
      List<String> genres = const [],
      List<String> tags = const [],
      String language = '',
      int duration = 0,
      int releaseYear = 0,
      String tagline = '',
      String fullStoryline = '',
    }) {
      try {
        _controller.pause();
        _controller.setVolume(0);
      } catch (_) {}

      if (Get.isRegistered<DetailsController>()) {
        Get.delete<DetailsController>(force: true);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VideoDetailScreen(
            key: ValueKey(videoId),
            videoId: videoId,
            videoTitle: title,
            image: imageUrl,
            videoTrailer: videoTrailer.isNotEmpty ? videoTrailer : videoMovies,
            videoMoives: videoMovies.isNotEmpty ? videoMovies : videoTrailer,
            subtitle: subtitle,
            dis: dis,
            logoImage: logoImage,
            imdbRating: imdbRating,
            ageRating: ageRating,
            directorInfo: directorInfo,
            castInfo: castInfo,
            genres: genres,
            tags: tags,
            language: language,
            duration: duration,
            releaseYear: releaseYear,
            tagline: tagline,
            fullStoryline: fullStoryline,
          ),
        ),
      );
    }

    if (widget.similarVideos.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, top: 14, bottom: 8),
            child: Text(
              "Similar Videos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 14),
              itemCount: widget.similarVideos.length,
              itemBuilder: (context, index) {
                final item = widget.similarVideos[index];

                final title = item['title']?.toString() ?? '';
                final imageUrl = item['image']?.toString() ?? '';
                final videoId = item['_id']?.toString() ?? '';

                final videoTrailer =
                    (item['videoTrailer']?.toString().isNotEmpty == true
                            ? item['videoTrailer']
                            : item['hlsUrl'] ??
                                  item['playUrl'] ??
                                  item['url'] ??
                                  '')
                        .toString();

                final videoMovies =
                    (item['videoMovies']?.toString().isNotEmpty == true
                            ? item['videoMovies']
                            : item['playUrl'] ?? item['hlsUrl'] ?? videoTrailer)
                        .toString();

                final subtitle = item['subtitle']?.toString() ?? '';
                final dis = item['dis']?.toString() ?? '';

                return GestureDetector(
                  onTap: () {
                    try {
                      _controller.pause();
                      _controller.setVolume(0);
                    } catch (_) {}

                    if (Get.isRegistered<DetailsController>()) {
                      Get.delete<DetailsController>(force: true);
                    }

                    final urlToPlay = videoMovies.isNotEmpty
                        ? videoMovies
                        : videoTrailer;

                    if (urlToPlay.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Video URL not available'),
                        ),
                      );
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoScreen(
                          url: urlToPlay,
                          title: title,
                          image: imageUrl,
                          videoId: videoId,
                          movieDuration:
                              int.tryParse(item['duration']?.toString() ?? '0') ??
                                  0,
                          similarVideos: widget.similarVideos,
                          vastTagUrl: _resolvedVastUrl,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImage(imageUrl, 170, 110),
                        ),
                        const SizedBox(height: 6),
                        watchlistButton(
                          videoId: videoId,
                          title: title,
                          imageUrl: imageUrl,
                          videoTrailer: videoTrailer,
                          videoMovies: videoMovies,
                          subtitle: subtitle,
                          dis: dis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return Obx(() {
      final list = _homeController.trendingList;

      if (list.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No videos available",
            style: TextStyle(color: Colors.white54),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, top: 14, bottom: 8),
            child: Text(
              "Trending Videos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 14),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final title = item['title']?.toString() ?? '';
                final imageUrl = item['image']?.toString() ?? '';
                final videoId = item['_id']?.toString() ?? '';
                final videoTrailer =
                    (item['videoTrailer']?.toString().isNotEmpty == true
                            ? item['videoTrailer']
                            : item['hlsUrl'] ??
                                  item['playUrl'] ??
                                  item['url'] ??
                                  '')
                        .toString();
                final videoMovies =
                    (item['videoMovies']?.toString().isNotEmpty == true
                            ? item['videoMovies']
                            : item['playUrl'] ?? item['hlsUrl'] ?? videoTrailer)
                        .toString();
                final subtitle = item['subtitle']?.toString() ?? '';
                final dis = item['dis']?.toString() ?? '';
                return GestureDetector(
                  onTap: () {
                    navigateToDetailsScreen(
                      videoId: videoId,
                      title: title,
                      imageUrl: imageUrl,
                      videoTrailer: videoTrailer,
                      videoMovies: videoMovies,
                      subtitle: subtitle,
                      dis: dis,
                      logoImage: item['logoImage']?.toString() ?? imageUrl,
                      imdbRating:
                          double.tryParse(item['imdbRating']?.toString() ?? '0') ??
                              0.0,
                      ageRating: item['ageRating']?.toString() ?? 'U/A',
                      directorInfo: item['directorInfo']?.toString() ?? '',
                      castInfo: item['castInfo']?.toString() ?? '',
                      genres:
                          (item['genres'] as List<dynamic>?)?.cast<String>() ??
                              [],
                      tags:
                          (item['tags'] as List<dynamic>?)?.cast<String>() ??
                              [],
                      language: item['language']?.toString() ?? '',
                      duration:
                          int.tryParse(item['duration']?.toString() ?? '0') ??
                              0,
                      releaseYear:
                          int.tryParse(item['releaseYear']?.toString() ?? '0') ??
                              0,
                      tagline: item['tagline']?.toString() ?? '',
                      fullStoryline: item['fullStoryline']?.toString() ?? '',
                    );
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImage(imageUrl, 170, 110),
                        ),
                        const SizedBox(height: 6),
                        watchlistButton(
                          videoId: videoId,
                          title: title,
                          imageUrl: imageUrl,
                          videoTrailer: videoTrailer,
                          videoMovies: videoMovies,
                          subtitle: subtitle,
                          dis: dis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildImage(String url, double height, double width) {
    final placeholder = Container(
      height: height,
      width: width,
      color: Colors.grey[850],
      child: const Icon(Icons.movie, color: Colors.white54, size: 32),
    );

    if (url.startsWith('http')) {
      return Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        cacheHeight: height.toInt() * 2,
        cacheWidth: width.toInt() * 2,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder;
        },
      );
    }
    return placeholder;
  }

  Widget _seekOverlay(bool right) {
    final show = right ? _showSeekRight : _showSeekLeft;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: show ? 1 : 0.9,
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
                  "10 sec",
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

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "${two(h)}:${two(m)}:${two(s)}";
    return "${two(m)}:${two(s)}";
  }

  @override
  void dispose() {
    _isDisposed = true;
    _progressSaveTimer?.cancel();
    _hideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();
    _unlockHideTimer?.cancel();
    _skipIntroCheckTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    WakelockPlus.disable();
    VolumeController().showSystemUI = true;

    _disposeController();

    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }
@override
Widget build(BuildContext context) {
 if (_controllerDisposed || !_isPlayerInitialized) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.red),
      ),
    );
  }
  final isPlaying = _controller.isPlaying() ?? false;

  return WillPopScope(
    onWillPop: () async {
      await _handleBackPress();
      return true;
    },
    child: Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  BetterPlayer(controller: _controller),
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
                  if (_isBackPressed || !mounted)
                    Positioned.fill(child: Container(color: Colors.black)),
                  if (_showAd)
                    Positioned.fill(
                      child: AdMobRewardOverlay(
                        onAdFinished: _startVideoAfterAd,
                        vastTagUrl: _resolvedVastUrl,
                      ),
                    ),
                  if (!_showAd) ...[
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    if (!_isLocked)
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onDoubleTap: () async {
                                  _showSeekEffect(false);
                                  await _seekBy(-10);
                                },
                                child: const SizedBox.expand(),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onDoubleTap: () async {
                                  _showSeekEffect(true);
                                  await _seekBy(10);
                                },
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onVerticalDragUpdate: (details) async {
                                if (!_isVideoReady) return;
                                double delta = details.primaryDelta! / 300;
                                brightness = (brightness - delta).clamp(0.0, 1.0);
                                await ScreenBrightness().setScreenBrightness(brightness);
                                if (!_isDisposed) setState(() => showBrightnessUI = true);
                                brightnessTimer?.cancel();
                                brightnessTimer = Timer(
                                  const Duration(milliseconds: 800),
                                  () {
                                    if (mounted && !_isDisposed)
                                      setState(() => showBrightnessUI = false);
                                  },
                                );
                              },
                              child: const SizedBox.expand(),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onVerticalDragUpdate: (details) async {
                                if (!_isVideoReady) return;
                                double delta = details.primaryDelta! / 300;
                                volume = (volume - delta).clamp(0.0, 1.0);
                                VolumeController().setVolume(volume);
                                if (!_isDisposed) setState(() => showVolumeUI = true);
                                volumeTimer?.cancel();
                                volumeTimer = Timer(
                                  const Duration(milliseconds: 800),
                                  () {
                                    if (mounted && !_isDisposed)
                                      setState(() => showVolumeUI = false);
                                  },
                                );
                              },
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isBuffering || _isSeeking)
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
                                  onPressed: _handleBackPress,
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
                                StreamBuilder<GoogleCastSession?>(
                                  stream: GoogleCastSessionManager
                                      .instance
                                      .currentSessionStream,
                                  builder: (context, snapshot) {
                                    final connected = GoogleCastSessionManager
                                            .instance
                                            .connectionState ==
                                        GoogleCastConnectState.connected;
                                    return IconButton(
                                      onPressed: connected
                                          ? GoogleCastSessionManager
                                              .instance
                                              .endSessionAndStopCasting
                                          : _openCastDialog,
                                      icon: Icon(
                                        connected
                                            ? Icons.cast_connected
                                            : Icons.cast,
                                        color: connected
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                    );
                                  },
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
                                IconButton(
                                  onPressed: _openFullscreen,
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_showControls && !_isLocked && _isVideoReady)
                      Positioned(
                        bottom: 8,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              activeColor: Colors.red,
                              inactiveColor: Colors.white24,
                              value: min(
                                _position.inSeconds.toDouble(),
                                _duration.inSeconds == 0
                                    ? 1
                                    : _duration.inSeconds.toDouble(),
                              ),
                              max: _duration.inSeconds == 0
                                  ? 1
                                  : _duration.inSeconds.toDouble(),
                              onChangeStart: (_) =>
                                  setState(() => _isDragging = true),
                              onChanged: (value) => setState(
                                () => _position = Duration(
                                  seconds: value.toInt(),
                                ),
                              ),
                              onChangeEnd: (value) async {
                                setState(() => _isDragging = false);
                                await _controller.seekTo(
                                  Duration(seconds: value.toInt()),
                                );
                                _startHideTimer();
                              },
                            ),
                            Text(
                              "${_format(_position)} / ${_format(_duration)}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    if (showBrightnessUI)
                      Positioned(
                        left: 20,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _sideIndicator(Icons.brightness_6, brightness),
                        ),
                      ),
                    if (showVolumeUI)
                      Positioned(
                        right: 20,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _sideIndicator(Icons.volume_up, volume),
                        ),
                      ),
                  ],
                  if (_showSkipIntroButton && !_isLocked && _skipIntroData != null)
                    Positioned(
                      bottom: 20.h,
                      right: 20.w,
                      child: GestureDetector(
                        onTap: () {
                          _skipIntro();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC1BDBD), Color(0xFFECEAEA)],
                            ),
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.skip_next,
                                color: Colors.black,
                                size: 15.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Skip Intro',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.isWebSeries
                        ? _buildWebSeriesSection()
                        : _similarVideosSection(),
                    if (!widget.isWebSeries) _trendingSection2(_homeController),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

// Rest of the code (HotstarFullscreenPage, HotstarSettingsDialog, _sideIndicator, HlsQuality)
// remains the same as in your new version...
class HotstarFullscreenPage extends StatefulWidget {
  final String videoUrl;
  final BetterPlayerController existingController;
  final String title;
  final double speed;
  final List<HlsQuality> qualities;
  final HlsQuality? selectedQuality;
  final Duration initialPosition;
  final Function(HlsQuality) onQualityChanged;
  final Function(double) onSpeedChanged;
  final String? videoId;
  final int movieDuration;
  final SkipIntroData? skipIntroData;
  final Map<String, dynamic>? nextEpisodeData;
  final bool isWebSeries;
  final List<Map<String, dynamic>> seasons;
  final bool wasPlaying;
  final String? seriesId;

  const HotstarFullscreenPage({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.speed,
    required this.qualities,
    required this.selectedQuality,
    required this.initialPosition,
    required this.onQualityChanged,
    required this.onSpeedChanged,
    this.videoId,
    this.movieDuration = 0,
    this.skipIntroData,
    this.nextEpisodeData,
    this.isWebSeries = false,
    this.seasons = const [],
    this.wasPlaying = false,
    this.seriesId,
      required this.existingController, 
  });

  @override
  State<HotstarFullscreenPage> createState() => _HotstarFullscreenPageState();
}

class _HotstarFullscreenPageState extends State<HotstarFullscreenPage>
    with WidgetsBindingObserver {
  late BetterPlayerController _controller;
  final _pip = Pip();
  bool _isBackPressed = false;
  Timer? _hideTimer;
  Timer? _unlockHideTimer;
  Timer? brightnessTimer;
  Timer? volumeTimer;
  Timer? _progressSaveTimer;
  String? _videoId;
  int _movieDuration = 0;

  bool _showControls = true;
  bool _isDragging = false;
  double _brightness = 0.5;
  double _volume = 0.5;
  bool showBrightnessUI = false;
  bool showVolumeUI = false;
  bool _isLocked = false;
  bool _showUnlockButton = false;
  bool _isFillMode = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isBuffering = true;
  bool _isSeeking = false;
  bool _showSeekLeft = false;
  bool _showSeekRight = false;
  bool _isDisposed = false;
  bool _showSkipIntroButton = false;
  bool _skipIntroShown = false;
  bool _showNextEpisode = false;
  Timer? _nextEpisodeCheckTimer;
  HlsQuality? _localSelectedQuality;
  DeviceOrientation _currentOrientation = DeviceOrientation.landscapeLeft;
  double _speed = 1.0;

  double _scale = 1.0;
  double _previousScale = 1.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 3.0;

  // ✅ MUTABLE STATE - next episode pe update hote hain
  String _currentTitle = '';
  Map<String, dynamic>? _currentNextEpisodeData;
  SkipIntroData? _currentSkipIntroData;

  @override
  void initState() {
    super.initState();
    _videoId = widget.videoId;
    _movieDuration = widget.movieDuration;
    _speed = widget.speed;

    // ✅ Initialize mutable state
    _currentTitle = widget.title;
    _currentNextEpisodeData = widget.nextEpisodeData;
    _currentSkipIntroData = widget.skipIntroData;

    _startProgressSaveTimer();
    _initPlayer();

    WidgetsBinding.instance.addObserver(this);
    _localSelectedQuality = widget.selectedQuality;
    VolumeController().showSystemUI = false;
    WakelockPlus.enable();

    _startNextEpisodeCheckTimer();

    Future.microtask(() async {
      if (_isDisposed) return;
      _brightness = await ScreenBrightness().current;
      _volume = await VolumeController().getVolume();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideTimer();
  }

  void _initPlayer() {
    
  // ✅ USE EXISTING CONTROLLER - DON'T CREATE A NEW ONE
  _controller = widget.existingController;
  
  // ✅ Just add the listener - controller already has the video loaded
  _controller.addEventsListener(_playerListener);
  
  // ✅ Seek to correct position if needed
  if (widget.initialPosition.inSeconds > 0) {
    final currentPos = _controller.videoPlayerController?.value.position ?? Duration.zero;
    if ((widget.initialPosition - currentPos).abs() > const Duration(seconds: 1)) {
      _controller.seekTo(widget.initialPosition);
    }
  }
  
  // ✅ Set speed
  _controller.setSpeed(_speed);
  
  // ✅ Resume or pause based on wasPlaying
  if (widget.wasPlaying) {
    _controller.play();
  }
}

  void _playerListener(BetterPlayerEvent event) {
    if (_isDisposed) return;

    final v = _controller.videoPlayerController?.value;

    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      debugPrint('🎬 Video finished!');
      if (_currentNextEpisodeData != null && widget.isWebSeries) {
        // ✅ _currentNextEpisodeData use karo
        _playNextEpisode();
      } else {
        try {
          _controller.seekTo(Duration.zero);
          _controller.pause();
          if (mounted) {
            setState(() {
              _position = Duration.zero;
              _showControls = true;
            });
            _hideTimer?.cancel();
          }
        } catch (_) {}
      }
      return;
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      if (v != null && v.duration != null && v.duration!.inSeconds > 0) {
        _checkForNextEpisode();
      }
    }

    if (v != null && v.duration != null && v.duration!.inSeconds > 0) {
      if (mounted) {
        setState(() {
          _position = v.position;
          _duration = v.duration ?? Duration.zero;
          _isBuffering = v.isBuffering;
          if (v.isPlaying && !v.isBuffering) _isSeeking = false;
        });
      }
    }

    _checkForSkipIntro();
  }

  void _checkForNextEpisode() {
    if (_currentNextEpisodeData == null) return; // ✅ local state

    final v = _controller.videoPlayerController?.value;
    if (v == null || v.duration == null) return;

    final totalDuration = v.duration!.inSeconds;
    final currentPosition = _position.inSeconds;
    final remainingSeconds = totalDuration - currentPosition;

    const showRemainingThreshold = 120;
    final shouldShow =
        remainingSeconds <= showRemainingThreshold && totalDuration > 0;

    if (shouldShow && !_showNextEpisode && mounted) {
      setState(() => _showNextEpisode = true);
      debugPrint(
          '🎬 Next episode button SHOWN! (${remainingSeconds}s remaining)');
    } else if (!shouldShow && _showNextEpisode) {
      setState(() => _showNextEpisode = false);
    }
  }

  void _startNextEpisodeCheckTimer() {
    _nextEpisodeCheckTimer?.cancel();
    _nextEpisodeCheckTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isDisposed && mounted && _duration.inSeconds > 0) {
        _checkForNextEpisode();
      }
    });
  }

  void _playNextEpisode() {
    if (_currentNextEpisodeData == null) return;
    if (_isDisposed) return;

    final nextData = _currentNextEpisodeData!;
    final nextUrl = nextData['url']?.toString() ?? '';
    final nextTitle = nextData['title']?.toString() ?? '';
    final nextId = nextData['id']?.toString();
    final nextDuration = nextData['duration'] as int? ?? 0;

    // Next ke baad wala episode (for chaining)
    final Map<String, dynamic>? nextNextEpisode =
        nextData['nextEpisode'] as Map<String, dynamic>?;

    // Next episode ka skip intro
    SkipIntroData? nextSkipIntro;
    final skipRaw = nextData['skipIntro'];
    if (skipRaw != null && skipRaw is Map<String, dynamic>) {
      final s = (skipRaw['start'] as num?)?.toInt() ?? 0;
      final e = (skipRaw['end'] as num?)?.toInt() ?? 0;
      if (e > s) nextSkipIntro = SkipIntroData(start: s, end: e);
    }

    if (nextUrl.isEmpty) {
      debugPrint('❌ Next episode URL empty!');
      return;
    }

    debugPrint('🎬 Playing next episode: $nextTitle');

    // ✅ STATE UPDATE - title, nextEpisodeData, skipIntroData sab update
    setState(() {
      _currentTitle = nextTitle.isNotEmpty ? nextTitle : _currentTitle;
      _currentNextEpisodeData = nextNextEpisode;
      _currentSkipIntroData = nextSkipIntro;
      _showNextEpisode = false;
      _showSkipIntroButton = false;
      _skipIntroShown = false;
      _position = Duration.zero;
      _duration = Duration.zero;
      _isBuffering = true;
      _isSeeking = false;
    });

    _videoId = nextId;
    _movieDuration = nextDuration;

    try {
      _controller.removeEventsListener(_playerListener);
      _controller.pause();
    } catch (_) {}

    final BetterPlayerDataSource dataSource;
    if (nextUrl.endsWith(".m3u8")) {
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        nextUrl,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: false,
          maxCacheSize: 0,
        ),
      );
    } else {
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        nextUrl,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: false,
          maxCacheSize: 0,
        ),
      );
    }

    _controller.addEventsListener(_playerListener);

    _controller.setupDataSource(dataSource).then((_) {
      if (_isDisposed || !mounted) return;
      _controller.setSpeed(_speed);
      _controller.play();
      debugPrint('✅ Now playing: $_currentTitle');
    }).catchError((e) {
      debugPrint('❌ Error loading next episode: $e');
    });

    _startNextEpisodeCheckTimer();
  }

  void _checkForSkipIntro() {
    if (_currentSkipIntroData == null) return; // ✅ local state
    if (_skipIntroShown) return;

    final currentSec = _position.inSeconds;
    final isInSkipRange = currentSec >= _currentSkipIntroData!.start &&
        currentSec < _currentSkipIntroData!.end;

    if (isInSkipRange != _showSkipIntroButton && mounted) {
      setState(() => _showSkipIntroButton = isInSkipRange);
    }

    if (currentSec >= _currentSkipIntroData!.end && _showSkipIntroButton) {
      setState(() {
        _showSkipIntroButton = false;
        _skipIntroShown = true;
      });
    }
  }

  Future<void> _skipIntro() async {
    if (_currentSkipIntroData == null) return; // ✅ local state

    setState(() {
      _showSkipIntroButton = false;
      _skipIntroShown = true;
    });

    try {
      if (_isSeeking) return;
      await _controller
          .seekTo(Duration(seconds: _currentSkipIntroData!.end));
      if (_controller.isPlaying() == true) {
        await _controller.play();
      }
      _startHideTimer();
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  void _startProgressSaveTimer() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer =
        Timer.periodic(const Duration(seconds: 10), (_) {
      _saveWatchProgress();
    });
  }

  Future<void> _saveWatchProgress() async {
    final id = _videoId ?? '';
    if (id.isEmpty) return;

    final v = _controller.videoPlayerController?.value;
    if (v == null) return;

    final watchedSec = v.position.inSeconds;
    final totalSec = v.duration?.inSeconds ?? _movieDuration;

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("continue_$id", watchedSec);

    try {
      final homeController = Get.find<HomeController>();
      final token = homeController.userToken.value;
      if (token.isEmpty) return;

      final cwService = ContinueWatchingService();
      await cwService.updateWatchProgress(
        token: token,
        movieId: id,
        watchedTime: watchedSec,
        duration: totalSec,
        isCompleted: (watchedSec / totalSec) > 0.9,
      );
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
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
      if (mounted && _isLocked && !_isDisposed)
        setState(() => _showUnlockButton = false);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // In fullscreen, don't enter PIP
    return;
  }

  Future<void> _enterPipMode() async {
    if (!(_controller.isPlaying() ?? false)) return;
    try {
      final supported = await _pip.isSupported();
      if (!supported) {
        try {
          _controller.pause();
        } catch (_) {}
        return;
      }
      await _pip.setup(
        PipOptions(
            autoEnterEnabled: false, aspectRatioX: 16, aspectRatioY: 9),
      );
      await _pip.start();
    } catch (e) {
      debugPrint("PiP error: $e");
      try {
        _controller.pause();
      } catch (_) {}
    }
  }

  Future<void> _seekBy(int seconds) async {
    if (_isLocked || _isDisposed) return;
    final v = _controller.videoPlayerController?.value;
    if (v == null) return;
    final current = v.position;
    final total = v.duration ?? Duration.zero;
    Duration target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > total) target = total;
    setState(() => _isSeeking = true);
    await _controller.seekTo(target);
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

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "${two(h)}:${two(m)}:${two(s)}";
    return "${two(m)}:${two(s)}";
  }

  void _toggleFillMode() {
    setState(() {
      _isFillMode = !_isFillMode;
      _scale = _isFillMode ? 1.5 : 1.0;
    });
    _startHideTimer();
  }

  void _openSettingsDialog() {
    if (_isLocked) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => HotstarSettingsDialog(
        qualities: widget.qualities,
        selectedQuality: _localSelectedQuality,
        speed: _speed,
        onQualitySelected: (q) {
          Navigator.pop(context);
          setState(() => _localSelectedQuality = q);
          widget.onQualityChanged(q);
          _applyQuality(q);
        },
        onSpeedSelected: (s) {
          setState(() => _speed = s);
          widget.onSpeedChanged(s);
          _controller.setSpeed(s);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _applyQuality(HlsQuality quality) async {
    final wasPlaying = _controller.isPlaying() ?? false;
    final currentPos =
        _controller.videoPlayerController?.value.position ?? _position;

    if (wasPlaying) await _controller.pause();

    await Future.delayed(const Duration(milliseconds: 150));

    await _controller.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        quality.url,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: false,
          maxCacheSize: 0,
        ),
      ),
    );

    if (_isDisposed) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!_isDisposed) await _controller.seekTo(currentPos);
    if (wasPlaying && !_isDisposed) await _controller.play();
  }

  // void _handleBack() {
  //   if (_isDisposed) return;

  //   _isBackPressed = true;
  //   _isDisposed = true;
  //   _progressSaveTimer?.cancel();
  //   _hideTimer?.cancel();
  //   _unlockHideTimer?.cancel();
  //   brightnessTimer?.cancel();
  //   volumeTimer?.cancel();

  //   final livePos =
  //       _controller.videoPlayerController?.value.position ?? _position;
  //   final wasPlaying = _controller.isPlaying() ?? false;

  //   // ✅ DON'T DISPOSE - this controller is shared with portrait screen
  //   try {
  //     _controller.removeEventsListener(_playerListener);
  //   } catch (_) {}
    
  //   try {
  //     _controller.pause();
  //   } catch (_) {}

  //   if (mounted) {
  //     Navigator.pop(context, {
  //       'position': livePos,
  //       'wasPlaying': wasPlaying,
  //     });
  //   }
  // }
  void _handleBack() {
  if (_isDisposed) return;
 
  _isBackPressed = true;
  // ❌ REMOVED: _isDisposed = true  <-- yahi tha asli problem
  _progressSaveTimer?.cancel();
  _hideTimer?.cancel();
  _unlockHideTimer?.cancel();
  brightnessTimer?.cancel();
  volumeTimer?.cancel();
 
  final livePos =
      _controller.videoPlayerController?.value.position ?? _position;
  final wasPlaying = _controller.isPlaying() ?? false;
 
  // Sirf listener hatao, dispose mat karo (shared controller hai)
  try {
    _controller.removeEventsListener(_playerListener);
  } catch (_) {}
 
  // Pause karo taaki portrait screen smoothly resume kar sake
  try {
    _controller.pause();
  } catch (_) {}
 
  if (mounted) {
    Navigator.pop(context, {
      'position': livePos,
      'wasPlaying': wasPlaying,
    });
  }
}
 

  @override
  void dispose() {
    _progressSaveTimer?.cancel();
    _nextEpisodeCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _hideTimer?.cancel();
    WakelockPlus.disable();
    _unlockHideTimer?.cancel();
    brightnessTimer?.cancel();
    volumeTimer?.cancel();
    VolumeController().showSystemUI = true;

    // ✅ DON'T DISPOSE - this controller is shared with portrait screen
    try {
      _controller.removeEventsListener(_playerListener);
    } catch (_) {}

    super.dispose();
  }

  Widget _seekOverlay(bool right) {
    final show = right ? _showSeekRight : _showSeekLeft;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedScale(
          scale: show ? 1 : 0.9,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  "10 sec",
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

  @override
  Widget build(BuildContext context) {
    final isPlaying = _controller.isPlaying() ?? false;

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. Video Player
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (d) => _previousScale = _scale,
                onScaleUpdate: (d) {
                  if (d.pointerCount >= 2) {
                    setState(() {
                      _scale = (_previousScale * d.scale)
                          .clamp(_minScale, _maxScale);
                    });
                  }
                },
                child: IgnorePointer(
                  ignoring: true,
                  child: RepaintBoundary(
                    child: Transform.scale(
                      scale: _scale,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller
                                  .videoPlayerController
                                  ?.value
                                  .aspectRatio ??
                              (16 / 9),
                          child: BetterPlayer(controller: _controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Loading
            if (_duration == Duration.zero)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.red),
                  ),
                ),
              ),

            if (_isBuffering || _isSeeking)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.red),
                  ),
                ),
              ),

            // 3. Touch areas - left (brightness + double tap seek)
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
                    double delta = details.primaryDelta! / 300;
                    _brightness = (_brightness - delta).clamp(0.0, 1.0);
                    await ScreenBrightness()
                        .setScreenBrightness(_brightness);
                    if (!_isDisposed)
                      setState(() => showBrightnessUI = true);
                    brightnessTimer?.cancel();
                    brightnessTimer =
                        Timer(const Duration(milliseconds: 800), () {
                      if (mounted && !_isDisposed)
                        setState(() => showBrightnessUI = false);
                    });
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // 3. Touch areas - right (volume + double tap seek)
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
                  onVerticalDragUpdate: (details) {
                    if (_isLocked || _isDisposed) return;
                    double delta = details.primaryDelta! / 300;
                    _volume = (_volume - delta).clamp(0.0, 1.0);
                    VolumeController().setVolume(_volume);
                    if (!_isDisposed) setState(() => showVolumeUI = true);
                    volumeTimer?.cancel();
                    volumeTimer =
                        Timer(const Duration(milliseconds: 800), () {
                      if (mounted && !_isDisposed)
                        setState(() => showVolumeUI = false);
                    });
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // 4. Seek overlays
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

            // 5. Center play/pause controls
            if (_showControls && !_isLocked)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(Icons.replay_10,
                        onTap: () => _seekBy(-10)),
                    const SizedBox(width: 28),
                    _circleButton(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      onTap: () {
                        isPlaying
                            ? _controller.pause()
                            : _controller.play();
                        setState(() {});
                        _startHideTimer();
                      },
                    ),
                    const SizedBox(width: 28),
                    _circleButton(Icons.forward_10,
                        onTap: () => _seekBy(10)),
                  ],
                ),
              ),

            // 6. Top bar - ✅ _currentTitle use karo
            if (_showControls && !_isLocked)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _handleBack,
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            _currentTitle, // ✅ widget.title ki jagah
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
                              color: Colors.white),
                        ),
                        IconButton(
                          onPressed: _toggleLock,
                          icon: const Icon(Icons.lock_open,
                              color: Colors.white),
                        ),
                        IconButton(
                          onPressed: _openSettingsDialog,
                          icon: const Icon(Icons.settings,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 7. Bottom progress bar
            if (_showControls && !_isLocked)
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
                        value: min(
                          _position.inSeconds.toDouble(),
                          _duration.inSeconds == 0
                              ? 1
                              : _duration.inSeconds.toDouble(),
                        ),
                        max: _duration.inSeconds == 0
                            ? 1
                            : _duration.inSeconds.toDouble(),
                        onChangeStart: (_) =>
                            setState(() => _isDragging = true),
                        onChanged: (value) => setState(() => _position =
                            Duration(seconds: value.toInt())),
                        onChangeEnd: (value) async {
                          setState(() => _isDragging = false);
                          await _controller
                              .seekTo(Duration(seconds: value.toInt()));
                          _startHideTimer();
                        },
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_format(_position)} / ${_format(_duration)}",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          IconButton(
                            onPressed: () async {
                              final next = _currentOrientation ==
                                      DeviceOrientation.landscapeLeft
                                  ? DeviceOrientation.landscapeRight
                                  : DeviceOrientation.landscapeLeft;
                              setState(
                                  () => _currentOrientation = next);
                              await SystemChrome
                                  .setPreferredOrientations([next]);
                              _startHideTimer();
                            },
                            icon: Icon(
                              _currentOrientation ==
                                      DeviceOrientation.landscapeLeft
                                  ? Icons.screen_rotation_alt
                                  : Icons.screen_rotation,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // 8. Next Episode Button - ✅ _currentNextEpisodeData use karo
            if (_showNextEpisode &&
                !_isLocked &&
                _currentNextEpisodeData != null)
              Positioned(
                bottom: 20,
                left: 20,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: _playNextEpisode,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFC1BDBD),
                            Color(0xFFECEAEA)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.skip_next,
                              color: Colors.black, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _currentNextEpisodeData!['title'] != null
                                ? 'Next: ${_currentNextEpisodeData!['title']}' // ✅
                                : 'Next Episode',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 9. Unlock button
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
                      child: const Icon(Icons.lock_open,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),

            // 10. Brightness indicator
            if (showBrightnessUI)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _sideIndicator(
                        Icons.brightness_6, _brightness)),
              ),

            // 11. Volume indicator
            if (showVolumeUI)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                    child: _sideIndicator(Icons.volume_up, _volume)),
              ),

            // 12. Skip Intro - ✅ _currentSkipIntroData use karo
            if (_showSkipIntroButton &&
                !_isLocked &&
                _currentSkipIntroData != null)
              Positioned(
                bottom: 20,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: _skipIntro,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFC1BDBD),
                            Color(0xFFECEAEA)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.skip_next,
                              color: Colors.black, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Skip Intro',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class HotstarSettingsDialog extends StatefulWidget {
  final List<HlsQuality> qualities;
  final HlsQuality? selectedQuality;
  final double speed;
  final Function(HlsQuality) onQualitySelected;
  final Function(double) onSpeedSelected;

  const HotstarSettingsDialog({
    super.key,
    required this.qualities,
    required this.selectedQuality,
    required this.speed,
    required this.onQualitySelected,
    required this.onSpeedSelected,
  });

  @override
  State<HotstarSettingsDialog> createState() => _HotstarSettingsDialogState();
}

class _HotstarSettingsDialogState extends State<HotstarSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _selectedSpeed = 1.0;
  HlsQuality? _selectedQuality;

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.speed;
    _selectedQuality = widget.selectedQuality;
    _tabController = TabController(length: 2, vsync: this);
    
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
                      Tab(text: "Quality"),
                      Tab(text: "Speed"),
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
                  ListView(
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
                  ListView(
                    children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                      final selected = _selectedSpeed == s;
                      return _rowItem(
                        s == 1.0 ? "1x  Normal" : "${s}x",
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
        Icon(icon, color: const Color.fromARGB(255, 155, 138, 138), size: 26),
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
          "${(value * 100).toInt()}%",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
  );
}

class HlsQuality {
  final String label;
  final String url;
  final int bitrate;
  HlsQuality({required this.label, required this.url, required this.bitrate});
}

