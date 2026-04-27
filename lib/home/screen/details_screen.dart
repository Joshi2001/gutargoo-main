import 'dart:ui';
import 'package:audio_session/audio_session.dart';
import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/custom/coming_Soon_movie.dart';
import 'package:gutrgoopro/custom/coming_soon_pro.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/home/model/web_series_model.dart';
import 'package:gutrgoopro/home/service/video_skip_service.dart';
import 'package:gutrgoopro/profile/getx/download_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:gutrgoopro/home/getx/details_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/screen/video_screen.dart';
import 'package:gutrgoopro/navigation/route_observer.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:gutrgoopro/widget/trailer_full_screen.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoTrailer;
  final String videoMoives;
  final String image;
  final String? videoId;
  final String subtitle;
  final String videoTitle;
  final String dis;
  final String logoImage;
  final double imdbRating;
  final String ageRating;
  final String directorInfo;
  final String castInfo;
  final String tagline;
  final String fullStoryline;
  final List<String> genres;
  final List<String> tags;
  final String language;
  final int duration;
  final int releaseYear;
  final String budget;
  final String awardsAndNominations;
  final String videoQuality;
  final String audioFormat;
  final bool publishStatus;
  final bool subscriptionRequired;
  final bool enableAds;
  final bool allowDownloads;
  final bool featuredMovie;
  final String contentVendor;
  final int viewCount;
  final String mp4Url;
  final String trailerMp4Url;
  final String thumbnailUrl;
  final String trailerThumbnailUrl;
  final String horizontalBannerUrl;
  final String verticalPosterUrl;
  final String customVideoUrl;
  final String customTrailerUrl;
  final String? downloadedPath;
  final DateTime? downloadedAt;
  final MovieModel? movieModel;
  final bool isWebSeries;
  final List<Map<String, dynamic>> seasons;
  final Duration initialPosition;

  const VideoDetailScreen({
    Key? key,
    required this.videoTrailer,
    required this.videoMoives,
    required this.image,
    required this.subtitle,
    required this.videoTitle,
    required this.dis,
    required this.logoImage,
    this.imdbRating = 0.0,
    this.ageRating = 'U/A',
    this.directorInfo = '',
    this.castInfo = '',
    this.tagline = '',
    this.fullStoryline = '',
    this.genres = const [],
    this.tags = const [],
    this.language = '',
    this.duration = 0,
    this.releaseYear = 0,
    this.budget = '',
    this.awardsAndNominations = '',
    this.videoQuality = '',
    this.audioFormat = '',
    this.publishStatus = true,
    this.subscriptionRequired = false,
    this.enableAds = false,
    this.allowDownloads = false,
    this.featuredMovie = false,
    this.contentVendor = '',
    this.viewCount = 0,
    this.mp4Url = '',
    this.trailerMp4Url = '',
    this.thumbnailUrl = '',
    this.trailerThumbnailUrl = '',
    this.horizontalBannerUrl = '',
    this.verticalPosterUrl = '',
    this.customVideoUrl = '',
    this.customTrailerUrl = '',
    this.movieModel,
    this.downloadedPath,
    this.downloadedAt,
    this.videoId,
    this.isWebSeries = false,
    this.seasons = const [],
    this.initialPosition = Duration.zero,
  }) : super(key: key);

  factory VideoDetailScreen.fromArgument(MovieArgument arg) =>
      VideoDetailScreen(
        key: ValueKey('video_${arg.id}'),
        videoId: arg.id,
        videoTrailer: arg.hlsUrl,
        videoMoives: arg.hlsUrl,
        image: arg.horizontalBannerUrl,
        subtitle: arg.subtitle,
        videoTitle: arg.title,
        dis: arg.description,
        logoImage: arg.logoUrl,
        imdbRating: arg.imdbRating,
        ageRating: arg.ageRating,
        directorInfo: arg.directorString,
        castInfo: arg.castString,
      );

  factory VideoDetailScreen.fromModel(MovieModel m,
          {required Duration initialPosition}) =>
      VideoDetailScreen(
        key: ValueKey('video_${m.id}'),
        videoId: m.id,
        videoTrailer: m.trailerUrl.isNotEmpty ? m.trailerUrl : m.playUrl,
        videoMoives: m.playUrl,
        image: m.horizontalBannerUrl,
        subtitle: m.genresString,
        videoTitle: m.movieTitle,
        dis: m.description,
        logoImage: m.logoUrl,
        imdbRating: m.imdbRating,
        ageRating: m.ageRating,
        directorInfo: m.directorString,
        castInfo: m.castString,
        tagline: m.tagline,
        fullStoryline: m.fullStoryline,
        genres: m.genres,
        tags: m.tags,
        language: m.language,
        duration: m.duration,
        releaseYear: m.releaseYear,
        budget: m.budget,
        awardsAndNominations: m.awardsAndNominations,
        videoQuality: m.videoQuality,
        audioFormat: m.audioFormat,
        publishStatus: m.publishStatus,
        subscriptionRequired: m.subscriptionRequired,
        enableAds: m.enableAds,
        allowDownloads: m.allowDownloads,
        featuredMovie: m.featuredMovie,
        contentVendor: m.contentVendor,
        viewCount: m.viewCount,
        mp4Url: m.movieFile?.mp4Url ?? '',
        trailerMp4Url: m.trailer?.mp4Url ?? '',
        thumbnailUrl: m.movieFile?.thumbnailUrl ?? '',
        trailerThumbnailUrl: m.trailer?.thumbnailUrl ?? '',
        horizontalBannerUrl: m.horizontalBannerUrl,
        verticalPosterUrl: m.verticalPosterUrl,
        customVideoUrl: m.customVideoUrl,
        customTrailerUrl: m.customTrailerUrl,
        movieModel: m,
        isWebSeries: _detectSeries(m),
        seasons: _buildSeasons(m),
        initialPosition: initialPosition,
      );

  factory VideoDetailScreen.fromBanner(BannerMovie b) => VideoDetailScreen(
        key: ValueKey('video_banner_${b.id}'),
        videoId: b.id,
        videoTrailer: b.trailerUrl.isNotEmpty ? b.trailerUrl : b.movieUrl,
        videoMoives: b.movieUrl.isNotEmpty ? b.movieUrl : b.trailerUrl,
        image: b.mobileImage,
        subtitle: b.genres.join(', '),
        videoTitle: b.title,
        dis: b.description,
        logoImage: b.logoImage,
        genres: b.genres,
      );

  factory VideoDetailScreen.fromWebSeries(WebSeriesModel series) {
  debugPrint('🎬 Creating VideoDetailScreen from WebSeries: ${series.title}');
  debugPrint('   ID: ${series.id}');
  debugPrint('   Seasons count: ${series.seasons.length}');
  
  List<Map<String, dynamic>> seasonsData = [];
  
  for (var season in series.seasons) {
    debugPrint('   Processing Season ${season.seasonNumber}: ${season.episodes.length} episodes');
    
    List<Map<String, dynamic>> episodesData = [];
    for (var episode in season.episodes) {
      debugPrint('      Episode ${episode.episodeNumber}: ${episode.title}');
      debugPrint('         Episode ID: ${episode.id}');
      debugPrint('         Play URL: ${episode.playUrl}');
      debugPrint('         Thumbnail: ${episode.videoFile.thumbnailUrl}');
      
      episodesData.add({
        'id': episode.id,
        'title': episode.title,
        'description': episode.description,
        'episodeNumber': episode.episodeNumber,
        'duration': episode.videoFile.duration,
        'thumbnailUrl': episode.videoFile.thumbnailUrl,
        'playUrl': episode.playUrl,
        'airDate': episode.releaseDate,
        'hasValidVideo': episode.hasValidVideoUrl,
        'videoFile': {
          'url': episode.playUrl,
          'thumbnailUrl': episode.videoFile.thumbnailUrl,
          'duration': episode.videoFile.duration,
        },
        'skipIntro': episode.skipIntro.end > episode.skipIntro.start
            ? {
                'start': episode.skipIntro.start,
                'end': episode.skipIntro.end,
              }
            : null,
      });
    }
    seasonsData.add({
      'season': season.seasonNumber,
      'title': season.title,
      'episodes': episodesData,
    });
  }
  
  final trailerVideoUrl = series.trailerUrl.isNotEmpty 
      ? series.trailerUrl 
      : (series.firstEpisode?.playUrl ?? '');
  
  final trailerThumbnail = series.trailerThumbnailUrl.isNotEmpty
      ? series.trailerThumbnailUrl
      : series.bannerUrl;

  debugPrint('✅ Created seasonsData with ${seasonsData.length} seasons');
  debugPrint('   Total episodes: ${seasonsData.fold(0, (sum, s) => sum + (s['episodes'] as List).length)}');

  return VideoDetailScreen(
    key: ValueKey('webseries_${series.id}'),
    videoId: series.id,
    videoTrailer: trailerVideoUrl,
    videoMoives: trailerVideoUrl,
    image: trailerThumbnail.isNotEmpty ? trailerThumbnail : series.thumbnail,
    subtitle: series.genresString,
    videoTitle: series.title,
    dis: series.description,
    logoImage: series.verticalPoster,
    ageRating: '',
    genres: series.genres,
    language: series.lang,
    duration: 0,
    isWebSeries: true,
    seasons: seasonsData,
    initialPosition: Duration.zero,
  );
}
  static bool _detectSeries(MovieModel m) {
    final tags = m.tags.map((t) => t.toLowerCase()).toList();
    final genres = m.genres.map((g) => g.toLowerCase()).toList();
    return tags.any((t) => t.contains('series') || t.contains('webseries')) ||
        genres.any((g) => g.contains('series') || g.contains('webseries'));
  }

  static List<Map<String, dynamic>> _buildSeasons(MovieModel m) {
    return [];
  }

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen>
    with RouteAware, SingleTickerProviderStateMixin {
  DetailsController? _detailsController;
  final HomeController homeController = Get.find<HomeController>();
  final FavoritesController favoritesController =
      Get.find<FavoritesController>();
  bool _isReturningFromVideo = false;
  List<Map<String, String>> _castList = [];

  BetterPlayerController? betterPlayerController;
  bool isVideoInitialized = false;
  String? errorMessage;
  bool showControls = true;
  bool isPlaying = false;
  bool isMuted = true;
  final isLiked = false.obs;
  final isShared = false.obs;
  final RxSet<String> likedMovieGenres = RxSet<String>();
  bool _isExpanded = false;
  late TabController _tabController;
  int _selectedSeasonIndex = 0;

  final Map<int, int> _visibleEpisodesCount = {};
  static const int _initialEpisodeCount = 5;

  String get _effectiveVideoUrl => widget.customVideoUrl.isNotEmpty
      ? widget.customVideoUrl
      : widget.videoMoives;

  String get _effectiveTrailerUrl {
    final candidates = [
      widget.customTrailerUrl,
      widget.trailerMp4Url,
      widget.videoTrailer,
      widget.videoMoives,
    ];
    return candidates.firstWhere(
      (u) => u.trim().isNotEmpty, 
      orElse: () => '',
    );
  }

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadSavedLikedGenres();
    _loadMuteState();
  });
  _tabController = TabController(vsync: this, length: 2);

  if (!Get.isRegistered<DownloadsController>()) {
    Get.put(DownloadsController());
  }
  if (Get.isRegistered<DetailsController>()) {
    Get.delete<DetailsController>(force: true);
  }
  _detailsController = Get.put(DetailsController(), permanent: false);
  _detailsController!.castList.listen((list) {
    if (mounted) {
      setState(() {
        _castList = List<Map<String, String>>.from(list);
      });
    }
  });

  WakelockPlus.enable();
  _createAndAttachController();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    _configureAudioSession();
    // ONLY fetch movie details for movies, not web series
    if (!widget.isWebSeries) {
      if (widget.movieModel != null) {
        _detailsController?.loadFromModel(widget.movieModel!);
      } else {
        _fetchMovieDetailsForBanner();
      }
    } else {
      debugPrint('📺 Skipping movie details fetch for web series: ${widget.videoTitle}');
      // For web series, we might want to load cast from the first episode or something else
      _loadWebSeriesCast();
    }
  });
}
Future<void> _configureAudioSession() async {
  final session = await AudioSession.instance;
  
  // iOS-specific configuration
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.moviePlayback,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.longFormVideo, // Changed for iOS
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.movie,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  } else {
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.moviePlayback,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.movie,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }
  
  await session.setActive(true);
  
  // Additional iOS-specific audio setup
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    // Force audio to play even when silent switch is on
    await session.setActive(true);
    
    // Small delay to ensure audio session is properly configured
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
void _loadWebSeriesCast() {
  debugPrint('📺 Loading web series cast for: ${widget.videoTitle}');
}
  Future<void> _loadMuteState() async {
    final prefs = await SharedPreferences.getInstance();
    final muted = prefs.getBool('video_muted') ?? false;
    if (mounted) setState(() => isMuted = muted);
  }

  Future<void> _saveMuteState(bool muted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('video_muted', muted);
  }
