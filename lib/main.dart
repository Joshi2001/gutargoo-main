import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/_google_cast_context/google_cast_context.dart';
import 'package:flutter_chrome_cast/entities/cast_options.dart';
import 'package:flutter_chrome_cast/entities/discovery_criteria.dart';
import 'package:flutter_chrome_cast/models/android/android_cast_options.dart';
import 'package:flutter_chrome_cast/models/ios/ios_cast_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/home/ad/controller/ad_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/getx/videoController.dart';
import 'package:gutrgoopro/profile/getx/download_controller.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/getx/profile_controller.dart';
import 'package:gutrgoopro/profile/screen/auth/controller/otp_controller.dart';
import 'package:gutrgoopro/search.dart/controller/search_controller.dart';
import 'package:gutrgoopro/splash/splash_screen.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await ScreenProtector.preventScreenshotOff();
  await ScreenProtector.protectDataLeakageWithBlur();  

  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _initServices();
    });
  }

  Future<void> _initServices() async {
    await MobileAds.instance.initialize();
    _initCast();
    Get.lazyPut(() => AdController(), fenix: true);
    Get.lazyPut(() => VideoController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => SearchControllerX(), fenix: true);
    Get.lazyPut(() => FavoritesController(), fenix: true);
    Get.lazyPut(() => DownloadsController(), fenix: true);
    Get.put(NavigationController(), permanent: true);
  }

  void _initCast() {
    const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;

    GoogleCastOptions options;

    if (Platform.isIOS) {
      options = IOSGoogleCastOptions(
        GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      );
    } else {
      options = GoogleCastOptionsAndroid(appId: appId);
    }

    GoogleCastContext.instance.setSharedInstanceWithOptions(options);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.cupertino,
          home: SplashScreen(),
        );
      },
    );
  }
}
