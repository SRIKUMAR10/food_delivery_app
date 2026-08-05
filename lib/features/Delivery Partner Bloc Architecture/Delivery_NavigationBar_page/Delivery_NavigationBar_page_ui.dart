import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Delivery_NavigationBar_page_bloc.dart';
import 'Delivery_NavigationBar_page_event.dart';
import 'Delivery_NavigationBar_page_repository.dart';
import 'Delivery_NavigationBar_page_service.dart';
import 'Delivery_NavigationBar_page_state.dart';
import '../Delivery_Profile_page/Delivery_Profile_page_ui.dart';
import '../Delivery_Dashboard_page/Delivery_Dashboard_page_ui.dart';
import '../Delivery_Orders_page/Delivery_Orders_page_ui.dart';
import '../Delivery_Navigation Screen_page/Delivery_Navigation Screen_page_ui.dart';
import '../Delivery_Earnings Dashboard_page/Delivery_Earnings Dashboard_page_ui.dart';
import '../Delivery_Wallet_page/Delivery_Wallet_page_ui.dart';
import '../Delivery_Order History_page/Delivery_Order History_page_ui.dart';
import '../Delivery_Incentives Dashboard_page/Delivery_Incentives Dashboard_page_ui.dart';
import '../Delivery_Settings_page/Delivery_Settings_page_ui.dart';
import '../Delivery_Incoming_Order_page/Delivery_Incoming_Order_page_ui.dart';
import '../Delivery_Pickup Confirmation_page/Delivery_Pickup Confirmation_page_ui.dart';
import '../Delivery_Delivery Completed_page/Delivery_Delivery Completed_page_ui.dart';
import '../../../core/repositories/delivery_active_order_session_repository.dart';
import '../../../core/theme/delivery_design_system.dart';
import '../auto_hide_app_bar_wrapper.dart';
import '../../../core/theme/delivery_app_colors.dart';
import '../../../core/theme/delivery_app_theme.dart';
import '../../../core/theme/delivery_app_typography.dart';

class DeliveryNavigationBarStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'brand': 'DELIVERY PARTNER',
      'tagline': 'Scooter Hub',
      'welcomeBack': 'Welcome back',
      'needHelp': 'Need Help?',
      'needHelpSub': 'We are here for you',
      'contactSupport': 'Contact Support',
      'contacting': 'Contacting support...',
      'online': 'Online',
      'offline': 'Offline',
      'overview': 'Overview',
      'manageHint': 'Manage your {label} and stay on top of your deliveries.',
      'retry': 'Retry',
      'emptyTitle': 'No navigation items available',
      'emptySub': 'Please refresh to load your workspace menu.',
      'offlineBanner': 'You are offline. Some features may be limited.',
    },
    'ta': {
      'brand': 'டெலிவரி பார்ட்னர்',
      'tagline': 'ஸ்கூட்டர் மையம்',
      'welcomeBack': 'மீண்டும் வரவேற்கிறோம்',
      'needHelp': 'உதவி தேவையா?',
      'needHelpSub': 'நாங்கள் உங்களுக்காக இருக்கிறோம்',
      'contactSupport': 'ஆதரவைத் தொடர்பு கொள்ளுங்கள்',
      'contacting': 'ஆதரவைத் தொடர்பு கொள்கிறோம்...',
      'online': 'நிகழ்நிலை',
      'offline': 'நிகழ்நிலையில் இல்லை',
      'overview': 'கண்ணோட்டம்',
      'manageHint':
          'உங்கள் {label}ஐ நிர்வகித்து, உங்கள் டெலிவரிகளில் முன்னணியில் இருங்கள்.',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'emptyTitle': 'வழிசெலுத்தல் உருப்படிகள் இல்லை',
      'emptySub': 'உங்கள் பணியிட மெனுவை ஏற்ற புதுப்பிக்கவும்.',
      'offlineBanner': 'நீங்கள் நிகழ்நிலையில் இல்லை. சில அம்சங்கள் வரம்புக்குட்பட்டவை.',
    },
  };

  static String of(String key, String localeCode) {
    final localeMap = _strings[localeCode] ?? _strings['en']!;
    return localeMap[key] ?? _strings['en']![key]!;
  }
}

