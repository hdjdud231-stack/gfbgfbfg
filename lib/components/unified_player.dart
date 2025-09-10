import "dart:io";

import "package:flutter/material.dart";
import "package:index/components/semo_player.dart";
import "package:index/components/webview_player.dart" as webview;
import "package:index/models/media_stream.dart";
import "package:index/enums/media_type.dart";

class UnifiedPlayer extends StatelessWidget {
  const UnifiedPlayer({
    super.key,
    required this.stream,
    required this.title,
    this.subtitle,
    this.subtitleFiles,
    this.initialProgress = 0,
    this.tmdbId,
    this.seasonId,
    this.episodeId,
    this.mediaType,
    this.onProgress,
    this.onError,
    this.onPlaybackComplete,
    this.onBack,
    this.showBackButton = true,
    this.autoPlay = true,
    this.autoHideControlsDelay = const Duration(seconds: 5),
  });

  final MediaStream stream;
  final String title;
  final String? subtitle;
  final List<File>? subtitleFiles;
  final int initialProgress;
  final int? tmdbId;
  final int? seasonId;
  final int? episodeId;
  final MediaType? mediaType;
  final OnProgressCallback? onProgress;
  final OnErrorCallback? onError;
  final Function(int progressSeconds)? onPlaybackComplete;
  final Function(int progressSeconds)? onBack;
  final bool showBackButton;
  final bool autoPlay;
  final Duration autoHideControlsDelay;

  bool _isWebViewUrl(String url) {
    // Check if URL is from web-based players that need WebView
    return url.contains('multiembed.mov') || 
           url.contains('superembed') ||
           url.contains('vidsrc.to') ||
           url.contains('vidsrc.xyz') ||
           url.contains('embed.su') ||
           url.contains('embed') ||
           url.contains('.php') ||
           url.contains('player') ||
           url.startsWith('https://') && !url.contains('.mp4') && !url.contains('.m3u8');
  }

  @override
  Widget build(BuildContext context) {
    // Check if stream URL is valid
    if (stream.url.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'لا يمكن العثور على رابط البث',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isWebViewUrl(stream.url)) {
      // Use WebView player for embed URLs
      return webview.WebViewPlayer(
        stream: stream,
        title: title,
        subtitle: subtitle,
        onProgress: onProgress,
        onError: onError,
        onPlaybackComplete: onPlaybackComplete,
        onBack: onBack,
        showBackButton: showBackButton,
        autoHideControlsDelay: autoHideControlsDelay,
      );
    } else {
      // Use native video player for direct video URLs
      return SemoPlayer(
        stream: stream,
        title: title,
        subtitle: subtitle,
        subtitleFiles: subtitleFiles,
        initialProgress: initialProgress,
        tmdbId: tmdbId,
        seasonId: seasonId,
        episodeId: episodeId,
        mediaType: mediaType,
        onProgress: onProgress,
        onError: onError,
        onPlaybackComplete: onPlaybackComplete,
        onBack: onBack,
        showBackButton: showBackButton,
        autoPlay: autoPlay,
        autoHideControlsDelay: autoHideControlsDelay,
      );
    }
  }
}