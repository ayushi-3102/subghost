import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'storage_service.dart';

class PurchaseResult {
  final bool success;
  final bool userCancelled;
  final String? errorMessage;

  const PurchaseResult({
    required this.success,
    required this.userCancelled,
    this.errorMessage,
  });
}

class PaywallService {
  // RevenueCat Public API Keys
  // Users can set their keys in code below, or dynamically via Settings -> Developer Lab
  static String appleApiKey = "appl_mock_key_for_setup";
  static String googleApiKey = "goog_mock_key_for_setup";
  static const String defaultEntitlementId = "pro_access";
  
  // Free tier limit
  static const int freeSubscriptionLimit = 3;

  static String get activeApiKey {
    final custom = StorageService.getCustomRevenueCatApiKey();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ? appleApiKey : googleApiKey;
  }

  static bool get hasLiveBillingKey {
    if (kIsWeb) return false;
    final key = activeApiKey;
    return key.isNotEmpty && !key.contains("mock");
  }

  static Future<void> initialize() async {
    // Only configure native StoreKit / Play Billing on actual mobile platforms
    // AND only when real, non-mock API keys are configured!
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      try {
        if (!hasLiveBillingKey) {
          debugPrint("PaywallService: Using offline local mode (no live billing key configured).");
          return;
        }
        await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
        final configuration = PurchasesConfiguration(activeApiKey);
        await Purchases.configure(configuration);
        debugPrint("PaywallService: RevenueCat successfully initialized with key: ${activeApiKey.substring(0, 8)}...");
      } catch (e) {
        debugPrint("RevenueCat initialization bypassed gracefully: $e");
      }
    }
  }

  /// Reconfigures RevenueCat dynamically (e.g. after user updates key in settings)
  static Future<bool> reconfigure(String newKey) async {
    try {
      await StorageService.setCustomRevenueCatApiKey(newKey);
      if (newKey.trim().isEmpty || newKey.contains("mock")) {
        return true;
      }
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(newKey.trim()));
      return true;
    } catch (e) {
      debugPrint("Error reconfiguring RevenueCat: $e");
      return false;
    }
  }

  /// Fetch live offerings from RevenueCat (Google Play / App Store)
  static Future<Offerings?> getOfferings() async {
    if (!hasLiveBillingKey || kIsWeb) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint("Error fetching RevenueCat offerings: $e");
      return null;
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
        final isPro = customerInfo.entitlements.all[defaultEntitlementId]?.isActive == true;
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
        final isPro = customerInfo.entitlements.all[defaultEntitlementId]?.isActive == true;
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

  // Purchase Pro Package with rich error reporting
  static Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isPro = customerInfo.entitlements.all[defaultEntitlementId]?.isActive == true;
      if (isPro) {
        await StorageService.setProLocally(true);
      }
      return PurchaseResult(success: isPro, userCancelled: false);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      final isCancelled = errorCode == PurchasesErrorCode.purchaseCancelledError;
      debugPrint("RevenueCat purchase error: ${e.message} (code: $errorCode)");
      return PurchaseResult(
        success: false,
        userCancelled: isCancelled,
        errorMessage: isCancelled ? null : e.message,
      );
    } catch (e) {
      debugPrint("Purchase error: $e");
      return PurchaseResult(success: false, userCancelled: false, errorMessage: e.toString());
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
