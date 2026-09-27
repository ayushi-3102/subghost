class CancellationService {
  static final Map<String, String> _cancellationUrls = {
    'netflix': 'https://www.netflix.com/youraccount',
    'spotify': 'https://www.spotify.com/account/subscription/',
    'apple': 'https://apps.apple.com/account/subscriptions',
    'apple music': 'https://apps.apple.com/account/subscriptions',
    'icloud': 'https://apps.apple.com/account/subscriptions',
    'amazon': 'https://www.amazon.com/mc/manage',
    'amazon prime': 'https://www.amazon.com/mc/manage',
    'prime': 'https://www.amazon.com/mc/manage',
    'chatgpt': 'https://chatgpt.com/#settings/Subscription',
    'openai': 'https://chatgpt.com/#settings/Subscription',
    'adobe': 'https://account.adobe.com/plans',
    'creative cloud': 'https://account.adobe.com/plans',
    'youtube': 'https://www.youtube.com/paid_memberships',
    'youtube premium': 'https://www.youtube.com/paid_memberships',
    'google': 'https://myaccount.google.com/payments-and-subscriptions',
    'disney': 'https://www.disneyplus.com/account',
    'hulu': 'https://secure.hulu.com/account',
    'hbo': 'https://auth.max.com/subscription',
    'max': 'https://auth.max.com/subscription',
  };

  static String? getCancellationUrl(String serviceName) {
    final lower = serviceName.toLowerCase().trim();
    for (var key in _cancellationUrls.keys) {
      if (lower.contains(key)) {
        return _cancellationUrls[key];
      }
    }
    // Fallback Apple Subscriptions URL for iOS apps
    return 'https://apps.apple.com/account/subscriptions';
  }
}
