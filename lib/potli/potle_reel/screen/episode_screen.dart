import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/potli/potle_reel/controller/reel_controller.dart';


class EpisodeSheet extends StatelessWidget {
  final VideoPlayerController controller;

  const EpisodeSheet({super.key, required this.controller});

  static void show(BuildContext context, VideoPlayerController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EpisodeSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = controller.videoModel.value;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    model?.title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔥 EPISODE GRID
          Expanded(
            child: Obx(() {
              final episodes = controller.videoModel.value?.episodes ?? [];

              if (episodes.isEmpty) {
                return const Center(
                  child: Text(
                    "No Episodes",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: episodes.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final ep = episodes[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      controller.switchEpisode(ep as int); 
                    },
                    child: _EpisodeTile(
                      number: index + 1,
                    ),
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// 🔥 EPISODE TILE
class _EpisodeTile extends StatelessWidget {
  final int number;

  const _EpisodeTile({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "$number",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}