import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_setting_page__bloc.dart';
import 'seller_setting_page__event.dart';
import 'seller_setting_page__state.dart';
import '../../../core/services/audio_notification_service.dart';
import '../../../core/widgets/logout_button.dart';
import '../../../repositories/seller_repository.dart';
import '../seller_store_details_page/seller_store_details_page__ui.dart';
import '../business_hours_page_/business_hours_page_ui.dart';
import '../seller_payment_page/seller_payment_page_ui.dart';
import '../seller_wallet_page/seller_wallet_page__ui.dart';

class SellerSettingPage extends StatefulWidget {
  const SellerSettingPage({Key? key}) : super(key: key);

  @override
  State<SellerSettingPage> createState() => _SellerSettingPageState();
}

class _SellerSettingPageState extends State<SellerSettingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerSettingBloc, SellerSettingState>(
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.error!)),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<SellerSettingBloc>().add(ClearSettingMessages());
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.successMessage!)),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.read<SellerSettingBloc>().add(ClearSettingMessages());
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.restaurantName.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE52929)),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                return Column(
                  children: [
                    _buildTopBar(context, state),
                    Expanded(
                      child: isWide
                          ? _buildWideLayout(context, state)
                          : _buildMobileLayout(context, state),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, SellerSettingState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.of(context).maybePop(),
                  color: const Color(0xFF111827),
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Restaurant Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        state.restaurantName.isNotEmpty
                            ? state.restaurantName
                            : 'App & Account Preferences',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.isDeactivated)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Deactivated',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, SellerSettingState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Nav Sidebar
        SizedBox(
          width: 280,
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildCategoryHeader('Preferences & Alerts'),
                _buildNavItem(context, 0, Icons.notifications_active_rounded, 'Notification Settings', state.selectedSectionIndex),
                _buildNavItem(context, 1, Icons.person_rounded, 'Account Settings', state.selectedSectionIndex),
                _buildNavItem(context, 2, Icons.privacy_tip_rounded, 'Privacy', state.selectedSectionIndex),

                _buildCategoryHeader('Account & Security'),
                _buildNavItem(context, 3, Icons.shield_rounded, 'Security', state.selectedSectionIndex),
                _buildNavItem(context, 4, Icons.lock_reset_rounded, 'Change Password', state.selectedSectionIndex),
                _buildNavItem(context, 5, Icons.logout_rounded, 'Logout', state.selectedSectionIndex, isDanger: true),
                _buildNavItem(context, 6, Icons.delete_forever_rounded, 'Delete / Deactivate', state.selectedSectionIndex, isDanger: true),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
        // Right Detail Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StoreOperationsQuickNav(),
                    const SizedBox(height: 24),
                    _buildSelectedSection(context, state),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, SellerSettingState state) {
    return Column(
      children: [
        // Horizontal Scrollable Category Bar
        Container(
          color: Colors.white,
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _buildFilterPill(context, 0, 'Notifications', state.selectedSectionIndex),
              _buildFilterPill(context, 1, 'Account', state.selectedSectionIndex),
              _buildFilterPill(context, 2, 'Privacy', state.selectedSectionIndex),
              _buildFilterPill(context, 3, 'Security', state.selectedSectionIndex),
              _buildFilterPill(context, 4, 'Password', state.selectedSectionIndex),
              _buildFilterPill(context, 5, 'Logout', state.selectedSectionIndex),
              _buildFilterPill(context, 6, 'Deactivate', state.selectedSectionIndex),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreOperationsQuickNav(),
                const SizedBox(height: 24),
                _buildSelectedSection(context, state),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF9CA3AF),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    int selectedIndex, {
    bool isDanger = false,
  }) {
    final isSelected = index == selectedIndex;
    final activeColor = isDanger ? const Color(0xFFEF4444) : const Color(0xFFE52929);
    final idleColor = isDanger ? const Color(0xFFDC2626) : const Color(0xFF4B5563);

    return InkWell(
      onTap: () {
        context.read<SellerSettingBloc>().add(SelectSettingsSection(index));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.25))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected ? activeColor : idleColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : idleColor,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(BuildContext context, int index, String label, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () {
        context.read<SellerSettingBloc>().add(SelectSettingsSection(index));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE52929) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSection(BuildContext context, SellerSettingState state) {
    switch (state.selectedSectionIndex) {
      case 0:
        return _NotificationSettingsView(state: state);
      case 1:
        return _AccountSettingsView(state: state);
      case 2:
        return _PrivacySettingsView(state: state);
      case 3:
        return _SecuritySettingsView(state: state);
      case 4:
        return _ChangePasswordView(state: state);
      case 5:
        return _LogoutView(state: state);
      case 6:
        return _DeleteDeactivateView(state: state);
      default:
        return _NotificationSettingsView(state: state);
    }
  }
}

// =========================================================================
// Store Operations Quick Navigation Hub
// =========================================================================
class _StoreOperationsQuickNav extends StatelessWidget {
  const _StoreOperationsQuickNav();

  void _pushPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _pushSellerScopedPage(BuildContext context, Widget Function(String sellerId) pageBuilder) {
    final sellerId = SellerRepository().currentUser?.uid ?? '';
    if (sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to configure store operations.')),
      );
      return;
    }
    _pushPage(context, pageBuilder(sellerId));
  }

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.storefront_rounded,
        'iconColor': const Color(0xFF3B82F6),
        'iconBgColor': const Color(0xFFEFF6FF),
        'title': 'Business Details',
        'subtitle': 'FSSAI, GSTIN, PAN & compliance',
        'onTap': () => _pushPage(context, const SellerStoreDetailsPage()),
      },
      {
        'icon': Icons.access_time_rounded,
        'iconColor': const Color(0xFF10B981),
        'iconBgColor': const Color(0xFFECFDF5),
        'title': 'Business Hours',
        'subtitle': 'Open / close slots & weekly schedule',
        'onTap': () => _pushSellerScopedPage(context, (id) => BusinessHoursPage(sellerId: id)),
      },
      {
        'icon': Icons.account_balance_rounded,
        'iconColor': const Color(0xFFF59E0B),
        'iconBgColor': const Color(0xFFFFFBEB),
        'title': 'Bank & Payout',
        'subtitle': 'Bank account, UPI & settlement',
        'onTap': () => _pushPage(context, const SellerPaymentPage()),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'iconColor': const Color(0xFF8B5CF6),
        'iconBgColor': const Color(0xFFF5F3FF),
        'title': 'Wallet & Earnings',
        'subtitle': 'Balance, payouts & transactions',
        'onTap': () => _pushPage(context, const SellerWalletPage()),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storefront_rounded, color: Color(0xFFE52929), size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store Operations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Business logistics live under the More tab. Jump to a section:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = constraints.maxWidth >= 700
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items.map((item) {
                return SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: item['onTap'] as VoidCallback,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item['iconBgColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: item['iconColor'] as Color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// =========================================================================
// 1. Notification Settings View
// =========================================================================
class _NotificationSettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _NotificationSettingsView({required this.state});

  @override
  State<_NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<_NotificationSettingsView> {
  late bool _push;
  late bool _sound;
  late bool _soundLoop;
  late String _ringtone;
  late double _volume;
  late bool _promo;
  late bool _lowStock;
  late bool _orderUpdates;
  late bool _whatsapp;
  late bool _sms;
  late final AudioNotificationService _audioService;
  bool _isPreviewPlaying = false;

  @override
  void initState() {
    super.initState();
    _push = widget.state.pushNotifications;
    _sound = widget.state.newOrderSound;
    _soundLoop = widget.state.soundLoopUntilAccepted;
    _ringtone = widget.state.orderAlertRingtone;
    _volume = widget.state.soundVolume;
    _promo = widget.state.promoAndOffers;
    _lowStock = widget.state.lowStockAlerts;
    _orderUpdates = widget.state.orderUpdates;
    _whatsapp = widget.state.whatsappNotifications;
    _sms = widget.state.smsNotifications;
    _audioService = AudioNotificationService(
      onRingtoneComplete: () {
        if (mounted) setState(() => _isPreviewPlaying = false);
      },
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _previewRingtone() async {
    setState(() => _isPreviewPlaying = true);
    await _audioService.playRingtone(ringtoneName: _ringtone, volume: _volume);
  }

  void _stopPreview() {
    setState(() => _isPreviewPlaying = false);
    _audioService.stop();
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateNotificationAdvancedSettings(
            pushNotifications: _push,
            newOrderSound: _sound,
            soundLoopUntilAccepted: _soundLoop,
            orderAlertRingtone: _ringtone,
            soundVolume: _volume,
            promoAndOffers: _promo,
            lowStockAlerts: _lowStock,
            orderUpdates: _orderUpdates,
            whatsappNotifications: _whatsapp,
            smsNotifications: _sms,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Notification & Audio Alerts',
      subtitle: 'Customize alert chimes, push notifications, and stock warning broadcasts.',
      icon: Icons.notifications_active_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow(
            title: 'Push Notifications',
            subtitle: 'Receive real-time push alerts on new order arrival.',
            value: _push,
            onChanged: (val) {
              setState(() => _push = val);
              _save();
            },
          ),
          _buildSwitchRow(
            title: 'New Order Sound Alert',
            subtitle: 'Play chime ringtone when a buyer places an order.',
            value: _sound,
            onChanged: (val) {
              setState(() => _sound = val);
              _save();
            },
          ),
          _buildSwitchRow(
            title: 'Continuous Alert Sound (Loop until accepted)',
            subtitle: 'Sound repeats until the order is accepted or dismissed.',
            value: _soundLoop,
            onChanged: (val) {
              setState(() => _soundLoop = val);
              _save();
            },
          ),
          const SizedBox(height: 16),
          const Text('Alert Chime Ringtone', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _ringtone,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Bell Chime', child: Text('Bell Chime (Standard)')),
                        DropdownMenuItem(value: 'Digital Siren', child: Text('Digital Siren (Loud)')),
                        DropdownMenuItem(value: 'Classic Phone Ring', child: Text('Classic Phone Ring')),
                        DropdownMenuItem(value: 'Kitchen Buzzer', child: Text('Kitchen Buzzer')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _ringtone = val);
                          _previewRingtone();
                          _save();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _isPreviewPlaying ? 'Stop Preview' : 'Preview Sound',
                child: IconButton(
                  onPressed: _isPreviewPlaying ? _stopPreview : _previewRingtone,
                  icon: Icon(
                    _isPreviewPlaying
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    size: 34,
                    color: _isPreviewPlaying
                        ? const Color(0xFFE52929)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _isPreviewPlaying ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                size: 14,
                color: _isPreviewPlaying ? const Color(0xFFE52929) : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _isPreviewPlaying
                      ? 'Previewing "$_ringtone" at ${(_volume * 100).toInt()}% volume...'
                      : 'Tap play to preview the selected ringtone.',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _isPreviewPlaying ? FontWeight.w600 : FontWeight.w400,
                    color: _isPreviewPlaying ? const Color(0xFFE52929) : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Alert Sound Volume: ${(_volume * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            activeColor: const Color(0xFFE52929),
            onChanged: (val) {
              setState(() => _volume = val);
              _previewRingtone();
              _save();
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            title: 'Low Stock Alerts',
            subtitle: 'Alert immediately when menu items fall below inventory threshold.',
            value: _lowStock,
            onChanged: (val) {
              setState(() => _lowStock = val);
              _save();
            },
          ),
          _buildSwitchRow(
            title: 'Order Status Updates',
            subtitle: 'Rider arrival & delivery completion notifications.',
            value: _orderUpdates,
            onChanged: (val) {
              setState(() => _orderUpdates = val);
              _save();
            },
          ),
          _buildSwitchRow(
            title: 'WhatsApp Order Notifications',
            subtitle: 'Receive instant summary messages on WhatsApp.',
            value: _whatsapp,
            onChanged: (val) {
              setState(() => _whatsapp = val);
              _save();
            },
          ),
          _buildSwitchRow(
            title: 'Promo & Marketing Offers',
            subtitle: 'Receive platform announcements and boost discounts.',
            value: _promo,
            onChanged: (val) {
              setState(() => _promo = val);
              _save();
            },
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 2. Account Settings View
// =========================================================================
class _AccountSettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _AccountSettingsView({required this.state});

  @override
  State<_AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<_AccountSettingsView> {
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late String _theme;
  late String _lang;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.state.registeredEmail);
    _phoneCtrl = TextEditingController(text: widget.state.registeredPhone);
    _theme = widget.state.appTheme;
    _lang = widget.state.language;
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateAccountSettings(
            registeredEmail: _emailCtrl.text.trim(),
            registeredPhone: _phoneCtrl.text.trim(),
            appTheme: _theme,
            language: _lang,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Account & App Preferences',
      subtitle: 'Manage registered contact details, theme mode, and multi-language preferences.',
      icon: Icons.person_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Registered Email Address', _emailCtrl, 'seller@domain.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField('Registered Phone Number', _phoneCtrl, '+91 9876543210', keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          const Text('Application Theme', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _theme,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Light', child: Text('Light Mode (Default)')),
                  DropdownMenuItem(value: 'Dark', child: Text('Dark Mode')),
                  DropdownMenuItem(value: 'System Default', child: Text('System Default')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _theme = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Language & Localization', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _lang,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English (US / Global)')),
                  DropdownMenuItem(value: 'Tamil', child: Text('தமிழ் (Tamil)')),
                  DropdownMenuItem(value: 'Hindi', child: Text('हिंदी (Hindi)')),
                  DropdownMenuItem(value: 'Spanish', child: Text('Español (Spanish)')),
                  DropdownMenuItem(value: 'French', child: Text('Français (French)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _lang = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 3. Privacy Settings View
// =========================================================================
class _PrivacySettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _PrivacySettingsView({required this.state});

  @override
  State<_PrivacySettingsView> createState() => _PrivacySettingsViewState();
}

class _PrivacySettingsViewState extends State<_PrivacySettingsView> {
  late bool _publicVisible;
  late bool _showRatings;
  late bool _showPhone;
  late bool _allowAnalytics;
  late bool _marketing;

  @override
  void initState() {
    super.initState();
    _publicVisible = widget.state.isPubliclyVisible;
    _showRatings = widget.state.showRatingsPublicly;
    _showPhone = widget.state.showPhoneNumberPublicly;
    _allowAnalytics = widget.state.allowAnalyticsTelemetry;
    _marketing = widget.state.receiveMarketingEmails;
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdatePrivacySettings(
            isPubliclyVisible: _publicVisible,
            showRatingsPublicly: _showRatings,
            showPhoneNumberPublicly: _showPhone,
            allowAnalyticsTelemetry: _allowAnalytics,
            receiveMarketingEmails: _marketing,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Privacy & Visibility',
      subtitle: 'Manage public visibility on buyer app, customer reviews, and analytical tracking.',
      icon: Icons.privacy_tip_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow(
            title: 'Public Store Visibility',
            subtitle: 'Display restaurant in buyer search results and recommendations.',
            value: _publicVisible,
            onChanged: (val) => setState(() => _publicVisible = val),
          ),
          _buildSwitchRow(
            title: 'Show Customer Ratings & Reviews',
            subtitle: 'Make review cards visible to all browsing customers.',
            value: _showRatings,
            onChanged: (val) => setState(() => _showRatings = val),
          ),
          _buildSwitchRow(
            title: 'Display Contact Number Publicly',
            subtitle: 'Allow buyers to see the restaurant direct dial phone.',
            value: _showPhone,
            onChanged: (val) => setState(() => _showPhone = val),
          ),
          _buildSwitchRow(
            title: 'Performance & Telemetry Sharing',
            subtitle: 'Help improve platform performance via anonymous diagnostic analytics.',
            value: _allowAnalytics,
            onChanged: (val) => setState(() => _allowAnalytics = val),
          ),
          _buildSwitchRow(
            title: 'Receive Marketing Communications',
            subtitle: 'Receive promotional emails, growth tips, and festival campaigns.',
            value: _marketing,
            onChanged: (val) => setState(() => _marketing = val),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 4. Security Settings View
// =========================================================================
class _SecuritySettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _SecuritySettingsView({required this.state});

  @override
  State<_SecuritySettingsView> createState() => _SecuritySettingsViewState();
}

class _SecuritySettingsViewState extends State<_SecuritySettingsView> {
  late bool _2fa;
  late String _2faMethod;
  late bool _pinLock;
  late bool _biometric;

  @override
  void initState() {
    super.initState();
    _2fa = widget.state.twoFactorAuthEnabled;
    _2faMethod = widget.state.twoFactorMethod;
    _pinLock = widget.state.appPinLockEnabled;
    _biometric = widget.state.biometricLockEnabled;
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateSecuritySettings(
            twoFactorAuthEnabled: _2fa,
            twoFactorMethod: _2faMethod,
            appPinLockEnabled: _pinLock,
            biometricLockEnabled: _biometric,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Security & Active Sessions',
      subtitle: 'Manage Two-Factor Authentication (2FA), biometric app lock, and active devices.',
      icon: Icons.shield_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow(
            title: 'Two-Factor Authentication (2FA)',
            subtitle: 'Require OTP verification code whenever logging into new devices.',
            value: _2fa,
            onChanged: (val) => setState(() => _2fa = val),
          ),
          if (_2fa) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _2faMethod,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'sms', child: Text('SMS OTP Verification')),
                    DropdownMenuItem(value: 'email', child: Text('Email OTP Verification')),
                    DropdownMenuItem(value: 'authenticator', child: Text('Authenticator App (TOTP)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _2faMethod = val);
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildSwitchRow(
            title: 'Biometric / Fingerprint App Lock',
            subtitle: 'Prompt biometric authentication when opening sensitive revenue tabs.',
            value: _biometric,
            onChanged: (val) => setState(() => _biometric = val),
          ),
          _buildSwitchRow(
            title: 'PIN Code Lock',
            subtitle: 'Require 4-digit PIN for payout requests and settings modifications.',
            value: _pinLock,
            onChanged: (val) => setState(() => _pinLock = val),
          ),
          const SizedBox(height: 20),
          const Text('Active Logged-in Devices', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.devices_rounded, color: Color(0xFF4B5563)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Current Device (Active Now)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Web / Android / Windows • IP: Verified', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All other device sessions revoked.')),
                    );
                  },
                  child: const Text('Revoke Others', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 5. Change Password View
// =========================================================================
class _ChangePasswordView extends StatefulWidget {
  final SellerSettingState state;
  const _ChangePasswordView({required this.state});

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _signOutOthers = true;
  String _strengthLabel = 'Enter Password';
  Color _strengthColor = Colors.grey;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _evalStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _strengthLabel = 'Enter Password';
        _strengthColor = Colors.grey;
      });
      return;
    }
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    setState(() {
      if (score <= 1) {
        _strengthLabel = 'Weak';
        _strengthColor = const Color(0xFFEF4444);
      } else if (score == 2) {
        _strengthLabel = 'Fair';
        _strengthColor = const Color(0xFFF59E0B);
      } else if (score == 3) {
        _strengthLabel = 'Good';
        _strengthColor = const Color(0xFF3B82F6);
      } else {
        _strengthLabel = 'Strong & Secure';
        _strengthColor = const Color(0xFF10B981);
      }
    });
  }

  void _submit() {
    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all password fields.')),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirmation do not match.')),
      );
      return;
    }
    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long.')),
      );
      return;
    }

    context.read<SellerSettingBloc>().add(
          ChangePasswordRequested(
            currentPassword: current,
            newPassword: newPass,
            signOutOtherDevices: _signOutOthers,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Change Password',
      subtitle: 'Update your account password regularly to keep your restaurant secure.',
      icon: Icons.lock_reset_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _currentCtrl,
            obscureText: _hideCurrent,
            decoration: InputDecoration(
              labelText: 'Current Password',
              hintText: '••••••••',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: Icon(_hideCurrent ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _hideCurrent = !_hideCurrent),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newCtrl,
            obscureText: _hideNew,
            onChanged: _evalStrength,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'At least 8 characters with numbers & symbols',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: Icon(_hideNew ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _hideNew = !_hideNew),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Password Strength: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(_strengthLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _strengthColor)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              hintText: '••••••••',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            title: 'Sign out of other devices',
            subtitle: 'Terminate active login sessions on all other phones and browsers.',
            value: _signOutOthers,
            onChanged: (val) => setState(() => _signOutOthers = val),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(
            label: 'Update Password',
            onPressed: _submit,
            isSaving: widget.state.isSaving,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 6. Logout View
// =========================================================================
class _LogoutView extends StatelessWidget {
  final SellerSettingState state;
  const _LogoutView({required this.state});

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Logout Session',
      subtitle: 'Safely terminate your current authenticated session on this device.',
      icon: Icons.logout_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFF4B5563)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Logging out will unbind your push notification device token and clear local session state.',
                    style: TextStyle(color: Color(0xFF374151), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            label: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showLogoutConfirmDialog(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to log out of your restaurant seller account?',
      confirmLabel: 'Logout',
      confirmColor: const Color(0xFFDC2626),
      onConfirm: () async {
        context.read<SellerSettingBloc>().add(LogoutRequested());
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );
  }
}

// =========================================================================
// 7. Delete / Deactivate Account View
// =========================================================================
class _DeleteDeactivateView extends StatefulWidget {
  final SellerSettingState state;
  const _DeleteDeactivateView({required this.state});

  @override
  State<_DeleteDeactivateView> createState() => _DeleteDeactivateViewState();
}

class _DeleteDeactivateViewState extends State<_DeleteDeactivateView> {
  final _deactReasonCtrl = TextEditingController();
  final _deletePassCtrl = TextEditingController();
  final _confirmKeywordCtrl = TextEditingController();
  int _durationDays = 30;

  @override
  void dispose() {
    _deactReasonCtrl.dispose();
    _deletePassCtrl.dispose();
    _confirmKeywordCtrl.dispose();
    super.dispose();
  }

  void _deactivate() {
    context.read<SellerSettingBloc>().add(
          DeactivateAccountRequested(
            reason: _deactReasonCtrl.text.trim().isNotEmpty
                ? _deactReasonCtrl.text.trim()
                : 'Temporary maintenance / break',
            durationDays: _durationDays,
          ),
        );
  }

  void _reactivate() {
    context.read<SellerSettingBloc>().add(ReactivateAccountRequested());
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Permanent Deletion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is irreversible. All menu items, reviews, order history, and restaurant identity will be permanently wiped.',
              style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deletePassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Account Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmKeywordCtrl,
              decoration: const InputDecoration(
                labelText: 'Type DELETE to confirm',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<SellerSettingBloc>().add(
                    DeleteAccountRequested(
                      password: _deletePassCtrl.text.trim(),
                      confirmationKeyword: _confirmKeywordCtrl.text.trim(),
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Permanently Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Deactivate or Delete Account',
      subtitle: 'Temporarily pause store operations or permanently delete your restaurant profile.',
      icon: Icons.delete_forever_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deactivation Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.pause_circle_filled_rounded, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Text('Temporary Account Deactivation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF92400E))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hides your restaurant listings and pauses orders for a specified duration without losing your data.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF78350F)),
                ),
                const SizedBox(height: 12),
                if (!widget.state.isDeactivated) ...[
                  _buildTextField('Reason for Deactivation', _deactReasonCtrl, 'e.g. Vacation / Renovation'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Duration: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      DropdownButton<int>(
                        value: _durationDays,
                        items: const [
                          DropdownMenuItem(value: 7, child: Text('7 Days')),
                          DropdownMenuItem(value: 14, child: Text('14 Days')),
                          DropdownMenuItem(value: 30, child: Text('30 Days')),
                          DropdownMenuItem(value: 90, child: Text('90 Days')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _durationDays = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _deactivate,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                    child: const Text('Deactivate Temporarily', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Account currently deactivated: "${widget.state.deactivationReason ?? 'Paused'}"',
                      style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reactivate,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    child: const Text('Reactivate Restaurant Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Permanent Deletion Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.dangerous_rounded, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Text('Permanent Account Deletion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF991B1B))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completely deletes all restaurant data, menu listings, orders, and credentials forever.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7F1D1D)),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showDeleteDialog,
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                  label: const Text('Request Permanent Deletion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// Shared Helper Form Widgets
// =========================================================================
class _SettingCardContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SettingCardContainer({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFE52929), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

Widget _buildTextField(
  String label,
  TextEditingController controller,
  String hint, {
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE52929), width: 1.5),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSwitchRow({
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFFE52929),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

Widget _buildSaveButton({
  required VoidCallback onPressed,
  required bool isSaving,
  String label = 'Save Changes',
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE52929),
        disabledBackgroundColor: const Color(0xFFFCA5A5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    ),
  );
}