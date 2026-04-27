
// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';

// class SubscriptionController extends GetxController {  
//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;

//   var selectedPlan = 0.obs;
//   var products = <ProductDetails>[].obs;
//   var isAvailable = false.obs;
//   var isLoading = false.obs;
//   var productsLoading = true.obs;

//   StreamSubscription<List<PurchaseDetails>>? _subscription;

//   final List<String> productIds = [
//     'premium_1_month',
//     'premium_6_months',
//     'premium_12_months',
//   ];

//   final Map<int, List<String>> planFeatures = {
//     0: ['Ad-free experience', 'HD streaming'],
//     1: [
//       'Ad-free experience',
//       'HD streaming',
//       'Download & Watch Offline',
//       'Multi-Device Support'
//     ],
//     2: [
//       'Ad-free experience',
//       'HD streaming',
//       'Download & Watch Offline',
//       'Multi-Device Support',
//       'Exclusive Premium Content'
//     ],
//   };

//   @override
//   void onInit() {
//     super.onInit();
//     print("🟡 SubscriptionController Initialized");
//     _initializeWithRetry();
//   }

//   /// Robust initialization with retry for connection errors
//   Future<void> _initializeWithRetry() async {
//     const maxRetries = 3;
//     int attempt = 0;
//     bool connected = false;

//     // Setup purchase stream before checking availability
//     _subscription = _inAppPurchase.purchaseStream.listen(
//       _listenToPurchaseUpdated,
//       onError: (error) => print("🔴 Purchase stream error: $error"),
//     );

//     while (attempt < maxRetries && !connected) {
//       attempt++;
//       try {
//         print("🟡 Checking billing availability... (attempt $attempt)");
//         isAvailable.value = await _inAppPurchase.isAvailable();

//         if (isAvailable.value) {
//           print("🟢 Billing connection successful");
//           await _getProducts();
//           connected = true;
//         } else {
//           print("🔴 Billing not available, retrying...");
//           await Future.delayed(const Duration(seconds: 2));
//         }
//       } catch (e) {
//         print("🔴 Billing init attempt $attempt failed: $e");
//         await Future.delayed(const Duration(seconds: 2));
//       }
//     }

//     if (!connected) {
//       print("🔴 Could not establish billing connection after $maxRetries attempts");
//       productsLoading.value = false;
//       Get.snackbar(
//         "Error",
//         "Failed to connect to Google Play Billing. Please use a real device with Play Store.",
//         duration: const Duration(seconds: 5),
//       );
//     }
//   }

//   Future<void> _getProducts() async {
//     print("🟡 Querying products from Play Console...");
//     print("🟡 Product IDs: $productIds");

//     try {
//       final response =
//           await _inAppPurchase.queryProductDetails(productIds.toSet());

//       if (response.error != null) {
//         print("🔴 Product query error: ${response.error}");
//         Get.snackbar(
//           "Error",
//           "Failed to load subscription plans: ${response.error!.message}",
//           duration: const Duration(seconds: 5),
//         );
//         productsLoading.value = false;
//         return;
//       }

//       if (response.productDetails.isEmpty) {
//         print("🔴 No products found! Check Play Console setup");
//         Get.snackbar(
//           "Error",
//           "No subscription products available. Check Play Console configuration.",
//           duration: const Duration(seconds: 5),
//         );
//       }

//       if (response.notFoundIDs.isNotEmpty) {
//         print("❌ Not Found IDs: ${response.notFoundIDs}");
//         // Get.snackbar(
//         //   "Warning",
//         //   "Some products not found in Play Console: ${response.notFoundIDs.join(', ')}",
//         //   duration: const Duration(seconds: 5),
//         // );
//       }

//       print("🟢 Products loaded: ${response.productDetails.length}");
//       products.value = response.productDetails;
//       productsLoading.value = false;
//     } catch (e) {
//       print("🔴 Exception loading products: $e");
//       productsLoading.value = false;
//       // Get.snackbar(
//       //   "Error",
//       //   "Failed to load products: $e",
//       //   duration: const Duration(seconds: 5),
//       // );
//     }
//   }

