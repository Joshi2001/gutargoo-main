
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:gutrgoopro/home/model/video_model.dart';

class VideoResponse {
  final bool success;
  final List<Video> data;

  VideoResponse({
    required this.success,
    required this.data,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    return VideoResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? List<Video>.from(
              json['data'].map((x) => Video.fromJson(x)),
            )
          : [],
    );
  }
}

class VideoController extends GetxController {


  final selectedCategory = 'All'.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final categories = <String>['All'].obs;
  final Map<String, List<Video>> videoData = {};

  final Rx<Video?> selectedVideo = Rx<Video?>(null);




  void selectCategory(String category) {
    selectedCategory.value = category;

    final list = videoData[category];
    if (list != null && list.isNotEmpty) {
      selectedVideo.value = list.first;
    }
  }

  void selectVideo(Video video) {
    selectedVideo.value = video;
  }

  List<Video> get currentVideos =>
      videoData[selectedCategory.value] ?? [];

}
