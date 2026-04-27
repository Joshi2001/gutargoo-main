// lib/widget/smart_image.dart

import 'dart:convert';
import 'package:flutter/material.dart';

/// Renders network URLs, asset paths, or base64 data URIs uniformly.
class SmartImage extends StatelessWidget {
  final String src;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SmartImage({
    Key? key,
    required this.src,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  Widget get _fallback =>
      errorWidget ??
      Container(
        height: height,
        width: width,
        color: Colors.grey.shade900,
        child: const Center(
          child: Icon(Icons.movie, color: Colors.white38, size: 36),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final child = _buildImage();
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _buildImage() {
    if (src.isEmpty) return _fallback;

    // ── base64 data URI ───────────────────────────────────────────────────
    if (src.startsWith('data:image')) {
      try {
        final base64Str = src.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => _fallback,
        );
      } catch (_) {
        return _fallback;
      }
    }

    // ── network URL ───────────────────────────────────────────────────────
    if (src.startsWith('http')) {
      return Image.network(
        src,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (_, child, progress) =>
            progress == null
                ? child
                : Container(
                    height: height,
                    width: width,
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white38,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
        errorBuilder: (_, __, ___) => _fallback,
      );
    }

    // ── asset path ────────────────────────────────────────────────────────
    return Image.asset(
      src,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback,
    );
  }
}