//   void selectPlan(int index) {
//     print("🟡 Selected Plan Index: $index");
//     selectedPlan.value = index;
//   }

//   Future<void> buySubscription() async {
//     print("🟡 Buy Subscription Clicked");
//     if (!isAvailable.value) {
//       Get.snackbar(
//         "Error",
//         "Google Play Billing not available",
//         duration: const Duration(seconds: 3),
//       );
//       return;
//     }

//     if (products.isEmpty) {
//       Get.snackbar(
//         "Error",
//         "Products not loaded. Retrying...",
//         duration: const Duration(seconds: 3),
//       );
//       await _getProducts();
//       if (products.isEmpty) return;
//     }

//     isLoading.value = true;

//     try {
//       final productId = productIds[selectedPlan.value];
//       final product = products.firstWhereOrNull((p) => p.id == productId);

//      if (product == null) {
//   print("❌ Product not found in queried products: $productId");
//   print("Available products: ${products.map((p) => p.id).toList()}");
//   isLoading.value = false;
//   return;
// }
//       print("🟢 Starting purchase for: ${product.id}");

//       final PurchaseParam purchaseParam =
//           PurchaseParam(productDetails: product);
//       await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//     } catch (e) {
//       print("🔴 Purchase failed: $e");
//       Get.snackbar(
//         "Error",
//         "Purchase failed: $e",
//         duration: const Duration(seconds: 3),
//       );
//       isLoading.value = false;
//     }
//   }

//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
//     for (final purchase in purchaseDetailsList) {
//       print("🟡 Purchase update: ${purchase.productID}, status: ${purchase.status}");

//       if (purchase.status == PurchaseStatus.pending) {
//         Get.snackbar("Processing", "Payment is processing...");
//       } else if (purchase.status == PurchaseStatus.purchased) {
//         await _verifyPurchase(purchase);
//         Get.snackbar("Success", "Subscription Activated 🎉");
//         isLoading.value = false;
//       } else if (purchase.status == PurchaseStatus.error) {
//         Get.snackbar("Error", purchase.error?.message ?? "Payment error");
//         isLoading.value = false;
//       } else if (purchase.status == PurchaseStatus.canceled) {
//         isLoading.value = false;
//       }

//       if (purchase.pendingCompletePurchase) {
//         await _inAppPurchase.completePurchase(purchase);
//       }
//     }
//   }
// /// Retry loading products when user taps the Retry button
// Future<void> retryLoadProducts() async {
//   if (productsLoading.value) return; // Already loading

//   productsLoading.value = true;
//   print("🟡 Retrying to load products...");

//   try {
//     await _getProducts();

//     if (products.isEmpty) {
//       print("🔴 Retry failed: no products loaded");
//       Get.snackbar(
//         "Error",
//         "No subscription plans available. Please check your connection.",
//         duration: const Duration(seconds: 3),
//       );
//     } else {
//       print("🟢 Retry success: products loaded");
//     }
//   } catch (e) {
//     print("🔴 Retry exception: $e");
//     Get.snackbar("Error", "Failed to load products: $e", duration: const Duration(seconds: 3));
//   } finally {
//     productsLoading.value = false;
//   }
// }

//   Future<void> _verifyPurchase(PurchaseDetails purchase) async {
//     print("🟡 Verifying purchase: ${purchase.productID}");
//     print("🟡 Verification Data: ${purchase.verificationData.serverVerificationData}");
//     // TODO: Send verificationData to backend for server-side validation
//   }

//   Future<void> restorePurchases() async {
//     print("🟡 Restore purchases called");
//     isLoading.value = true;
//     try {
//       await _inAppPurchase.restorePurchases();
//       Get.snackbar("Success", "Purchases restored successfully", duration: const Duration(seconds: 2));
//     } catch (e) {
//       print("🔴 Restore failed: $e");
//       Get.snackbar("Error", "Failed to restore purchases: $e", duration: const Duration(seconds: 3));
//     }
//     isLoading.value = false;
//   }

//   @override
//   void onClose() {
//     _subscription?.cancel();
//     super.onClose();
//   }
// }
