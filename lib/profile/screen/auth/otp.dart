import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/profile/screen/auth/controller/otp_controller.dart';
import 'package:gutrgoopro/profile/screen/auth/otv_verifie_screen.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _showSwipeUI = false;
  final HomeController controller = Get.put(HomeController());
  final LoginController loginController = Get.put(LoginController());
  final TextEditingController _phoneController = TextEditingController();
  final RxBool isPhoneValid = false.obs;

  int _currentPage = 0;
  Timer? _autoScrollTimer;
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _swipeFadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _swipeFadeAnimation;

  final List<String> _images = [
    'assets/img3.jpeg',
    'assets/the_networker.jpeg',
    'assets/img4.png',
    'assets/awasaan_trailer.jpg',
    'assets/red_trailer.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(() {
      isPhoneValid.value = _phoneController.text.length == 10;
    });
    _pageController = PageController(viewportFraction: 0.72, initialPage: 2);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _swipeFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _swipeFadeAnimation = CurvedAnimation(
      parent: _swipeFadeController,
      curve: Curves.easeIn,
    );

    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final isFirst = await LocalStore.isFirstTime();
    if (isFirst) {
      await LocalStore.setFirstTimeDone();
      _showSwipeScreen();
    } else {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/logo.mp4');
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
        _controller!.play();
        _controller!.addListener(() {
          if (_controller!.value.position >= _controller!.value.duration) {
            _showSwipeScreen();
          }
        });
      }
    } catch (e) {
      _showSwipeScreen();
    }
  }

  void _showSwipeScreen() {
    if (!mounted) return;
    setState(() => _showSwipeUI = true);
    _fadeController.forward();
    _swipeFadeController.forward();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _phoneController.dispose();
    _fadeController.dispose();
    _swipeFadeController.dispose();
    _pageController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: _showSwipeUI ? _buildSwipeUI(context) : _buildVideoUI(),
    );
  }

  Widget _buildVideoUI() {
    return _controller != null && _controller!.value.isInitialized
        ? Center(
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
          )
        : const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildSwipeUI(BuildContext context) {
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
                  colors: [Color(0xFF0D1B14), Color(0xFF000000)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      height: 380.h,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 999,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          final realIndex = index % _images.length;
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double page = _pageController.hasClients
                                  ? (_pageController.page ?? index.toDouble())
                                  : index.toDouble();
                              double distance = (page - index).abs();
                              return Transform.scale(
                                scale: (1 - distance * 0.1).clamp(0.85, 1.0),
                                child: Transform.rotate(
                                  angle: (page - index) * -0.1,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        width: (_currentPage % _images.length) == i
                            ? 20.w
                            : 6.w,
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

                  SizedBox(height: 20.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login with Mobile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // PHONE FIELD
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '10-digit mobile number',
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🇮🇳'),
                                    SizedBox(width: 6.w),
                                    const Text(
                                      '+91',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16.w),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // SEND OTP BUTTON
                        Obx(() {
                          // LoginController se values le rahe hain
                          final bool loading = loginController.isSending.value;
                          final bool valid = isPhoneValid.value;

                          return SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: (valid && !loading)
                                  ? () async {
                                      // Yahan loginController use hoga
                                      final success = await loginController
                                          .sendOtp(
                                            _phoneController.text.trim(),
                                          );
                                      if (success) {
                                        Get.to(
                                          () => const OtpVerificationScreen(),
                                        );
                                      } else {
                                        // Agar fail ho jaye toh error dikhane ke liye
                                        Get.snackbar(
                                          "Error",
                                          loginController.errorMessage.value,
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF97316),
                                disabledBackgroundColor: Colors.grey.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        color: valid
                                            ? Colors.white
                                            : Colors.white38,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }),

                        SizedBox(height: 15.h),
                        GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(
                              'https://gutargooplus.com/',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'By continuing, you agree to our ',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms & Privacy Policy',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Center(
                          child: Image.asset(
                            'assets/white_logo.png',
                            height: 36.h,
                            width: 140.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
