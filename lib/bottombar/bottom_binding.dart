import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/bottombar/bottom_screen.dart';
import 'package:gutrgoopro/home/screen/home_screen.dart';
import 'package:gutrgoopro/profile/screen/favorites_profile.dart';
import 'package:gutrgoopro/profile/screen/profile_screen.dart';
import 'package:gutrgoopro/search.dart/screen/search_screen.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class BottomNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  late final NavigationController controller;
  DateTime? lastBackPressed;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    controller = Get.find<NavigationController>();

    screens = [
      HomeScreen(),
      SearchScreen(fromBottomNav: true),
      FavoritesScreen(fromProfile: false),
      ProfileScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.currentIndex.value = widget.initialIndex;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
   
 return WillPopScope(
  onWillPop: () async {
    await controller.handleBackPress();
    return false; 
  },
  child: Obx(
    () => Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: screens,
      ),
      bottomNavigationBar: controller.showBottomNav.value
          ? CustomBottomNavigation(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
            )
          : null,
    ),
  ),
);
  }
}


Widget _buildBody(int index) {
  switch (index) {
    case 0: return HomeScreen();
    case 1: return SearchScreen(fromBottomNav: true);
    // case 2: return PotliHomeScreen(); // 👈 NEW SCREEN
    case 2: return FavoritesScreen(fromProfile: false);
    case 3: return ProfileScreen();
    default: return HomeScreen();
  }
}
