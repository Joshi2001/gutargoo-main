import 'package:get/get.dart';
import 'package:gutrgoopro/profile/getx/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
