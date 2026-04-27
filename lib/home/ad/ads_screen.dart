import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdMobRewardOverlay extends StatefulWidget {
  final VoidCallback onAdFinished;
  final String? vastTagUrl;
  final VoidCallback? onAdStarted;  // ✅ Added callback for when ad starts
  final VoidCallback? onAdError;     // ✅ Added callback for ad errors

  const AdMobRewardOverlay({
    super.key,
    required this.onAdFinished,
    this.vastTagUrl,
    this.onAdStarted,
    this.onAdError,
  });

  @override
  State<AdMobRewardOverlay> createState() => _AdMobRewardOverlayState();
}

class _AdMobRewardOverlayState extends State<AdMobRewardOverlay> {
  late final WebViewController _webViewController;
  bool _adFinished = false;
  bool _isLoading = true;
  bool _canSkip = false;
  bool _adStarted = false;
  int _skipCountdown = 5;
  Timer? _skipTimer;
  Timer? _timeoutTimer;
  Timer? _loadTimeoutTimer;
  Timer? _heartbeatTimer;  // ✅ Track ad playback health

  String get _correlator =>
      DateTime.now().millisecondsSinceEpoch.toString();

  String get _vastUrl {
    if (widget.vastTagUrl != null && widget.vastTagUrl!.isNotEmpty) {
      return widget.vastTagUrl!;
    }
    return 'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_preroll_skippable&sz=640x480&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&correlator=$_correlator';
  }

  String get _adHtml {
    final escapedUrl = _vastUrl.replaceAll("'", "\\'");
    
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%; height: 100%;
      background: #000;
      overflow: hidden;
    }
    #video-content {
      position: absolute;
      width: 1px; height: 1px;
      opacity: 0;
      pointer-events: none;
    }
    #ad-container {
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
      background: #000;
    }
    #ad-container video {
      width: 100% !important;
      height: 100% !important;
      object-fit: contain !important;
      background: #000;
    }
    .debug-info {
      position: absolute;
      bottom: 10px;
      left: 10px;
      color: white;
      background: rgba(0,0,0,0.5);
      font-size: 10px;
      padding: 2px 5px;
      z-index: 100;
      display: none;
    }
  </style>
</head>
<body>

  <video
    id="video-content"
    playsinline
    muted
    src="data:video/mp4;base64,AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMW1wNDEAAAAIZnJlZQAAA..."
  ></video>

  <div id="ad-container"></div>
  <div id="debug" class="debug-info"></div>

  <script src="https://imasdk.googleapis.com/js/sdkloader/ima3.js"></script>
  <script>
    var adDisplayContainer, adsLoader, adsManager;
    var videoContent = document.getElementById('video-content');
    var adContainer  = document.getElementById('ad-container');
    var adStarted    = false;
    var initAttempts = 0;
    var adComplete   = false;
    var debugDiv = document.getElementById('debug');

    function debugLog(msg) {
      console.log(msg);
      if (debugDiv) debugDiv.innerText = msg;
    }

    function notify(msg) {
      if (window.AdChannel && window.AdChannel.postMessage) {
        window.AdChannel.postMessage(msg);
      }
    }

    function initIMA() {
      debugLog('Initializing IMA...');
      
      try {
        if (typeof google === 'undefined' || typeof google.ima === 'undefined') {
          debugLog('IMA SDK not loaded yet, retrying...');
          initAttempts++;
          if (initAttempts < 15) {
            setTimeout(initIMA, 500);
          } else {
            debugLog('IMA SDK failed to load');
            notify('AD_ERROR');
          }
          return;
        }
        
        debugLog('IMA SDK loaded, setting up...');
        
        google.ima.settings.setDisableCustomPlaybackForIOS10Plus(true);
        
        adDisplayContainer = new google.ima.AdDisplayContainer(adContainer, videoContent);
        adDisplayContainer.initialize();
        
        adsLoader = new google.ima.AdsLoader(adDisplayContainer);
        adsLoader.addEventListener(
          google.ima.AdsManagerLoadedEvent.Type.ADS_MANAGER_LOADED,
          onAdsManagerLoaded,
          false
        );
        adsLoader.addEventListener(
          google.ima.AdErrorEvent.Type.AD_ERROR,
          onAdError,
          false
        );
        
        var adsRequest = new google.ima.AdsRequest();
        adsRequest.adTagUrl = '$escapedUrl';
        adsRequest.linearAdSlotWidth = window.innerWidth;
        adsRequest.linearAdSlotHeight = window.innerHeight;
        adsRequest.setAdWillAutoPlay(true);
        adsRequest.setAdWillPlayMuted(false);
        
        debugLog('Requesting ads from: $escapedUrl');
        adsLoader.requestAds(adsRequest);
        
      } catch(e) {
        debugLog('Init error: ' + e.toString());
        notify('AD_ERROR');
      }
    }

    function onAdsManagerLoaded(adsManagerLoadedEvent) {
      debugLog('Ads manager loaded');
      
      try {
        adsManager = adsManagerLoadedEvent.getAdsManager(videoContent);
        
        adsManager.addEventListener(google.ima.AdErrorEvent.Type.AD_ERROR, onAdError);
        adsManager.addEventListener(google.ima.AdEvent.Type.STARTED, onAdStarted);
        adsManager.addEventListener(google.ima.AdEvent.Type.COMPLETE, onAdDone);
        adsManager.addEventListener(google.ima.AdEvent.Type.SKIPPED, onAdDone);
        adsManager.addEventListener(google.ima.AdEvent.Type.ALL_ADS_COMPLETED, onAdDone);
        
        adsManager.init(
          window.innerWidth,
          window.innerHeight,
          google.ima.ViewMode.NORMAL
        );
        adsManager.start();
        
      } catch(e) {
        debugLog('Ads manager error: ' + e.toString());
        notify('AD_ERROR');
      }
    }

    function onAdStarted() {
      debugLog('Ad started');
      if (!adStarted) {
        adStarted = true;
        notify('AD_STARTED');
      }
    }

    function onAdDone() {
      debugLog('Ad completed/skipped');
      if (!adComplete) {
        adComplete = true;
        notify('AD_COMPLETE');
      }
    }

    function onAdError(event) {
      var errorMsg = 'Unknown error';
      if (event.getError) {
        var error = event.getError();
        errorMsg = error.toString();
      }
      debugLog('Ad error: ' + errorMsg);
      notify('AD_ERROR');
    }

    window.addEventListener('load', function() {
      debugLog('Page loaded, starting IMA init...');
      setTimeout(initIMA, 100);
    });
  </script>
