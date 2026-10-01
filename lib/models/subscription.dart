import 'dart:convert';

class Subscription {
  final String id;
  final String name;
  final double cost;
  final DateTime nextBillingDate;
  final String billingCycle; // 'monthly' | 'yearly' | 'weekly'
  final String category;
  final String? iconName;
  final String? notes;
  final bool isTrial;
  final DateTime? trialEndDate;
  final int splitCount; // 1 = solo, 2+ = split with family/friends
  final String? paymentMethod; // e.g. 'Google Pay', 'Apple Pay', 'Amex', 'Visa'

  Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.nextBillingDate,
    this.billingCycle = 'monthly',
    this.category = 'General',
    this.iconName,
    this.notes,
    this.isTrial = false,
    this.trialEndDate,
    this.splitCount = 1,
    this.paymentMethod,
  });

  // Effective cost after family/roommate split
  double get effectiveCost => splitCount > 1 ? (cost / splitCount) : cost;

  // Calculate annual cost for spend analytics (based on user's actual share)
  double get annualCost {
    final c = effectiveCost;
    switch (billingCycle.toLowerCase()) {
      case 'weekly':
        return c * 52;
      case 'yearly':
        return c;
      case 'monthly':
      default:
        return c * 12;
    }
  }

  // Calculate monthly normalized cost (based on user's actual share)
  double get monthlyCost {
    final c = effectiveCost;
    switch (billingCycle.toLowerCase()) {
      case 'weekly':
        return (c * 52) / 12;
      case 'yearly':
        return c / 12;
      case 'monthly':
      default:
        return c;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'billingCycle': billingCycle,
      'category': category,
      'iconName': iconName,
      'notes': notes,
      'isTrial': isTrial,
      'trialEndDate': trialEndDate?.toIso8601String(),
      'splitCount': splitCount,
      'paymentMethod': paymentMethod,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      nextBillingDate: DateTime.tryParse(map['nextBillingDate'] ?? '') ?? DateTime.now(),
      billingCycle: map['billingCycle'] ?? 'monthly',
      category: map['category'] ?? 'General',
      iconName: map['iconName'],
      notes: map['notes'],
      isTrial: map['isTrial'] as bool? ?? false,
      trialEndDate: map['trialEndDate'] != null ? DateTime.tryParse(map['trialEndDate']) : null,
      splitCount: (map['splitCount'] as num?)?.toInt() ?? 1,
      paymentMethod: map['paymentMethod'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Subscription.fromJson(String source) => Subscription.fromMap(json.decode(source));

  Subscription copyWith({
    String? id,
    String? name,
    double? cost,
    DateTime? nextBillingDate,
    String? billingCycle,
    String? category,
    String? iconName,
    String? notes,
    bool? isTrial,
    DateTime? trialEndDate,
    int? splitCount,
    String? paymentMethod,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      billingCycle: billingCycle ?? this.billingCycle,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      notes: notes ?? this.notes,
      isTrial: isTrial ?? this.isTrial,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      splitCount: splitCount ?? this.splitCount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
