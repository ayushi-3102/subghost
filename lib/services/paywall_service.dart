import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'storage_service.dart';

class PaywallService {
  static const String appleApiKey = "appl_mock_key_for_setup";
  static const String googleApiKey = "goog_mock_key_for_setup";
  static const String entitlementId = "pro_access";
  
  // Free tier limit
  static const int freeSubscriptionLimit = 3;

  static Future<void> initialize() async {
    // Only configure native StoreKit / Play Billing on actual mobile platforms
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      try {
        await Purchases.setLogLevel(LogLevel.debug);
        final apiKey = defaultTargetPlatform == TargetPlatform.iOS ? appleApiKey : googleApiKey;
        final configuration = PurchasesConfiguration(apiKey);
        await Purchases.configure(configuration);
      } catch (e) {
        debugPrint("RevenueCat config note: $e");
      }
    }
  }

  // Check if current user is Pro
  static Future<bool> isProUser() async {
    // Check local offline unlock flag first
    if (StorageService.isProLocallyUnlocked()) {
      return true;
    }

    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        final isPro = customerInfo.entitlements.all[entitlementId]?.isActive == true;
        if (isPro) {
          await StorageService.setProLocally(true);
        }
        return isPro;
      } catch (e) {
        return StorageService.isProLocallyUnlocked();
      }
    }

    return StorageService.isProLocallyUnlocked();
  }

  // Restore Purchases
  static Future<bool> restorePurchases() async {
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      try {
        final customerInfo = await Purchases.restorePurchases();
        final isPro = customerInfo.entitlements.all[entitlementId]?.isActive == true;
        await StorageService.setProLocally(isPro);
        return isPro;
      } catch (e) {
        debugPrint("Restore error: $e");
        return false;
      }
    }
    // Simulation for desktop testing
    await StorageService.setProLocally(true);
    return true;
  }

  // Purchase Pro Package
  static Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isPro = customerInfo.entitlements.all[entitlementId]?.isActive == true;
      await StorageService.setProLocally(isPro);
      return isPro;
    } catch (e) {
      debugPrint("Purchase error: $e");
      return false;
    }
  }

  // Debug unlock for development testing on Windows
  static Future<void> toggleDebugPro() async {
    final current = StorageService.isProLocallyUnlocked();
    await StorageService.setProLocally(!current);
  }
}