class DeliveryNavigationBarPage extends StatelessWidget {
  final DeliveryNavigationBarRepositoryBase? repository;
  final DeliveryNavigationBarServiceBase? service;
  final DeliveryNavigationBarPageBloc? bloc;

  const DeliveryNavigationBarPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryNavigationBarPageBloc>.value(
        value: bloc!,
        child: const DeliveryNavigationBarPageView(),
      );
    }

    return BlocProvider<DeliveryNavigationBarPageBloc>(
      create: (context) => DeliveryNavigationBarPageBloc(
        repository: repository ?? DeliveryNavigationBarRepository(),
        service: service ?? DeliveryNavigationBarService(),
      )..add(const DeliveryNavigationBarInitEvent()),
      child: const DeliveryNavigationBarPageView(),
    );
  }
}

class DeliveryNavigationBarPageView extends StatefulWidget {
  const DeliveryNavigationBarPageView({super.key});

  @override
  State<DeliveryNavigationBarPageView> createState() =>
      _DeliveryNavigationBarPageViewState();
}

class _DeliveryNavigationBarPageViewState
    extends State<DeliveryNavigationBarPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _animController.value = 1.0;
    } else {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNavTap(BuildContext context, int index) {
    context
        .read<DeliveryNavigationBarPageBloc>()
        .add(DeliveryNavigationBarTabChangedEvent(index));
  }

  void _onContactSupportPressed(BuildContext context) {
    context
        .read<DeliveryNavigationBarPageBloc>()
        .add(const DeliveryNavigationBarContactSupportClickedEvent());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          DeliveryNavigationBarStrings.of('contacting', context
              .read<DeliveryNavigationBarPageBloc>()
              .state
              .localeCode),
        ),
        backgroundColor: DeliveryAppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryNavigationBarPageBloc, DeliveryNavigationBarState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null),
      listener: (context, state) {
        if (state.status == DeliveryNavigationBarStatus.loggedOut) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/deliveryLogin',
            (route) => false,
          );
        }
        if (state.status == DeliveryNavigationBarStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Something went wrong. Please try again.',
              ),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
            final isMobile = !isDesktop && !isTablet;
            final isLoaded = state.status == DeliveryNavigationBarStatus.loaded;

            Widget? drawer;
            Widget? bottomNavigationBar;
            if (isMobile && isLoaded) {
              drawer = _MobileDrawer(
                state: state,
                onItemTap: (i) => _onNavTap(context, i),
                onContactSupport: () => _onContactSupportPressed(context),
              );
              bottomNavigationBar = _MobileBottomBar(
                state: state,
                onItemTap: (i) => _onNavTap(context, i),
              );
            }

            final Widget body;
            if (state.status == DeliveryNavigationBarStatus.initial ||
                state.status == DeliveryNavigationBarStatus.loading) {
              body = _SkeletonShell(isMobile: isMobile);
            } else if (state.status == DeliveryNavigationBarStatus.error) {
              body = _ErrorShell(state: state);
            } else if (state.status == DeliveryNavigationBarStatus.empty) {
              body = _EmptyShell(state: state);
            } else {
              body = FadeTransition(
                opacity: _fadeAnim,
                child: _LoadedShell(
                  state: state,
                  isDesktop: isDesktop,
                  isTablet: isTablet,
                  isMobile: isMobile,
                  onNavTap: (i) => _onNavTap(context, i),
                  onContactSupport: () => _onContactSupportPressed(context),
                ),
              );
            }

            return Scaffold(
              backgroundColor: const Color(0xFF000000),
              drawer: drawer,
              bottomNavigationBar: bottomNavigationBar,
              body: body,
            );
          },
        );
      },
    );
  }
}

class _LoadedShell extends StatelessWidget {
  final DeliveryNavigationBarState state;
  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;
  final ValueChanged<int> onNavTap;
  final VoidCallback onContactSupport;

  const _LoadedShell({
    required this.state,
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
    required this.onNavTap,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = isTablet ? 260 : 280;

    final Widget sidebar = _DeliverySidebar(
      state: state,
      width: sidebarWidth,
      onItemTap: onNavTap,
      onContactSupport: onContactSupport,
    );

    if (isMobile) {
      return _ContentArea(state: state, isMobile: true);
    }

    return Row(
      children: [
        sidebar,
        Expanded(child: _ContentArea(state: state, isMobile: false)),
      ],
    );
  }
}

class _DeliverySidebar extends StatelessWidget {
  final DeliveryNavigationBarState state;
  final double width;
  final ValueChanged<int> onItemTap;
  final VoidCallback onContactSupport;

