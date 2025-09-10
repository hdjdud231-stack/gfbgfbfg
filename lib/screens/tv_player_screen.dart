import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:index/models/tv_channel.dart';
import 'package:index/screens/base_screen.dart';

class TvPlayerScreen extends BaseScreen {
  final TvChannel channel;

  const TvPlayerScreen({
    super.key,
    required this.channel,
  });

  @override
  State<TvPlayerScreen> createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends BaseScreenState<TvPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = true;
  String? _errorMessage;

  @override
  String get screenName => 'TV Player';

  @override
  Future<void> initializeScreen() async {
    await _initializePlayer();
    WakelockPlus.enable();
    
    // Hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      );

      await _controller!.initialize();
      
      _controller!.addListener(_videoPlayerListener);
      
      await _controller!.play();
      
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'فشل في تشغيل القناة: ${e.toString()}';
      });
    }
  }

  void _videoPlayerListener() {
    if (_controller != null && mounted) {
      final isPlaying = _controller!.value.isPlaying;
      if (_isPlaying != isPlaying) {
        setState(() => _isPlaying = isPlaying);
      }

      if (_controller!.value.hasError) {
        setState(() {
          _hasError = true;
          _errorMessage = 'خطأ في التشغيل: ${_controller!.value.errorDescription}';
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    
    if (_showControls) {
      // Hide controls after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _retry() {
    _initializePlayer();
  }

  @override
  void handleDispose() {
    _controller?.removeListener(_videoPlayerListener);
    _controller?.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.handleDispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _hasError
                      ? _buildErrorWidget()
                      : _controller != null && _controller!.value.isInitialized
                          ? GestureDetector(
                              onTap: _toggleControls,
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            )
                          : const CircularProgressIndicator(),
            ),
            
            // Controls Overlay
            if (_showControls) _buildControlsOverlay(),
            
            // Top Bar
            if (_showControls) _buildTopBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            _errorMessage ?? 'حدث خطأ غير متوقع',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _retry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.channel.country != null)
                    Text(
                      widget.channel.country!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.channel.quality != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.channel.quality!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: _togglePlayPause,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _retry,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                // Toggle fullscreen
                if (MediaQuery.of(context).orientation == Orientation.portrait) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ]);
                } else {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}