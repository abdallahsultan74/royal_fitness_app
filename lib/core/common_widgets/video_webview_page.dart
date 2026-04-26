import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
      ..loadRequest(Uri.parse(widget.url));
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