  const _DeliverySidebar({
    required this.state,
    required this.width,
    required this.onItemTap,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          _SidebarHeader(
            partnerName: state.partnerName,
            isOffline: state.isOffline,
            localeCode: state.localeCode,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (var i = 0; i < state.navItems.length; i++)
                  if (state.navItems[i].id != 'profile')
                    _SidebarMenuItem(
                      key: ValueKey('dp_nav_${state.navItems[i].id}'),
                      item: state.navItems[i],
                      isSelected: state.selectedIndex == i,
                      onTap: () => onItemTap(i),
                    ),
                if (state.isUploading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: _UploadProgressIndicator(
                      progress: state.uploadProgress,
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _HelpCard(
            localeCode: state.localeCode,
            onContactSupport: onContactSupport,
          ),
          const _LogoutButton(),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final String partnerName;
  final bool isOffline;
  final String localeCode;

  const _SidebarHeader({
    required this.partnerName,
    required this.isOffline,
    required this.localeCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [DeliveryAppColors.primary, DeliveryAppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: DeliveryAppSpacing.borderRadiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: DeliveryAppColors.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.two_wheeler,
                  color: DeliveryAppColors.buttonPrimaryText,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryNavigationBarStrings.of('brand', localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliveryNavigationBarStrings.of('tagline', localeCode),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D141C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1A2530),
                  child: Icon(Icons.person, color: Color(0xFF94A3B8), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isOffline
                                  ? const Color(0xFFEF4444)
                                  : DeliveryAppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOffline
                                ? DeliveryNavigationBarStrings.of(
                                    'offline',
                                    localeCode,
                                  )
                                : DeliveryNavigationBarStrings.of(
                                    'online',
                                    localeCode,
                                  ),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _SidebarMenuItem extends StatefulWidget {
  final DeliveryNavigationBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isSelected = widget.isSelected;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Tooltip(
                message: item.label,
                waitDuration: const Duration(milliseconds: 600),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DeliveryAppColors.primaryDark.withValues(alpha: 0.12)
                          : _hovered
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: DeliveryAppColors.primaryDark.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : _hovered
                              ? [
                                  BoxShadow(
                                    color: DeliveryAppColors.primaryDark.withValues(
                                      alpha: 0.12,
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 0.5,
                                  ),
                                ]
                              : const [],
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: 4,
                          height: isSelected ? 28 : (_hovered ? 16 : 0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? DeliveryAppColors.primary
                                : _hovered
                                    ? DeliveryAppColors.primary
                                        .withValues(alpha: 0.5)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? DeliveryAppColors.primary
                              : _hovered
                                  ? DeliveryAppColors.primary
                                      .withValues(alpha: 0.8)
                                  : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFE8FFF3)
                                  : _hovered
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : const Color(0xFF9AA5B1),
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            key: const Key('dp_nav_indicator'),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: DeliveryAppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String localeCode;
  final VoidCallback onContactSupport;

  const _HelpCard({
    required this.localeCode,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B14), Color(0xFF0A1410)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DeliveryAppColors.primaryDark.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headset_mic,
                  color: DeliveryAppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryNavigationBarStrings.of('needHelp', localeCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliveryNavigationBarStrings.of(
                        'needHelpSub',
                        localeCode,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onContactSupport,
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                DeliveryNavigationBarStrings.of('contactSupport', localeCode),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadProgressIndicator extends StatelessWidget {
  final double progress;

  const _UploadProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file, color: DeliveryAppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Uploading media...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: DeliveryAppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF1A2530),
              valueColor: const AlwaysStoppedAnimation(DeliveryAppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  final DeliveryNavigationBarState state;
  final bool isMobile;

  const _ContentArea({required this.state, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        state.navItems.isNotEmpty &&
        state.selectedIndex >= 0 &&
        state.selectedIndex < state.navItems.length;

    final appBar = _ContentTopBar(state: state, isMobile: isMobile);
    final body = Column(
      children: [
        if (state.isOffline) const _OfflineBanner(),
        Expanded(
          child: IndexedStack(
            index: hasSelection ? state.selectedIndex : 0,
            children: [
              for (var i = 0; i < state.navItems.length; i++)
                _DeferredNavigationPage(
                  isActive: state.selectedIndex == i,
                  builder: () {
                    switch (state.navItems[i].id) {
                      case 'dashboard':
                        return const DeliveryDashboardPage();
                      case 'orders':
                        return const DeliveryOrdersPage();
                      case 'earnings':
                        return const DeliveryEarningsDashboardPage();
                      case 'incentives':
                        return const DeliveryIncentivesDashboardPage();
                      case 'navigate':
                        return const DeliveryNavigationScreenPage();
                      case 'wallet':
                        return const DeliveryWalletPage();
                      case 'history':
                        return const DeliveryOrderHistoryPage();
                      case 'settings':
                        return const DeliverySettingsPage();
                      case 'profile':
                        return const DeliveryProfilePage();
                      default:
                        return _OverviewPanel(
                          state: state,
                          item: state.navItems[i],
                        );
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );

    return Container(
      color: const Color(0xFF0B1219),
      child: SafeArea(
        child: AutoHideAppBarWrapper(
          appBar: appBar,
          body: body,
          appBarHeight: 70.0,
          isMobile: isMobile,
        ),
      ),
    );
  }
}


class _DeferredNavigationPage extends StatefulWidget {
  final bool isActive;
  final Widget Function() builder;

  const _DeferredNavigationPage({
    required this.isActive,
    required this.builder,
  });

  @override
  State<_DeferredNavigationPage> createState() =>
      _DeferredNavigationPageState();
}

class _DeferredNavigationPageState extends State<_DeferredNavigationPage> {
  bool _built = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) {
      _built = true;
    }
    if (!_built) {
      return const SizedBox.shrink();
    }
    return widget.builder();
  }
}

class _OverviewPanel extends StatelessWidget {
  final DeliveryNavigationBarState state;
  final DeliveryNavigationBarItem item;

  const _OverviewPanel({
    required this.state,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DeliveryAppColors.primaryDark.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: DeliveryAppColors.primaryDark.withValues(alpha: 0.18),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                item.activeIcon,
                color: DeliveryAppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${item.label} ${DeliveryNavigationBarStrings.of('overview', state.localeCode)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryNavigationBarStrings.of(
                'manageHint',
                state.localeCode,
              ).replaceAll('{label}', item.label),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
            if (state.isUploading) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.uploadProgress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF1A2530),
                    valueColor: const AlwaysStoppedAnimation(
                      DeliveryAppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
            if (state.uploadProgress >= 1.0) ...[
              const SizedBox(height: 16),
              const Text(
                'Upload complete',
                style: TextStyle(
                  color: DeliveryAppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContentTopBar extends StatelessWidget {
  final DeliveryNavigationBarState state;
  final bool isMobile;

  const _ContentTopBar({required this.state, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open navigation menu',
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DeliveryNavigationBarStrings.of(
                    'welcomeBack',
                    state.localeCode,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.partnerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: state.isOffline
                  ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                  : DeliveryAppColors.primaryDark.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: state.isOffline
                    ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                    : DeliveryAppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.isOffline
                        ? const Color(0xFFEF4444)
                        : DeliveryAppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  state.isOffline
                      ? DeliveryNavigationBarStrings.of(
                          'offline',
                          state.localeCode,
                        )
                      : DeliveryNavigationBarStrings.of(
                          'online',
                          state.localeCode,
                        ),
                  style: TextStyle(
                    color: state.isOffline
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              final profileIndex = state.navItems
                  .indexWhere((item) => item.id == 'profile');
              if (profileIndex != -1) {
                context.read<DeliveryNavigationBarPageBloc>().add(
                      DeliveryNavigationBarTabChangedEvent(profileIndex),
                    );
              }
            },
            borderRadius: BorderRadius.circular(999),
            child: Semantics(
              button: true,
              label: 'View Profile',
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DeliveryAppColors.primaryDark.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF1A2530),
                  child: Icon(
                    Icons.person,
                    color: DeliveryAppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF7F1D1D),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Color(0xFFFECACA), size: 16),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'You are offline. Some features may be limited.',
              style: TextStyle(
                color: Color(0xFFFECACA),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  final DeliveryNavigationBarState state;
  final ValueChanged<int> onItemTap;
  final VoidCallback onContactSupport;

  const _MobileDrawer({
    required this.state,
    required this.onItemTap,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF060B11),
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            _SidebarHeader(
              partnerName: state.partnerName,
              isOffline: state.isOffline,
              localeCode: state.localeCode,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                   for (var i = 0; i < state.navItems.length; i++)
                    if (state.navItems[i].id != 'profile')
                      _SidebarMenuItem(
                        key: ValueKey('dp_nav_${state.navItems[i].id}'),
                        item: state.navItems[i],
                        isSelected: state.selectedIndex == i,
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          onItemTap(i);
                        },
                      ),
                ],
              ),
            ),
            _HelpCard(
              localeCode: state.localeCode,
              onContactSupport: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                onContactSupport();
              },
            ),
            const _LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class _MobileBottomBar extends StatelessWidget {
  final DeliveryNavigationBarState state;
  final ValueChanged<int> onItemTap;

  const _MobileBottomBar({required this.state, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final filteredItems = state.navItems.where((item) => item.id != 'profile').toList();
    final visibleItems = filteredItems.length >= 5
        ? filteredItems.sublist(0, 5)
        : filteredItems;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060B11),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < visibleItems.length; i++)
              Expanded(
                child: _MobileBottomItem(
                  item: visibleItems[i],
                  isSelected: state.selectedIndex == state.navItems.indexOf(visibleItems[i]),
                  onTap: () => onItemTap(state.navItems.indexOf(visibleItems[i])),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileBottomItem extends StatelessWidget {
  final DeliveryNavigationBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileBottomItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DeliveryAppColors.primaryDark.withValues(alpha: 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: DeliveryAppColors.primaryDark.withValues(alpha: 0.3),
                            blurRadius: 14,
                          ),
                        ]
                      : const [],
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected
                      ? DeliveryAppColors.primary
                      : const Color(0xFF94A3B8),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF9AA5B1),
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonShell extends StatelessWidget {
  final bool isMobile;

  const _SkeletonShell({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return const _ContentSkeleton();
    }
    return Row(
      children: [
        const _SidebarSkeleton(),
        Expanded(child: const _ContentSkeleton()),
      ],
    );
  }
}

class _SidebarSkeleton extends StatelessWidget {
  const _SidebarSkeleton();

  Widget _box({
    required double width,
    required double height,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(10)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dp_skeleton_shell'),
      width: 280,
      color: const Color(0xFF060B11),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 46, height: 46, shape: BoxShape.circle),
          const SizedBox(height: 16),
          _box(width: 160, height: 14),
          const SizedBox(height: 8),
          _box(width: 110, height: 12),
          const SizedBox(height: 32),
          for (var i = 0; i < 6; i++) ...[
            _box(width: double.infinity, height: 44),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ContentSkeleton extends StatelessWidget {
  const _ContentSkeleton();

  Widget _box({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1219),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: double.infinity, height: 56),
          const SizedBox(height: 24),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: _box(width: 72, height: 72),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: _box(width: 180, height: 20),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: _box(width: 260, height: 12),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ErrorShell extends StatelessWidget {
  final DeliveryNavigationBarState state;

  const _ErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Center(
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
            const Text(
              'Something went wrong',
              style: TextStyle(
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
            ElevatedButton(
              onPressed: () => context
                  .read<DeliveryNavigationBarPageBloc>()
                  .add(const DeliveryNavigationBarRefreshEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(140, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                DeliveryNavigationBarStrings.of('retry', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShell extends StatelessWidget {
  final DeliveryNavigationBarState state;

  const _EmptyShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final String localeCode = state.localeCode;
    return Center(
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
                Icons.inbox_outlined,
                color: Color(0xFF64748B),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DeliveryNavigationBarStrings.of('emptyTitle', localeCode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DeliveryNavigationBarStrings.of('emptySub', localeCode),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<DeliveryNavigationBarPageBloc>()
                  .add(const DeliveryNavigationBarRefreshEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(140, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                DeliveryNavigationBarStrings.of('retry', localeCode),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () {
          context.read<DeliveryNavigationBarPageBloc>().add(
                const DeliveryNavigationBarLogoutRequestedEvent(),
              );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.25),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Color(0xFFFF5252), size: 20),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
