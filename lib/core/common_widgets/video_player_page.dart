import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_colors.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  Object? _error;

  Future<void> _setPortrait() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller = c;
      await c.initialize();
      await c.setLooping(true);
      await c.play();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Keep app orientation flexible when leaving video.
    unawaited(_setPortrait());
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
          (t == null || t.isEmpty) ? 'Video' : t,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to play video.\n${_error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.creamDim),
                ),
              )
            : (c == null || !c.value.isInitialized)
                ? const CircularProgressIndicator(color: AppColors.accentGold)
                : AspectRatio(
                    aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(c),
                        Positioned(
                          bottom: 16,
                          child: _PlayPauseButton(controller: c),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final playing = controller.value.isPlaying;
    return FilledButton.tonalIcon(
      onPressed: () async {
        if (playing) {
          await controller.pause();
        } else {
          await controller.play();
        }
      },
      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
      label: Text(playing ? 'Pause' : 'Play'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color.fromRGBO(212, 175, 55, 0.18),
        foregroundColor: AppColors.textCream,
      ),
    );
  }
}

