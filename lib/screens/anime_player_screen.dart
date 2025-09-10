import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:index/models/anime.dart';
import 'package:index/models/anime_episode.dart';
import 'package:index/screens/base_screen.dart';
import 'package:index/services/anime_service.dart';

class AnimePlayerScreen extends BaseScreen {
  final Anime anime;
  final AnimeEpisode episode;

  const AnimePlayerScreen({
    super.key,
    required this.anime,
    required this.episode,
  });

  @override
  State<AnimePlayerScreen> createState() => _AnimePlayerScreenState();
}

class _AnimePlayerScreenState extends BaseScreenState<AnimePlayerScreen> {
  final AnimeService _animeService = AnimeService();
  VideoPlayerController? _controller;
  List<AnimeStreamSource> _streamSources = [];
  AnimeStreamSource? _currentSource;
  
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = true;
  String? _errorMessage;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  String get screenName => 'Anime Player';

  @override
  Future<void> initializeScreen() async {
    await _loadStreamSources();
    WakelockPlus.enable();
    
    // Hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  Future<void> _loadStreamSources() async {
    setState(() => _isLoading = true);
    
    try {
      final sources = await _animeService.getEpisodeStreamSources(widget.episode.id);
      setState(() {
        _streamSources = sources;
        _isLoading = false;
      });
      
      if (sources.isNotEmpty) {
        await _initializePlayer(sources.first);
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'لا توجد مصادر متاحة لهذه الحلقة';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'فشل في تحميل مصادر التشغيل: $e';
      });
    }
  }

  Future<void> _initializePlayer(AnimeStreamSource source) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
        _currentSource = source;
      });

      await _controller?.dispose();
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(source.url),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
        httpHeaders: source.headers ?? {},
      );

      await _controller!.initialize();
      
      _controller!.addListener(_videoPlayerListener);
      
      await _controller!.play();
      
      setState(() {
        _isLoading = false;
        _isPlaying = true;
        _duration = _controller!.value.duration;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'فشل في تشغيل الحلقة: ${e.toString()}';
      });
    }
  }

  void _videoPlayerListener() {
    if (_controller != null && mounted) {
      final isPlaying = _controller!.value.isPlaying;
      final position = _controller!.value.position;
      final duration = _controller!.value.duration;
      
      if (_isPlaying != isPlaying || _position != position || _duration != duration) {
        setState(() {
          _isPlaying = isPlaying;
          _position = position;
          _duration = duration;
        });
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

  void _seekTo(Duration position) {
    _controller?.seekTo(position);
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

  void _changeQuality(AnimeStreamSource source) {
    if (source != _currentSource) {
      final currentPosition = _controller?.value.position ?? Duration.zero;
      _initializePlayer(source).then((_) {
        if (currentPosition > Duration.zero) {
          _seekTo(currentPosition);
        }
      });
    }
  }

  void _retry() {
    if (_currentSource != null) {
      _initializePlayer(_currentSource!);
    } else {
      _loadStreamSources();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
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
            
            // Bottom Controls
            if (_showControls) _buildBottomControls(),
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
                    widget.anime.displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'الحلقة ${widget.episode.episodeNumber}: ${widget.episode.title}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Quality Selector
            if (_streamSources.length > 1)
              PopupMenuButton<AnimeStreamSource>(
                icon: const Icon(Icons.hd, color: Colors.white),
                onSelected: _changeQuality,
                itemBuilder: (context) => _streamSources.map((source) =>
                  PopupMenuItem(
                    value: source,
                    child: Row(
                      children: [
                        if (source == _currentSource)
                          const Icon(Icons.check, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text('${source.quality} - ${source.server}'),
                      ],
                    ),
                  ),
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.replay_10,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                final newPosition = _position - const Duration(seconds: 10);
                _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
              },
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: _togglePlayPause,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(
                Icons.forward_10,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                final newPosition = _position + const Duration(seconds: 10);
                _seekTo(newPosition > _duration ? _duration : newPosition);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress Bar
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Theme.of(context).primaryColor,
                      overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: _duration.inMilliseconds > 0
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds: (value * _duration.inMilliseconds).round(),
                        );
                        _seekTo(newPosition);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _retry,
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}