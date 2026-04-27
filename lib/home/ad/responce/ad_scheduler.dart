import 'package:flutter/material.dart';
import 'package:gutrgoopro/home/ad/ad_model.dart/ad_model.dart';

/// Tracks which ad positions have already been shown in this video session.
class AdScheduler {
  final List<AdModel> ads;

  /// Keys: 'start', 'mid', 'end', 'custom_N' (where N = seconds), 'multi_N'
  final Set<String> _playedKeys = {};

  AdScheduler(this.ads);

  void reset() => _playedKeys.clear();

  /// Call this every time video position updates.
  /// Returns the ad to show right now, or null if nothing is due.
  AdModel? checkPosition({
    required int currentSeconds,
    required int totalSeconds,
  }) {
    if (totalSeconds <= 0) return null;

    for (final ad in ads) {
      if (!ad.isActive) continue;
      if (ad.vastUrl == null || ad.vastUrl!.isEmpty) continue;

      // ── START ────────────────────────────────────────────────
      if ((ad.positionType == 'start' || ad.showAtStart) &&
          currentSeconds == 0 &&
          !_playedKeys.contains('start')) {
        _playedKeys.add('start');
        debugPrint('🎬 [AdScheduler] Triggering START ad');
        return ad;
      }

      // ── MID ──────────────────────────────────────────────────
      if ((ad.positionType == 'mid' || ad.showAtMid) &&
          !_playedKeys.contains('mid')) {
        final midPoint = totalSeconds ~/ 2;
        if (currentSeconds >= midPoint) {
          _playedKeys.add('mid');
          debugPrint('🎬 [AdScheduler] Triggering MID ad at ${currentSeconds}s');
          return ad;
        }
      }

      // ── END ──────────────────────────────────────────────────
      if ((ad.positionType == 'end' || ad.showAtEnd) &&
          !_playedKeys.contains('end')) {
        final endThreshold = (totalSeconds * 0.92).toInt();
        if (currentSeconds >= endThreshold) {
          _playedKeys.add('end');
          debugPrint('🎬 [AdScheduler] Triggering END ad at ${currentSeconds}s');
          return ad;
        }
      }

      // ── CUSTOM ───────────────────────────────────────────────
      if (ad.positionType == 'custom' && ad.showAt != null) {
        final key = 'custom_${ad.showAt}';
        if (!_playedKeys.contains(key) &&
            currentSeconds >= ad.showAt! &&
            currentSeconds <= ad.showAt! + 2) {
          _playedKeys.add(key);
          debugPrint('🎬 [AdScheduler] Triggering CUSTOM ad at ${ad.showAt}s');
          return ad;
        }
      }

      // ── MULTIPLE ─────────────────────────────────────────────
      if (ad.positionType == 'multiple') {
        for (final pos in ad.multiplePositions) {
          final key = 'multi_$pos';
          if (!_playedKeys.contains(key) &&
              currentSeconds >= pos &&
              currentSeconds <= pos + 2) {
            _playedKeys.add(key);
            debugPrint(
                '🎬 [AdScheduler] Triggering MULTIPLE ad at ${pos}s');
            return ad;
          }
        }
      }
    }

    return null;
  }

  /// Convenience: get a start ad immediately (used on video load).
  AdModel? getStartAd() {
    for (final ad in ads) {
      if (!ad.isActive) continue;
      if (ad.vastUrl == null || ad.vastUrl!.isEmpty) continue;
      if (ad.positionType == 'start' || ad.showAtStart) {
        if (!_playedKeys.contains('start')) {
          _playedKeys.add('start');
          return ad;
        }
      }
    }
    return null;
  }
}