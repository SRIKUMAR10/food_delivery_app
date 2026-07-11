import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_store_details_page__bloc.dart';
import 'seller_store_details_page__event.dart';
import 'seller_store_details_page__state.dart';

class SellerStoreDetailsPage extends StatelessWidget {
  const SellerStoreDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SellerStoreDetailsBloc()..add(LoadStoreDetailsEvent()),
      child: const Scaffold(
        backgroundColor: Color(0xFFF8FAFC), // Light grayish-blue background
        body: SafeArea(child: ResponsiveStoreDetailsLayout()),
      ),
    );
  }
}

class ResponsiveStoreDetailsLayout extends StatelessWidget {
  const ResponsiveStoreDetailsLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return const Center(
            child: SizedBox(width: 800, child: StoreDetailsContent()),
          );
        } else if (constraints.maxWidth > 600) {
          return const Center(
            child: SizedBox(width: 600, child: StoreDetailsContent()),
          );
        }
        return const StoreDetailsContent();
      },
    );
  }
}

class StoreDetailsContent extends StatelessWidget {
  const StoreDetailsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
      builder: (context, state) {
        if (state is SellerStoreDetailsLoading || state is SellerStoreDetailsInitial) {
          return const _StoreDetailsSkeleton();
        } else if (state is SellerStoreDetailsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is SellerStoreDetailsLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Store Details',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Manage your store settings and information',
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

                  // Store Status Banner
                  _AnimatedStatusBanner(state: state),
                  const SizedBox(height: 24),

                  // Store Details Grid/List
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isDesktop = constraints.maxWidth > 600;
                      final double itemWidth = isDesktop ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;
                      
                      final List<Widget> items = [
                        _HoverableInfoCard(
                          index: 0,
                          icon: Icons.storefront_outlined,
                          iconColor: const Color(0xFF3B82F6),
                          iconBgColor: const Color(0xFFEFF6FF),
                          title: state.restaurantName,
                          subtitle: '${state.address}\n${state.phone}',
                          isEditable: false,
                        ),
                        _HoverableInfoCard(
                          index: 1,
                          icon: Icons.access_time_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          iconBgColor: const Color(0xFFFFFBEB),
                          title: 'Opening Hours',
                          subtitle: state.openingHours,
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(context, 'Opening Hours', state.openingHours, (val) {
                              context.read<SellerStoreDetailsBloc>().add(UpdateFieldEvent('openingHours', val));
                            });
                          },
                        ),
                        _HoverableInfoCard(
                          index: 2,
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF10B981),
                          iconBgColor: const Color(0xFFECFDF5),
                          title: 'Delivery Time',
                          subtitle: state.deliveryTime,
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(context, 'Delivery Time', state.deliveryTime, (val) {
                              context.read<SellerStoreDetailsBloc>().add(UpdateFieldEvent('deliveryTime', val));
                            });
                          },
                        ),
                        _HoverableInfoCard(
                          index: 3,
                          icon: Icons.delivery_dining_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          iconBgColor: const Color(0xFFF5F3FF),
                          title: 'Delivery Area',
                          subtitle: state.deliveryArea,
                          isEditable: false,
                        ),
                        if (state.gstNumber != null)
                          _HoverableInfoCard(
                            index: 4,
                            icon: Icons.account_balance_outlined,
                            iconColor: const Color(0xFF64748B),
                            iconBgColor: const Color(0xFFF1F5F9),
                            title: 'GST Number',
                            subtitle: state.gstNumber!,
                            isEditable: false,
                          ),
                        if (state.fssaiNumber != null)
                          _HoverableInfoCard(
                            index: 5,
                            icon: Icons.restaurant_menu_outlined,
                            iconColor: const Color(0xFFEC4899),
                            iconBgColor: const Color(0xFFFDF2F8),
                            title: 'FSSAI License',
                            subtitle: state.fssaiNumber!,
                            isEditable: false,
                          ),
                        if (state.panNumber != null)
                          _HoverableInfoCard(
                            index: 6,
                            icon: Icons.credit_card_outlined,
                            iconColor: const Color(0xFF14B8A6),
                            iconBgColor: const Color(0xFFF0FDFA),
                            title: 'PAN Number',
                            subtitle: state.panNumber!,
                            isEditable: false,
                          ),
                        _HoverableInfoCard(
                          index: 7,
                          icon: Icons.monetization_on_outlined,
                          iconColor: const Color(0xFFEF4444),
                          iconBgColor: const Color(0xFFFEF2F2),
                          title: 'Minimum Order Value',
                          subtitle: '₹${state.minimumOrderValue.toStringAsFixed(2)}',
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(context, 'Minimum Order Value', state.minimumOrderValue.toStringAsFixed(0), (val) {
                              final double? parsed = double.tryParse(val);
                              if (parsed != null) {
                                context.read<SellerStoreDetailsBloc>().add(UpdateFieldEvent('minimumOrderValue', parsed));
                              }
                            }, isNumeric: true);
                          },
                        ),
                        _HoverableInfoCard(
                          index: 8,
                          icon: Icons.takeout_dining_outlined,
                          iconColor: const Color(0xFFF97316),
                          iconBgColor: const Color(0xFFFFF7ED),
                          title: 'Packaging Charges',
                          subtitle: '₹${state.packagingCharges.toStringAsFixed(2)}',
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(context, 'Packaging Charges', state.packagingCharges.toStringAsFixed(0), (val) {
                              final double? parsed = double.tryParse(val);
                              if (parsed != null) {
                                context.read<SellerStoreDetailsBloc>().add(UpdateFieldEvent('packagingCharges', parsed));
                              }
                            }, isNumeric: true);
                          },
                        ),
                      ];

                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: items.map((widget) => SizedBox(width: itemWidth, child: widget)).toList()
                          ..add(
                             SizedBox(
                                width: itemWidth,
                                child: _HoverableDropdownCard(
                                  index: 9,
                                  icon: Icons.percent,
                                  iconColor: const Color(0xFF6366F1),
                                  iconBgColor: const Color(0xFFEEF2FF),
                                  title: 'GST Percentage',
                                  subtitle: 'Applicable GST rate',
                                  value: [0.0, 5.0, 12.0, 18.0, 28.0].contains(state.gstPercentage) ? state.gstPercentage : 18.0,
                                  items: [0.0, 5.0, 12.0, 18.0, 28.0],
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      context.read<SellerStoreDetailsBloc>().add(UpdateFieldEvent('gstPercentage', newValue));
                                    }
                                  },
                                ),
                             )
                          ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Edit Button
                  _AnimatedEditButton(),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showEditDialog(BuildContext context, String title, String initialValue, Function(String) onSave, {bool isNumeric = false}) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit $title', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              labelText: title,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE52929), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52929),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedStatusBanner extends StatefulWidget {
  final SellerStoreDetailsLoaded state;
  const _AnimatedStatusBanner({required this.state});

  @override
  State<_AnimatedStatusBanner> createState() => _AnimatedStatusBannerState();
}

