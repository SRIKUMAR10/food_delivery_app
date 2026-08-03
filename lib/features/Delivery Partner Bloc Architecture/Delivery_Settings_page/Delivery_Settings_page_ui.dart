import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'Delivery_Settings_page_bloc.dart';
import 'Delivery_Settings_page_event.dart';
import 'Delivery_Settings_page_repository.dart';
import 'Delivery_Settings_page_service.dart';
import 'Delivery_Settings_page_state.dart';
import '../../../core/theme/delivery_app_colors.dart';

String formatDeliveryCurrency(num amount, String localeCode) {
  try {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  } catch (_) {
    return '\u20B9${amount.toStringAsFixed(2)}';
  }
}

class DeliverySettingsStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Delivery Settings',
      'subtitle':
          'Manage your delivery preferences and app behaviour.',
      'preferences': 'Delivery Preferences',
      'radius': 'Delivery Radius',
      'radiusSub': 'How far you are willing to travel for each delivery.',
      'km': 'km',
      'language': 'Language',
      'languageSub': 'Choose your preferred language for the app.',
      'english': 'English',
      'tamil': 'Tamil',
      'appBehaviour': 'App Behaviour',
      'notifications': 'Notifications',
      'notificationsSub': 'Get real-time alerts for new delivery requests.',
      'autoAccept': 'Auto-Accept Orders',
      'autoAcceptSub': 'Automatically accept matching orders in your area.',
      'darkMode': 'Dark Mode',
      'darkModeSub': 'Use a dark theme for better visibility at night.',
      'sunMode': 'Outdoor / Sun Mode',
      'sunModeSub': 'High-contrast light theme for direct sunlight visibility.',
      'oledMode': 'OLED Battery Saver',
      'oledModeSub': 'True black theme. Saves 15-30% battery on OLED screens.',
      'earningsPreview': 'Estimated Daily Earnings',
      'earningsPreviewSub':
          'Based on your delivery radius and demand in your area.',
      'perDay': 'per day',
      'helpSupport': 'Help & Support',
      'helpSupportSub':
          'Have questions? Our support team is here to help you.',
      'contactSupport': 'Contact Support',
      'helpContacted':
          'Support request submitted. Our team will reach out shortly.',
      'save': 'Save Settings',
      'saving': 'Saving...',
      'saved': 'Settings saved successfully',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'errorTitle': 'Something went wrong',
      'emptyTitle': 'No settings available',
      'emptySub': 'No delivery settings were found. Refresh to load them.',
    },
    'ta': {
      'title': 'டெலிவரி அமைப்புகள்',
      'subtitle': 'உங்கள் டெலிவரி விருப்பங்களையும் பயன்பாட்டு நடத்தையையும் நிர்வகிக்கவும்.',
      'preferences': 'டெலிவரி விருப்பங்கள்',
      'radius': 'டெலிவரி ஆரம்',
      'radiusSub': 'ஒவ்வொரு டெலிவரிக்கும் நீங்கள் பயணிக்க விரும்பும் தூரம்.',
      'km': 'கி.மீ',
      'language': 'மொழி',
      'languageSub': 'பயன்பாட்டிற்கான உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்.',
      'english': 'ஆங்கிலம்',
      'tamil': 'தமிழ்',
      'appBehaviour': 'பயன்பாட்டு நடத்தை',
      'notifications': 'அறிவிப்புகள்',
      'notificationsSub': 'புதிய டெலிவரி கோரிக்கைகளுக்கான நேரடி எச்சரிக்கைகளைப் பெறுங்கள்.',
      'autoAccept': 'ஆர்டர்களை தானாக ஏற்கவும்',
      'autoAcceptSub': 'உங்கள் பகுதியில் உள்ள பொருந்தும் ஆர்டர்களை தானாக ஏற்கவும்.',
      'darkMode': 'டார்க் மோட்',
      'darkModeSub': 'இரவில் சிறந்த பார்வைக்காக இருண்ட தீம் பயன்படுத்தவும்.',
      'sunMode': 'வெளிப்புற / சூரிய மோட்',
      'sunModeSub': 'நேரடி சூரிய ஒளியில் தெளிவான பார்வைக்கு அதிக மாறுபாடு கொண்ட தீம்.',
      'oledMode': 'OLED பேட்டரி சேமிப்பு',
      'oledModeSub': 'OLED திரைகளில் 15-30% பேட்டரியை சேமிக்கும் உண்மையான கருப்பு தீம்.',
      'earningsPreview': 'மதிப்பிடப்பட்ட தினசரி வருவாய்',
      'earningsPreviewSub': 'உங்கள் டெலிவரி ஆரம் மற்றும் உங்கள் பகுதியில் உள்ள தேவையின் அடிப்படையில்.',
      'perDay': 'ஒரு நாளுக்கு',
      'helpSupport': 'உதவி & ஆதரவு',
      'helpSupportSub': 'கேள்விகள் உள்ளதா? எங்கள் ஆதரவு குழு உங்களுக்கு உதவ இங்கே உள்ளது.',
      'contactSupport': 'ஆதரவைத் தொடர்பு கொள்ளவும்',
      'helpContacted': 'ஆதரவு கோரிக்கை சமர்ப்பிக்கப்பட்டது. எங்கள் குழு விரைவில் தொடர்பு கொள்ளும்.',
      'save': 'அமைப்புகளை சேமிக்கவும்',
      'saving': 'சேமிக்கிறது...',
      'saved': 'அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'refresh': 'புதுப்பிக்கவும்',
      'errorTitle': 'ஏதோ தவறு ஏற்பட்டது',
      'emptyTitle': 'அமைப்புகள் இல்லை',
      'emptySub': 'டெலிவரி அமைப்புகள் எதுவும் கிடைக்கவில்லை. அவற்றை ஏற்ற புதுப்பிக்கவும்.',
    },
  };

  static String of(String key, String localeCode) {
    final localeMap = _strings[localeCode] ?? _strings['en']!;
    return localeMap[key] ?? _strings['en']![key]!;
  }
}

