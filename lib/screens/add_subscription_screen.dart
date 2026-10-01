import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/currency_service.dart';
import '../services/paywall_service.dart';
import 'paywall_screen.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? existingSubscription;

  const AddSubscriptionScreen({super.key, this.existingSubscription});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String _billingCycle = 'monthly';
  String _category = 'Entertainment';

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSubscription;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _costController = TextEditingController(text: existing != null ? existing.cost.toStringAsFixed(existing.cost.truncateToDouble() == existing.cost ? 0 : 2) : '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    if (existing != null) {
      _selectedDate = existing.nextBillingDate;
      _billingCycle = existing.billingCycle;
      _category = existing.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyTemplate(Map<String, dynamic> template) {
    HapticFeedback.lightImpact();
    final currency = ref.read(currencyProvider);
    final cost = CurrencyService.getPresetCost(
      preset: template,
      cycle: _billingCycle,
      currencySymbol: currency,
    );
    setState(() {
      _nameController.text = template['name'];
      _costController.text = cost.toStringAsFixed(cost.truncateToDouble() == cost ? 0 : 2);
      _category = template['category'];
    });
  }

  void _submit() async {
    HapticFeedback.mediumImpact();
    if (!_formKey.currentState!.validate()) return;

    final isPro = ref.read(isProProvider);
    final currentCount = ref.read(subscriptionsProvider).length;

    // Check freemium quota (3 items max for free tier)
    if (widget.existingSubscription == null && !isPro && currentCount >= PaywallService.freeSubscriptionLimit) {
      Navigator.of(context).push(
        CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const PaywallScreen()),
      );
      return;
    }

    final cost = double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0.0;
    final sub = Subscription(
      id: widget.existingSubscription?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      cost: cost,
      nextBillingDate: _selectedDate,
      billingCycle: _billingCycle,
      category: _category,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (widget.existingSubscription == null) {
      await ref.read(subscriptionsProvider.notifier).addSubscription(sub);
    } else {
      await ref.read(subscriptionsProvider.notifier).updateSubscription(sub);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSubscription != null;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF040306), // Void Obsidian
      body: Stack(
        children: [
          // Ambient purple orb
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
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
                      Text(
                        isEditing ? "Modify Vault Item" : "New Subscription",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Luxury Large Amount Input Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1B1432), Color(0xFF0F0B1E)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "RECURRING OUTFLOW",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _costController,
                                  textAlign: TextAlign.center,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "0.00",
                                    hintStyle: const TextStyle(color: Colors.white24),
                                    prefixText: "$currency ",
                                    prefixStyle: const TextStyle(
                                      color: Color(0xFFA855F7),
                                      fontSize: 40,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return "Enter an amount";
                                    if (double.tryParse(val.replaceAll(',', '.')) == null) return "Invalid";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Billed automatically on cycle",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          if (!isEditing) ...[
                            Text(
                              "QUICK PRESETS",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 38,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: CurrencyService.presetServices.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final t = CurrencyService.presetServices[index];
                                  final currency = ref.watch(currencyProvider);
                                  final cost = CurrencyService.getPresetCost(
                                    preset: t,
                                    cycle: _billingCycle,
                                    currencySymbol: currency,
                                  );
                                  final costStr = cost.truncateToDouble() == cost ? cost.toInt().toString() : cost.toStringAsFixed(2);
                                  return ActionChip(
                                    backgroundColor: const Color(0xFF130E24),
                                    label: Text(
                                      "${t['name']} • $currency$costStr",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onPressed: () => _applyTemplate(t),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                          ],

                          // Service Name Field
                          _buildSectionTitle("SERVICE OR MERCHANT"),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            decoration: _buildLuxuryInput("e.g. Netflix, Equinox, Bloomberg"),
                            validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 18),

                          // Billing Frequency
                          _buildSectionTitle("BILLING CADENCE"),
                          Row(
                            children: [
                              _buildCadenceSelector("Monthly", "monthly"),
                              const SizedBox(width: 8),
                              _buildCadenceSelector("Yearly", "yearly"),
                              const SizedBox(width: 8),
                              _buildCadenceSelector("Weekly", "weekly"),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Next Billing Date Picker
                          _buildSectionTitle("NEXT RENEWAL DATE"),
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.selectionClick();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFFA855F7),
                                        surface: Color(0xFF160F2B),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                              decoration: BoxDecoration(
                                color: const Color(0xFF120E22),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(CupertinoIcons.calendar, color: Color(0xFFC084FC), size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Notes
                          _buildSectionTitle("PRIVATE MEMO (OPTIONAL)"),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: _buildLuxuryInput("e.g. Split with partner, review in December"),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  Widget _buildCadenceSelector(String label, String value) {
    final isSelected = _billingCycle == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (_billingCycle == value) return;
          final oldCycle = _billingCycle;
          final newCycle = value;
          setState(() {
            _billingCycle = newCycle;

            // Auto-update price if matched with preset or custom calculation
            final currentName = _nameController.text.trim().toLowerCase();
            final matched = CurrencyService.presetServices.firstWhere(
              (p) => (p['name'] as String).toLowerCase().contains(currentName) ||
                     (currentName.isNotEmpty && currentName.contains((p['name'] as String).toLowerCase())),
              orElse: () => {},
            );

            final currency = ref.read(currencyProvider);
            if (matched.isNotEmpty) {
              final cost = CurrencyService.getPresetCost(
                preset: matched,
                cycle: newCycle,
                currencySymbol: currency,
              );
              _costController.text = cost.toStringAsFixed(cost.truncateToDouble() == cost ? 0 : 2);
            } else {
              final currentCost = double.tryParse(_costController.text.trim()) ?? 0.0;
              if (currentCost > 0) {
                if (oldCycle == 'monthly' && newCycle == 'yearly') {
                  final yearly = currentCost * 12;
                  _costController.text = yearly.toStringAsFixed(yearly.truncateToDouble() == yearly ? 0 : 2);
                } else if (oldCycle == 'yearly' && newCycle == 'monthly') {
                  final monthly = currentCost / 12;
                  _costController.text = monthly.toStringAsFixed(2);
                }
              }
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFF3B1875), Color(0xFF241049)])
                : null,
            color: isSelected ? null : const Color(0xFF120E22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFA855F7) : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildLuxuryInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13.5),
      filled: true,
      fillColor: const Color(0xFF120E22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFA855F7), width: 1.5),
      ),
    );
  }
}