class _AnimatedStatusBannerState extends State<_AnimatedStatusBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.state.isOnline ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9), width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.state.isOnline ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.03),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.state.isOnline ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      color: widget.state.isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.state.isOnline ? 'Store is Online' : 'Store is Offline',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: widget.state.isOnline ? const Color(0xFF065F46) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.state.isOnline ? 'Customers can place orders' : 'Store is currently not accepting orders',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: widget.state.isOnline,
                onChanged: (value) {
                  context.read<SellerStoreDetailsBloc>().add(ToggleStoreStatusEvent(value));
                },
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF10B981),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverableInfoCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isEditable;
  final VoidCallback? onEdit;

  const _HoverableInfoCard({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.isEditable,
    this.onEdit,
  });

  @override
  State<_HoverableInfoCard> createState() => _HoverableInfoCardState();
}

class _HoverableInfoCardState extends State<_HoverableInfoCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _entryController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered && widget.isEditable ? 1.02 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
                  blurRadius: _isHovered ? 24 : 12,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isEditable)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: _isHovered ? const Color(0xFFE52929) : const Color(0xFF9CA3AF),
                      onPressed: widget.onEdit,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverableDropdownCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final double value;
  final List<double> items;
  final ValueChanged<double?> onChanged;

  const _HoverableDropdownCard({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_HoverableDropdownCard> createState() => _HoverableDropdownCardState();
}

class _HoverableDropdownCardState extends State<_HoverableDropdownCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _entryController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
                  blurRadius: _isHovered ? 24 : 12,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        value: widget.value,
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        items: widget.items.map((double value) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text('${value.toInt()}%'),
                          );
                        }).toList(),
                        onChanged: widget.onChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedEditButton extends StatefulWidget {
  @override
  State<_AnimatedEditButton> createState() => _AnimatedEditButtonState();
}

class _AnimatedEditButtonState extends State<_AnimatedEditButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _entryController;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              context.read<SellerStoreDetailsBloc>().add(const EditStoreDetailsEvent());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()..scale(_isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0)),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE52929), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE52929).withValues(alpha: _isHovered ? 0.4 : 0.2),
                    blurRadius: _isHovered ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit_note_outlined, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Edit Store Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreDetailsSkeleton extends StatelessWidget {
  const _StoreDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 250, height: 48, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Container(width: 300, height: 20, color: Colors.grey.shade200),
          const SizedBox(height: 32),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
