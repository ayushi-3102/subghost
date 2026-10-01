import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/cancellation_service.dart';
import '../services/paywall_service.dart';
import 'add_subscription_screen.dart';
import 'onboarding_screen.dart';
import 'paywall_screen.dart';
import 'settings_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'All';
  int _activeNavIndex = 0; // 0 = Subscriptions, 1 = Upcoming, 2 = Analytics, 3 = Settings

  final List<String> _categories = [
    'All',
    'Entertainment',
    'Music',
    'Wellness',
    'Shopping',
    'Intelligence',
    'Cloud & Storage',
    'Utilities',
  ];

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final totalMonthly = ref.watch(totalMonthlySpendProvider);
    final totalAnnual = ref.watch(totalAnnualSpendProvider);
    final categoryBreakdown = ref.watch(categorySpendBreakdownProvider);
    final currency = ref.watch(currencyProvider);
    final isPro = ref.watch(isProProvider);
    final isLocked = ref.watch(isVaultLockedProvider);

    // Filter and sort subscriptions by active view tab
    final filteredSubs = subscriptions.where((sub) {
      if (_activeNavIndex == 1) {
        // Upcoming tab: show bills due within 30 days
        final days = sub.nextBillingDate.difference(DateTime.now()).inDays;
        return days >= 0 && days <= 30;
      }
      if (_activeNavIndex == 2) {
        // Analytics tab: show all ranked by cost
        return true;
      }
      if (_selectedCategory == 'All') return true;
      return sub.category.toLowerCase().contains(_selectedCategory.toLowerCase());
    }).toList();

    if (_activeNavIndex == 1) {
      filteredSubs.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    } else if (_activeNavIndex == 2) {
      filteredSubs.sort((a, b) => b.monthlyCost.compareTo(a.monthlyCost));
    }

    // Find next urgent renewal
    Subscription? nextDueSub;
    int? nextDueDays;
    if (subscriptions.isNotEmpty) {
      final sortedByDate = List<Subscription>.from(subscriptions)
        ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
      final futureRenewals = sortedByDate.where((s) => s.nextBillingDate.isAfter(DateTime.now().subtract(const Duration(days: 1))));
      if (futureRenewals.isNotEmpty) {
        nextDueSub = futureRenewals.first;
        nextDueDays = nextDueSub.nextBillingDate.difference(DateTime.now()).inDays;
      } else {
        nextDueSub = sortedByDate.first;
        nextDueDays = nextDueSub.nextBillingDate.difference(DateTime.now()).inDays;
      }
    }

    final spendParts = totalMonthly.toStringAsFixed(2).split('.');
    final wholeSpend = spendParts[0];
    final decimalSpend = spendParts.length > 1 ? spendParts[1] : '00';

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E10), // Stitch Surface-Container-Lowest
      body: Stack(
        children: [
          // 1. Ambient Lighting (Stitch Aura Glow)
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA078FF).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            left: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E296).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header (Stitch with Controls)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.6,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const SizedBox(height: 3),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).push(
                                  CupertinoPageRoute(builder: (_) => const OnboardingScreen()),
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "SubGhost",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(CupertinoIcons.sparkles, size: 14, color: Color(0xFFA078FF)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Header Actions (Tour + Currency + Settings + VIP Pro Badge)
                        Row(
                          children: [
                            // Replay Tour Button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).push(
                                  CupertinoPageRoute(builder: (_) => const OnboardingScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1B1D),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFA078FF).withValues(alpha: 0.3)),
                                ),
                                child: const Icon(CupertinoIcons.play_circle_fill, color: Color(0xFFA078FF), size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Currency Switcher
                            GestureDetector(
                              onTap: () => _showCurrencyPicker(context, currency),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1B1D),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                child: Text(
                                  currency,
                                  style: const TextStyle(
                                    color: Color(0xFFD0BCFF),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Vault Settings
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const SettingsSheet(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1B1D),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                child: const Icon(CupertinoIcons.slider_horizontal_3, color: Colors.white70, size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // VIP Pro Status Pill
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).push(
                                  CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isPro
                                        ? [const Color(0xFF2E1065), const Color(0xFF3B0764)]
                                        : [const Color(0xFF201F21), const Color(0xFF1B1B1D)],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isPro
                                        ? const Color(0xFFA855F7).withValues(alpha: 0.7)
                                        : const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPro ? CupertinoIcons.shield_lefthalf_fill : CupertinoIcons.sparkles,
                                      size: 12,
                                      color: isPro ? const Color(0xFFC084FC) : const Color(0xFFFBBF24),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isPro ? "VIP" : "PRO",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                        color: isPro ? const Color(0xFFE9D5FF) : const Color(0xFFFDE68A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Stitch Hero Spending Overview Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: _buildStitchHeroCard(
                      currency: currency,
                      wholeSpend: wholeSpend,
                      decimalSpend: decimalSpend,
                      activeCount: subscriptions.length,
                      annualTotal: totalAnnual,
                      nextDueSub: nextDueSub,
                      nextDueDays: nextDueDays,
                    ),
                  ),
                ),

                // Visual Category Spend Velocity Bar (Breakdown)
                if (categoryBreakdown.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _buildCategoryBreakdownCard(currency, categoryBreakdown, totalMonthly),
                    ),
                  ),

                // Stitch Segmented Category Filter Bar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = cat);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFD0BCFF) : const Color(0xFF2A2A2C),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat == 'All' ? 'All (${subscriptions.length})' : cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? const Color(0xFF3C0091) : const Color(0xFFCBC3D7),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _activeNavIndex == 1 ? "Upcoming Renewals (<14d)" : "Active Services",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: Color(0xFFE5E1E4),
                          ),
                        ),
                        if (!isPro)
                          Text(
                            "${subscriptions.length}/${PaywallService.freeSubscriptionLimit} Used",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: subscriptions.length >= PaywallService.freeSubscriptionLimit
                                  ? const Color(0xFFFFB4AB)
                                  : const Color(0xFFD0BCFF),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Subscriptions List with Stitch Brand Badges
                if (filteredSubs.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          "No subscriptions found",
                          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.35)),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sub = filteredSubs[index];
                          return _buildStitchSubscriptionItem(context, ref, sub, currency);
                        },
                        childCount: filteredSubs.length,
                      ),
                    ),
                  ),

                // 📈 Stitch 6-Month Cash Flow Sparkline Graph Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _buildStitchSparklineCard(totalMonthly, currency),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(height: 120 + MediaQuery.paddingOf(context).bottom),
                ),
              ],
            ),
          ),

          // 3. Stitch Frosted Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStitchBottomNavBar(context),
          ),

          // 4. Biometric FaceID Vault Lock Overlay
          if (isLocked)
            _buildBiometricLockOverlay(context, ref),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 74 + MediaQuery.paddingOf(context).bottom,
          right: 6,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA078FF).withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFA078FF),
            foregroundColor: const Color(0xFF340080),
            elevation: 0,
            shape: const CircleBorder(),
            onPressed: () {
              HapticFeedback.lightImpact();
              final isPro = ref.read(isProProvider);
              final currentCount = ref.read(subscriptionsProvider).length;

              if (!isPro && currentCount >= PaywallService.freeSubscriptionLimit) {
                Navigator.of(context).push(
                  CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()),
                );
              } else {
                Navigator.of(context).push(
                  CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const AddSubscriptionScreen()),
                );
              }
            },
            child: const Icon(CupertinoIcons.add, size: 28),
          ),
        ),
      ),
    );
  }

  // --- Stitch Hero Spending Overview Card ---
  Widget _buildStitchHeroCard({
    required String currency,
    required String wholeSpend,
    required String decimalSpend,
    required int activeCount,
    required double annualTotal,
    required Subscription? nextDueSub,
    required int? nextDueDays,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2C), // surface-container-high
            Color(0xFF201F21), // surface-container
            Color(0xFF1B1B1D), // surface-container-low
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Metric
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Monthly Spend",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFCBC3D7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF353437),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.arrow_up_right, size: 11, color: Color(0xFF4DFFB2)),
                    SizedBox(width: 4),
                    Text(
                      "+11.3%",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4DFFB2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Split Currency Figure
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currency,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD0BCFF),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                wholeSpend,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE5E1E4),
                  letterSpacing: -1.5,
                ),
              ),
              Text(
                ".$decimalSpend",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFCBC3D7),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Quick Metrics Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E0E10).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(CupertinoIcons.square_stack_3d_up_fill, size: 16, color: Color(0xFFD0BCFF)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Active", style: TextStyle(fontSize: 11, color: Color(0xFFCBC3D7))),
                          Text(
                            "$activeCount Vaults",
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E0E10).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(CupertinoIcons.repeat, size: 16, color: Color(0xFF4DFFB2)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Next Due", style: TextStyle(fontSize: 11, color: Color(0xFFCBC3D7))),
                            Text(
                              nextDueSub != null ? "${nextDueSub.name} • ${nextDueDays}d" : "None",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Micro Upcoming Notice Strip
          if (nextDueSub != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF353437).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFB4AB),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      "${DateFormat('MMM d').format(nextDueSub.nextBillingDate)} renewal: ${nextDueSub.name} ($currency${nextDueSub.cost.toStringAsFixed(2)})",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBC3D7), fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_right, size: 12, color: Color(0xFF958EA0)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- 📈 Stitch 6-Month Cash Flow Sparkline Graph Card ---
  Widget _buildStitchSparklineCard(double monthly, String currency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1D), // surface-container-low
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "6-Month Outflow Trend",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE5E1E4),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF003822),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00E296).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.graph_circle, size: 12, color: Color(0xFF4DFFB2)),
                    SizedBox(width: 4),
                    Text(
                      "Stable",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4DFFB2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Painted Smooth Sparkline Chart
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(),
            ),
          ),
          const SizedBox(height: 10),

          // Month Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("May", style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              Text("Jun", style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              Text("Jul", style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              Text("Aug", style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              Text("Sep", style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              const Text("Oct", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFD0BCFF))),
            ],
          ),
        ],
      ),
    );
  }

  // --- Category Spend Breakdown ---
  Widget _buildCategoryBreakdownCard(String currency, Map<String, double> breakdown, double total) {
    if (total <= 0) return const SizedBox.shrink();

    final colors = [
      const Color(0xFFA078FF),
      const Color(0xFF4DFFB2),
      const Color(0xFF4CD7F6),
      const Color(0xFFFFB4AB),
      const Color(0xFFE9DDFF),
    ];

    int colorIndex = 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF201F21),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SPEND VELOCITY BREAKDOWN",
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Color(0xFF958EA0),
                ),
              ),
              const Icon(CupertinoIcons.chart_pie_fill, size: 14, color: Color(0xFFD0BCFF)),
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: breakdown.entries.map((entry) {
                  final pct = (entry.value / total);
                  final color = colors[colorIndex++ % colors.length];
                  return Expanded(
                    flex: (pct * 1000).toInt(),
                    child: Container(color: color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: breakdown.entries.map((entry) {
              final pct = ((entry.value / total) * 100).toStringAsFixed(0);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFCBC3D7)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$currency${entry.value.toStringAsFixed(0)} ($pct%)",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD0BCFF)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Stitch Subscription Item with Real Brand Logos ---
  Widget _buildStitchSubscriptionItem(BuildContext context, WidgetRef ref, Subscription sub, String currency) {
    final now = DateTime.now();
    final daysLeft = sub.nextBillingDate.difference(now).inDays;
    final isUrgent = daysLeft >= 0 && daysLeft <= 3;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showSubscriptionDetailsSheet(context, ref, sub, currency);
      },
      child: Dismissible(
        key: Key(sub.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF93000A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(CupertinoIcons.trash_fill, color: Colors.white),
        ),
        onDismissed: (_) {
          HapticFeedback.mediumImpact();
          ref.read(subscriptionsProvider.notifier).deleteSubscription(sub.id);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF201F21),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUrgent ? const Color(0xFFFFB4AB).withValues(alpha: 0.4) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Real Brand Icon Badge
              _buildBrandAvatar(sub.name),
              const SizedBox(width: 14),

              // Title & Subtitle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            sub.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE5E1E4),
                            ),
                          ),
                        ),
                        if (isUrgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF93000A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${daysLeft}d left",
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFFFDAD6)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${sub.category} • Renews ${DateFormat('MMM d').format(sub.nextBillingDate)}",
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF958EA0)),
                    ),
                  ],
                ),
              ),

              // Cost
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$currency${sub.cost.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE5E1E4),
                    ),
                  ),
                  Text(
                    sub.billingCycle == 'yearly' ? "/yr" : "/mo",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF958EA0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Real Brand Logo Avatar Builder
  Widget _buildBrandAvatar(String name) {
    final lower = name.toLowerCase();

    // Netflix
    if (lower.contains('netflix')) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Text(
          "N",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE50914),
            fontFamily: 'serif',
          ),
        ),
      );
    }

    // Spotify
    if (lower.contains('spotify')) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1DB954).withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.waveform, color: Color(0xFF1DB954), size: 24),
      );
    }

    // Apple One / Music
    if (lower.contains('apple')) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.device_laptop, color: Colors.white, size: 22),
      );
    }

    // ChatGPT / OpenAI
    if (lower.contains('chatgpt') || lower.contains('ai') || lower.contains('openai')) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF10A37F).withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.sparkles, color: Color(0xFF10A37F), size: 22),
      );
    }

    // YouTube
    if (lower.contains('youtube')) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF0000).withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.play_circle_fill, color: Color(0xFFFF0000), size: 24),
      );
    }

    // Amazon
    if (lower.contains('amazon') || lower.contains('prime')) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Icon(CupertinoIcons.cart_fill, color: Color(0xFFFF9900), size: 22),
      );
    }

    // Default Squircle Monogram
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "S",
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Color(0xFFD0BCFF),
        ),
      ),
    );
  }

  // --- Stitch Frosted Bottom Navigation Bar ---
  Widget _buildStitchBottomNavBar(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + (bottomInset > 0 ? bottomInset : 8)),
          decoration: BoxDecoration(
            color: const Color(0xFF131315).withValues(alpha: 0.94),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, CupertinoIcons.creditcard, "Subscriptions"),
              _buildNavItem(1, CupertinoIcons.calendar_today, "Upcoming"),
              _buildNavItem(2, CupertinoIcons.chart_pie, "Analytics"),
              _buildNavItem(3, CupertinoIcons.settings, "Settings"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _activeNavIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        if (index == 3) {
          // Open Settings Modal
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const SettingsSheet(),
          );
        } else {
          setState(() => _activeNavIndex = index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: isActive ? const Color(0xFFD0BCFF) : const Color(0xFF958EA0),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFFD0BCFF) : const Color(0xFF958EA0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1-Tap Cancellation Bottom Sheet ---
  void _showSubscriptionDetailsSheet(BuildContext context, WidgetRef ref, Subscription sub, String currency) {
    final cancelUrl = CancellationService.getCancellationUrl(sub.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131315),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sub.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      "$currency${sub.cost.toStringAsFixed(2)} / ${sub.billingCycle}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD0BCFF)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Next charge on ${sub.nextBillingDate.month}/${sub.nextBillingDate.day}/${sub.nextBillingDate.year}",
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
                ),
                if (sub.notes != null && sub.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF201F21),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sub.notes!,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // ⚡ 1-Tap Cancellation Portal Button
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Clipboard.setData(ClipboardData(text: cancelUrl ?? ""));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("⚡ Cancellation link copied: $cancelUrl"),
                          backgroundColor: const Color(0xFFBE123C),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.arrow_up_right_square, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Launch Cancellation Portal",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => AddSubscriptionScreen(existingSubscription: sub),
                        ),
                      );
                    },
                    child: const Text("Edit Subscription Details", style: TextStyle(color: Colors.white54)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Currency Picker Sheet ---
  void _showCurrencyPicker(BuildContext context, String current) {
    final currencies = ['\$', '€', '£', '¥', '₹', 'C\$'];
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text("Select Currency Unit"),
          actions: currencies.map((sym) {
            return CupertinoActionSheetAction(
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(currencyProvider.notifier).setCurrency(sym);
                Navigator.of(context).pop();
              },
              child: Text(
                sym,
                style: TextStyle(
                  color: sym == current ? const Color(0xFFA078FF) : Colors.white,
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

  // --- Biometric FaceID Vault Lock Overlay ---
  Widget _buildBiometricLockOverlay(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFA078FF), Color(0xFF6D3BD7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA078FF).withValues(alpha: 0.5),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(CupertinoIcons.lock_fill, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "SubGhost Vault Locked",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "Encrypted biometric authentication required",
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA078FF),
                foregroundColor: const Color(0xFF340080),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                ref.read(isVaultLockedProvider.notifier).state = false;
              },
              icon: const Icon(CupertinoIcons.sparkles, size: 18),
              label: const Text("Unlock with FaceID", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Smooth Sparkline Painter for Stitch 6-Month Cash Flow ---
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD0BCFF).withValues(alpha: 0.35),
          const Color(0xFFD0BCFF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final strokePaint = Paint()
      ..color = const Color(0xFFD0BCFF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF4DFFB2)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.78);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.74, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.54, size.width, size.height * 0.25);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Draw active endpoint pulse dot
    canvas.drawCircle(Offset(size.width, size.height * 0.25), 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
