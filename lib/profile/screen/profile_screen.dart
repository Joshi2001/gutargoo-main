import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/_session_manager/cast_session_manager.dart';
import 'package:flutter_chrome_cast/entities/cast_session.dart';
import 'package:flutter_chrome_cast/enums/connection_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/custom/coming_soon_pro.dart';
import 'package:gutrgoopro/profile/getx/profile_controller.dart';
import 'package:gutrgoopro/profile/screen/edit_profile.dart';
import 'package:gutrgoopro/profile/screen/favorites_profile.dart';
import 'package:gutrgoopro/profile/screen/help_faq.dart';
import 'package:gutrgoopro/profile/screen/privacy_policy.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:gutrgoopro/widget/redeem_code.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final RxBool isLoggedIn = false.obs;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      bool loggedIn = await LocalStore.isLoggedIn();
      isLoggedIn.value = loggedIn;

      if (loggedIn) {
        await controller.loadUserData();
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _profileCard(),

            // SizedBox(height: 24.h),
            _sectionTitle('APP SETTINGS'),

            _menuTile(Icons.person_outline, 'My Account',
                onTap: () => Get.to(() => EditProfileScreen())),

            _menuTile(Icons.bookmark_border, 'Watchlist', onTap: () => Get.to(() => FavoritesScreen())),

            // _menuTile(Icons.history, 'History'),

       _menuTile(Icons.card_giftcard, 'Redeem Code', onTap: () async {
  final token = await LocalStore.getToken() ?? '';
  print('🎟️ Token for redeem: $token');
  RedeemCodeBottomSheet.show(
    context,
    authToken: token, 
  );
}),

            SizedBox(height: 24.h),
            _sectionTitle('VIDEO SETTINGS'),

       _menuTile(
  Icons.download, 
  'Download Settings',
  onTap: () => showComingSoonPlansPopup(context), 
),

            SizedBox(height: 24.h),
            _sectionTitle('SUPPORT'),

            _menuTile(Icons.help_outline, 'Help & FAQ',
                onTap: () => Get.to(() => HelpFAQScreen())),

            _menuTile(Icons.privacy_tip_outlined, 'Privacy Policy',
                onTap: () => Get.to(() => PrivacyPolicyScreen())),

            // SizedBox(height: 30.h),

            // _bottomButtons(),

            SizedBox(height: 20.h),

            Center(
              child: Text(
                'Version: 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
Widget activateTvTile(BuildContext context) {
  return StreamBuilder<GoogleCastSession?>(
    stream: GoogleCastSessionManager.instance.currentSessionStream,
    builder: (context, snapshot) {
      final connected =
          GoogleCastSessionManager.instance.connectionState ==
              GoogleCastConnectState.connected;

      return _menuTile(
        Icons.tv,
        'Activate TV',
        onTap: () {
          if (connected) {
            // Connected → show bottom sheet
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Casting Active',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        GoogleCastSessionManager.instance
                            .endSessionAndStopCasting();
                        Navigator.pop(context);
                      },
                      child: Text('Stop Casting'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Not connected → open cast dialog
            GoogleCastSessionManager.instance.endSession();
          }
        },
      
       
      );
    },
  );
}

  Widget _menuTile(IconData icon, String title,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios,
          color: Colors.white, size: 16),
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _bottomItem(IconData icon, String title,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Color(0xFF121212),
      borderRadius: BorderRadius.circular(16),
    );
  }
}

