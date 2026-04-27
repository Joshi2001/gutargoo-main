import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ================= MODEL =================
class VideoModel {
  final String id;
  final String title;
  final String playUrl;
  final int totalEpisodes;
  final int likesCount;
  final int savesCount;
  final List<Episode> episodes;

  VideoModel({
    required this.id,
    required this.title,
    required this.playUrl,
    required this.totalEpisodes,
    required this.likesCount,
    required this.savesCount,
    required this.episodes,
  });
}

class Episode {
  final String id;
  final String title;
  final String playUrl;

  Episode({
    required this.id,
    required this.title,
    required this.playUrl,
  });
}

/// ================= CONTROLLER =================
class VideoPlayerController extends GetxController {
  late BetterPlayerController betterPlayerController;

  RxBool isPlaying = false.obs;
  RxBool isLiked = false.obs;
  RxBool isSaved = false.obs;

  RxInt likeCount = 0.obs;
  RxInt saveCount = 0.obs;

  Rx<Duration> position = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;

  Rx<VideoModel?> videoModel = Rx<VideoModel?>(null);

  void init(VideoModel video) {
   print("🔥 INIT VIDEO URL: ${video.playUrl}");

  assert(
    video.playUrl.startsWith('http'),
    'playUrl must be a network URL: ${video.playUrl}',
  );
  // ✅ Dispose old controller if it exists
  if (isInitialized) {
    betterPlayerController.removeEventsListener(_eventsListener);
    betterPlayerController.dispose();
  }

  videoModel.value = video;
  likeCount.value = video.likesCount;
  saveCount.value = video.savesCount;
  isLiked.value = false;
  isSaved.value = false;

final dataSource = BetterPlayerDataSource(
  BetterPlayerDataSourceType.network,
  video.playUrl,
  videoFormat: BetterPlayerVideoFormat.other,
  headers: {
    "User-Agent": "Mozilla/5.0", // 👈 IMPORTANT
  },
  cacheConfiguration: const BetterPlayerCacheConfiguration(
    useCache: false,
  ),
);

  betterPlayerController = BetterPlayerController(
    const BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,
      controlsConfiguration:
          BetterPlayerControlsConfiguration(showControls: false),
    ),
    betterPlayerDataSource: dataSource,
  );

  betterPlayerController.addEventsListener(_eventsListener);
  isInitialized = true;
}

bool isInitialized = false;

void _eventsListener(BetterPlayerEvent event) {
  if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
    position.value = event.parameters?['progress'] ?? Duration.zero;
    duration.value = event.parameters?['duration'] ?? Duration.zero;
  }
  if (event.betterPlayerEventType == BetterPlayerEventType.play) {
    isPlaying.value = true;
  }
  if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
    isPlaying.value = false;
  }
}

@override
void onClose() {
  if (isInitialized) {
    betterPlayerController.removeEventsListener(_eventsListener);
    betterPlayerController.dispose();
  }
  super.onClose();
}

  void togglePlayPause() {
    if (isPlaying.value) {
      betterPlayerController.pause();
    } else {
      betterPlayerController.play();
    }
  }

  void toggleLike() {
    isLiked.value = !isLiked.value;
    likeCount.value += isLiked.value ? 1 : -1;
  }

  void toggleSave() {
    isSaved.value = !isSaved.value;
    saveCount.value += isSaved.value ? 1 : -1;
  }

  void shareVideo() {
    Get.snackbar("Share", "Share clicked 🔥");
  }

  String formatCount(int num) {
    if (num > 1000) return "${(num / 1000).toStringAsFixed(1)}K";
    return num.toString();
  }
}

VideoModel getDummyVideo() {
  return VideoModel(
    id: "demo",
    title: "Demo Reel 🔥",
    playUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    totalEpisodes: 2,
    likesCount: 120,
    savesCount: 40,
    episodes: [],
  );
}

class PotliReelScreen extends StatefulWidget {
  final VideoModel video;

  const PotliReelScreen({super.key, required this.video});

  @override
  State<PotliReelScreen> createState() => _PotliReelScreenState();
}

class _PotliReelScreenState extends State<PotliReelScreen> {
  late final VideoPlayerController ctrl;

  @override
  void initState() {
    super.initState();

    ctrl = Get.put(VideoPlayerController(), tag: widget.video.id);
    ctrl.init(widget.video);
  }

  @override
  void dispose() {
    Get.delete<VideoPlayerController>(tag: widget.video.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return Stack(
          children: [
            Positioned.fill(
              child: BetterPlayer(
                controller: ctrl.betterPlayerController,
              ),
            ),

           GestureDetector(
  onTap: ctrl.togglePlayPause,
  child: Container(color: Colors.transparent), 
),

            if (!ctrl.isPlaying.value)
              Center(
                child: Icon(Icons.play_arrow,
                    size: 80, color: Colors.white),
              ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white),
              ),
            ),

            Positioned(
              right: 10,
              bottom: 120,
              child: Column(
                children: [
                  Obx(() => _ActionBtn(
                        icon: ctrl.isLiked.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        text: ctrl.formatCount(ctrl.likeCount.value),
                        onTap: ctrl.toggleLike,
                      )),
                  const SizedBox(height: 20),
                  Obx(() => _ActionBtn(
                        icon: ctrl.isSaved.value
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        text: ctrl.formatCount(ctrl.saveCount.value),
                        onTap: ctrl.toggleSave,
                      )),
                  const SizedBox(height: 20),
                  _ActionBtn(
                    icon: Icons.grid_view,
                    text: "Episodes",
                    onTap: () => _showEpisodes(context),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(() {
                final pos = ctrl.position.value.inSeconds.toDouble();
                final dur = ctrl.duration.value.inSeconds.toDouble();

                return LinearProgressIndicator(
                  value: dur == 0 ? 0 : pos / dur,
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  void _showEpisodes(BuildContext context) {
    final episodes = ctrl.videoModel.value?.episodes ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: episodes.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (_, i) {
            final ep = episodes[i];
            return GestureDetector(
              onTap: () {
              Navigator.pop(context);
ctrl.betterPlayerController.setupDataSource(
  BetterPlayerDataSource(
    BetterPlayerDataSourceType.network,
    ep.playUrl,
    videoFormat: BetterPlayerVideoFormat.other,
    cacheConfiguration: const BetterPlayerCacheConfiguration(
      useCache: false,
    ),
  ),
);
              },
              child: Card(
                child: Center(child: Text(ep.title)),
              ),
            );
          },
        );
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
        ),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

