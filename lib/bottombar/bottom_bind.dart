import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/getx/profile_controller.dart';

class BottomBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<SearchController>(() => SearchController()); 
    Get.lazyPut<FavoritesController>(() => FavoritesController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}