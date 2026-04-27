
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/profile/screen/help_faq.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 16.r),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          _buildPolicySection(
            title: '1. Information We Collect',
            content:
                'We collect information you provide directly, such as when you create an account or contact us. This includes name, email, and viewing preferences.',
          ),
          _buildPolicySection(
            title: '2. How We Use Your Information',
            content:
                'We use your information to provide, maintain, and improve our services, send communications, and comply with legal obligations.',
          ),
          _buildPolicySection(
            title: '3. Data Security',
            content:
                'We implement industry-standard security measures to protect your personal information. All data is encrypted during transmission and stored securely.',
          ),
          _buildPolicySection(
            title: '4. Sharing Your Information',
            content:
                'We do not sell your personal information. We may share data with trusted service providers under strict confidentiality.',
          ),
          _buildPolicySection(
            title: '5. Cookies and Tracking',
            content:
                'We use cookies and similar technologies to enhance your experience and analyze usage patterns.',
          ),
          _buildPolicySection(
            title: '6. Your Rights',
            content:
                'You can access, update, or delete your personal information anytime by contacting support@Gutargooplus.com.',
          ),
          _buildPolicySection(
            title: '7. iOS Subscription & Payment',
            content:
                'Gutargoo+ does not offer paid subscriptions on iOS. All content is free.',
          ),
          _buildPolicySection(
            title: '8. Contact Us',
            content:
                'For support, contact us at Support@Gutargooplus.com',
          ),

          SizedBox(height: 24.h),

          Text(
            'Last Updated: January 2026',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF6B6B6B),
              fontSize: 12.sp,
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F0F0F),
            Color(0xFF1A0A0A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(14.r),

        border: Border.all(
          color: const Color.fromRGBO(155, 8, 8, 0.35),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(155, 8, 8, 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFFF2F2F2),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: TextStyle(
              color: const Color(0xFFB5B5B5),
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
class SettingsOptionsWidget extends StatelessWidget {
  const SettingsOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSettingOption(
          icon: Icons.help_outline,
          label: 'Help & FAQ',
          onTap: () => Get.to(() => const HelpFAQScreen()),
        ),
        _buildSettingOption(
          icon: Icons.security,
          label: 'Privacy Policy',
          onTap: () => Get.to(() => const PrivacyPolicyScreen()),
        ),
      ],
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A0A0A),
            ],
          ),

          borderRadius: BorderRadius.circular(14.r),

          border: Border.all(
            color: const Color.fromRGBO(155, 8, 8, 0.35),
          ),

          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(155, 8, 8, 0.20),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF2F2F2), size: 22),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFFF2F2F2),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Color.fromRGBO(155, 8, 8, 0.9),
            ),
          ],
        ),
      ),
    );
  }
}
