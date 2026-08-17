import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_setting_page__bloc.dart';
import 'seller_setting_page__event.dart';
import 'seller_setting_page__state.dart';

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
                            : 'Real-time Control Center',
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
          const SizedBox(width: 8),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLiveStatusChip(
                label: state.isAcceptingOrders ? 'Accepting Orders' : 'Paused',
                isActive: state.isAcceptingOrders,
                activeColor: const Color(0xFF10B981),
                inactiveColor: const Color(0xFFEF4444),
                onTap: () {
                  context.read<SellerSettingBloc>().add(
                        ToggleAcceptingOrders(!state.isAcceptingOrders),
                      );
                },
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
        ],
      ),
    );
  }

  Widget _buildLiveStatusChip({
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    final color = isActive ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
                _buildCategoryHeader('Store & Operations'),
                _buildNavItem(context, 0, Icons.storefront_rounded, 'Restaurant Info', state.selectedSectionIndex),
                _buildNavItem(context, 1, Icons.access_time_rounded, 'Business Hours', state.selectedSectionIndex),
                _buildNavItem(context, 2, Icons.delivery_dining_rounded, 'Delivery Settings', state.selectedSectionIndex),
                _buildNavItem(context, 3, Icons.receipt_long_rounded, 'Order Settings', state.selectedSectionIndex),

                _buildCategoryHeader('Preferences & Alerts'),
                _buildNavItem(context, 4, Icons.notifications_active_rounded, 'Notification Settings', state.selectedSectionIndex),
                _buildNavItem(context, 5, Icons.account_balance_wallet_rounded, 'Payment Settings', state.selectedSectionIndex),
                _buildNavItem(context, 6, Icons.account_balance_rounded, 'Bank / UPI Settings', state.selectedSectionIndex),
                _buildNavItem(context, 7, Icons.receipt_rounded, 'Tax Information', state.selectedSectionIndex),

                _buildCategoryHeader('Account & Security'),
                _buildNavItem(context, 8, Icons.person_rounded, 'Account Settings', state.selectedSectionIndex),
                _buildNavItem(context, 9, Icons.privacy_tip_rounded, 'Privacy', state.selectedSectionIndex),
                _buildNavItem(context, 10, Icons.shield_rounded, 'Security', state.selectedSectionIndex),
                _buildNavItem(context, 11, Icons.lock_reset_rounded, 'Change Password', state.selectedSectionIndex),
                _buildNavItem(context, 12, Icons.logout_rounded, 'Logout', state.selectedSectionIndex, isDanger: true),
                _buildNavItem(context, 13, Icons.delete_forever_rounded, 'Delete / Deactivate', state.selectedSectionIndex, isDanger: true),
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
                child: _buildSelectedSection(context, state),
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
              _buildFilterPill(context, 0, 'Info', state.selectedSectionIndex),
              _buildFilterPill(context, 1, 'Hours', state.selectedSectionIndex),
              _buildFilterPill(context, 2, 'Delivery', state.selectedSectionIndex),
              _buildFilterPill(context, 3, 'Orders', state.selectedSectionIndex),
              _buildFilterPill(context, 4, 'Notifications', state.selectedSectionIndex),
              _buildFilterPill(context, 5, 'Payments', state.selectedSectionIndex),
              _buildFilterPill(context, 6, 'Bank/UPI', state.selectedSectionIndex),
              _buildFilterPill(context, 7, 'Tax', state.selectedSectionIndex),
              _buildFilterPill(context, 8, 'Account', state.selectedSectionIndex),
              _buildFilterPill(context, 9, 'Privacy', state.selectedSectionIndex),
              _buildFilterPill(context, 10, 'Security', state.selectedSectionIndex),
              _buildFilterPill(context, 11, 'Password', state.selectedSectionIndex),
              _buildFilterPill(context, 12, 'Logout', state.selectedSectionIndex),
              _buildFilterPill(context, 13, 'Deactivate', state.selectedSectionIndex),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildSelectedSection(context, state),
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
        return _RestaurantInfoView(state: state);
      case 1:
        return _BusinessHoursView(state: state);
      case 2:
        return _DeliverySettingsView(state: state);
      case 3:
        return _OrderSettingsView(state: state);
      case 4:
        return _NotificationSettingsView(state: state);
      case 5:
        return _PaymentSettingsView(state: state);
      case 6:
        return _BankUpiSettingsView(state: state);
      case 7:
        return _TaxInformationView(state: state);
      case 8:
        return _AccountSettingsView(state: state);
      case 9:
        return _PrivacySettingsView(state: state);
      case 10:
        return _SecuritySettingsView(state: state);
      case 11:
        return _ChangePasswordView(state: state);
      case 12:
        return _LogoutView(state: state);
      case 13:
        return _DeleteDeactivateView(state: state);
      default:
        return _RestaurantInfoView(state: state);
    }
  }
}

