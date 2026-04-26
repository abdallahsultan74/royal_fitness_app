import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../theme/app_colors.dart';

class VideoWebViewPage extends StatefulWidget {
  const VideoWebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<VideoWebViewPage> createState() => _VideoWebViewPageState();
}

class _VideoWebViewPageState extends State<VideoWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  String _effectiveUrl(String raw) {
    final s = raw.trim();
    final uri = Uri.tryParse(s);
    if (uri == null) return s;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');

    if (host == 'youtu.be') {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (id.isEmpty) return s;
      return 'https://www.youtube.com/embed/$id?autoplay=1&playsinline=1&rel=0';
    }

    if (host.endsWith('youtube.com')) {
      final v = uri.queryParameters['v'];
      final parts = uri.pathSegments;
      final idx = parts.indexWhere((p) => p == 'shorts' || p == 'embed' || p == 'v');
      final id = (v != null && v.trim().isNotEmpty)
          ? v.trim()
          : (idx >= 0 && idx + 1 < parts.length ? parts[idx + 1].trim() : '');
      if (id.isEmpty) return s;
      return 'https://www.youtube.com/embed/$id?autoplay=1&playsinline=1&rel=0';
    }

    if (host.endsWith('vimeo.com')) {
      final segs = uri.pathSegments.where((e) => e.trim().isNotEmpty).toList();
      final id = (segs.isNotEmpty && segs.first == 'video' && segs.length > 1)
          ? segs[1]
          : (segs.isNotEmpty ? segs.first : '');
      if (id.isEmpty) return s;
      return 'https://player.vimeo.com/video/$id?autoplay=1&playsinline=1';
    }

    return s;
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.emeraldDark)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(_effectiveUrl(widget.url)));

    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.title?.trim();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDark,
        foregroundColor: AppColors.textCream,
        title: Text(
          (t == null || t.isEmpty) ? 'Video' : t,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            ),
        ],
      ),
    );
  }
}

