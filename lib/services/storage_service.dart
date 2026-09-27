import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription.dart';

class StorageService {
  static const String _boxName = 'subzero_subscriptions_box';
  static const String _settingsBoxName = 'subzero_settings_box';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
    await Hive.openBox(_settingsBoxName);
  }

  static Box getSettingsBox() => Hive.box(_settingsBoxName);

  // --- Subscriptions Storage ---
  static List<Subscription> getAllSubscriptions() {
    final box = Hive.box<String>(_boxName);
    final List<Subscription> list = [];
    for (var key in box.keys) {
      final jsonStr = box.get(key);
      if (jsonStr != null) {
        try {
          list.add(Subscription.fromJson(jsonStr));
        } catch (_) {}
      }
    }
    list.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return list;
  }

  static Future<void> saveSubscription(Subscription sub) async {
    final box = Hive.box<String>(_boxName);
    await box.put(sub.id, sub.toJson());
  }

  static Future<void> deleteSubscription(String id) async {
    final box = Hive.box<String>(_boxName);
    await box.delete(id);
  }

  // --- CSV Export Engine ---
  static String exportToCsv() {
    final subs = getAllSubscriptions();
    final StringBuffer csv = StringBuffer();
    csv.writeln("Service Name,Cost,Billing Frequency,Next Renewal Date,Annual Outflow,Notes");
    for (var sub in subs) {
      final date = "${sub.nextBillingDate.year}-${sub.nextBillingDate.month.toString().padLeft(2, '0')}-${sub.nextBillingDate.day.toString().padLeft(2, '0')}";
      final notes = (sub.notes ?? '').replaceAll(',', ';').replaceAll('\n', ' ');
      csv.writeln("${sub.name},${sub.cost.toStringAsFixed(2)},${sub.billingCycle},$date,${sub.annualCost.toStringAsFixed(2)},$notes");
    }
    return csv.toString();
  }

  // --- Pro Status ---
  static bool isProLocallyUnlocked() {
    final box = Hive.box(_settingsBoxName);
    return box.get('is_pro_user', defaultValue: false);
  }

  static Future<void> setProLocally(bool isPro) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('is_pro_user', isPro);
  }

  // --- Currency Configuration ---
  static String getCurrencySymbol() {
    final box = Hive.box(_settingsBoxName);
    return box.get('currency_symbol', defaultValue: '\$');
  }

  static Future<void> setCurrencySymbol(String symbol) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('currency_symbol', symbol);
  }

  // --- Biometric Lock Configuration ---
  static bool isBiometricEnabled() {
    final box = Hive.box(_settingsBoxName);
    return box.get('biometric_lock_enabled', defaultValue: false);
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('biometric_lock_enabled', enabled);
  }

  // --- First-Time Launch Onboarding ---
  static bool hasSeenOnboarding() {
    final box = Hive.box(_settingsBoxName);
    return box.get('has_seen_onboarding', defaultValue: false);
  }

  static Future<void> setHasSeenOnboarding(bool seen) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('has_seen_onboarding', seen);
  }
}
