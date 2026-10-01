import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../services/paywall_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;
  int _selectedTier = 1; // 0 = monthly, 1 = lifetime (recommended)

  @override
  Widget build(BuildContext context) {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      backgroundColor: const Color(0xFF030206), // Deep Space Obsidian
      body: Stack(
        children: [
          // 1. Ambient Luxury Radial Mesh Lights
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA855F7).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.xmark, color: Colors.white70, size: 16),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          setState(() => _isLoading = true);
                          final success = await PaywallService.restorePurchases();
                          setState(() => _isLoading = false);
                          if (context.mounted) {
                            ref.read(isProProvider.notifier).checkStatus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? "VIP Privileges Restored!"
                                      : (isAndroid
                                          ? "No previous Google Play license found."
                                          : "No previous Apple ID license found."),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: success ? const Color(0xFF8B5CF6) : const Color(0xFF374151),
                              ),
                            );
                            if (success) Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          "Restore License",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // VIP Obsidian Pass Card
                        _buildBlackCardPass(),

                        const SizedBox(height: 28),

                        const Text(
                          "Private Wealth Suite",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Cancel a single forgotten renewal, and SubGhost pays for itself indefinitely.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Exclusive Luxury Features
                        _buildLuxuryFeature(
                          CupertinoIcons.infinite,
                          "Unlimited Active Vaults",
                          "Bypass the 3-subscription constraint forever",
                        ),
                        _buildLuxuryFeature(
                          CupertinoIcons.lock_shield_fill,
                          isAndroid ? "Biometric Security Lock" : "Biometric FaceID Lock",
                          isAndroid
                              ? "Encrypted on-device vault protected by fingerprint or face unlock"
                              : "Encrypted on-device vault protected by your biometric key",
                        ),
                        _buildLuxuryFeature(
                          CupertinoIcons.bell_fill,
                          "Precision Renewal Dispatch",
                          "Autonomous reminders 48h before card charges occur",
                        ),
                        _buildLuxuryFeature(
                          CupertinoIcons.graph_circle_fill,
                          "Runway Spend Analytics",
                          "Visualized outflow charts and recurring burn velocity",
                        ),

                        const SizedBox(height: 28),

                        // Tier Selection
                        Row(
                          children: [
                            Expanded(
                              child: _buildTierSelector(
                                title: "Monthly",
                                price: "\$2.99",
                                unit: "/ month",
                                subtitle: "Cancel anytime",
                                isSelected: _selectedTier == 0,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedTier = 0);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTierSelector(
                                title: "Lifetime VIP",
                                price: "\$9.99",
                                unit: "one-time",
                                subtitle: "Yours for eternity",
                                isBestValue: true,
                                isSelected: _selectedTier == 1,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedTier = 1);
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Luxury CTA Button
                        Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA855F7), Color(0xFF6366F1)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.45),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    HapticFeedback.heavyImpact();
                                    if (PaywallService.hasLiveBillingKey) {
                                      setState(() => _isLoading = true);
                                      // Real Google Play / StoreKit billing
                                      final success = await PaywallService.restorePurchases();
                                      setState(() => _isLoading = false);
                                      if (context.mounted && success) {
                                        Navigator.of(context).pop();
                                      }
                                    } else {
                                      // Offline / Mock / Test mode
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (ctx) => CupertinoAlertDialog(
                                          title: Text(isAndroid ? "Google Play In-App Purchase" : "Apple StoreKit Purchase"),
                                          content: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              isAndroid
                                                  ? "In this offline-first build, Google Play Billing requires a connected Google Play Store account with active merchant SKUs.\n\nTo test the Free Tier limits vs. VIP privileges, you can choose to simulate an unlock below or test free tier limits in Settings."
                                                  : "In this offline build, Apple StoreKit requires sandbox credentials.\n\nYou can simulate VIP unlock below or test free tier limits in Settings.",
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text("Stay on Free Tier"),
                                              onPressed: () => Navigator.of(ctx).pop(),
                                            ),
                                            CupertinoDialogAction(
                                              isDefaultAction: true,
                                              child: const Text("Simulate VIP Unlock"),
                                              onPressed: () async {
                                                Navigator.of(ctx).pop();
                                                setState(() => _isLoading = true);
                                                await ref.read(isProProvider.notifier).toggleDebug();
                                                setState(() => _isLoading = false);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("✨ VIP Privileges Activated (Simulation)."),
                                                      backgroundColor: Color(0xFF7C3AED),
                                                    ),
                                                  );
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                            child: _isLoading
                                ? const CupertinoActivityIndicator(color: Colors.white)
                                : Text(
                                    _selectedTier == 1
                                        ? "Claim Lifetime Membership (\$9.99)"
                                        : "Start Monthly Access (\$2.99/mo)",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.checkmark_shield_fill,
                                size: 12, color: Colors.white.withValues(alpha: 0.35)),
                            const SizedBox(width: 6),
                            Text(
                              isAndroid
                                  ? "Guaranteed by Google Play Billing • Zero Telemetry"
                                  : "Guaranteed by Apple StoreKit • Zero Telemetry",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _showLegalNotice(
                                context,
                                "Privacy Policy",
                                "SubGhost operates on a strict 100% Offline-First architecture.\n\n"
                                "1. Zero Telemetry: No financial data, subscription names, costs, or personal details are collected, transmitted, or stored on external servers.\n\n"
                                "2. Local Sandbox: All vaults are stored solely on your local device hardware.\n\n"
                                "3. Third Parties: No third-party trackers or data brokers are integrated.",
                              ),
                              child: Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  decoration: TextDecoration.underline,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            Text("  •  ", style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 10)),
                            GestureDetector(
                              onTap: () => _showLegalNotice(
                                context,
                                isAndroid ? "Terms of Service (Google Play)" : "Terms of Use (EULA)",
                                isAndroid
                                    ? "SubGhost Terms of Service adhere to Google Play Developer policies.\n\n"
                                      "1. License: You are granted a personal, non-exclusive license to use SubGhost on compatible Android devices.\n\n"
                                      "2. Subscriptions: Payment is charged to your Google Account upon purchase confirmation. Subscriptions automatically renew unless cancelled in Google Play Subscriptions at least 24 hours prior to renewal.\n\n"
                                      "3. Restoration: Active lifetime or subscription licenses can be restored on any Android device linked to your Google Account."
                                    : "SubGhost utilizes Apple's Standard EULA.\n\n"
                                      "1. License: You are granted a personal, non-exclusive license to use SubGhost on compatible iOS devices.\n\n"
                                      "2. Subscriptions: Payment will be charged to your Apple ID account upon purchase confirmation. Subscriptions auto-renew unless cancelled at least 24 hours prior to renewal.\n\n"
                                      "3. Restoration: You may restore active lifetime or subscription purchases on any device linked to your Apple ID at any time.",
                              ),
                              child: Text(
                                isAndroid ? "Terms of Service" : "Terms of Use (EULA)",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  decoration: TextDecoration.underline,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Centurion Black Card Pass
  Widget _buildBlackCardPass() {
    return Container(
      width: double.infinity,
      height: 175,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF281C48),
            Color(0xFF16102B),
            Color(0xFF090714),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFC084FC).withValues(alpha: 0.38),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
            blurRadius: 34,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.sparkles, color: Color(0xFFFBBF24), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "SUBGHOST CENTURION",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "UNLIMITED",
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black),
                ),
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LIFETIME FOUNDER PASS",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Autonomous local privacy engine active",
                style: TextStyle(fontSize: 11, color: Color(0xFFA78BFA)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MEMBER NO. #00492",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              const Icon(CupertinoIcons.radiowaves_right, color: Colors.white24, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  // Luxury Feature Item
  Widget _buildLuxuryFeature(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  const Color(0xFF6366F1).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: const Color(0xFFC084FC), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tier Selector Card
  Widget _buildTierSelector({
    required String title,
    required String price,
    required String unit,
    required String subtitle,
    bool isBestValue = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [const Color(0xFF2B1754), const Color(0xFF160E2C)]
                : [const Color(0xFF110E1D), const Color(0xFF0C0A14)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFA855F7) : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                ),
                if (isBestValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "★ BEST",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalNotice(BuildContext context, String title, String content) {
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
              child: const Text("Understood"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
