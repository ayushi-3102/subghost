import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';
import '../services/paywall_service.dart';

import '../services/currency_service.dart';

// --- Currency State ---
final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier(ref);
});

class CurrencyNotifier extends StateNotifier<String> {
  final Ref _ref;
  CurrencyNotifier(this._ref) : super(StorageService.getCurrencySymbol());

  Future<void> setCurrency(String symbol, {bool convertExisting = true}) async {
    final oldSymbol = state;
    if (oldSymbol == symbol) return;

    if (convertExisting) {
      final currentSubs = _ref.read(subscriptionsProvider);
      for (final sub in currentSubs) {
        final convertedCost = CurrencyService.convert(
          amount: sub.cost,
          fromSymbol: oldSymbol,
          toSymbol: symbol,
        );
        final updated = sub.copyWith(cost: convertedCost);
        await StorageService.saveSubscription(updated);
      }
      _ref.read(subscriptionsProvider.notifier).loadSubscriptions();
    }

    await StorageService.setCurrencySymbol(symbol);
    state = symbol;
  }
}

// --- Biometric Security State ---
final biometricEnabledProvider = StateNotifierProvider<BiometricNotifier, bool>((ref) {
  return BiometricNotifier();
});

class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(StorageService.isBiometricEnabled());

  Future<void> toggle() async {
    final next = !state;
    await StorageService.setBiometricEnabled(next);
    state = next;
  }
}

final isVaultLockedProvider = StateProvider<bool>((ref) {
  // If biometric is enabled, start app locked
  return StorageService.isBiometricEnabled();
});

// --- Stealth Privacy Mode State ---
final stealthModeProvider = StateNotifierProvider<StealthModeNotifier, bool>((ref) {
  return StealthModeNotifier();
});

class StealthModeNotifier extends StateNotifier<bool> {
  StealthModeNotifier() : super(StorageService.isStealthModeEnabled());

  Future<void> toggle() async {
    final next = !state;
    await StorageService.setStealthModeEnabled(next);
    state = next;
  }

  Future<void> setStealth(bool value) async {
    await StorageService.setStealthModeEnabled(value);
    state = value;
  }
}

// --- Pro User Status State ---
final isProProvider = StateNotifierProvider<ProStatusNotifier, bool>((ref) {
  return ProStatusNotifier();
});

class ProStatusNotifier extends StateNotifier<bool> {
  ProStatusNotifier() : super(StorageService.isProLocallyUnlocked()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final pro = await PaywallService.isProUser();
    state = pro;
  }

  Future<void> toggleDebug() async {
    final next = await PaywallService.toggleDebugPro();
    state = next;
  }

  Future<void> resetToFree() async {
    await PaywallService.resetToFreeTier();
    state = false;
  }
}

// --- Subscriptions List State ---
final subscriptionsProvider = StateNotifierProvider<SubscriptionsNotifier, List<Subscription>>((ref) {
  return SubscriptionsNotifier();
});

class SubscriptionsNotifier extends StateNotifier<List<Subscription>> {
  SubscriptionsNotifier() : super([]) {
    loadSubscriptions();
  }

  void loadSubscriptions() {
    state = StorageService.getAllSubscriptions();
  }

  Future<void> addSubscription(Subscription sub) async {
    await StorageService.saveSubscription(sub);
    loadSubscriptions();
  }

  Future<void> updateSubscription(Subscription sub) async {
    await StorageService.saveSubscription(sub);
    loadSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    await StorageService.deleteSubscription(id);
    loadSubscriptions();
  }
}

// --- Computed Totals & Category Breakdown ---
final totalMonthlySpendProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs.fold(0.0, (sum, item) => sum + item.monthlyCost);
});

final totalAnnualSpendProvider = Provider<double>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  return subs.fold(0.0, (sum, item) => sum + item.annualCost);
});

// Category Distribution Provider
final categorySpendBreakdownProvider = Provider<Map<String, double>>((ref) {
  final subs = ref.watch(subscriptionsProvider);
  final Map<String, double> map = {};
  for (var sub in subs) {
    final cat = sub.category.isEmpty ? 'General' : sub.category;
    map[cat] = (map[cat] ?? 0.0) + sub.monthlyCost;
  }
  return map;
});
