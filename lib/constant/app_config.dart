// Configuration for environment
// prod = production, stag = staging, dev = development
// Read from --dart-define=ENV=... at compile time.
// Defaults to 'stag' so local dev builds never accidentally hit production.
// Usage: flutter run                          (defaults to staging)
//        flutter run --dart-define=ENV=prod   (explicit production)
//        flutter build appbundle --dart-define=ENV=prod
const String env = String.fromEnvironment('ENV', defaultValue: 'stag');

const String baseUrl = env == 'prod'
    ? "https://api.optmsg.com"
    : env == 'stag'
    ? "https://staging-api.optmsg.com"
    : "https://konstantlab.com";
const String webAppUrl = env == 'prod'
    ? "https://web.optmsg.com"
    : env == 'stag'
    ? "https://staging.optmsg.com"
    : "https://konstantlab.com";
const String contactUrl = env == 'prod'
    ? "https://contact.optmsg.com"
    : env == 'stag'
    ? "https://staging-contact.optmsg.com"
    : "https://konstantlab.com";
// ignore: constant_identifier_names
const Map<String, dynamic> appInfo = {"name": "OptMsg"};

// S3 and bucket url
// ignore: constant_identifier_names
// const String S3BaseUrl = "https://optmsg-app.s3.us-east-1.amazonaws.com/";
const String s3BaseUrl = env == 'prod'
    ? "https://attachment.optmsg.com/"
    : env == 'stag'
    ? "https://staging-attachment.optmsg.com/"
    : "https://dev-attachment.optmsg.com/";
const String bucketFolder = "email/";

// Base API URLs
const String defaultBaseUrl =
    "$baseUrl${env == 'prod'
        ? "/api/"
        : env == 'stag'
        ? "/api/"
        : ":3140/api/"}";
const String contactBaseUrl =
    "$contactUrl${env == 'prod'
        ? "/"
        : env == 'stag'
        ? "/"
        : ":3133/"}";
const String socketUrl =
    "$baseUrl${env == 'prod'
        ? ""
        : env == 'stag'
        ? ""
        : ":3140"}";

// Descope Configuration
const String descopeApiBaseUrl = "https://api.descope.com/";
const String projectId = env == 'prod'
    ? "P2alQDgugt5dS2lwh9TmvxFve64y"
    : env == 'stag'
    ? "P2sGChBrHhLT2ISUptlvqdAeCVY3"
    : "P2g8jg3lnebcop4fXLvEHxQeNfaf";

// Web App URLs
const String webAppSignUp =
    "$webAppUrl${env == 'prod'
        ? "/signup"
        : env == 'stag'
        ? "/signup"
        : ":3187/signup"}";

const String webApp =
    "$webAppUrl${env == 'prod'
        ? "/"
        : env == 'stag'
        ? "/"
        : ":3187/"}";
// Print and Email URLs
const String printUrl = (env == 'prod' || env == 'stag')
    ? "$baseUrl/api/email/mail?mailId="
    : "$baseUrl:3140/api/email/mail?mailId=";

const String emailExtension = env == 'stag'
    ? "@staging.optmsg.com"
    : "@optmsg.com";

// Feature flags
// Set to true to use native Flutter compose instead of WebView compose.
// Toggle via: --dart-define=USE_NATIVE_COMPOSE=true
const bool useNativeCompose =
    bool.fromEnvironment('USE_NATIVE_COMPOSE', defaultValue: false);

// Send limits — defaults only. Actual limits are fetched from the server
// at login via GET user/get-profile (or a dedicated settings endpoint) and
// cached in SendLimits. These compile-time values are fallbacks if the
// server hasn't been reached yet. Server always enforces independently.
const int _defaultMaxRecipientsPerEmail = 100;
const int _defaultMaxDailySends = 250;

/// Runtime send limits — synced from server, falls back to compile-time defaults.
class SendLimits {
  static int maxRecipientsPerEmail = _defaultMaxRecipientsPerEmail;
  static int maxDailySends = _defaultMaxDailySends;

  /// Call once after login/profile fetch to sync limits from server.
  /// Expected payload: { "maxRecipientsPerEmail": 100, "maxDailySendsPerUser": 250 }
  static void updateFromServer(Map<String, dynamic>? settings) {
    if (settings == null) return;
    if (settings['maxRecipientsPerEmail'] is int) {
      maxRecipientsPerEmail = settings['maxRecipientsPerEmail'] as int;
    }
    if (settings['maxDailySendsPerUser'] is int) {
      maxDailySends = settings['maxDailySendsPerUser'] as int;
    }
  }
}

// Convenience getters for backward compatibility
int get maxRecipientsPerEmail => SendLimits.maxRecipientsPerEmail;
int get maxDailySends => SendLimits.maxDailySends;

// Miscellaneous
const int itemCount = 50;
String newNotification = 'no';
const List<String> kOfficeIpAddresses = [
  "111.93.246.170",
  "111.93.246.171",
  "111.93.246.172",
  "111.93.246.173",
  "111.93.246.174",
  "202.157.76.18",
  "202.157.76.19",
  "202.157.76.20",
  "202.157.76.21",
  "202.157.76.22",
];

/// Play Store and App Store URLs
const String playStoreUrl = 'https://play.google.com/store/apps/details?id=';
const String appStoreUrl = 'https://apps.apple.com/us/app/optmsg/id6742815057';

// youhavebeenspwned API KEY
const String hibpApiKey = 'd5260708c3234019a04e7e77efa9e7d7';
