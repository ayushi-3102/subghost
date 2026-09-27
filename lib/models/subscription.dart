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

  Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.nextBillingDate,
    this.billingCycle = 'monthly',
    this.category = 'General',
    this.iconName,
    this.notes,
  });

  // Calculate annual cost for spend analytics
  double get annualCost {
    switch (billingCycle.toLowerCase()) {
      case 'weekly':
        return cost * 52;
      case 'yearly':
        return cost;
      case 'monthly':
      default:
        return cost * 12;
    }
  }

  // Calculate monthly normalized cost
  double get monthlyCost {
    switch (billingCycle.toLowerCase()) {
      case 'weekly':
        return (cost * 52) / 12;
      case 'yearly':
        return cost / 12;
      case 'monthly':
      default:
        return cost;
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
    );
  }
}