void _toggleMute() {
  if (betterPlayerController == null) return;
  if (betterPlayerController?.isVideoInitialized() != true) return;
  
  setState(() {
    isMuted = !isMuted;
  });
  
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    Future.delayed(const Duration(milliseconds: 50), () {
      betterPlayerController?.setVolume(isMuted ? 0 : 1);
    });
  } else {
    betterPlayerController?.setVolume(isMuted ? 0 : 1);
  }
  
  _saveMuteState(isMuted);
}
  
  Future<void> _loadSavedLikedGenres() async {
    final savedGenres = await _getLikedGenres();
    if (savedGenres.isNotEmpty && mounted) {
      Future.microtask(() {
        if (mounted) {
          likedMovieGenres.value = savedGenres;
          isLiked.value = true;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (!mounted) return;
      _isReturningFromVideo = true;
     setState(() {
      isVideoInitialized = false;
      isPlaying = false;
      errorMessage = null;
      showControls = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (betterPlayerController != null) {
      try {
        betterPlayerController?.pause();
        betterPlayerController?.clearCache();
        betterPlayerController?.dispose();
        betterPlayerController = null;
      } catch (_) {}
    }
     Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _createAndAttachController();
      _isReturningFromVideo = false;
    });
    });
  }

  @override
  void deactivate() {
    try {
      if (betterPlayerController?.isVideoInitialized() == true) {
        betterPlayerController?.pause();
      }
    } catch (_) {}
    super.deactivate();
  }

  @override
  void didPushNext() {
    
    final controller = betterPlayerController;
    betterPlayerController = null;
      if (controller != null && controller.isVideoInitialized() == true) {
      try {
        controller.pause();
        // Don't dispose here - keep it for when we come back
      } catch (_) {}
    }
    
    if (mounted) {
      setState(() {
        isVideoInitialized = false;
        isPlaying = false;
        showControls = true;
      });
    }
    try { controller?.pause(); } catch (_) {}
    try { controller?.clearCache(); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 200), () {
      try { controller?.dispose(); } catch (_) {}
    });
    try { WakelockPlus.disable(); } catch (_) {}
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    try { routeObserver.unsubscribe(this); } catch (_) {}
    try { WakelockPlus.disable(); } catch (_) {}
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } catch (_) {}
    try {
      betterPlayerController?.pause();
      betterPlayerController?.clearCache();
      betterPlayerController?.dispose();
      betterPlayerController = null;
    } catch (_) {}
    if (Get.isRegistered<DetailsController>()) {
      Get.delete<DetailsController>(force: true);
    }
    super.dispose();
  }

  Future<void> _fetchMovieDetailsForBanner() async {
     if (widget.isWebSeries) {
    debugPrint('📺 Skipping movie details fetch for web series');
    return;
  }
  if (homeController.homeSections.isEmpty) {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  final allItems = homeController.trendingMovies; 

  SectionItem? matched;
  try {
    matched = allItems.firstWhereOrNull(
      (item) =>
          item.title.trim().toLowerCase() ==
          widget.videoTitle.trim().toLowerCase(),
    );
    matched ??= allItems.firstWhereOrNull(
      (item) => item.title.toLowerCase().contains(
            widget.videoTitle.toLowerCase(),
          ),
    );
    matched ??= allItems.firstWhereOrNull(
      (item) => widget.videoTitle.toLowerCase().contains(
            item.title.toLowerCase(),
          ),
    );

    if (matched != null && mounted) {
      if (matched.movie != null) {
        _detailsController?.loadFromModel(matched.movie!);
      }
    }
  } catch (e) {
    debugPrint("❌ Cast fetch error: $e");
  }
}
  void _createAndAttachController() {
    // Don't recreate if we already have a working controller and we're just returning
    if (!_isReturningFromVideo && betterPlayerController != null && 
        betterPlayerController?.isVideoInitialized() == true) {
      // Resume playback if it was playing before
      if (betterPlayerController?.isPlaying() == false) {
        betterPlayerController?.play();
      }
      return;
    }
    
    final url = _effectiveTrailerUrl;
    if (url.isEmpty) {
      setState(() => errorMessage = 'Trailer not available');
      return;
    }
    
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath || !uri.hasAuthority) {
      setState(() => errorMessage = 'Invalid video URL');
      return;
    }
    
    try {
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        videoFormat: BetterPlayerVideoFormat.hls,
        useAsmsTracks: true,
        useAsmsSubtitles: true,
      );
      
      betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          handleLifecycle: true,
          looping: false,
          aspectRatio: 16 / 9,
          fit: BoxFit.cover,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
          ),
           autoDetectFullscreenDeviceOrientation: true,
    autoDetectFullscreenAspectRatio: true,
        ),
        
        betterPlayerDataSource: dataSource,
      );
      
      betterPlayerController?.setVolume(isMuted ? 0.0 : 1.0);
      _attachPlayerListeners();
    } catch (e) {
      debugPrint('Error creating player: $e');
      setState(() => errorMessage = 'Failed to initialize player');
    }
  }


  void _attachPlayerListeners() {
    betterPlayerController?.addEventsListener((event) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (event.betterPlayerEventType) {
          case BetterPlayerEventType.initialized:
            setState(() {
              isVideoInitialized = true;
              isPlaying = true;
            });
            betterPlayerController?.setVolume(isMuted ? 0 : 1);
            _hideControlsAfterDelay();
            break;
          case BetterPlayerEventType.play:
            setState(() => isPlaying = true);
            _hideControlsAfterDelay();
            break;
          case BetterPlayerEventType.pause:
            setState(() {
              isPlaying = false;
              showControls = true;
            });
            break;
          case BetterPlayerEventType.finished:
            setState(() {
              isPlaying = false;
              showControls = true;
            });
            break;
          case BetterPlayerEventType.exception:
            setState(() => errorMessage = 'Video failed to load');
            break;
          default:
            break;
        }
      });
    });
  }

  void _togglePlayPause() {
    if (betterPlayerController?.isVideoInitialized() != true) return;
    setState(() {
      if (betterPlayerController?.isPlaying() == true) {
        betterPlayerController?.pause();
        isPlaying = false;
        showControls = true;
      } else {
        betterPlayerController?.play();
        isPlaying = true;
        _hideControlsAfterDelay();
      }
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (isPlaying) setState(() => showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => showControls = !showControls);
    if (showControls && betterPlayerController?.isPlaying() == true) {
      _hideControlsAfterDelay();
    }
  }

  void _handleBackPress() {
    if (!mounted) return;
    try { 
      betterPlayerController?.pause(); 
      betterPlayerController?.setVolume(0.0);
    } catch (_) {}
    try { WakelockPlus.disable(); } catch (_) {}
    Get.back();
  }

  void _shareMovie() {
    Share.share(
      'Download App: https://play.google.com/store/apps/details?id=com.gutargooproo.application',
      subject: 'Movie Recommendation',
    );
  }
  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      try { 
        betterPlayerController?.pause(); 
        betterPlayerController?.setVolume(0.0);
      } catch (_) {}
      try { WakelockPlus.disable(); } catch (_) {}
      return true;
    },
    child: SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            _buildVideoPlayer(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildLogoOrTitle()),
                    _buildInfoSection(),
                    SizedBox(height: 8.h),
                    _buildWatchButton(),
                    SizedBox(height: 8.h),
                    _buildDownloadButton(),
                    SizedBox(height: 8.h),
                    _buildDescription(),
                    SizedBox(height: 10.h),
                    _buildActionButtons(),
                    SizedBox(height: 16.h),
                    _buildCastSection(),
                    widget.isWebSeries
                        ? _buildWebSeriesBottom()
                        : _buildMovieBottom(),
                    SizedBox(height: 40.h),
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

  Widget _buildMovieBottom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExploreMore(),
        SizedBox(height: 10.h),
        _trendingSection(),
      ],
    );
  }

  Widget _buildWebSeriesBottom() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        _buildTabBar(),
        SizedBox(height: 8.h),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEpisodesTab(),
              _buildMoreLikeThisTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.red,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 14.sp),
        tabs: const [
          Tab(text: 'EPISODES'),
          Tab(text: 'MORE LIKE THIS'),
        ],
      ),
    );
  }

  Widget _buildEpisodesTab() {
    if (widget.seasons.isEmpty) {
      return Center(
        child: ComingSoonDialog(isWebSeries: widget.isWebSeries),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        _buildSeasonSelector(),
        SizedBox(height: 4.h),
        Expanded(child: _buildEpisodesListHotstar()),
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
    final currentSeason = widget.seasons[_selectedSeasonIndex];
    final episodes = (currentSeason['episodes'] as List<dynamic>? ?? []);

    if (episodes.isEmpty) {
      return Center(
        child: ComingSoonDialog(isWebSeries: true),
      );
    }

    final visibleCount = _visibleEpisodesCount[_selectedSeasonIndex] ?? _initialEpisodeCount;
    final showingAll = visibleCount >= episodes.length;
    final displayEpisodes = episodes.take(visibleCount).toList();

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 4.h, bottom: 16.h),
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
                    _visibleEpisodesCount[_selectedSeasonIndex] = _initialEpisodeCount;
                  } else {
                    _visibleEpisodesCount[_selectedSeasonIndex] = episodes.length;
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
                      showingAll ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
      ],
    );
  }

  Widget _buildHotstarEpisodeCard(Map<String, dynamic> episode, int episodeNumber) {
    final title = episode['title']?.toString() ?? '';
    final description = episode['description']?.toString() ?? '';
    final thumbnail = episode['thumbnailUrl']?.toString() ?? '';
    final duration = episode['duration'] as int? ?? 0;
    final playUrl = episode['playUrl']?.toString() ?? '';
    final airDate = episode['airDate']?.toString() ?? '';
    
    final hasValidVideo = playUrl.isNotEmpty;

    String durationText = '';
    if (duration > 0) {
      final minutes = duration ~/ 60;
      durationText = '${minutes}m';
    }

    final seasonNum = _selectedSeasonIndex + 1;
    final episodeLabel = StringBuffer('S$seasonNum E$episodeNumber');
    if (airDate.isNotEmpty) episodeLabel.write(' · $airDate');
    if (durationText.isNotEmpty) episodeLabel.write(' · $durationText');

    return GestureDetector(
      onTap: () {
        if (hasValidVideo) {
          _playEpisode(playUrl, title, thumbnail, episode['id']?.toString(), duration);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white10, width: 0.5),
          ),
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
                                errorBuilder: (_, __, ___) => _episodeThumbnailPlaceholder(),
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
                                  Icon(Icons.access_time_filled, color: Colors.orange, size: 24.sp),
                                  SizedBox(height: 4.h),
                                  Text('Coming Soon', style: TextStyle(color: Colors.orange, fontSize: 10.sp, fontWeight: FontWeight.bold)),
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
                            decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 14.sp),
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
                                color: hasValidVideo ? Colors.white : Colors.white54,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!hasValidVideo)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                              ),
                              child: Text('Coming Soon', style: TextStyle(color: Colors.orange, fontSize: 8.sp, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                        if (description.isNotEmpty) ...[
                      SizedBox(height: 8.h),
              Text(
                description,
                style: TextStyle(color: hasValidVideo ? Colors.white60 : Colors.white38, fontSize: 11.sp, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
                      SizedBox(height: 4.h),
                      Text(
                        "Episode ${episodeNumber.toString()}",
                        style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          ],
        ),
      ),
    );
  }

  Widget _episodeThumbnailPlaceholder() => Container(
        width: 130.w,
        height: 80.h,
        decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(6.r)),
        child: Icon(Icons.play_circle_outline, color: Colors.white38, size: 28.sp),
      );

  void _playEpisode(String url, String title, String thumbnail, String? episodeId, int duration) {
  debugPrint('🎬 _playEpisode called');
  debugPrint('   Episode ID: $episodeId');
  debugPrint('   Series ID: ${widget.videoId}');
  debugPrint('   URL: $url');
  
  try { betterPlayerController?.pause(); } catch (_) {}
  
  Get.to(
    () => VideoScreen(
      url: url,
      title: '${widget.videoTitle} - $title',
      image: thumbnail.isNotEmpty ? thumbnail : widget.image,
      similarVideos: const [],
      vastTagUrl: null,
      videoId: episodeId,           // Episode ID
      seriesId: widget.videoId,     // Series ID - CRITICAL!
      movieDuration: duration,
      isWebSeries: true,            // CRITICAL!
      seasons: widget.seasons,
    ),
    transition: Transition.fadeIn,
  );
}

  Widget _buildCastSection() {
    if (_castList.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Cast & Crew',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _castList.length,
            itemBuilder: (context, index) {
              final castMember = _castList[index];
              final name = castMember['name'] ?? '';
              final role = castMember['role'] ?? '';
              final image = castMember['image'] ?? '';
              return Container(
                width: 70.w,
                margin: EdgeInsets.only(right: 12.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: image.isNotEmpty
                          ? Image.network(image, width: 60.w, height: 60.h, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _castPlaceholder())
                          : _castPlaceholder(),
                    ),
                    SizedBox(height: 8.h),
                    Flexible(
                      child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white),
                          textAlign: TextAlign.center),
                    ),
                    SizedBox(height: 4.h),
                    Flexible(
                      child: Text(role, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9.sp, color: Colors.grey), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _castPlaceholder() => Container(
        width: 60.w,
        height: 60.w,
        color: Colors.grey.shade800,
        child: Icon(Icons.person, color: Colors.white54, size: 40.sp),
      );

  Widget _buildMoreLikeThisTab() {
  return Obx(() {
    final _ = homeController.homeSections.length;
    final trending = _getAllTrendingMovies();
    if (homeController.isLoadingTrending.value && trending.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (trending.isEmpty) {
      return Center(
        child: Text(
          'Nothing here yet',
          style: TextStyle(color: Colors.white38, fontSize: 13.sp),
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(12.w),
       physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: trending.length,
      itemBuilder: (ctx, i) {
        final item = trending[i];
        final imageUrl = item['image']?.toString() ?? '';
        return GestureDetector(
          onTap: () {
            final raw = Map<String, dynamic>.from(item);
            final trailerUrl = raw['videoTrailer']?.toString() ?? '';
            final movieUrl = raw['videoMovies']?.toString() ?? trailerUrl;
            if (trailerUrl.isEmpty && movieUrl.isEmpty) return;
            if (Get.isRegistered<DetailsController>()) {
              Get.delete<DetailsController>(force: true);
            }
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => VideoDetailScreen(
                  key: ValueKey('video_${raw['_id'] ?? raw['title']}'),
                  videoId: raw['_id']?.toString(),
                  videoTrailer: trailerUrl,
                  videoMoives: movieUrl,
                  image: raw['image']?.toString() ?? '',
                  subtitle: raw['subtitle']?.toString() ?? '',
                  videoTitle: raw['title']?.toString() ?? '',
                  dis: raw['dis']?.toString() ?? '',
                  logoImage: raw['logoImage']?.toString() ?? '',
                  imdbRating: double.tryParse(
                          raw['imdbRating']?.toString() ?? '0') ??
                      0.0,
                  ageRating: raw['ageRating']?.toString() ?? '',
                ),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade800),
                  )
                : Container(color: Colors.grey.shade800),
          ),
        );
      },
    );
  });
}

  // ✅ FIXED: Get all trending movies from homeSections
  List<Map<String, dynamic>> _getAllTrendingMovies() {
  final result = <Map<String, dynamic>>[];
  final seen = <String>{};

  for (final section in homeController.homeSections) {
    // ✅ allDisplayItems use karo, items nahi
    for (final item in section.allDisplayItems) {
      if (!seen.add(item.id)) continue;
      result.add({
        '_id': item.id,
        'title': item.title,
        'image': item.verticalPosterUrl,
        'subtitle': item.genresString,
        'videoTrailer': item.movie?.trailerUrl ?? item.webSeries?.trailerUrl ?? '',
        'videoMovies': item.movie?.playUrl ?? '',
        'dis': item.description,
        'logoImage': item.movie?.logoUrl ?? '',
        'imdbRating': item.imdbRating,
        'ageRating': item.movie?.ageRating ?? '',
      });
    }
  }

  return result;
}
  Widget _buildVideoPlayer() {
    if (errorMessage != null) {
      return SizedBox(
        height: 220.h,
        child: Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white))),
      );
    }
    
    if (betterPlayerController == null || !isVideoInitialized) {
      return SizedBox(
        height: 220.h,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: betterPlayerController!),
        ),
        Positioned.fill(
          child: GestureDetector(onTap: _toggleControls, behavior: HitTestBehavior.translucent),
        ),
        if (showControls)
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36.sp),
                ),
              ),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildTopBar(), _buildTitle()],
            ),
          ),
        ),
        Positioned(
          bottom: 16.h,
          right: 16.w,
          child: GestureDetector(
            onTap: _toggleMute,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: Icon(isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 20.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(top: 0.h, left: 10.w, right: 16.w),
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
        onPressed: _handleBackPress,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Text("Trailer", style: TextStyle(color: Colors.white60, fontSize: 12.sp, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildLogoOrTitle() {
    if (widget.logoImage.isNotEmpty && widget.logoImage != widget.image) {
      final imageWidget = widget.logoImage.startsWith('http')
          ? Image.network(widget.logoImage, height: 50.h, width: 160.w, fit: BoxFit.contain,
              cacheWidth: 360, cacheHeight: 100, errorBuilder: (_, __, ___) => _titleText())
          : Image.asset(widget.logoImage, height: 50.h, width: 160.w, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _titleText());
      return imageWidget;
    }
    return _titleText();
  }

  Widget _titleText() => Text(widget.videoTitle,
      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
      textAlign: TextAlign.center);

  Widget _buildInfoSection() {
    final imdbLabel = widget.imdbRating > 0 ? 'IMDB ${widget.imdbRating.toStringAsFixed(1)}' : 'IMDB 8.6';
    final ratingLabel = widget.ageRating.isNotEmpty ? widget.ageRating : 'U/A 16+';

    String? seasonInfo;
    if (widget.isWebSeries && widget.seasons.isNotEmpty) {
      seasonInfo = '${widget.seasons.length} Season${widget.seasons.length > 1 ? 's' : ''}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(imdbLabel, style: TextStyle(color: const Color(0xFFFFA500), fontSize: 12.sp, fontWeight: FontWeight.w800)),
        SizedBox(width: 4.w),
        _dot(),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(widget.subtitle, style: TextStyle(color: Colors.grey, fontSize: 10.sp), overflow: TextOverflow.ellipsis),
        ),
        if (seasonInfo != null) ...[
          SizedBox(width: 4.w),
          _dot(),
          SizedBox(width: 4.w),
          Text(seasonInfo, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
        ],
        SizedBox(width: 4.w),
        _dot(),
        SizedBox(width: 4.w),
        Text(ratingLabel, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
      ],
    );
  }

  Widget _dot() => Container(width: 4.w, height: 4.h, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle));

  Widget _buildDescription() {
    final isLong = widget.dis.length > 100;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.dis, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
              maxLines: _isExpanded ? null : 3, overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Text(_isExpanded ? 'Read Less' : 'Read More',
                    style: TextStyle(fontSize: 11.sp, color: Colors.blue, fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          imagePath: 'assets/t.png',
          label: 'Trailer',
          onTap: () {
            try { betterPlayerController?.pause(); } catch (_) {}
            Get.to(() => TrailerFullScreen(url: _effectiveTrailerUrl), transition: Transition.fadeIn);
          },
          activeColor: Colors.red,
          isActive: false,
        ),
        Obx(() => _buildActionButton(
          icon: isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
          label: 'Like',
          onTap: () {
            isLiked.value = !isLiked.value;
            if (isLiked.value) {
              likedMovieGenres.value = widget.genres.toSet();
              _saveLikedGenres(widget.genres);
            } else {
              likedMovieGenres.clear();
              _clearLikedGenres();
            }
          },
          activeColor: Colors.red,
          isActive: isLiked.value,
        )),
        Obx(() {
          final favs = favoritesController.favorites.toList();
          if (widget.videoId == null || widget.videoId!.isEmpty) return const SizedBox();
          final isFav = favs.any((e) => e.id == widget.videoId);
          return _buildActionButton(
            icon: isFav ? Icons.check_circle : Icons.add_outlined,
            label: 'My List',
            activeColor: Colors.red,
            isActive: isFav,
            onTap: () {
              if (isFav) {
                favoritesController.removeFavorite(widget.videoId!);
              } else {
                favoritesController.addFavorite(FavoriteItem(
                  id: widget.videoId!,
                  title: widget.videoTitle,
                   image: widget.verticalPosterUrl.isNotEmpty   // ← use vertical poster
      ? widget.verticalPosterUrl
      : widget.image,
                  videoTrailer: widget.videoTrailer,
                  subtitle: widget.subtitle,
                  videoMovies: widget.videoMoives,
                  logoImage: widget.logoImage,
                  description: widget.dis,
                  imdbRating: widget.imdbRating,
                  ageRating: widget.ageRating,
                  directorInfo: widget.directorInfo,
                  castInfo: widget.castInfo,
                  tagline: widget.tagline,
                  fullStoryline: widget.fullStoryline,
                  genres: widget.genres,
                  tags: widget.tags,
                  language: widget.language,
                  duration: widget.duration,
                  releaseYear: widget.releaseYear,
                ));
              }
            },
          );
        }),
        Obx(() => _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          onTap: () async {
            _shareMovie();
            isShared.value = true;
            await Future.delayed(const Duration(milliseconds: 300));
            isShared.value = false;
          },
          activeColor: Colors.red,
          isActive: isShared.value,
        )),
      ],
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    String? imagePath,
    required String label,
    required VoidCallback onTap,
    required Color activeColor,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: isActive ? activeColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          border: Border.all(color: isActive ? activeColor : Colors.white24, width: 0.9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: imagePath != null
                  ? Image.asset(imagePath, key: ValueKey(isActive), width: 16, height: 16,
                      color: isActive ? activeColor : Colors.white)
                  : Icon(icon, key: ValueKey(isActive), size: 16, color: isActive ? activeColor : Colors.white),
            ),
            SizedBox(width: 6.w),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(label, key: ValueKey(isActive),
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500,
                      color: isActive ? activeColor : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () {
          final ctrl = betterPlayerController;
          betterPlayerController = null;
          setState(() {
            isVideoInitialized = false;
            isPlaying = false;
          });
          try { ctrl?.pause(); } catch (_) {}
          Future.delayed(const Duration(milliseconds: 100), () {
            try { ctrl?.clearCache(); ctrl?.dispose(); } catch (_) {}
          });

          if (widget.isWebSeries) {
            _playFirstEpisode();
          } else if (widget.videoMoives.isNotEmpty) {
            Get.to(
              () => VideoScreen(
                url: widget.videoMoives,
                title: widget.videoTitle,
                image: widget.image,
                similarVideos: const [],
                vastTagUrl: null,
                videoId: widget.videoId,
                movieDuration: widget.duration,
              ),
              transition: Transition.fadeIn,
            );
          } else {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.7),
              builder: (_) => ComingSoonDialog(isWebSeries: widget.isWebSeries),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9e1119), Color(0xFFdf4119), Color(0xFF9e1119)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, color: Colors.white, size: 20.sp),
              SizedBox(width: 4.w),
              Text('Play', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _playFirstEpisode() {
  debugPrint('🎬 _playFirstEpisode called for web series: ${widget.videoTitle}');
  debugPrint('   widget.isWebSeries: ${widget.isWebSeries}');
  debugPrint('   widget.seasons length: ${widget.seasons.length}');
  
  if (widget.seasons.isEmpty) {
    debugPrint('❌ No seasons found!');
    if (Get.context != null) {
      showDialog(
        context: Get.context!,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('No Episodes', style: TextStyle(color: Colors.white)),
          content: const Text('No episodes available for this web series.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(Get.context!),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    return;
  }

  final firstSeason = widget.seasons[0];
  final episodes = firstSeason['episodes'] as List? ?? [];
  
  debugPrint('   First season episodes count: ${episodes.length}');
  
  if (episodes.isEmpty) {
    debugPrint('❌ No episodes in first season!');
    if (Get.context != null) {
      showDialog(
        context: Get.context!,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('No Episodes', style: TextStyle(color: Colors.white)),
          content: const Text('No episodes available in first season.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(Get.context!),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    return;
  }
  
  final firstEpisode = episodes[0] as Map<String, dynamic>;
  
  String playUrl = firstEpisode['playUrl']?.toString() ?? '';
  if (playUrl.isEmpty) {
    playUrl = firstEpisode['url']?.toString() ?? '';
  }
  if (playUrl.isEmpty && firstEpisode['videoFile'] != null) {
    playUrl = firstEpisode['videoFile']['url']?.toString() ?? '';
  }
  
  debugPrint('   First episode playUrl: $playUrl');
  
  if (playUrl.isEmpty) {
    debugPrint('❌ First episode has no valid URL!');
    if (Get.context != null) {
      showDialog(
        context: Get.context!,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Video Unavailable', style: TextStyle(color: Colors.white)),
          content: const Text('This episode is not available yet.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(Get.context!),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    return;
  }
  
  final episodeTitle = firstEpisode['title']?.toString() ?? 'Episode 1';
  
  // Try different thumbnail keys
  String thumb = firstEpisode['thumbnailUrl']?.toString() ?? '';
  if (thumb.isEmpty && firstEpisode['videoFile'] != null) {
    thumb = firstEpisode['videoFile']['thumbnailUrl']?.toString() ?? '';
  }
  if (thumb.isEmpty) {
    thumb = widget.image;
  }
  
  final episodeId = firstEpisode['id']?.toString() ?? '';
  final duration = firstEpisode['duration'] as int? ?? 0;
  
  // Extract skip intro data
  SkipIntroData? skipIntroData;
  final skipIntroRaw = firstEpisode['skipIntro'];
  if (skipIntroRaw != null && skipIntroRaw is Map<String, dynamic>) {
    final start = (skipIntroRaw['start'] as num?)?.toInt() ?? 0;
    final end = (skipIntroRaw['end'] as num?)?.toInt() ?? 0;
    if (end > start) {
      skipIntroData = SkipIntroData(start: start, end: end);
      debugPrint('✅ Skip intro found for first episode: $start-$end');
    }
  }
  
  // Find next episode data
  Map<String, dynamic>? nextEpisodeData;
  if (episodes.length > 1) {
    final nextEp = episodes[1] as Map<String, dynamic>;
    String nextUrl = nextEp['playUrl']?.toString() ?? '';
    if (nextUrl.isEmpty && nextEp['videoFile'] != null) {
      nextUrl = nextEp['videoFile']['url']?.toString() ?? '';
    }
    nextEpisodeData = {
      'id': nextEp['id']?.toString() ?? '',
      'title': nextEp['title']?.toString() ?? '',
      'url': nextUrl,
      'image': nextEp['thumbnailUrl']?.toString() ?? '',
      'duration': nextEp['duration'] as int? ?? 0,
      'episodeNumber': nextEp['episodeNumber'] ?? 2,
      'nextEpisode': episodes.length > 2 ? {
        'id': episodes[2]['id']?.toString() ?? '',
        'title': episodes[2]['title']?.toString() ?? '',
        'url': episodes[2]['playUrl']?.toString() ?? '',
      } : null,
    };
    debugPrint('✅ Next episode found: ${nextEp['title']}');
  }
  
  debugPrint('🎬 Playing first episode: $episodeTitle');
  debugPrint('   Episode ID: $episodeId');
  debugPrint('   Series ID: ${widget.videoId}');
  
  // Pause current player
  try { betterPlayerController?.pause(); } catch (_) {}
  
  // Navigate to VideoScreen
  Get.to(
    () => VideoScreen(
      url: playUrl,
      title: '${widget.videoTitle} - $episodeTitle',
      image: thumb.isNotEmpty ? thumb : widget.image,
      similarVideos: const [],
      vastTagUrl: null,
      videoId: episodeId,           // Episode ID
      seriesId: widget.videoId,     // Series ID - CRITICAL for fetching skip intro!
      movieDuration: duration,
      isWebSeries: true,            // CRITICAL - tells VideoScreen it's a web series!
      seasons: widget.seasons,      // Pass all seasons for episode navigation
      nextEpisodeData: nextEpisodeData, // Pass next episode for auto-play
      skipIntroData: skipIntroData,
    ),
    transition: Transition.fadeIn,
  );
}
  Widget _buildDownloadButton() {
    return FutureBuilder<String>(
      future: _getToken(),
      builder: (context, snapshot) {
        final token = homeController.userToken.value;
        final resolvedToken = token.isNotEmpty ? token : (snapshot.data ?? '');
        if (resolvedToken.isEmpty) return const SizedBox();
        return DownloadButton(
          videoId: widget.movieModel?.id ?? widget.videoId ?? '',
          videoTitle: widget.videoTitle,
          subtitle: widget.subtitle,
          image: widget.image,
          videoTrailer: _effectiveVideoUrl,
          token: resolvedToken,
        );
      },
    );
  }

  Widget _buildExploreMore() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text('Explore More', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }
  Widget _trendingSection() {
    return Obx(() {
      final trendingMovies = _getAllTrendingMovies();
      
      if (homeController.isLoadingTrending.value && trendingMovies.isEmpty) {
        return SizedBox(
          height: 170.h,
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }
      
      if (trendingMovies.isEmpty) {
        return SizedBox(
          height: 170.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_outlined, color: Colors.white38, size: 40.sp),
                SizedBox(height: 8.h),
                Text('No movies available', style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
              ],
            ),
          ),
        );
      }
      
      return SizedBox(
        height: 170.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 15.w),
          itemCount: trendingMovies.length,
          itemBuilder: (context, index) {
            final item = trendingMovies[index];
            final imageUrl = item['image']?.toString() ?? '';
            return GestureDetector(
              onTap: () {
                try { betterPlayerController?.pause(); } catch (_) {}
                try {
                  betterPlayerController?.clearCache();
                  betterPlayerController?.dispose();
                  betterPlayerController = null;
                } catch (_) {}
                if (Get.isRegistered<DetailsController>()) {
                  Get.delete<DetailsController>(force: true);
                }
                final rawItem = Map<String, dynamic>.from(item);
                final trailerUrl = rawItem['videoTrailer']?.toString() ?? '';
                final movieUrl = rawItem['videoMovies']?.toString() ?? trailerUrl;
                if (trailerUrl.isEmpty && movieUrl.isEmpty) return;
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => VideoDetailScreen(
                      key: ValueKey('video_${rawItem['_id'] ?? rawItem['title']}'),
                      videoId: rawItem['_id']?.toString(),
                      videoTrailer: trailerUrl,
                      videoMoives: movieUrl,
                      image: rawItem['image']?.toString() ?? '',
                      subtitle: rawItem['subtitle']?.toString() ?? '',
                      videoTitle: rawItem['title']?.toString() ?? '',
                      dis: rawItem['dis']?.toString() ?? '',
                      logoImage: rawItem['logoImage']?.toString() ?? '',
                      imdbRating: double.tryParse(rawItem['imdbRating']?.toString() ?? '0') ?? 0.0,
                      ageRating: rawItem['ageRating']?.toString() ?? '',
                    ),
                    transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Container(
                width: 120.w,
                margin: EdgeInsets.only(right: 10.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: imageUrl.isEmpty
                      ? _imagePlaceholder()
                      : Image.network(
                          imageUrl,
                          height: 170.h,
                          width: 100.w,
                          fit: BoxFit.fill,
                          cacheWidth: 200,
                          cacheHeight: 340,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 170.h,
                              width: 100.w,
                              color: Colors.grey.shade800,
                              child: const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
                            );
                          },
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _imagePlaceholder() => Container(
        color: Colors.grey.shade800,
        child: Icon(Icons.movie, color: Colors.white54, size: 24.sp),
      );
}

class DownloadButton extends StatelessWidget {
  final String videoId;
  final String videoTitle;
  final String subtitle;
  final String image;
  final String videoTrailer;
  final String token;

  const DownloadButton({
    Key? key,
    required this.videoId,
    required this.videoTitle,
    required this.subtitle,
    required this.image,
    required this.videoTrailer,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DownloadsController>()) {
      Get.put(DownloadsController());
    }
    final controller = Get.find<DownloadsController>();

    return Obx(() {
      final isDownloading = controller.isDownloading(videoId);
      final isDownloaded = controller.isItemDownloaded(videoId);
      final progress = controller.getProgress(videoId);

      final Color bgColor = isDownloaded
          ? const Color(0xFF1a7a3a)
          : isDownloading ? Colors.grey.shade800 : Colors.grey.shade900;

      final String label = isDownloaded
          ? 'Downloaded'
          : isDownloading ? '${(progress * 100).toStringAsFixed(0)}%' : 'Download';

      final IconData icon = isDownloaded
          ? Icons.check_circle_rounded
          : isDownloading ? Icons.hourglass_top_rounded : Icons.download_rounded;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Opacity(
          opacity: (isDownloading || isDownloaded) ? 0.7 : 1.0,
          child: Tooltip(
            message: isDownloaded ? 'Already Downloaded' : 'Download this video',
            child: GestureDetector(
              onTap: () {
                if (isDownloaded || isDownloading) return;
                showComingSoonPlansPopup(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 40.h,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: bgColor,
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isDownloading)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) => LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.white, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(label, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token') ?? prefs.getString('auth_token') ?? prefs.getString('user_token') ?? '';
}

Future<void> _saveLikedGenres(List<String> genres) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('liked_genres', genres);
}

Future<void> _clearLikedGenres() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('liked_genres');
}

Future<Set<String>> _getLikedGenres() async {
  final prefs = await SharedPreferences.getInstance();
  final genres = prefs.getStringList('liked_genres') ?? [];
  return genres.toSet();
}

