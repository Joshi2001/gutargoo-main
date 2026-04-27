import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_bind.dart';
import 'package:gutrgoopro/bottombar/bottom_binding.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/profile/screen/auth/otp.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController? _controller;
  bool _hasNavigated = false;
  bool _showSwipeUI = false;
  bool _isFirstTime = true;
  bool _isInitialized = false;
  int _currentPage = 0;
  double _sliderValue = 0.0;
  bool _isUnlocking = false;

  late HomeController controller;
  Timer? _autoScrollTimer;
  Timer? _videoTimer;

  late PageController _pageController;
  late AnimationController _arrowController;
  late AnimationController _fadeController;
  late AnimationController _swipeFadeController;
  late Animation<double> _arrowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _swipeFadeAnimation;

  final List<String> _images = [
    'assets/img3.jpeg',
    'assets/1.png',
    'assets/img4.png',
    'assets/awasaan_trailer.jpg',
    'assets/red_trailer.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Initialize controller
    if (!Get.isRegistered<HomeController>()) {
      controller = Get.put(HomeController());
    } else {
      controller = Get.find<HomeController>();
    }

    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: 2,
    );

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _swipeFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _arrowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _swipeFadeAnimation = CurvedAnimation(
      parent: _swipeFadeController,
      curve: Curves.easeIn,
    );

    _controller = null;
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    try {
      final isFirst = await LocalStore.isFirstTime();
 controller.fetchPopupData();
   controller.fetchHomeData(); 
      if (!mounted) return;

      if (isFirst) {
        await LocalStore.setFirstTimeDone();
        if (mounted) {
          setState(() {
            _isFirstTime = true;
            _showSwipeUI = true;
            _isInitialized = true;
          });
        }
        _showSwipeScreen();
      } else {
        setState(() {
          _isFirstTime = false;
          _isInitialized = true;
        });
        _initializeVideo();
      }
    } catch (e) {
      debugPrint('❌ Check First Time Error: $e');
      if (mounted) {
        setState(() => _isInitialized = true);
        _navigateToHome();
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/logo.mp4');
      await _controller!.initialize();

      if (!mounted) return;

      setState(() {});

      if (_controller!.value.isInitialized) {
        _controller!.addListener(_videoListener);
        await _controller!.play();

        _videoTimer = Timer(const Duration(seconds: 5), () {
          if (!_hasNavigated && mounted) {
            debugPrint('⏱️ Video timeout - navigating...');
            _navigateToHome();
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Video initialization error: $e');
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  void _videoListener() {
    if (_controller == null ||
        _controller!.value.position >= _controller!.value.duration) {
      if (!_hasNavigated && mounted) {
        debugPrint('✅ Video completed - navigating...');
        _videoTimer?.cancel();
        _navigateToHome();
      }
    }
  }

  void _showSwipeScreen() {
    if (!mounted) return;

    _fadeController.forward();
    _swipeFadeController.forward();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

Future<void> _navigateToHome({bool forceHome = false}) async {
  if (!_hasNavigated && mounted) {
    _hasNavigated = true;
    _autoScrollTimer?.cancel();
    _videoTimer?.cancel();

    if (_isFirstTime) {
      setState(() => _isUnlocking = true);
    }
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    try {
      final isLoggedIn = await LocalStore.isLoggedIn();

      if (forceHome || isLoggedIn) {
        // ← Popup already fetch ho chuka hoga, HomeScreen turant dikhayega
        Get.offAll(
          () => const BottomNavigationScreen(initialIndex: 0),
          binding: BottomBindings(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      } else {
        Get.offAll(
          () => const PhoneLoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
    }
  }
}
  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _videoTimer?.cancel();
    _arrowController.dispose();
    _fadeController.dispose();
    _swipeFadeController.dispose();
    _pageController.dispose();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _showSwipeUI ? _buildSwipeUI(context) : _buildVideoUI(),
    );
  }

 Widget _buildVideoUI() {
  if (_controller == null || !_controller!.value.isInitialized) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0), 
    child: SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    ),
  );
}

  Widget _buildSwipeUI(BuildContext context) {
    final double sliderWidth = 1.sw - 60.w;

    return FadeTransition(
      opacity: _swipeFadeAnimation,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D1B14),
                    Color(0xFF0D1B14),
                    Color(0xFF000000),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    height: 440.h,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 99999,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final realIndex = index % _images.length;
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double page = _pageController.hasClients &&
                                    _pageController.position.haveDimensions
                                ? (_pageController.page ?? index.toDouble())
                                : index.toDouble();
                            double distance = (page - index).abs();
                            double scale =
                                (1 - distance * 0.12).clamp(0.85, 1.0);
                            double angle = (page - index) * -0.18;
                            double translateY = distance * 20;

                            return Transform.translate(
                              offset: Offset(0, translateY),
                              child: Transform.scale(
                                scale: scale,
                                child: Transform.rotate(
                                  angle: angle,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 10.h,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: Image.asset(
                                _images[realIndex],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: (_currentPage % _images.length) == i ? 24.w : 6.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: (_currentPage % _images.length) == i
                            ? Colors.white
                            : Colors.white30,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      children: [
                        Text(
                          'Watch On\nAny Device Free',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Discover unlimited entertainments',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Container(
                    height: 62.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(40.r),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40.r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 30),
                            width: 60.r +
                                (_sliderValue * (sliderWidth - 50.r)),
                            height: 62.h,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 155, 8, 8)
                                  .withOpacity(0.25),
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              FadeTransition(
                                opacity: _arrowAnimation,
                                child: Text(
                                  '>>>',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16.sp,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: _sliderValue * (sliderWidth - 50.r),
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                double newVal = _sliderValue +
                                    details.delta.dx / (sliderWidth - 50.r);
                                _sliderValue = newVal.clamp(0.0, 1.0);
                              });
                              if (_sliderValue >= 0.88) {
                                _navigateToHome(forceHome: true);
                              }
                            },
                            onHorizontalDragEnd: (_) {
                              if (!_hasNavigated) {
                                setState(() => _sliderValue = 0.0);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(6.r),
                              height: 50.r,
                              width: 49.r,
                              child: _isUnlocking
                                  ? Padding(
                                      padding: EdgeInsets.all(10.r),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/ic_launch.png',
                                      height: 18.r,
                                      width: 18.r,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}