class DeliverySettingsPage extends StatelessWidget {
  final DeliverySettingsRepositoryBase? repository;
  final DeliverySettingsServiceBase? service;
  final DeliverySettingsBloc? bloc;

  const DeliverySettingsPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliverySettingsBloc>.value(
        value: bloc!,
        child: const DeliverySettingsPageView(),
      );
    }

    return BlocProvider<DeliverySettingsBloc>(
      create: (context) => DeliverySettingsBloc(
        repository: repository ?? DeliverySettingsRepository(),
        service: service ?? DeliverySettingsService(),
      )..add(const DeliverySettingsInitEvent()),
      child: const DeliverySettingsPageView(),
    );
  }
}

class DeliverySettingsPageView extends StatelessWidget {
  const DeliverySettingsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliverySettingsBloc, DeliverySettingsState>(
      listener: (context, state) {
        if (state.saveStatus == DeliverySettingsSaveStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                DeliverySettingsStrings.of('saved', state.localeCode),
              ),
              backgroundColor: DeliveryAppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.errorMessage != null &&
            state.status != DeliverySettingsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return KeyedSubtree(
          key: const Key('dp_settings_page'),
          child: switch (state.status) {
            DeliverySettingsStatus.initial ||
            DeliverySettingsStatus.loading =>
              const _SettingsSkeleton(),
            DeliverySettingsStatus.saving ||
            DeliverySettingsStatus.loaded =>
              _SettingsLoadedView(state: state),
            DeliverySettingsStatus.error => _SettingsErrorView(state: state),
            DeliverySettingsStatus.empty => _SettingsEmptyView(state: state),
          },
        );
      },
    );
  }
}

class _SettingsLoadedView extends StatefulWidget {
  final DeliverySettingsState state;

  const _SettingsLoadedView({required this.state});

  @override
  State<_SettingsLoadedView> createState() => _SettingsLoadedViewState();
}

