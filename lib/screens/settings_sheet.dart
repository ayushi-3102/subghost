import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../services/notification_service.dart';
import '../services/paywall_service.dart';
import '../services/storage_service.dart';
import 'onboarding_screen.dart';
import 'paywall_screen.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    final currency = ref.watch(currencyProvider);
    final isBiometricOn = ref.watch(biometricEnabledProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0714),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Vault Settings",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.xmark, color: Colors.white70, size: 15),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // VIP Pro Card Banner
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1754), Color(0xFF160E2C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPro ? const Color(0xFFA855F7) : const Color(0xFFF59E0B).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPro ? CupertinoIcons.shield_lefthalf_fill : CupertinoIcons.sparkles,
                          color: isPro ? const Color(0xFFC084FC) : const Color(0xFFFBBF24),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPro ? "SubGhost Centurion Active" : "Unlock SubGhost Lifetime",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPro
                                  ? "All biometric features and unlimited vaults unlocked"
                                  : "Tap to view VIP lifetime membership privileges",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: Security & Hardware
              _buildSectionTitle("SECURITY & PREFERENCES"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF130E22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      activeTrackColor: const Color(0xFF8B5CF6),
                      secondary: const Icon(CupertinoIcons.lock_shield_fill, color: Color(0xFF10B981)),
                      title: const Text("FaceID Biometric Lock", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text("Require biometric scan to open vault", style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
                      value: isBiometricOn,
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        ref.read(biometricEnabledProvider.notifier).toggle();
                      },
                    ),
                    Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(CupertinoIcons.money_dollar_circle_fill, color: Color(0xFFA78BFA)),
                      title: const Text("Vault Currency Unit", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF281848),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4)),
                        ),
                        child: Text(currency, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showCurrencyPicker(context, ref, currency);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Section 2: Data Portability & Backup
              _buildSectionTitle("DATA PORTABILITY & BACKUP"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF130E22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: const Icon(CupertinoIcons.doc_text_fill, color: Color(0xFF06B6D4)),
                  title: const Text("Export Vault to CSV", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text("Generate spreadsheet for tax & accounting", style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
                  trailing: const Icon(CupertinoIcons.share, color: Colors.white54, size: 18),
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    final csv = StorageService.exportToCsv();
                    Clipboard.setData(ClipboardData(text: csv));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("📑 Vault exported! CSV copied to clipboard."),
                        backgroundColor: Color(0xFF06B6D4),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Section 3: Renewal Radar (Push Notifications)
              _buildSectionTitle("RENEWAL RADAR (PREMIUM PUSH ALERTS)"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF130E22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    StatefulBuilder(
                      builder: (context, setTileState) {
                        final isNotifEnabled = NotificationService.areNotificationsEnabled();
                        return SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          activeTrackColor: const Color(0xFF8B5CF6),
                          secondary: const Icon(CupertinoIcons.bell_fill, color: Color(0xFF4CD7F6)),
                          title: const Text(
                            "Proactive Renewal Alerts",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            "Offline alerts 48h & 24h before cards charge",
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
                          ),
                          value: isNotifEnabled,
                          onChanged: (val) async {
                            HapticFeedback.mediumImpact();
                            await NotificationService.setNotificationsEnabled(val);
                            setTileState(() {});
                          },
                        );
                      },
                    ),
                    Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(CupertinoIcons.speaker_2_fill, color: Color(0xFF4DFFB2)),
                      title: const Text(
                        "Send Test Renewal Alert",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "Simulates a 48h renewal notice with haptics",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
                      ),
                      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
                      onTap: () {
                        NotificationService.showTestNotification(
                          context,
                          serviceName: 'Netflix Premium 4K',
                          cost: 15.99,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Section 4: First-Run Experience & Tours
              _buildSectionTitle("EXPERIENCE & ONBOARDING"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF130E22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: const Icon(CupertinoIcons.play_circle_fill, color: Color(0xFFA078FF)),
                      title: const Text(
                        "Replay Animated Welcome Tour",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "Watch the animated opening screen and quick-add presets",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
                      ),
                      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => const OnboardingScreen()),
                        );
                      },
                    ),
                    Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(CupertinoIcons.arrow_counterclockwise_circle_fill, color: Color(0xFFE5E1E4)),
                      title: const Text(
                        "Reset to First-Run State",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "Next app launch will trigger the Welcome screen",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
                      ),
                      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
                      onTap: () async {
                        HapticFeedback.heavyImpact();
                        await StorageService.setHasSeenOnboarding(false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✨ First-run state reset! Opening the Animated Welcome screen..."),
                            backgroundColor: Color(0xFFA078FF),
                          ),
                        );
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(builder: (_) => const OnboardingScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Section 5: Legal Disclosures (Mandatory for Apple Review)
              _buildSectionTitle("LEGAL & PRIVACY (APPLE REVIEW COMPLIANT)"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF130E22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: const Icon(CupertinoIcons.hand_raised_fill, color: Colors.white60, size: 18),
                      title: const Text("Privacy Policy", style: TextStyle(color: Colors.white, fontSize: 13.5)),
                      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white24, size: 14),
                      onTap: () => _showLegalDialog(
                        context,
                        "Privacy Policy",
                        "SubGhost operates on a strict 100% Offline-First architecture.\n\n"
                        "1. Zero Telemetry: We do not collect, transmit, store, or sell any of your financial data, billing cycles, or personal names.\n\n"
                        "2. On-Device Storage: All data resides strictly in your device's sandboxed local hardware storage.\n\n"
                        "3. Third Parties: No third-party analytics, tracking SDKs, or cloud databases are incorporated.",
                      ),
                    ),
                    Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: const Icon(CupertinoIcons.doc_plaintext, color: Colors.white60, size: 18),
                      title: const Text("Terms of Service (EULA)", style: TextStyle(color: Colors.white, fontSize: 13.5)),
                      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white24, size: 14),
                      onTap: () => _showLegalDialog(
                        context,
                        "Terms of Service (EULA)",
                        "SubGhost is licensed under the standard Apple End User License Agreement (EULA).\n\n"
                        "1. License: You are granted a personal, non-exclusive license to use SubGhost on supported iOS and iPadOS devices.\n\n"
                        "2. Subscriptions: Payment will be charged to your Apple ID account upon purchase confirmation. Subscriptions auto-renew unless cancelled at least 24 hours prior to the current period end.\n\n"
                        "3. Restoration: You may restore active lifetime or subscription purchases on any device linked to your Apple ID at any time.",
                      ),
                    ),
                    Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: const Icon(CupertinoIcons.arrow_clockwise, color: Colors.white60, size: 18),
                      title: const Text("Restore StoreKit Purchases", style: TextStyle(color: Colors.white, fontSize: 13.5)),
                      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white24, size: 14),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final success = await PaywallService.restorePurchases();
                        if (context.mounted) {
                          ref.read(isProProvider.notifier).checkStatus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? "Purchases successfully restored!" : "No active license found."),
                              backgroundColor: const Color(0xFF8B5CF6),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Version & Sovereign Badge
              Center(
                child: Column(
                  children: [
                    Text(
                      "SUBGHOST v1.0.0 (BUILD 1)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sovereign Offline Architecture • Zero Cloud Risk",
                      style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.2)),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, String current) {
    final currencies = ['\$', '€', '£', '¥', '₹', 'C\$'];
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text("Select Currency Unit"),
          actions: currencies.map((sym) {
            return CupertinoActionSheetAction(
              onPressed: () {
                ref.read(currencyProvider.notifier).setCurrency(sym);
                Navigator.of(context).pop();
              },
              child: Text(
                sym,
                style: TextStyle(
                  color: sym == current ? const Color(0xFFA855F7) : Colors.white,
                  fontWeight: sym == current ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Done"),
          ),
        );
      },
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(content, textAlign: TextAlign.left, style: const TextStyle(fontSize: 12.5)),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
