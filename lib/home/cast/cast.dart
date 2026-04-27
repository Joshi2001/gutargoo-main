
import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/_discovery_manager/discovery_manager.dart';
import 'package:flutter_chrome_cast/_remote_media_client/remote_media_client.dart';
import 'package:flutter_chrome_cast/_session_manager/cast_session_manager.dart';
import 'package:flutter_chrome_cast/entities/cast_device.dart';
import 'package:flutter_chrome_cast/entities/media_metadata/movie_media_metadata.dart';
import 'package:flutter_chrome_cast/enums/stream_type.dart';
import 'package:flutter_chrome_cast/models/ios/ios_media_information.dart';  
class CastDeviceSheet extends StatelessWidget {
  final String videoUrl;
  final String title;

  const CastDeviceSheet({required this.videoUrl, required this.title});

  Future<void> _connectAndPlay(GoogleCastDevice device, BuildContext context) async {
    Navigator.pop(context);
    try {
      await GoogleCastSessionManager.instance.startSessionWithDevice(device);
      await Future.delayed(const Duration(milliseconds: 800));
      await GoogleCastRemoteMediaClient.instance.loadMedia(
        GoogleCastMediaInformationIOS(
          contentId: videoUrl,
          streamType: CastMediaStreamType.buffered,
          contentUrl: Uri.parse(videoUrl),
          contentType: 'application/x-mpegURL', // HLS
          metadata: GoogleCastMovieMediaMetadata(title: title),
        ),
        autoPlay: true,
        playPosition: Duration.zero,
      );
    } catch (e) {
      debugPrint('Cast error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cast, color: Colors.white),
              SizedBox(width: 10),
              Text('Cast to Device',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<GoogleCastDevice>>(
            stream: GoogleCastDiscoveryManager.instance.devicesStream,
            builder: (context, snapshot) {
              final devices = snapshot.data ?? [];
              if (devices.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Searching for devices...\nMake sure you\'re on the same Wi-Fi.',
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Column(
                children: devices.map((device) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.tv, color: Colors.white70),
                    title: Text(device.friendlyName,
                        style: const TextStyle(color: Colors.white, fontSize: 15)),
                    subtitle: Text(device.modelName ?? '',
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                    onTap: () => _connectAndPlay(device, context),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}