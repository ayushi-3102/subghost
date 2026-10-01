import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import 'storage_service.dart';

class BackupService {
  static const String currentSchemaVersion = "1.0.0";

  /// Exports the entire vault to a clean JSON string
  static String exportVaultToJson() {
    final subs = StorageService.getAllSubscriptions();
    final currency = StorageService.getCurrencySymbol();

    final data = {
      'app': 'SubGhost',
      'schema_version': currentSchemaVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'currency': currency,
      'subscriptions_count': subs.length,
      'subscriptions': subs.map((s) => s.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Imports vault from a JSON string, saving subscriptions into local Hive storage.
  /// Returns the number of subscriptions successfully imported.
  static Future<int> importVaultFromJson(String jsonStr) async {
    try {
      final decoded = json.decode(jsonStr.trim());
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException("Invalid backup format: root must be a JSON object.");
      }

      final subsList = decoded['subscriptions'];
      if (subsList is! List) {
        throw const FormatException("Invalid backup payload: missing 'subscriptions' array.");
      }

      int importedCount = 0;
      for (final item in subsList) {
        if (item is Map<String, dynamic>) {
          try {
            final sub = Subscription.fromMap(item);
            if (sub.name.isNotEmpty) {
              await StorageService.saveSubscription(sub);
              importedCount++;
            }
          } catch (e) {
            debugPrint("Skipping malformed subscription item: $e");
          }
        }
      }

      // Optionally restore currency if present
      final backupCurrency = decoded['currency'];
      if (backupCurrency is String && backupCurrency.isNotEmpty) {
        await StorageService.setCurrencySymbol(backupCurrency);
      }

      return importedCount;
    } catch (e) {
      debugPrint("Backup import error: $e");
      rethrow;
    }
  }
}
