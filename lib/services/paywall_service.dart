import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'storage_service.dart';

class PaywallService {
  static const String appleApiKey = "appl_mock_key_for_setup";
  static const String googleApiKey = "goog_mock_key_for_setup";
  static const String entitlementId = "pro_access";
  
  // Free tier limit
  static const int freeSubscriptionLimit = 3;

  static bool get hasLiveBillingKey {
    if (kIsWeb) return false;
    final apiKey = defaultTargetPlatform == TargetPlatform.iOS ? appleApiKey : googleApiKey;
    return apiKey.isNotEmpty && !apiKey.contains("mock");
  }

  static Future<void> initialize() async {
    // Only configure native StoreKit / Play Billing on actual mobile platforms
    // AND only when real, non-mock API keys are configured!
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      try {
        if (!hasLiveBillingKey) {
          debugPrint("PaywallService: Using offline local mode (no live billing key).");
          return;
        }
        await Purchases.setLogLevel(LogLevel.debug);
        final apiKey = defaultTargetPlatform == TargetPlatform.iOS ? appleApiKey : googleApiKey;
        final configuration = PurchasesConfiguration(apiKey);
        await Purchases.configure(configuration);
      } catch (e) {
        debugPrint("RevenueCat initialization bypassed gracefully: $e");
      }
    }
  }

  // Check if current user is Pro
  static Future<bool> isProUser() async {
    // Check local offline unlock flag first
    if (StorageService.isProLocallyUnlocked()) {
      return true;
    }

    if (hasLiveBillingKey && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
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
    if (hasLiveBillingKey && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
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
    // Return actual status without falsely granting Pro
    return StorageService.isProLocallyUnlocked();
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

  // Debug unlock for testing
  static Future<bool> toggleDebugPro() async {
    final current = StorageService.isProLocallyUnlocked();
    final next = !current;
    await StorageService.setProLocally(next);
    return next;
  }

  static Future<void> resetToFreeTier() async {
    await StorageService.setProLocally(false);
  }
}
