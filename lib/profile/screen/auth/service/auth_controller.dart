import 'package:get/get.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }
  Future<void> checkLoginStatus() async {
    try {
      final loggedIn = await LocalStore.isLoggedIn();
      isLoggedIn.value = loggedIn;
      
      if (loggedIn) {
        final prefs = await SharedPreferences.getInstance();
        userName.value = prefs.getString('userName') ?? '';
        userEmail.value = prefs.getString('userEmail') ?? '';
        userPhone.value = prefs.getString('userPhone') ?? '';
        userId.value = prefs.getString('userId') ?? '';
      }
      
      print('🔍 AuthController: Status checked - isLoggedIn: $loggedIn');
    } catch (e) {
      print('❌ AuthController: Error checking status: $e');
      isLoggedIn.value = false;
    }
  }

  Future<bool> login({
    required String phone,
    String? name,
    String? email,
    String? id,
  }) async {
    try {
      await LocalStore.saveLoginState(
        isLoggedIn: true,
        userId: id ?? phone,
        phoneNumber: phone,
      );
      
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString('userName', name);
      if (email != null) await prefs.setString('userEmail', email);
      
      isLoggedIn.value = true;
      userPhone.value = phone;
      userId.value = id ?? phone;
      if (name != null) userName.value = name;
      if (email != null) userEmail.value = email;
      
      print('✅ AuthController: User logged in - $phone');
      return true;
    } catch (e) {
      print('❌ AuthController: Login error: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await LocalStore.logout();
      isLoggedIn.value = false;
      userName.value = '';
      userEmail.value = '';
      userPhone.value = '';
      userId.value = '';
      
      print('✅ AuthController: User logged out');
      return true;
    } catch (e) {
      print('❌ AuthController: Logout error: $e');
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (name != null) {
        await prefs.setString('userName', name);
        userName.value = name;
      }
      if (email != null) {
        await prefs.setString('userEmail', email);
        userEmail.value = email;
      }
      
      print('✅ AuthController: Profile updated');
    } catch (e) {
      print('❌ AuthController: Update profile error: $e');
    }
  }
}