import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_bind.dart';
import 'package:gutrgoopro/bottombar/bottom_binding.dart';
import 'package:gutrgoopro/profile/screen/auth/controller/otp_controller.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> with TickerProviderStateMixin {
  final LoginController controller = Get.find<LoginController>();
  final TextEditingController pinController = TextEditingController();

  // Timer logic
  int _remainingTime = 300;
  Timer? _timer;
  bool canResend = false;

  // Animation & Swipe UI
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

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
    _startTimer();
    
    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: 500, 
    );

    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000)
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    _fadeController.forward();
    _startAutoScroll();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      _pageController.animateToPage(
        _pageController.page!.toInt() + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 300;
      canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        setState(() => canResend = true);
      }
    });
  }

  String get _timerText {
    final m = _remainingTime ~/ 60;
    final s = _remainingTime % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _handleVerifyOtp(String pin) async {
    if (pin.length != 6) return;
    final success = await controller.verifyOtp(pin);
    if (success) {
      await LocalStore.setLoggedIn(true);
      Get.offAll(
        () => const BottomNavigationScreen(initialIndex: 0),
        binding: BottomBindings(),
      );
    } else {
      pinController.clear();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoScrollTimer?.cancel();
    _fadeController.dispose();
    _pageController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient (Same as Login)
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
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),

                  // Animated Swipe Cards
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      height: 360.h,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 9999,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          final realIndex = index % _images.length;
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double page = _pageController.hasClients ? (_pageController.page ?? index.toDouble()) : index.toDouble();
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
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Image.asset(_images[realIndex], fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: (_currentPage % _images.length) == i ? 20.w : 6.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: (_currentPage % _images.length) == i ? Colors.white : Colors.white30,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    )),
                  ),

                  SizedBox(height: 25.h),

                  // Bottom Verification Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verify OTP',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12.h),

                        // Phone Display box (Login style)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Obx(() => Text(
                            '+91 ${controller.phoneNumber.value}',
                            style: TextStyle(color: Colors.white70, fontSize: 15.sp, letterSpacing: 1.2),
                          )),
                        ),

                        SizedBox(height: 20.h),

                        // Pin Input
                        Center(
                          child: Pinput(
                            controller: pinController,
                            length: 6,
                            defaultPinTheme: PinTheme(
                              width: 46.w,
                              height: 52.h,
                              textStyle: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.w600),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.white12),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 46.w,
                              height: 52.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: const Color(0xFFF97316), width: 1.5.w),
                              ),
                            ),
                            onCompleted: _handleVerifyOtp,
                          ),
                        ),

                        SizedBox(height: 15.h),

                        // Timer & Resend Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              canResend ? 'OTP expired' : 'Expires in $_timerText',
                              style: TextStyle(
                                color: _remainingTime < 60 ? Colors.red.shade400 : Colors.grey.shade600,
                                fontSize: 12.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: canResend ? () async {
                                final success = await controller.resendOtp();
                                if(success) _startTimer();
                              } : null,
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: canResend ? const Color(0xFFF97316) : Colors.grey.shade800,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 25.h),

                        // Verify Button
                        Obx(() {
                          final isLoading = controller.isVerifying.value;
                          return SizedBox(
                            width: double.infinity,
                            height: 54.h,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () => _handleVerifyOtp(pinController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF97316),
                                disabledBackgroundColor: Colors.grey.shade900,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Verify & Continue', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }),

                        SizedBox(height: 15.h),

                        // Back to login
                        Center(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Change Phone Number?',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp, decoration: TextDecoration.underline),
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // Terms
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'By continuing, you agree to our ',
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                              children: [
                                TextSpan(
                                  text: 'Terms & Privacy Policy',
                                  style: TextStyle(color: Colors.blue.shade400, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
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
