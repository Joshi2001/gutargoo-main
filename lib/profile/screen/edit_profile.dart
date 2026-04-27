import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/custom/sign_out.dart';
import 'package:gutrgoopro/profile/getx/edit_profile_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';
import 'package:gutrgoopro/uitls/local_store.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileController controller;
  final RxBool isLoggedIn = false.obs;
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<EditProfileController>()) {
      controller = Get.put(EditProfileController());
    } else {
      controller = Get.find<EditProfileController>();
    }
    
    _init();
  }

  @override
  void dispose() {
    emailController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final mobile = await LocalStore.getMobile();
    controller.userPhone.value = mobile ?? '';

    final loggedIn = await LocalStore.isLoggedIn();
    isLoggedIn.value = loggedIn;
    
    final savedEmail = await LocalStore.getEmail();
    final savedAge = await LocalStore.getAge();
    emailController.text = savedEmail ?? '';
    ageController.text = savedAge ?? '';
  }

  Future<void> _updateProfile() async {
    await LocalStore.saveEmail(emailController.text);
    await LocalStore.saveAge(ageController.text);
    Get.back();
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: _updateProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar with edit option ──
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48.r,
                            backgroundColor: const Color(0xFF2A2A2A),
                            child: Obx(() => controller.profileImage.value != null
                                ? ClipOval(
                                    child: Image.file(
                                      controller.profileImage.value!,
                                      width: 96.w,
                                      height: 96.h,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 48.sp,
                                    color: Colors.white38,
                                  ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showImagePickerOptions(),
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF121212),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Obx(() => Text(
                        controller.userPhone.value.isNotEmpty
                            ? controller.userPhone.value
                            : '—',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13.sp,
                        ),
                      )),
                    ],
                  ),
                ),
      
                SizedBox(height: 24.h),
      
                // ── Phone Number Card (non-editable) ──
                Text(
                  'Phone Number',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.07),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '🇮🇳',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '+91',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 1,
                        height: 20.h,
                        color: Colors.white12,
                      ),
                      SizedBox(width: 12.w),
                      Obx(() => Text(
                        isLoggedIn.value
                            ? (controller.userPhone.value.isNotEmpty
                                ? controller.userPhone.value
                                : '—')
                            : 'You are Guest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          letterSpacing: isLoggedIn.value ? 2 : 0,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                      const Spacer(),
                    ],
                  ),
                ),
      
                SizedBox(height: 16.h),
      
                // ── Email Field ──
                Text(
                  'Email Address',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.07),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: 20.sp,
                        color: Colors.white38,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
      
                SizedBox(height: 16.h),
      
                // ── Age Field ──
                Text(
                  'Age',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.07),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: ageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your age',
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.cake_outlined,
                        size: 20.sp,
                        color: Colors.white38,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
      
                const Spacer(),
      
                // Sign Out / Sign In Button
                Obx(() {
                  return GestureDetector(
                    onTap: () => showSignOutPopup(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: isLoggedIn.value
                            ? Colors.red.withOpacity(0.08)
                            : Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isLoggedIn.value
                              ? Colors.red.withOpacity(0.5)
                              : Colors.green.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLoggedIn.value
                                ? Icons.logout_rounded
                                : Icons.login_rounded,
                            color: isLoggedIn.value ? Colors.red : Colors.green,
                            size: 18.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            isLoggedIn.value
                                ? 'Sign Out'
                                : 'Sign in with member',
                            style: TextStyle(
                              color: isLoggedIn.value ? Colors.red : Colors.green,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                controller.pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}