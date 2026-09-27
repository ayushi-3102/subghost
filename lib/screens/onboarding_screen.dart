import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';

class QuickServicePreset {
  final String id;
  final String name;
  final double cost;
  final String category;
  final Widget icon;

  const QuickServicePreset({
    required this.id,
    required this.name,
    required this.cost,
    required this.category,
    required this.icon,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  // Pre-selected default 3 services matching the Stitch design
  final Set<String> _selectedIds = {'netflix', 'spotify', 'chatgpt'};

  // 1. Entrance Controller for staggered animations
  late final AnimationController _entranceController;

  // 2. Pulse Controller for breathing violet ambient glow
  late final AnimationController _pulseController;

  // 3. Shimmer Controller for the primary CTA button
  late final AnimationController _shimmerController;

  final List<QuickServicePreset> _presets = [
    QuickServicePreset(
      id: 'netflix',
      name: 'Netflix',
      cost: 15.99,
      category: 'Entertainment',
      icon: const Text(
        'N',
        style: TextStyle(
          color: Color(0xFFE50914),
          fontWeight: FontWeight.w900,
          fontSize: 20,
          fontFamily: 'serif',
        ),
      ),
    ),
    QuickServicePreset(
      id: 'spotify',
      name: 'Spotify',
      cost: 16.99,
      category: 'Music',
      icon: const Icon(CupertinoIcons.waveform, color: Color(0xFF1DB954), size: 20),
    ),
    QuickServicePreset(
      id: 'youtube',
      name: 'YouTube',
      cost: 13.99,
      category: 'Entertainment',
      icon: const Icon(CupertinoIcons.play_circle_fill, color: Color(0xFFFF0000), size: 20),
    ),
    QuickServicePreset(
      id: 'apple_one',
      name: 'Apple One',
      cost: 37.95,
      category: 'Cloud & Storage',
      icon: const Icon(CupertinoIcons.device_laptop, color: Colors.white, size: 19),
    ),
    QuickServicePreset(
      id: 'chatgpt',
      name: 'ChatGPT',
      cost: 20.00,
      category: 'Productivity',
      icon: const Icon(CupertinoIcons.sparkles, color: Color(0xFF10A37F), size: 19),
    ),
    QuickServicePreset(
      id: 'icloud',
      name: 'iCloud+',
      cost: 2.99,
      category: 'Cloud & Storage',
      icon: const Icon(CupertinoIcons.cloud_fill, color: Color(0xFF4CD7F6), size: 19),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding({required bool prefillData}) async {
    HapticFeedback.mediumImpact();
    await StorageService.setHasSeenOnboarding(true);

    if (prefillData && _selectedIds.isNotEmpty) {
      final notifier = ref.read(subscriptionsProvider.notifier);
      final now = DateTime.now();

      int dayOffset = 3;
      for (final preset in _presets) {
        if (_selectedIds.contains(preset.id)) {
          final sub = Subscription(
            id: 'init_${preset.id}_${now.millisecondsSinceEpoch}',
            name: preset.name,
            cost: preset.cost,
            billingCycle: 'monthly',
            nextBillingDate: now.add(Duration(days: dayOffset)),
            category: preset.category,
            notes: 'Pre-loaded from Quick-Start',
          );
          await notifier.addSubscription(sub);
          dayOffset += 5;
        }
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131315),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav Strip: LOCAL ENGINE indicator + Close 'x'
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003822),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E296).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated pulsing green status dot
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            final alpha = 0.5 + (_pulseController.value * 0.5);
                            return Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4DFFB2).withValues(alpha: alpha),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4DFFB2).withValues(alpha: alpha * 0.8),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          "LOCAL ENGINE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: Color(0xFF4DFFB2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _completeOnboarding(prefillData: false),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF201F21),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: const Icon(CupertinoIcons.xmark, size: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content with Staggered Entrance
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    // 1. Centered Emblem with Breathing Violet Halo Glow
                    _buildAnimatedEmblem(),

                    const SizedBox(height: 14),

                    // 2. Headline & Subtitle with Fade & Slide
                    _buildAnimatedHeader(),

                    const SizedBox(height: 22),

                    // 3. 3 Privacy Feature Cards (Staggered Slide-In)
                    _buildAnimatedCard(
                      intervalStart: 0.25,
                      intervalEnd: 0.65,
                      child: _buildFeatureCard(
                        icon: CupertinoIcons.lock_shield_fill,
                        iconColor: const Color(0xFFD0BCFF),
                        title: "100% Offline Vault",
                        badge: "Encrypted",
                        badgeColor: const Color(0xFF4DFFB2),
                        badgeBg: const Color(0xFF003822),
                        subtitle: "Zero bank syncing, zero tracking. All financial assets stay encrypted on-device.",
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildAnimatedCard(
                      intervalStart: 0.35,
                      intervalEnd: 0.75,
                      child: _buildFeatureCard(
                        icon: CupertinoIcons.bolt_fill,
                        iconColor: const Color(0xFF4DFFB2),
                        title: "1-Tap Direct Cancellation",
                        badge: "Instant",
                        badgeColor: const Color(0xFFD0BCFF),
                        badgeBg: const Color(0xFF2E1065),
                        subtitle: "Cancel sneaky renewals in seconds with automated deep links before you get charged.",
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildAnimatedCard(
                      intervalStart: 0.45,
                      intervalEnd: 0.85,
                      child: _buildFeatureCard(
                        icon: CupertinoIcons.bell_fill,
                        iconColor: const Color(0xFF4CD7F6),
                        title: "Renewal Radar",
                        badge: "Smart Ping",
                        badgeColor: const Color(0xFF4CD7F6),
                        badgeBg: const Color(0xFF003640),
                        subtitle: "Silent triggers alert you 72h and 24h before trial periods and annual fees execute.",
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Quick-Add Grid with Smooth Pop-In
                    _buildAnimatedCard(
                      intervalStart: 0.55,
                      intervalEnd: 0.95,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Quick-Add Common Services",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Tap to preload into your vault",
                                    style: TextStyle(fontSize: 11, color: Color(0xFF958EA0)),
                                  ),
                                ],
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(scale: animation, child: child),
                                child: Text(
                                  "${_selectedIds.length} Selected",
                                  key: ValueKey(_selectedIds.length),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFA078FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildPresetsGrid(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTAs: Glowing Shimmer "Enter My Vault →" + "Skip to empty vault"
            _buildAnimatedCtaSection(),
          ],
        ),
      ),
    );
  }

  // --- Widget 1: Animated Central Shield Emblem ---
  Widget _buildAnimatedEmblem() {
    final scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Breathing Radial Glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final glowRadius = 70.0 + (_pulseController.value * 25.0);
                  final glowAlpha = 0.22 + (_pulseController.value * 0.22);
                  return Container(
                    width: glowRadius * 2,
                    height: glowRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFA078FF).withValues(alpha: glowAlpha),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Solid Dark Frosted Shield Tile
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.shield_lefthalf_fill,
                      color: Color(0xFFD0BCFF),
                      size: 36,
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DFFB2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1B1B1D), width: 1.8),
                        ),
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

  // --- Widget 2: Animated Header ---
  Widget _buildAnimatedHeader() {
    final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: const Column(
          children: [
            Text(
              "Welcome to SubGhost",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "100% Private & Offline Subscription Tracker",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFFCBC3D7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for Staggered Cards ---
  Widget _buildAnimatedCard({
    required double intervalStart,
    required double intervalEnd,
    required Widget child,
  }) {
    final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
      ),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  // --- Widget 3: Presets Grid with Tap Spring Scale ---
  Widget _buildPresetsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _presets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final preset = _presets[index];
        final isSelected = _selectedIds.contains(preset.id);

        return _PresetCardItem(
          preset: preset,
          isSelected: isSelected,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedIds.remove(preset.id);
              } else {
                _selectedIds.add(preset.id);
              }
            });
          },
        );
      },
    );
  }

  // --- Widget 4: Animated CTA Section with Shimmer Sweep ---
  Widget _buildAnimatedCtaSection() {
    final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _completeOnboarding(prefillData: true),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    final shimmerProgress = _shimmerController.value;
                    return Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + (shimmerProgress * 2.0), -0.5),
                          end: Alignment(1.0 + (shimmerProgress * 2.0), 0.5),
                          colors: const [
                            Color(0xFFA078FF),
                            Color(0xFF8B5CF6),
                            Color(0xFFC084FC),
                            Color(0xFFA078FF),
                          ],
                          stops: const [0.0, 0.45, 0.55, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA078FF).withValues(alpha: 0.45),
                            blurRadius: 22,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Enter My Vault",
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(CupertinoIcons.arrow_right, size: 16, color: Colors.white),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _completeOnboarding(prefillData: false),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    "Skip to empty vault",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF958EA0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF26262A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFCBC3D7),
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
}

// Dedicated Preset Card with Tap Spring Feedback & Checkmark Rotation
class _PresetCardItem extends StatefulWidget {
  final QuickServicePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetCardItem({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PresetCardItem> createState() => _PresetCardItemState();
}

class _PresetCardItemState extends State<_PresetCardItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFA078FF)
                  : Colors.white.withValues(alpha: 0.08),
              width: widget.isSelected ? 1.6 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFA078FF).withValues(alpha: 0.28),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Selection Indicator (Checkmark / Plus with micro-flip transition)
              Positioned(
                top: 0,
                right: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey(widget.isSelected),
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? const Color(0xFFA078FF)
                          : const Color(0xFF2A2A2C),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isSelected ? CupertinoIcons.check_mark : CupertinoIcons.add,
                      size: 11,
                      color: widget.isSelected
                          ? const Color(0xFF131315)
                          : Colors.white60,
                    ),
                  ),
                ),
              ),

              // Centered Brand Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.preset.icon,
                    const SizedBox(height: 6),
                    Text(
                      widget.preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: widget.isSelected ? Colors.white : const Color(0xFFCBC3D7),
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
