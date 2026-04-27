import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/ad/ad_model.dart/ad_model.dart';
import 'package:gutrgoopro/home/ad/responce/ad_scheduler.dart';
import 'package:gutrgoopro/home/ad/service.dart/ad_service.dart';

class AdController extends GetxController {
  final RxList<AdModel> allAds = <AdModel>[].obs;
  final Rxn<AdModel> activePrerollAd = Rxn<AdModel>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationFuture => _initCompleter.future;

  /// Returns a fresh scheduler for each video session.
  AdScheduler createScheduler() => AdScheduler(allAds.toList());

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 AdController initialized');
    loadAds().then((_) {
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    });
  }

  Future<void> loadAds() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final response = await AdService.fetchAllAds();
      if (response != null && response.success) {
        allAds.assignAll(response.data);
        debugPrint('✅ Total ads: ${allAds.length}');
        activePrerollAd.value =
            AdService.getActivePrerollAdFromList(allAds);
        debugPrint('🎬 Active preroll: ${activePrerollAd.value?.vastUrl}');
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
      debugPrint('❌ AdController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String? get activeVastUrl => activePrerollAd.value?.vastUrl;

  Future<void> ensureLoaded() async {
    if (allAds.isNotEmpty) return;
    if (isLoading.value) {
      await initializationFuture;
    } else {
      await loadAds();
    }
  }
}
