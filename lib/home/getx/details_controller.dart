import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';

class DetailsController extends GetxController {

  var isFavorite  = false.obs;
  var isShare     = false.obs;
  var isDownload  = false.obs;
  var currentTab  = 'iptv'.obs;
  var shareTab    = 'share'.obs;
  var downloadTab = 'dow'.obs;

  void toggleFavorite() => isFavorite.value  = !isFavorite.value;
  void toggleShare()    => isShare.value     = !isShare.value;
  void toggleDownload() => isDownload.value  = !isDownload.value;

  void changeTab(String tab) {
    currentTab.value  = tab;
    shareTab.value    = tab;
    downloadTab.value = tab;
  }
  final RxList<Map<String, String>> castList = <Map<String, String>>[].obs;

void loadFromModel(MovieModel movie) {
  debugPrint('=== loadFromModel called ===');
  
  final List<Map<String, String>> list = [
    ...movie.director.map((e) => {
      'name': e.name,
      'role': 'Director',
      'character': '',
      'image': e.imageUrl,
    }),
    ...movie.producer.map((e) => {
      'name': e.name,
      'role': 'Producer',
      'character': '',
      'image': e.imageUrl,
    }),
    ...movie.writer.map((e) => {
      'name': e.name,
      'role': 'Writer',
      'character': '',
      'image': e.imageUrl,
    }),
    ...movie.musicDirector.map((e) => {
      'name': e.name,
      'role': 'Music Director',
      'character': '',
      'image': e.imageUrl,
    }),
    ...movie.cinematographer.map((e) => {
      'name': e.name,
      'role': 'Cinematographer',
      'character': '',
      'image': e.imageUrl,
    }),
    ...movie.editor.map((e) => {
      'name': e.name,
      'role': 'Editor',
      'character': '',
      'image': e.imageUrl,
    }),
    // ✅ castMembers was missing
    ...movie.castMembers.map((e) => {
      'name': e.name,
      'role': 'Actor',
      'character': e.character,
      'image': e.imageUrl,
    }),
  ];

  castList.assignAll(list);
  debugPrint('✅ Total cast loaded: ${castList.length}');
}
}