// =========================================================================
// 1. Restaurant Information View
// =========================================================================
class _RestaurantInfoView extends StatefulWidget {
  final SellerSettingState state;
  const _RestaurantInfoView({required this.state});

  @override
  State<_RestaurantInfoView> createState() => _RestaurantInfoViewState();
}

class _RestaurantInfoViewState extends State<_RestaurantInfoView> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ownerCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cuisineInputCtrl;
  late List<String> _cuisines;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.state.restaurantName);
    _ownerCtrl = TextEditingController(text: widget.state.ownerName);
    _phoneCtrl = TextEditingController(text: widget.state.phoneNumber);
    _emailCtrl = TextEditingController(text: widget.state.email);
    _descCtrl = TextEditingController(text: widget.state.restaurantDescription);
    _addressCtrl = TextEditingController(text: widget.state.address);
    _cuisineInputCtrl = TextEditingController();
    _cuisines = List.from(widget.state.cuisines);
  }

  @override
  void didUpdateWidget(covariant _RestaurantInfoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _nameCtrl.text = widget.state.restaurantName;
      _ownerCtrl.text = widget.state.ownerName;
      _phoneCtrl.text = widget.state.phoneNumber;
      _emailCtrl.text = widget.state.email;
      _descCtrl.text = widget.state.restaurantDescription;
      _addressCtrl.text = widget.state.address;
      _cuisines = List.from(widget.state.cuisines);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _cuisineInputCtrl.dispose();
    super.dispose();
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateRestaurantInfo(
            restaurantName: _nameCtrl.text.trim(),
            ownerName: _ownerCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            restaurantDescription: _descCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            cuisines: _cuisines,
            profileImageUrl: widget.state.profileImageUrl,
            coverImageUrl: widget.state.coverImageUrl,
            latitude: widget.state.latitude,
            longitude: widget.state.longitude,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Restaurant Information',
      subtitle: 'Manage your restaurant profile, contact details, and cuisine types.',
      icon: Icons.storefront_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Restaurant Name', _nameCtrl, 'e.g. Spice Symphony'),
          const SizedBox(height: 16),
          _buildTextField('Owner / Manager Name', _ownerCtrl, 'e.g. John Doe'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Contact Phone', _phoneCtrl, '+91 9876543210', keyboardType: TextInputType.phone)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Contact Email', _emailCtrl, 'restaurant@domain.com', keyboardType: TextInputType.emailAddress)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Restaurant Bio / Description', _descCtrl, 'Describe your food specialty and heritage...', maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField('Full Street Address', _addressCtrl, 'e.g. 124 Main Street, Chennai', maxLines: 2),
          const SizedBox(height: 16),
          const Text('Cuisine Specializations', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._cuisines.map((c) => Chip(
                    label: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFFFEE2E2),
                    deleteIconColor: const Color(0xFFE52929),
                    onDeleted: () {
                      setState(() => _cuisines.remove(c));
                    },
                  )),
              SizedBox(
                width: 150,
                height: 36,
                child: TextField(
                  controller: _cuisineInputCtrl,
                  decoration: InputDecoration(
                    hintText: '+ Add Cuisine',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty && !_cuisines.contains(val.trim())) {
                      setState(() {
                        _cuisines.add(val.trim());
                        _cuisineInputCtrl.clear();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 2. Business Hours View
// =========================================================================
class _BusinessHoursView extends StatefulWidget {
  final SellerSettingState state;
  const _BusinessHoursView({required this.state});

  @override
  State<_BusinessHoursView> createState() => _BusinessHoursViewState();
}

class _BusinessHoursViewState extends State<_BusinessHoursView> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  late Map<String, dynamic> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.state.businessHours);
    for (final day in _days) {
      if (!_schedule.containsKey(day.toLowerCase())) {
        _schedule[day.toLowerCase()] = {
          'isOpen': true,
          'openTime': '09:00 AM',
          'closeTime': '10:00 PM',
        };
      }
    }
  }

  void _save() {
    context.read<SellerSettingBloc>().add(UpdateBusinessHoursSchedule(_schedule));
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Business Hours & Schedule',
      subtitle: 'Configure daily opening and closing hours or activate temporary holiday closure.',
      icon: Icons.access_time_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.beach_access_rounded, color: Color(0xFFDC2626)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Temporary Emergency / Holiday Closure',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                      ),
                      Text(
                        'Instantly pause storefront and cancel auto-accept for holidays.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.state.isEmergencyClosed,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFFDC2626),
                  onChanged: (val) {
                    context.read<SellerSettingBloc>().add(ToggleEmergencyClosure(val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Weekly Operating Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const SizedBox(height: 12),
          ..._days.map((day) {
            final key = day.toLowerCase();
            final dayData = _schedule[key] as Map<String, dynamic>? ?? {'isOpen': true, 'openTime': '09:00 AM', 'closeTime': '10:00 PM'};
            final isOpen = dayData['isOpen'] as bool? ?? true;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isOpen ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Switch(
                    value: isOpen,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() {
                        _schedule[key] = {
                          ...dayData,
                          'isOpen': val,
                        };
                      });
                    },
                  ),
                  const Spacer(),
                  if (isOpen) ...[
                    Text(
                      '${dayData['openTime'] ?? '09:00 AM'} - ${dayData['closeTime'] ?? '10:00 PM'}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                  ] else ...[
                    const Text(
                      'Closed',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 3. Delivery Settings View
// =========================================================================
class _DeliverySettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _DeliverySettingsView({required this.state});

  @override
  State<_DeliverySettingsView> createState() => _DeliverySettingsViewState();
}

class _DeliverySettingsViewState extends State<_DeliverySettingsView> {
  late double _radius;
  late TextEditingController _minOrderCtrl;
  late TextEditingController _baseFeeCtrl;
  late TextEditingController _perKmFeeCtrl;
  late TextEditingController _freeThresholdCtrl;
  late TextEditingController _prepTimeCtrl;
  late TextEditingController _pkgChargesCtrl;
  late bool _allowPickup;
  late bool _isSelfDelivery;

  @override
  void initState() {
    super.initState();
    _radius = widget.state.deliveryRadius;
    _minOrderCtrl = TextEditingController(text: widget.state.minimumOrderValue.toStringAsFixed(0));
    _baseFeeCtrl = TextEditingController(text: widget.state.baseDeliveryFee.toStringAsFixed(0));
    _perKmFeeCtrl = TextEditingController(text: widget.state.perKmDeliveryFee.toStringAsFixed(0));
    _freeThresholdCtrl = TextEditingController(text: widget.state.freeDeliveryThreshold.toStringAsFixed(0));
    _prepTimeCtrl = TextEditingController(text: widget.state.estimatedPrepTimeMinutes.toString());
    _pkgChargesCtrl = TextEditingController(text: widget.state.packagingCharges.toStringAsFixed(0));
    _allowPickup = widget.state.allowSelfPickup;
    _isSelfDelivery = widget.state.isSelfDelivery;
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateDeliverySettings(
            deliveryRadius: _radius,
            minimumOrderValue: double.tryParse(_minOrderCtrl.text) ?? 150.0,
            baseDeliveryFee: double.tryParse(_baseFeeCtrl.text) ?? 25.0,
            perKmDeliveryFee: double.tryParse(_perKmFeeCtrl.text) ?? 5.0,
            freeDeliveryThreshold: double.tryParse(_freeThresholdCtrl.text) ?? 500.0,
            estimatedPrepTimeMinutes: int.tryParse(_prepTimeCtrl.text) ?? 20,
            deliveryTimeEstimate: widget.state.deliveryTimeEstimate,
            packagingCharges: double.tryParse(_pkgChargesCtrl.text) ?? 15.0,
            allowSelfPickup: _allowPickup,
            isSelfDelivery: _isSelfDelivery,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Delivery & Logistics Settings',
      subtitle: 'Tune service radius, delivery fees, minimum thresholds, and pickup options.',
      icon: Icons.delivery_dining_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Maximum Delivery Radius: ${_radius.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            value: _radius,
            min: 1.0,
            max: 35.0,
            divisions: 34,
            activeColor: const Color(0xFFE52929),
            label: '${_radius.toStringAsFixed(0)} km',
            onChanged: (val) => setState(() => _radius = val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Minimum Order Value (₹)', _minOrderCtrl, '150', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Base Delivery Fee (₹)', _baseFeeCtrl, '25', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Per Km Delivery Charge (₹)', _perKmFeeCtrl, '5', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Free Delivery Above (₹)', _freeThresholdCtrl, '500', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Estimated Prep Time (mins)', _prepTimeCtrl, '20', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Packaging Charges (₹)', _pkgChargesCtrl, '15', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchRow(
            title: 'Allow Self-Pickup / Takeaway',
            subtitle: 'Customers can place order online and collect in-store.',
            value: _allowPickup,
            onChanged: (val) => setState(() => _allowPickup = val),
          ),
          _buildSwitchRow(
            title: 'Self Delivery Fleet',
            subtitle: 'Use your own delivery staff instead of platform third-party riders.',
            value: _isSelfDelivery,
            onChanged: (val) => setState(() => _isSelfDelivery = val),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 4. Order Settings View
// =========================================================================
class _OrderSettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _OrderSettingsView({required this.state});

  @override
  State<_OrderSettingsView> createState() => _OrderSettingsViewState();
}

class _OrderSettingsViewState extends State<_OrderSettingsView> {
  late bool _autoAccept;
  late TextEditingController _bufferCtrl;
  late TextEditingController _maxOrdersCtrl;
  late bool _allowScheduled;
  late bool _allowInstructions;
  late TextEditingController _cancelWindowCtrl;

  @override
  void initState() {
    super.initState();
    _autoAccept = widget.state.autoAcceptOrders;
    _bufferCtrl = TextEditingController(text: widget.state.prepBufferTimeMinutes.toString());
    _maxOrdersCtrl = TextEditingController(text: widget.state.maxActiveOrdersLimit.toString());
    _allowScheduled = widget.state.allowScheduledOrders;
    _allowInstructions = widget.state.allowSpecialInstructions;
    _cancelWindowCtrl = TextEditingController(text: widget.state.cancellationWindowMinutes.toString());
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateOrderSettings(
            autoAcceptOrders: _autoAccept,
            prepBufferTimeMinutes: int.tryParse(_bufferCtrl.text) ?? 15,
            maxActiveOrdersLimit: int.tryParse(_maxOrdersCtrl.text) ?? 20,
            allowScheduledOrders: _allowScheduled,
            allowSpecialInstructions: _allowInstructions,
            cancellationWindowMinutes: int.tryParse(_cancelWindowCtrl.text) ?? 2,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Order Flow & Kitchen Capacity',
      subtitle: 'Manage automatic order acceptance, capacity limits, and cooking instructions.',
      icon: Icons.receipt_long_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow(
            title: 'Auto-Accept Incoming Orders',
            subtitle: 'Automatically accept valid orders without manual intervention.',
            value: _autoAccept,
            onChanged: (val) => setState(() => _autoAccept = val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Preparation Buffer (mins)', _bufferCtrl, '15', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Max Active Orders Limit', _maxOrdersCtrl, '20', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Cancellation Grace Window (mins)', _cancelWindowCtrl, '2', keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildSwitchRow(
            title: 'Allow Scheduled / Pre-Orders',
            subtitle: 'Customers can schedule orders for a later time slot.',
            value: _allowScheduled,
            onChanged: (val) => setState(() => _allowScheduled = val),
          ),
          _buildSwitchRow(
            title: 'Allow Cooking / Special Notes',
            subtitle: 'Customers can write extra spice level or allergy instructions.',
            value: _allowInstructions,
            onChanged: (val) => setState(() => _allowInstructions = val),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 5. Notification Settings View
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
      title: 'Notification Settings',
      subtitle: 'Customize alert chimes, push notifications, and stock warning broadcasts.',
      icon: Icons.notifications_active_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow(
            title: 'Push Notifications',
            subtitle: 'Receive real-time push alerts on new order arrival.',
            value: _push,
            onChanged: (val) => setState(() => _push = val),
          ),
          _buildSwitchRow(
            title: 'New Order Sound Alert',
            subtitle: 'Play chime ringtone when a buyer places an order.',
            value: _sound,
            onChanged: (val) => setState(() => _sound = val),
          ),
          _buildSwitchRow(
            title: 'Continuous Alert Sound (Loop until accepted)',
            subtitle: 'Sound repeats until the order is accepted or dismissed.',
            value: _soundLoop,
            onChanged: (val) => setState(() => _soundLoop = val),
          ),
          const SizedBox(height: 16),
          const Text('Alert Chime Ringtone', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
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
                  if (val != null) setState(() => _ringtone = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Alert Sound Volume: ${(_volume * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            activeColor: const Color(0xFFE52929),
            onChanged: (val) => setState(() => _volume = val),
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            title: 'Low Stock Alerts',
            subtitle: 'Alert immediately when menu items fall below inventory threshold.',
            value: _lowStock,
            onChanged: (val) => setState(() => _lowStock = val),
          ),
          _buildSwitchRow(
            title: 'Order Status Updates',
            subtitle: 'Rider arrival & delivery completion notifications.',
            value: _orderUpdates,
            onChanged: (val) => setState(() => _orderUpdates = val),
          ),
          _buildSwitchRow(
            title: 'WhatsApp Order Notifications',
            subtitle: 'Receive instant summary messages on WhatsApp.',
            value: _whatsapp,
            onChanged: (val) => setState(() => _whatsapp = val),
          ),
          _buildSwitchRow(
            title: 'Promo & Marketing Offers',
            subtitle: 'Receive platform announcements and boost discounts.',
            value: _promo,
            onChanged: (val) => setState(() => _promo = val),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 6. Payment Settings View
// =========================================================================
class _PaymentSettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _PaymentSettingsView({required this.state});

  @override
  State<_PaymentSettingsView> createState() => _PaymentSettingsViewState();
}

class _PaymentSettingsViewState extends State<_PaymentSettingsView> {
  late bool _cod;
  late bool _online;
  late bool _wallet;
  late String _schedule;
  late TextEditingController _minPayoutCtrl;
  late bool _autoSettlement;

  @override
  void initState() {
    super.initState();
    _cod = widget.state.acceptCashOnDelivery;
    _online = widget.state.acceptOnlinePayments;
    _wallet = widget.state.acceptWalletPayments;
    _schedule = widget.state.payoutSchedule;
    _minPayoutCtrl = TextEditingController(text: widget.state.minPayoutThreshold.toStringAsFixed(0));
    _autoSettlement = widget.state.autoSettlementEnabled;
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdatePaymentSettings(
            acceptCashOnDelivery: _cod,
            acceptOnlinePayments: _online,
            acceptWalletPayments: _wallet,
            payoutSchedule: _schedule,
            minPayoutThreshold: double.tryParse(_minPayoutCtrl.text) ?? 500.0,
            autoSettlementEnabled: _autoSettlement,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Payment & Payout Settings',
      subtitle: 'Control supported buyer payment methods and seller settlement frequencies.',
      icon: Icons.account_balance_wallet_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchRow(
            title: 'Accept Cash On Delivery (COD)',
            subtitle: 'Allow customers to pay via cash upon food arrival.',
            value: _cod,
            onChanged: (val) => setState(() => _cod = val),
          ),
          _buildSwitchRow(
            title: 'Accept Online Payments (UPI / Card / NetBanking)',
            subtitle: 'Secure payments via Razorpay & UPI gateways.',
            value: _online,
            onChanged: (val) => setState(() => _online = val),
          ),
          _buildSwitchRow(
            title: 'Accept In-App Wallet Payments',
            subtitle: 'Allow instant checkout using FoodGo user wallet.',
            value: _wallet,
            onChanged: (val) => setState(() => _wallet = val),
          ),
          const SizedBox(height: 20),
          const Text('Payout Schedule Preference', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _schedule,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily Settlement (Automatic T+1)')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly Settlement (Every Monday)')),
                  DropdownMenuItem(value: 'Instant', child: Text('Instant On-Demand Payout')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _schedule = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Minimum Payout Threshold (₹)', _minPayoutCtrl, '500', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildSwitchRow(
            title: 'Auto-Settlement Enabled',
            subtitle: 'Automatically transfer earnings to registered bank account.',
            value: _autoSettlement,
            onChanged: (val) => setState(() => _autoSettlement = val),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 7. Bank / UPI Settings View
// =========================================================================
class _BankUpiSettingsView extends StatefulWidget {
  final SellerSettingState state;
  const _BankUpiSettingsView({required this.state});

  @override
  State<_BankUpiSettingsView> createState() => _BankUpiSettingsViewState();
}

class _BankUpiSettingsViewState extends State<_BankUpiSettingsView> {
  late TextEditingController _holderCtrl;
  late TextEditingController _bankNameCtrl;
  late TextEditingController _accNumCtrl;
  late TextEditingController _ifscCtrl;
  late TextEditingController _branchCtrl;
  late TextEditingController _upiCtrl;
  late String _payoutMode;

  @override
  void initState() {
    super.initState();
    _holderCtrl = TextEditingController(text: widget.state.accountHolderName);
    _bankNameCtrl = TextEditingController(text: widget.state.bankName);
    _accNumCtrl = TextEditingController(text: widget.state.bankAccountNumber);
    _ifscCtrl = TextEditingController(text: widget.state.ifscCode);
    _branchCtrl = TextEditingController(text: widget.state.bankBranch);
    _upiCtrl = TextEditingController(text: widget.state.upiId);
    _payoutMode = widget.state.primaryPayoutMethod;
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateBankUpiSettings(
            accountHolderName: _holderCtrl.text.trim(),
            bankName: _bankNameCtrl.text.trim(),
            bankAccountNumber: _accNumCtrl.text.trim(),
            ifscCode: _ifscCtrl.text.trim().toUpperCase(),
            bankBranch: _branchCtrl.text.trim(),
            upiId: _upiCtrl.text.trim(),
            primaryPayoutMethod: _payoutMode,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Bank & UPI Settlement Details',
      subtitle: 'Configure your bank account and UPI VPA for receiving restaurant revenue.',
      icon: Icons.account_balance_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Account Holder Name', _holderCtrl, 'e.g. John Doe / Spice Symphony LLC'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Bank Name', _bankNameCtrl, 'e.g. HDFC Bank')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('IFSC Code', _ifscCtrl, 'HDFC0001234')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Bank Account Number', _accNumCtrl, '50100234567890', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Branch Name', _branchCtrl, 'e.g. Anna Nagar, Chennai')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Primary UPI ID / VPA', _upiCtrl, 'restaurant@okhdfcbank'),
          const SizedBox(height: 20),
          const Text('Primary Preferred Payout Destination', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _payoutMode = 'bank'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _payoutMode == 'bank' ? const Color(0xFFFEE2E2) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _payoutMode == 'bank' ? const Color(0xFFE52929) : const Color(0xFFE5E7EB),
                        width: _payoutMode == 'bank' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _payoutMode == 'bank'
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: _payoutMode == 'bank'
                              ? const Color(0xFFE52929)
                              : const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Bank Transfer (NEFT/IMPS)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _payoutMode = 'upi'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _payoutMode == 'upi' ? const Color(0xFFFEE2E2) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _payoutMode == 'upi' ? const Color(0xFFE52929) : const Color(0xFFE5E7EB),
                        width: _payoutMode == 'upi' ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _payoutMode == 'upi'
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: _payoutMode == 'upi'
                              ? const Color(0xFFE52929)
                              : const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Instant UPI Transfer',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 8. Tax Information View
// =========================================================================
class _TaxInformationView extends StatefulWidget {
  final SellerSettingState state;
  const _TaxInformationView({required this.state});

  @override
  State<_TaxInformationView> createState() => _TaxInformationViewState();
}

class _TaxInformationViewState extends State<_TaxInformationView> {
  late TextEditingController _gstCtrl;
  late double _gstPercentage;
  late bool _isTaxIncluded;
  late TextEditingController _panCtrl;
  late TextEditingController _fssaiCtrl;
  late TextEditingController _fssaiExpiryCtrl;
  late TextEditingController _prefixCtrl;

  @override
  void initState() {
    super.initState();
    _gstCtrl = TextEditingController(text: widget.state.gstNumber);
    _gstPercentage = widget.state.gstPercentage;
    _isTaxIncluded = widget.state.isTaxIncludedInPrice;
    _panCtrl = TextEditingController(text: widget.state.panNumber);
    _fssaiCtrl = TextEditingController(text: widget.state.fssaiNumber);
    _fssaiExpiryCtrl = TextEditingController(text: widget.state.fssaiExpiryDate);
    _prefixCtrl = TextEditingController(text: widget.state.invoicePrefix);
  }

  void _save() {
    context.read<SellerSettingBloc>().add(
          UpdateTaxSettings(
            gstNumber: _gstCtrl.text.trim().toUpperCase(),
            gstPercentage: _gstPercentage,
            isTaxIncludedInPrice: _isTaxIncluded,
            panNumber: _panCtrl.text.trim().toUpperCase(),
            fssaiNumber: _fssaiCtrl.text.trim(),
            fssaiExpiryDate: _fssaiExpiryCtrl.text.trim(),
            invoicePrefix: _prefixCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _SettingCardContainer(
      title: 'Tax & Compliance Information',
      subtitle: 'Enter GSTIN, PAN, and mandatory FSSAI food licensing certificates.',
      icon: Icons.receipt_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('GSTIN Number (15-digit)', _gstCtrl, '33AAAAA0000A1Z5')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Permanent Account Number (PAN)', _panCtrl, 'ABCDE1234F')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('FSSAI License Number (14-digit)', _fssaiCtrl, '12423000000000', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('FSSAI Expiry Date', _fssaiExpiryCtrl, 'YYYY-MM-DD')),
            ],
          ),
          const SizedBox(height: 20),
          Text('Restaurant GST Rate: ${_gstPercentage.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            children: [5.0, 12.0, 18.0].map((rate) {
              final isSelected = _gstPercentage == rate;
              return ChoiceChip(
                label: Text('${rate.toStringAsFixed(0)}% GST'),
                selected: isSelected,
                selectedColor: const Color(0xFFFEE2E2),
                onSelected: (val) {
                  if (val) setState(() => _gstPercentage = rate);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            title: 'Prices Include Tax (GST Inclusive)',
            subtitle: 'Menu item prices displayed already include all applicable taxes.',
            value: _isTaxIncluded,
            onChanged: (val) => setState(() => _isTaxIncluded = val),
          ),
          const SizedBox(height: 16),
          _buildTextField('Tax Invoice Number Prefix', _prefixCtrl, 'INV-'),
          const SizedBox(height: 24),
          _buildSaveButton(onPressed: _save, isSaving: widget.state.isSaving),
        ],
      ),
    );
  }
}

// =========================================================================
// 9. Account Settings View
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
      title: 'Account & Regional Settings',
      subtitle: 'Manage login credentials, theme mode, and multi-language preferences.',
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
// 10. Privacy Settings View
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
// 11. Security Settings View
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
// 12. Change Password View
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
// 13. Logout View
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
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your restaurant seller account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<SellerSettingBloc>().add(LogoutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 14. Delete / Deactivate Account View
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
