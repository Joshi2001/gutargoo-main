import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_bind.dart';
import 'package:gutrgoopro/bottombar/bottom_binding.dart';
import 'dart:ui';
import 'package:gutrgoopro/profile/screen/auth/otp.dart';
import 'package:gutrgoopro/uitls/local_store.dart';

void showSignOutPopup(BuildContext context) {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: screenWidth * 0.85,
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A2A4F).withOpacity(0.95),
                  const Color(0xFF000000).withOpacity(0.95),
                  const Color(0xFF2B0A3D).withOpacity(0.90),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:  EdgeInsets.only(top: 10.h),
                  child: Image.asset("assets/white_logo.png",fit: BoxFit.contain,height: 20.h,width: double.infinity),
                ),
                SizedBox(height: screenHeight * 0.02),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFF97316),
                      Color(0xFFEF4444),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    "SIGN OUT",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.015),
                const Text(
                  "Are you sure you want to sign out?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade800,
                                Colors.grey.shade900,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.shade700,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await _signOut();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFF97316),
                                Color(0xFFEF4444),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFF97316).withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Out",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
Future<void> _signOut() async {
  try {
    await LocalStore.logout(); // ✅ Bas yahi kafi hai
    
    Get.deleteAll();
    Get.offAll(() => const PhoneLoginScreen());
    
  } catch (e) {
    print('Sign out error: $e');
    Get.offAll(
      () => const BottomNavigationScreen(initialIndex: 0),
      binding: BottomBindings(),
    );
  }
}