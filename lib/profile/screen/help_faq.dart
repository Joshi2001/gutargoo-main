import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HelpFAQScreen extends StatelessWidget {
  const HelpFAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🖤 deep black base
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help & FAQ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFAQItem(
            question: 'What type of content is available on Gutargoo+?',
            answer:
                'Gutargoo+ offers self-produced movies as well as officially licensed movies available for streaming.',
          ),
          _buildFAQItem(
            question: 'What should I do if I don’t receive the OTP?',
            answer:
                'Please check your network connection and try the “Resend OTP” option. If the issue continues, try again after some time.',
          ),
          _buildFAQItem(
            question: 'How do I contact customer support?',
            answer:
                'You can reach our support team via email at support@Gutargooplus.com.',
          ),
          _buildFAQItem(
            question: 'How can I use Gutargoo+?',
            answer:
                'Download the app, enter your mobile number, verify using OTP, and start streaming.',
          ),
          _buildFAQItem(
            question: 'How can I improve video quality?',
            answer:
                'Go to Player Settings > Video Quality and select your preferred quality.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),

      // 🖤 BLACK + 🔴 RED MIX CARD
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F0F0F), // deep black
            Color(0xFF1A0A0A), // dark red-black mix
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(14.r),

        border: Border.all(
          color: const Color.fromRGBO(155, 8, 8, 0.35), // red glow border
        ),

        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(155, 8, 8, 0.20), // soft red glow
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),

        title: Text(
          question,
          style: TextStyle(
            color: const Color(0xFFF2F2F2),
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        trailing: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color.fromRGBO(155, 8, 8, 0.9), // red accent
        ),

        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              answer,
              style: TextStyle(
                color: const Color(0xFFB5B5B5),
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
