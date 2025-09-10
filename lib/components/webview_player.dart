import "dart:async";

import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";
import "package:index/models/media_stream.dart";

typedef OnProgressCallback = void Function(Duration progress, Duration total);
typedef OnErrorCallback = void Function(dynamic error);

class WebViewPlayer extends StatefulWidget {
  const WebViewPlayer({
    super.key,
    required this.stream,
    required this.title,
    this.subtitle,
    this.onProgress,
    this.onError,
    this.onPlaybackComplete,
    this.onBack,
    this.showBackButton = true,
    this.autoHideControlsDelay = const Duration(seconds: 5),
  });

  final MediaStream stream;
  final String title;
  final String? subtitle;
  final OnProgressCallback? onProgress;
  final OnErrorCallback? onError;
  final Function(int progressSeconds)? onPlaybackComplete;
  final Function(int progressSeconds)? onBack;
  final bool showBackButton;
  final Duration autoHideControlsDelay;

  @override
  State<WebViewPlayer> createState() => _WebViewPlayerState();
}

class _WebViewPlayerState extends State<WebViewPlayer> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    // Don't start hide controls timer initially - let user control it
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              // Wait a bit for the page to fully load before injecting CSS
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  _injectCustomCSS();
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView Error: ${error.description}');
            // Only report critical errors
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.timeout) {
              widget.onError?.call(error.description);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow navigation to the same domain or embed domains
            if (request.url.contains('multiembed.mov') ||
                request.url.contains('vidsrc.to') ||
                request.url.contains('vidsrc.xyz') ||
                request.url.contains('embed.su') ||
                request.url.contains(widget.stream.url.split('/')[2])) {
              return NavigationDecision.navigate;
            }
            // Block navigation to external domains (ads, etc.)
            return NavigationDecision.prevent;
          },
        ),
      );
    
    // Set custom headers if provided
    Map<String, String> headers = {};
    if (widget.stream.headers != null) {
      headers.addAll(widget.stream.headers!);
    }
    
    _webViewController.loadRequest(
      Uri.parse(widget.stream.url),
      headers: headers,
    );
  }

  void _injectCustomCSS() {
    // Inject CSS to hide unnecessary elements and improve fullscreen experience
    _webViewController.runJavaScript('''
      try {
        // Hide scroll bars
        document.body.style.overflow = 'hidden';
        document.documentElement.style.overflow = 'hidden';
        
        // Remove margins and padding
        document.body.style.margin = '0';
        document.body.style.padding = '0';
        document.documentElement.style.margin = '0';
        document.documentElement.style.padding = '0';
        
        // Make body full height
        document.body.style.height = '100vh';
        document.documentElement.style.height = '100vh';
        
        // Try to make video fullscreen
        var videos = document.getElementsByTagName('video');
        for (var i = 0; i < videos.length; i++) {
          videos[i].style.width = '100%';
          videos[i].style.height = '100%';
          videos[i].style.objectFit = 'contain';
          videos[i].style.position = 'fixed';
          videos[i].style.top = '0';
          videos[i].style.left = '0';
          videos[i].style.zIndex = '9999';
        }
        
        // Hide common ad elements and overlays
        var selectors = [
          '[id*="ad"]', '[class*="ad"]', '[id*="popup"]', '[class*="popup"]',
          '[id*="overlay"]', '[class*="overlay"]', '[id*="banner"]', '[class*="banner"]',
          '.advertisement', '.ads', '.popup', '.overlay', '.banner'
        ];
        
        selectors.forEach(function(selector) {
          try {
            var elements = document.querySelectorAll(selector);
            elements.forEach(function(el) {
              el.style.display = 'none !important';
            });
          } catch(e) {}
        });
        
        // Try to click play button automatically (but don't force it)
        setTimeout(function() {
          try {
            var playButtons = document.querySelectorAll('button[aria-label*="play"], .play-button, [class*="play"], .vjs-big-play-button');
            for (var i = 0; i < playButtons.length; i++) {
              if (playButtons[i].offsetParent !== null) { // Check if button is visible
                playButtons[i].click();
                break;
              }
            }
          } catch(e) {
            console.log('Could not auto-click play button:', e);
          }
        }, 2000);
        
      } catch(e) {
        console.log('Error injecting CSS:', e);
      }
    ''');
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(widget.autoHideControlsDelay, () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = !_showControls; // Toggle controls instead
    });
    
    // Only start timer if controls are now visible
    if (_showControls) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _showControlsTemporarily,
        child: Stack(
          children: [
            // WebView
            WebViewWidget(controller: _webViewController),
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            
            // Controls overlay
            if (_showControls)
              Positioned(
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
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          if (widget.showBackButton)
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                widget.onBack?.call(0);
                                Navigator.of(context).pop();
                              },
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.subtitle != null)
                                  Text(
                                    widget.subtitle!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}