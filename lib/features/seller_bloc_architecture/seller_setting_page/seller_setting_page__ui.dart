import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_setting_page__bloc.dart';
import 'seller_setting_page__event.dart';
import 'seller_setting_page__state.dart';

class SellerSettingPage extends StatelessWidget {
  const SellerSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold for Settings page
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SellerSettingBloc, SellerSettingState>(
        buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final contentItems = [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Settings',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your notification preferences',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: const Color(0xFF111827),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Preferences'),
            _buildSwitchTile(
              title: 'Push Notifications',
              value: state.pushNotifications,
              onChanged: (val) {
                context.read<SellerSettingBloc>().add(UpdatePushNotifications(val));
              },
            ),
            _buildSwitchTile(
              title: 'New Order Sound',
              value: state.newOrderSound,
              onChanged: (val) {
                context.read<SellerSettingBloc>().add(UpdateNewOrderSound(val));
              },
            ),
            _buildSwitchTile(
              title: 'Promo & Offers',
              value: state.promoAndOffers,
              onChanged: (val) {
                context.read<SellerSettingBloc>().add(UpdatePromoAndOffers(val));
              },
            ),
            _buildSwitchTile(
              title: 'Low Stock Alerts',
              value: state.lowStockAlerts,
              onChanged: (val) {
                context.read<SellerSettingBloc>().add(UpdateLowStockAlerts(val));
              },
            ),
            _buildSwitchTile(
              title: 'Order Updates',
              value: state.orderUpdates,
              onChanged: (val) {
                context.read<SellerSettingBloc>().add(UpdateOrderUpdates(val));
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('App Theme'),
            const SizedBox(height: 12),
            _buildDropdown(
              value: state.appTheme,
              items: const ['Light', 'Dark', 'System Default'],
              onChanged: (val) {
                if (val != null) {
                  context.read<SellerSettingBloc>().add(UpdateAppTheme(val));
                }
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Language'),
            const SizedBox(height: 12),
            _buildDropdown(
              value: state.language,
              items: const ['English', 'Tamil', 'Spanish', 'French'],
              onChanged: (val) {
                if (val != null) {
                  context.read<SellerSettingBloc>().add(UpdateLanguage(val));
                }
              },
            ),
            const SizedBox(height: 40),
          ];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(contentItems.length, (index) {
                      return _StaggeredListItem(
                        index: index,
                        child: contentItems[index],
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2C3241),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _HoverableTile(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF20C976),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A5568)),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredListItem({Key? key, required this.child, required this.index}) : super(key: key);

  @override
  State<_StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<_StaggeredListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class _HoverableTile extends StatefulWidget {
  final Widget child;
  const _HoverableTile({Key? key, required this.child}) : super(key: key);

  @override
  State<_HoverableTile> createState() => _HoverableTileState();
}

class _HoverableTileState extends State<_HoverableTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFF8FAFC) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: _isHovered ? Border.all(color: const Color(0xFFF1F5F9)) : Border.all(color: Colors.transparent),
        ),
        child: widget.child,
      ),
    );
  }
}