</body>
</html>
''';
  }

  @override
  void initState() {
    super.initState();
    
    debugPrint('🎬 AdMobRewardOverlay initialized');
    debugPrint('   VAST URL: ${widget.vastTagUrl ?? 'null'}');

    // ✅ 20 second total timeout for ad loading
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!_adFinished && mounted) {
        debugPrint("⏱️ Ad timeout (20s) — finishing");
        _finish();
      }
    });
    
    // ✅ 8 second load timeout - if no response, skip
    _loadTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (!_adStarted && !_adFinished && mounted) {
        debugPrint("⏱️ No ad response after 8s — skipping");
        _finish();
      }
    });

    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          debugPrint("📄 WebView loaded");
        },
        onWebResourceError: (error) {
          debugPrint("❌ WebView error: ${error.description}");
          if (!_adFinished && mounted) {
            _finish();
          }
        },
      ))
      ..addJavaScriptChannel(
        'AdChannel',
        onMessageReceived: (message) {
          debugPrint("📢 Ad message: ${message.message}");

          if (_adFinished) return;

          switch (message.message) {
            case 'AD_STARTED':
              debugPrint("✅ Ad started playing");
              widget.onAdStarted?.call();  // ✅ Notify parent
              if (mounted) {
                setState(() {
                  _adStarted = true;
                  _isLoading = false;
                });
                _startSkipTimer();
                _loadTimeoutTimer?.cancel();
                _startHeartbeat();  // ✅ Start heartbeat to monitor ad
              }
              break;

            case 'AD_COMPLETE':
              debugPrint("✅ Ad completed");
              _finish();
              break;

            case 'AD_ERROR':
              debugPrint("❌ Ad error");
              widget.onAdError?.call();  // ✅ Notify parent
              _finish();
              break;
          }
        },
      )
      ..loadHtmlString(
        _adHtml,
        baseUrl: 'https://pubads.g.doubleclick.net',
      );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_adFinished || !mounted) {
        timer.cancel();
        return;
      }
      
      // ✅ Check if ad is still responsive
      _webViewController.runJavaScript('''
        if (typeof adsManager !== 'undefined' && adsManager) {
          try {
            var ad = adsManager.getCurrentAd();
            if (ad && ad.isLinear()) {
              console.log('Ad heartbeat OK');
            }
          } catch(e) {
            console.log('Heartbeat error: ' + e);
          }
        }
      ''');
    });
  }

  void _startSkipTimer() {
    _skipTimer?.cancel();
    _skipCountdown = 5;
    _skipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _adFinished) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          _skipCountdown--;
          if (_skipCountdown <= 0) {
            _canSkip = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _finish() {
    if (_adFinished) return;
    
    debugPrint("🏁 Finishing ad overlay");
    _adFinished = true;
    
    _skipTimer?.cancel();
    _timeoutTimer?.cancel();
    _loadTimeoutTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    // ✅ Clean up WebView properly
    _cleanupWebView();
    
    if (mounted) {
      widget.onAdFinished();
    }
  }

  void _cleanupWebView() async {
    try {
      // ✅ Stop any playing ad
      await _webViewController.runJavaScript('''
        if (typeof adsManager !== 'undefined' && adsManager) {
          try {
            adsManager.destroy();
          } catch(e) {}
        }
        if (typeof adsLoader !== 'undefined' && adsLoader) {
          try {
            adsLoader.destroy();
          } catch(e) {}
        }
      ''');
      
      // ✅ Clear the WebView
      await _webViewController.loadHtmlString('<html><body style="background:#000"></body></html>');
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  @override
  void dispose() {
    debugPrint("🗑️ Disposing AdMobRewardOverlay");
    _skipTimer?.cancel();
    _timeoutTimer?.cancel();
    _loadTimeoutTimer?.cancel();
    _heartbeatTimer?.cancel();
    _cleanupWebView();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Black background behind WebView
        Container(color: Colors.black),
        
        // WebView - full screen ad
        Positioned.fill(
          child: WebViewWidget(controller: _webViewController),
        ),

        // Loading indicator (only show for first 5 seconds)
        if (_isLoading && !_adStarted)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.red,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Loading ad...",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // "Ad" label (always visible)
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white30),
            ),
            child: const Text(
              "Advertisement",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // ✅ Skip button (only after ad starts)
        if (_adStarted)
          Positioned(
            bottom: 20,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _canSkip
                  ? GestureDetector(
                      key: const ValueKey('skip'),
                      onTap: () {
                        debugPrint("⏭ User skipped ad");
                        _finish();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white60),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Skip Ad",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.skip_next, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('countdown'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        "Skip in $_skipCountdown",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}