class _SettingsLoadedViewState extends State<_SettingsLoadedView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final TextEditingController _radiusController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _radiusController = TextEditingController(
      text: widget.state.deliveryRadius.toStringAsFixed(1),
    );
    _entranceController.forward();
  }

  @override
  void didUpdateWidget(covariant _SettingsLoadedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.deliveryRadius != widget.state.deliveryRadius) {
      _radiusController.text = widget.state.deliveryRadius.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeader(state: widget.state),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isDesktop = constraints.maxWidth >= 1024;
                        final bool isTablet = constraints.maxWidth >= 600;

                        final Widget mainColumn = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PreferencesCard(
                              state: widget.state,
                              radiusController: _radiusController,
                            ),
                            const SizedBox(height: 20),
                            _ToggleCard(state: widget.state),
                          ],
                        );

                        final Widget sideColumn = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _EarningsCard(state: widget.state),
                            const SizedBox(height: 20),
                            _HelpCard(state: widget.state),
                          ],
                        );

                        if (isDesktop || isTablet) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: mainColumn),
                              const SizedBox(width: 24),
                              Expanded(flex: 2, child: sideColumn),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            mainColumn,
                            const SizedBox(height: 20),
                            _EarningsCard(state: widget.state),
                            const SizedBox(height: 20),
                            _HelpCard(state: widget.state),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _SaveBar(state: widget.state, localeCode: widget.state.localeCode),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final DeliverySettingsState state;

  const _SettingsHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DeliverySettingsStrings.of('title', state.localeCode),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DeliverySettingsStrings.of('subtitle', state.localeCode),
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ],
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  final DeliverySettingsState state;
  final TextEditingController radiusController;

  const _PreferencesCard({
    required this.state,
    required this.radiusController,
  });

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Container(
      key: const Key('dp_settings_preferences_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliverySettingsStrings.of('preferences', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliverySettingsStrings.of('radius', localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliverySettingsStrings.of('radiusSub', localeCode),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                key: const Key('dp_settings_radius_value'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${state.deliveryRadius.toStringAsFixed(1)} '
                  '${DeliverySettingsStrings.of('km', localeCode)}',
                  style: const TextStyle(
                    color: DeliveryAppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label:
                '${DeliverySettingsStrings.of('radius', localeCode)} '
                '${state.deliveryRadius.toStringAsFixed(1)}',
            child: Slider(
              key: const Key('dp_settings_radius_slider'),
              value: state.deliveryRadius.clamp(1.0, 20.0),
              min: 1.0,
              max: 20.0,
              divisions: 38,
              activeColor: DeliveryAppColors.primary,
              inactiveColor: const Color(0xFF1A2530),
              onChanged: (value) => context
                  .read<DeliverySettingsBloc>()
                  .add(DeliverySettingsUpdateRadiusEvent(value)),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            key: const Key('dp_settings_radius_input'),
            controller: radiusController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText:
                  '${DeliverySettingsStrings.of('radius', localeCode)} '
                  '(${DeliverySettingsStrings.of('km', localeCode)})',
              suffixText: DeliverySettingsStrings.of('km', localeCode),
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFF0B1219),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DeliveryAppColors.primaryDark),
              ),
            ),
            onSubmitted: (value) {
              final parsed = context
                  .read<DeliverySettingsBloc>()
                  .service
                  .parseDeliveryRadius(value);
              context
                  .read<DeliverySettingsBloc>()
                  .add(DeliverySettingsUpdateRadiusEvent(parsed));
            },
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.language, color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliverySettingsStrings.of('language', localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliverySettingsStrings.of('languageSub', localeCode),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('dp_settings_language_dropdown'),
            initialValue: state.languageCode.isEmpty ? null : state.languageCode,
            dropdownColor: const Color(0xFF0D141C),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0B1219),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DeliveryAppColors.primaryDark),
              ),
            ),
            items: [
              for (final code in DeliverySettingsRepository.supportedLanguageCodes)
                DropdownMenuItem(
                  value: code,
                  child: Text(
                    DeliverySettingsStrings.of(
                      code == 'en' ? 'english' : 'tamil',
                      localeCode,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                context
                    .read<DeliverySettingsBloc>()
                    .add(DeliverySettingsChangeLanguageEvent(value));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final DeliverySettingsState state;

  const _ToggleCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    final List<DeliverySettingsItem> items = state.items;
    return Container(
      key: const Key('dp_settings_toggle_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.toggle_on_outlined,
                  color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliverySettingsStrings.of('appBehaviour', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++) ...[
            _ToggleTile(item: items[i], localeCode: localeCode),
            if (i != items.length - 1)
              Divider(color: Colors.white.withValues(alpha: 0.06)),
          ],
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final DeliverySettingsItem item;
  final String localeCode;

  const _ToggleTile({required this.item, required this.localeCode});

  void _onChanged(BuildContext context) {
    final bloc = context.read<DeliverySettingsBloc>();
    switch (item.id) {
      case 'notifications':
        bloc.add(const DeliverySettingsToggleNotificationEvent());
        break;
      case 'autoAccept':
        bloc.add(const DeliverySettingsToggleAutoAcceptEvent());
        break;
      case 'darkMode':
        bloc.add(const DeliverySettingsToggleDarkModeEvent());
        break;
      case 'sunMode':
        bloc.add(const DeliverySettingsToggleSunModeEvent());
        break;
      case 'oledMode':
        bloc.add(const DeliverySettingsToggleOledModeEvent());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.value
                  ? DeliveryAppColors.primaryDark.withValues(alpha: 0.12)
                  : const Color(0xFF1A2530),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.value
                  ? DeliveryAppColors.primary
                  : const Color(0xFF64748B),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliverySettingsStrings.of(item.titleKey, localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DeliverySettingsStrings.of(item.subtitleKey, localeCode),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: DeliverySettingsStrings.of(item.titleKey, localeCode),
            toggled: item.value,
            child: Switch(
              key: Key('dp_settings_toggle_${item.id}'),
              value: item.value,
              activeThumbColor: const Color(0xFF06120B),
              activeTrackColor: DeliveryAppColors.primaryDark,
              inactiveThumbColor: const Color(0xFF64748B),
              inactiveTrackColor: const Color(0xFF1A2530),
              onChanged: (_) => _onChanged(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final DeliverySettingsState state;

  const _EarningsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    final double estimate = state.deliveryRadius * 240.0;
    return Container(
      key: const Key('dp_settings_earnings_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DeliveryAppColors.primaryDark.withValues(alpha: 0.2),
        ),
        gradient: LinearGradient(
          colors: [
            DeliveryAppColors.surface,
            DeliveryAppColors.primaryDark.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliverySettingsStrings.of('earningsPreview', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DeliverySettingsStrings.of('earningsPreviewSub', localeCode),
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Text(
            formatDeliveryCurrency(estimate, localeCode),
            key: const Key('dp_settings_earnings_amount'),
            style: const TextStyle(
              color: DeliveryAppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DeliverySettingsStrings.of('perDay', localeCode),
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final DeliverySettingsState state;

  const _HelpCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Container(
      key: const Key('dp_settings_help_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: DeliveryAppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DeliverySettingsStrings.of('helpSupport', localeCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DeliverySettingsStrings.of('helpSupportSub', localeCode),
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('dp_settings_help_button'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      DeliverySettingsStrings.of('helpContacted', localeCode),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.headset_mic_outlined, size: 18),
              label: Text(
                DeliverySettingsStrings.of('contactSupport', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: DeliveryAppColors.primary,
                side: const BorderSide(color: DeliveryAppColors.primaryDark),
                minimumSize: const Size(160, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final DeliverySettingsState state;
  final String localeCode;

  const _SaveBar({required this.state, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final bool saving = state.saveStatus == DeliverySettingsSaveStatus.saving;
    return Container(
      key: const Key('dp_settings_save_bar'),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewPadding.bottom > 0 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            key: const Key('dp_settings_save_button'),
            onPressed: saving
                ? null
                : () => context
                    .read<DeliverySettingsBloc>()
                    .add(const DeliverySettingsSaveEvent()),
            style: FilledButton.styleFrom(
              backgroundColor: DeliveryAppColors.primaryDark,
              disabledBackgroundColor: const Color(0xFF1A2530),
              foregroundColor: const Color(0xFF06120B),
              disabledForegroundColor: const Color(0xFF64748B),
              minimumSize: const Size(180, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF64748B),
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              saving
                  ? DeliverySettingsStrings.of('saving', localeCode)
                  : DeliverySettingsStrings.of('save', localeCode),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  Widget _box({
    required double width,
    required double height,
    BorderRadius radius = const BorderRadius.all(Radius.circular(10)),
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: radius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('dp_settings_skeleton'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 200, height: 24),
          const SizedBox(height: 12),
          _box(width: 300, height: 12),
          const SizedBox(height: 24),
          _box(
            width: double.infinity,
            height: 260,
            radius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 20),
          _box(
            width: double.infinity,
            height: 220,
            radius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }
}

class _SettingsErrorView extends StatelessWidget {
  final DeliverySettingsState state;

  const _SettingsErrorView({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Center(
      key: const Key('dp_settings_error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFF87171),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              DeliverySettingsStrings.of('errorTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.errorMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('dp_settings_retry'),
              onPressed: () => context
                  .read<DeliverySettingsBloc>()
                  .add(const DeliverySettingsRetryEvent()),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                DeliverySettingsStrings.of('retry', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsEmptyView extends StatelessWidget {
  final DeliverySettingsState state;

  const _SettingsEmptyView({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Center(
      key: const Key('dp_settings_empty'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0D141C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_applications_outlined,
                color: Color(0xFF64748B),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DeliverySettingsStrings.of('emptyTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                DeliverySettingsStrings.of('emptySub', localeCode),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('dp_settings_refresh'),
              onPressed: () => context
                  .read<DeliverySettingsBloc>()
                  .add(const DeliverySettingsRetryEvent()),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                DeliverySettingsStrings.of('refresh', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
