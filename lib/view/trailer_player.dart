import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Pemutar trailer YouTube. Controller dibuat saat widget muncul dan
/// ditutup saat widget hilang, jadi video berhenti otomatis ketika
/// pengguna pindah dari tab Overview.
class TrailerPlayer extends StatefulWidget {
  final String videoId;

  const TrailerPlayer({super.key, required this.videoId});

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        interfaceLanguage: 'id',
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        // Batasi lebar agar tidak terlalu besar di layar lebar.
        constraints: const BoxConstraints(maxWidth: 760),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }
}