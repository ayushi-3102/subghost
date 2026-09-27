import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subscription.dart';
import 'storage_service.dart';

class NotificationService {
  static const String _notificationsEnabledKey = 'renewal_notifications_enabled';
  static const String _leadTimeDaysKey = 'notification_lead_time_days';

  // --- Preference Getters & Setters ---
  static bool areNotificationsEnabled() {
    final box = StorageService.getSettingsBox();
    return box.get(_notificationsEnabledKey, defaultValue: true);
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final box = StorageService.getSettingsBox();
    await box.put(_notificationsEnabledKey, enabled);
  }

  static int getLeadTimeDays() {
    final box = StorageService.getSettingsBox();
    return box.get(_leadTimeDaysKey, defaultValue: 2);
  }

  static Future<void> setLeadTimeDays(int days) async {
    final box = StorageService.getSettingsBox();
    await box.put(_leadTimeDaysKey, days);
  }

  // --- Schedule Renewal Alerts for Subscriptions ---
  static void scheduleRenewalReminders(List<Subscription> subscriptions) {
    if (!areNotificationsEnabled()) return;

    final now = DateTime.now();
    final leadDays = getLeadTimeDays();

    for (final sub in subscriptions) {
      final daysUntilRenewal = sub.nextBillingDate.difference(now).inDays;
      // Scheduled local notification trigger logic
      if (daysUntilRenewal <= leadDays && daysUntilRenewal >= 0) {
        debugPrint(
          '[Renewal Radar] Scheduled alert for ${sub.name}: '
          'Renews in $daysUntilRenewal days (${sub.cost})',
        );
      }
    }
  }

  // --- Trigger In-App Test Notification Banner ---
  static void showTestNotification(BuildContext context, {String? serviceName, double? cost}) {
    HapticFeedback.heavyImpact();

    final name = serviceName ?? 'Netflix';
    final amount = cost ?? 15.99;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1D24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFA078FF).withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA078FF).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2834),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF4DFFB2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Renewal Radar Alert 🔔",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: Color(0xFFD0BCFF),
                          ),
                        ),
                        Text(
                          "in 48 hours",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "$name will renew for \$${amount.toStringAsFixed(2)}. Tap to cancel before charge.",
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFE5E1E4),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
