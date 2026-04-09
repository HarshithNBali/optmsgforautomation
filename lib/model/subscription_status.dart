/// H-STRIPE-02: Subscription status enum derived from existing user fields.
///
/// Replaces ad-hoc boolean checks with a single source of truth that
/// distinguishes lapsed paid accounts from never-subscribed users,
/// enabling recovery prompts for churned subscribers.
enum SubscriptionStatus {
  /// Paid subscriber with active subscription.
  active,

  /// Free/reader plan user with a valid (future) end date.
  freeActive,

  /// Free/reader plan user whose end date has passed.
  freeExpired,

  /// Previously paid subscriber whose subscription has expired.
  /// This is the key state that was previously invisible — these users
  /// should see a recovery/re-subscribe prompt.
  lapsed,

  /// No subscription data at all (new user, pre-checkout).
  none;

  /// Human-readable label for UI display.
  String get label => switch (this) {
        active => 'Active',
        freeActive => 'Active',
        freeExpired => 'Expired',
        lapsed => 'Expired',
        none => '',
      };

  /// Whether the user currently has access to paid features.
  bool get hasAccess => this == active;

  /// Whether the user had a paid subscription that is no longer active.
  /// Use this to decide whether to show a recovery/re-subscribe prompt.
  bool get isLapsed => this == lapsed;

  /// Whether the user is on any free plan (active or expired).
  bool get isFree => this == freeActive || this == freeExpired;

  /// Derives subscription status from a raw user JSON map
  /// (as stored in `authProvider.userData['user']`).
  ///
  /// Works with both `LoginModel.User.toJson()` output and raw API payloads.
  static SubscriptionStatus fromUserData(Map<String, dynamic>? userData) {
    if (userData == null) return none;

    final isSubscribed = userData['isSubscribed'] as bool? ?? false;
    final isFreeUser = userData['isFreeUser'] as bool?;
    final rawEnd = userData['subscriptionEndDate'] as int? ?? 0;

    // Normalise seconds → milliseconds (same logic as isSubscriptionValid)
    final endMs = rawEnd > 0 && rawEnd < 10000000000 ? rawEnd * 1000 : rawEnd;
    final hasEndDate = endMs > 0;
    final endInFuture =
        hasEndDate && DateTime.fromMillisecondsSinceEpoch(endMs).isAfter(DateTime.now());

    // Active paid subscriber
    if (isSubscribed && isFreeUser != true) return active;

    // Free/reader plan
    if (isFreeUser == true) {
      return endInFuture ? freeActive : freeExpired;
    }

    // Not subscribed, not free, but has a past end date → lapsed paid user
    if (!isSubscribed && hasEndDate && !endInFuture) return lapsed;

    return none;
  }
}
