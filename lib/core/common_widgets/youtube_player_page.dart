import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../theme/app_colors.dart';

class YouTubePlayerPage extends StatefulWidget {
  const YouTubePlayerPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<YouTubePlayerPage> createState() => _YouTubePlayerPageState();
}

class _YouTubePlayerPageState extends State<YouTubePlayerPage> {
  YoutubePlayerController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final id = YoutubePlayer.convertUrlToId(widget.url);
    if (id == null || id.trim().isEmpty) {
      _error = 'Invalid YouTube URL';
      return;
    }
    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.title?.trim();
    final c = _controller;
    return Scaffold(
      backgroundColor: AppColors.emeraldDark,
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDark,
        foregroundColor: AppColors.textCream,
        title: Text(
          (t == null || t.isEmpty) ? 'YouTube' : t,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.creamDim),
                ),
              )
            : (c == null)
                ? const CircularProgressIndicator(color: AppColors.accentGold)
                : YoutubePlayer(
                    controller: c,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.accentGold,
                    progressColors: const ProgressBarColors(
                      playedColor: AppColors.accentGold,
                      handleColor: AppColors.goldLight,
                    ),
                  ),
      ),
    );
  }
}

