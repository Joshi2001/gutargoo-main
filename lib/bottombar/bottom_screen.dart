import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,

        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
        selectedFontSize: 10.sp,
        unselectedFontSize: 10.sp,
       items: [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined, size: 24.sp),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.search_outlined, size: 24.sp),
    label: 'Search',
  ),
  // BottomNavigationBarItem(
  //   icon: Image.asset("assets/potli.png", width: 24.w, height: 24.h,color: Colors.white,), // ✅ NEW
  //   label: 'Potli',
  // ),
  BottomNavigationBarItem(
    icon: Icon(Icons.favorite, size: 24.sp),
   
    label: 'Favorite',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outlined, size: 24.sp),
    label: 'Profile',
  ),
],
      ),
    );
  }
}
