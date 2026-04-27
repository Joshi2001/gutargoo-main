import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gutrgoopro/custom/coming_soon_pro.dart';

class GoProButton extends StatefulWidget {
  const GoProButton({super.key});

  @override
  State<GoProButton> createState() => _GoProButtonState();
}

class _GoProButtonState extends State<GoProButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showComingSoonPlansPopup(context);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            constraints:
                BoxConstraints(maxWidth: 100.w, minHeight: 23.h),
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.crown,
                      color: Colors.black,
                      size: 11.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Go Pro",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
Positioned.fill(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(25.r),
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
         offset: Offset(
  120 * _controller.value - 60,
  0,
),
          child: Container(
            width: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              ),
            ),
          ),
        );
      },
    ),
  ),
),
              ],
            ),
          );
        },
      ),
    );
  }
}