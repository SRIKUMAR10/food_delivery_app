import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Delivery_onboarding_page_state.dart';

abstract class DeliveryOnboardingRepositoryBase {
  Future<List<OnboardingFeatureItem>> getFeatures();
  Future<List<PartnerStatItem>> getPartnerStats();
  Future<void> saveSelectedLanguage(String languageCode);
  Future<String> getSelectedLanguage();
  Map<String, String> getSecureEnvironmentConfigs();
}

class DeliveryOnboardingRepository implements DeliveryOnboardingRepositoryBase {
  final SharedPreferences? prefs;

  DeliveryOnboardingRepository({this.prefs});

  @override
  Map<String, String> getSecureEnvironmentConfigs() {
    if (!dotenv.isInitialized) return const {};
    return {
      'BASE_URL': dotenv.env['BASE_URL'] ?? '',
      'API_KEY': dotenv.env['API_KEY'] ?? '',
      'KEY_SECRET': dotenv.env['KEY_SECRET'] ?? '',
    };
  }

  @override
  Future<List<OnboardingFeatureItem>> getFeatures() async {
    return const [
      OnboardingFeatureItem(
        title: 'Fast Delivery',
        description:
            'Optimized routes and smart navigation to save time and deliver more.',
        iconKey: 'fast_delivery',
      ),
      OnboardingFeatureItem(
        title: 'Flexible Earnings',
        description:
            'Choose your own hours and maximize your earnings potential.',
        iconKey: 'flexible_earnings',
      ),
      OnboardingFeatureItem(
        title: 'Live Tracking',
        description:
            'Real-time updates and live tracking for every delivery you make.',
        iconKey: 'live_tracking',
      ),
      OnboardingFeatureItem(
        title: 'Secure Payments',
        description:
            'Your earnings are safe with secure and instant payment options.',
        iconKey: 'secure_payments',
      ),
    ];
  }

  @override
  Future<List<PartnerStatItem>> getPartnerStats() async {
    return const [
      PartnerStatItem(
        value: '10K+',
        label: 'Active Partners',
        iconKey: 'partners',
      ),
      PartnerStatItem(
        value: '99.5%',
        label: 'On-time Delivery',
        iconKey: 'speed',
      ),
      PartnerStatItem(
        value: '4.8 ★',
        label: 'Partner Rating',
        iconKey: 'rating',
      ),
      PartnerStatItem(
        value: '24/7',
        label: 'Support',
        iconKey: 'support',
      ),
    ];
  }

  @override
  Future<void> saveSelectedLanguage(String languageCode) async {
    if (prefs != null) {
      await prefs!.setString('delivery_onboarding_lang', languageCode);
      return;
    }
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('delivery_onboarding_lang', languageCode);
    } catch (_) {}
  }

  @override
  Future<String> getSelectedLanguage() async {
    if (prefs != null) {
      return prefs!.getString('delivery_onboarding_lang') ?? 'English';
    }
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getString('delivery_onboarding_lang') ?? 'English';
    } catch (_) {
      return 'English';
    }
  }
}
