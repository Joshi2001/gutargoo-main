// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/custom/coming_soon_pro.dart';
// import 'package:gutrgoopro/home/getx/subscribe_controller.dart';
// import 'package:gutrgoopro/uitls/colors.dart';

// class SubscriptionScreen extends GetView<SubscriptionController> {
//   const SubscriptionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//   onWillPop: () async {
//     Get.back();
//     return false;
//   },
//   child:
//      Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: Get.back,
//         ),
//         title: const Text(
//           'Subscribe',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 13),
//               child: Column(
//                 children: [
//                   _header(),
//                   const SizedBox(height: 18),
//                   _planCard(
//                     index: 0,
//                     title: '1 Month',
//                     subtitle: 'Ads Free Experience',
//                     price: '₹99',
//                     duration: '/month',
//                     icon: Icons.bolt,
//                   ),
        
//                   const SizedBox(height: 13),
        
//                   _planCard(
//                     index: 1,
//                     title: '6 Months',
//                     subtitle: 'Ads Free Experience',
//                     price: '₹199',
//                     duration: '/6 months',
//                     icon: FontAwesomeIcons.star,
//                     popular: true,
//                   ),
        
//                   const SizedBox(height: 13),
        
//                   _planCard(
//                     index: 2,
//                     title: '12 Months',
//                     subtitle: 'Ads Free Experience',
//                     price: '₹349',
//                     duration: '/year',
//                     icon: FontAwesomeIcons.crown,
//                   ),
        
//                   const SizedBox(height: 24),
//                   _features(),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: GestureDetector(
//                 // onTap: () => Get.to(() => BottomNavigationScreen()),
//               onTap: () =>  showComingSoonPlansPopup(context),
//                 child: _subscribeButton(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _footer(),
//           ],
//         ),
//       ),
//     ));
//   }

//   /// HEADER
//   Widget _header() {
//     return Column(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: AppColors.primaryGradient,
//           ),
//           child: Center(
//             child: FaIcon(
//               FontAwesomeIcons.crown,
//               color: Colors.white,
//               size: 16,
//             ),
//           ),
//         ),

//         SizedBox(height: 16),
//         Text(
//           'Go Premium',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 19,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           'Unlock unlimited entertainment',
//           style: TextStyle(color: Colors.grey, fontSize: 13),
//         ),
//       ],
//     );
//   }

//   Widget _planCard({
//     required int index,
//     required String title,
//     required String subtitle,
//     required String price,
//     required String duration,
//     required IconData icon,
//     bool popular = false,
//   }) {
//     return Obx(() {
//       final bool selected = controller.selectedPlan.value == index;

//       return GestureDetector(
//         onTap: () => controller.selectPlan(index),
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               decoration: BoxDecoration(
//                 color: selected
//                     ? const Color(0xFF4A3500)
//                     : const Color(0xFF1A1A1A),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: selected
//                       ? const Color(0xFFFFA500)
//                       : Colors.transparent,
//                   width: 2,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   /// ICON
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       gradient: AppColors.primaryGradient,
//                       color: selected
//                           ? const Color(0xFFFFA500)
//                           : Colors.grey.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: Icon(
//                       icon,
//                       color: selected ? Colors.white : Colors.grey,
//                       size: 20,
//                     ),
//                   ),

//                   const SizedBox(width: 16),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           subtitle,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: selected ? Colors.white70 : Colors.grey,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         price,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 19,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         duration,
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(width: 12),

//                   /// RADIO
//                   _radio(selected),
//                 ],
//               ),
//             ),

//             /// POPULAR TAG (STATIC ON 6 MONTHS)
//             if (popular)
//               Positioned(
//                 top: -10,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: AppColors.primaryGradient,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       'POPULAR',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }

//   /// RADIO BUTTON
//   Widget _radio(bool selected) {
//     return Container(
//       width: 19,
//       height: 16,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: selected ? const Color(0xFFFFA500) : Colors.white54,
//           width: 2,
//         ),
//       ),
//       child: selected
//           ? Center(
//               child: Container(
//                 width: 10,
//                 height: 10,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFFFA500),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             )
//           : null,
//     );
//   }

//   Widget _features() {
//     return Obx(() {
//       final features =
//           controller.planFeatures[controller.selectedPlan.value] ?? [];

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Plan Features:',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
          
//           const SizedBox(height: 12),

//        GridView.builder(
//   shrinkWrap: true,
//   physics: const NeverScrollableScrollPhysics(),
//   itemCount: features.length,
//   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//     crossAxisCount: 2,
//     // mainAxisSpacing: 10,     
//     // crossAxisSpacing: 50,   
//     childAspectRatio: 6,    
//   ),
//   itemBuilder: (context, index) {
//     return _Feature(text: features[index]);
//   },
// ),
//         ],
//       );
//     });
//   }

//   Widget _subscribeButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0),
//       child: SizedBox(
//         width: double.infinity,
//         height: 45,
//         child: Ink(
//           decoration: BoxDecoration(
//             gradient: AppColors.primaryGradient,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Center(
//             child: Text(
//               'Subscribe Now',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _footer() {
//     return Column(
//       children: const [
//         Text(
//           'Secured by Razorpay',
//           style: TextStyle(color: Colors.grey, fontSize: 12),
//         ),
//         SizedBox(height: 6),
//         Text(
//           'By subscribing, you agree to our Terms & Privacy Policy',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.grey, fontSize: 11),
//         ),
//       ],
//     );
//   }
// }

// class _Feature extends StatelessWidget {
//   final String text;
//   const _Feature({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           const Icon(Icons.check, color: Color(0xFFFFA500), size: 14),
//           const SizedBox(width: 4),
//          Expanded(
//            child: Text(
//              text,
//              maxLines: 1,
//              overflow: TextOverflow.ellipsis,
//              style: const TextStyle(color: Colors.white70, fontSize: 10.5),
//            ),
//          ),
//         ],
//       ),
//     );
//   }
// }
