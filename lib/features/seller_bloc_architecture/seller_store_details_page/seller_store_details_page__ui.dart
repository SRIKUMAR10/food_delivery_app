import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_store_details_page__bloc.dart';
import 'seller_store_details_page__event.dart';
import 'seller_store_details_page__state.dart';
import '../../../core/widgets/hoverable_widgets.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../repositories/seller_repository.dart';
import '../seller_auth_shared/onboarding_back_handler.dart';
import '../seller_auth_shared/seller_wizard_container.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';

class SellerStoreDetailsPage extends StatelessWidget {
  final SellerStoreDetailsBloc? bloc;
  final bool isOnboardingFlow;
  const SellerStoreDetailsPage({super.key, this.bloc, this.isOnboardingFlow = false});

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF0F172A),
          size: 20,
        ),
        onPressed: () {
          if (isOnboardingFlow) {
            OnboardingBackHandler.handleBack(context, previousRoute: '/sellerVerificationForm');
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      title: Text(
        isOnboardingFlow ? 'Step 2: Store Details' : 'Store Details',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
      ),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = isOnboardingFlow
        ? SellerWizardContainer(
            stepIndex: 2,
            totalSteps: 8,
            stepBadge: 'Step 2 of 8 • Store Address & Geocoding',
            title: 'Store Details & GPS Location',
            subtitle: 'Set your restaurant identity, pinpoint GPS map location, and delivery radius',
            onBack: () => OnboardingBackHandler.handleBack(context, previousRoute: '/sellerVerificationForm'),
            child: const StoreDetailsContent(isOnboardingFlow: true),
          )
        : Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(context),
            body: SafeArea(child: ResponsiveStoreDetailsLayout(isOnboardingFlow: isOnboardingFlow)),
          );

    return PopScope(
      canPop: !isOnboardingFlow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (isOnboardingFlow) {
          await OnboardingBackHandler.handleBack(context, previousRoute: '/sellerVerificationForm');
        }
      },
      child: bloc != null
          ? BlocProvider<SellerStoreDetailsBloc>.value(
              value: bloc!,
              child: content,
            )
          : BlocProvider(
              create: (context) =>
                  SellerStoreDetailsBloc()..add(LoadStoreDetailsEvent()),
              child: content,
            ),
    );
  }
}

class ResponsiveStoreDetailsLayout extends StatelessWidget {
  final bool isOnboardingFlow;
  const ResponsiveStoreDetailsLayout({Key? key, this.isOnboardingFlow = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Center(
            child: SizedBox(width: 800, child: StoreDetailsContent(isOnboardingFlow: isOnboardingFlow)),
          );
        } else if (constraints.maxWidth > 600) {
          return Center(
            child: SizedBox(width: 600, child: StoreDetailsContent(isOnboardingFlow: isOnboardingFlow)),
          );
        }
        return StoreDetailsContent(isOnboardingFlow: isOnboardingFlow);
      },
    );
  }
}

class StoreDetailsContent extends StatelessWidget {
  final bool isOnboardingFlow;
  const StoreDetailsContent({Key? key, this.isOnboardingFlow = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SellerStoreDetailsBloc, SellerStoreDetailsPageState>(
      buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
            builder: (context, state) {
        if (state is SellerStoreDetailsLoading ||
            state is SellerStoreDetailsInitial) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 250, height: 48, borderRadius: 0),
                const SizedBox(height: 8),
                const SkeletonBox(width: 300, height: 20, borderRadius: 0),
                const SizedBox(height: 32),
                const SkeletonBox(height: 100, borderRadius: 24),
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
                    itemBuilder: (context, index) =>
                        const SkeletonBox(borderRadius: 24),
                  ),
                ),
              ],
            ),
          );
        } else if (state is SellerStoreDetailsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is SellerStoreDetailsLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOnboardingFlow) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.flag_outlined, color: Color(0xFF3B82F6), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Step 2 of 8 (Store Address & GPS Geocoding)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E40AF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Text(
                    'Manage your store settings and information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Status Banner
                  _AnimatedStatusBanner(state: state),
                  const SizedBox(height: 24),

                  // Store Details Grid/List
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isDesktop = constraints.maxWidth > 600;
                      final double itemWidth = isDesktop
                          ? (constraints.maxWidth - 24) / 2
                          : constraints.maxWidth;

                      final List<Widget> items = [
                        _buildInfoCard(
                          index: 0,
                          icon: Icons.storefront_outlined,
                          iconColor: const Color(0xFF3B82F6),
                          iconBgColor: const Color(0xFFEFF6FF),
                          title: state.restaurantName,
                          subtitle: '${state.address}\n${state.phone}',
                          isEditable: false,
                        ),

                        _buildInfoCard(
                          index: 2,
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF10B981),
                          iconBgColor: const Color(0xFFECFDF5),
                          title: 'Delivery Time',
                          subtitle: state.deliveryTime,
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(
                              context,
                              'Delivery Time',
                              state.deliveryTime,
                              (val) {
                                context.read<SellerStoreDetailsBloc>().add(
                                  UpdateFieldEvent('deliveryTime', val),
                                );
                              },
                            );
                          },
                        ),
                        _buildInfoCard(
                          index: 3,
                          icon: Icons.delivery_dining_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          iconBgColor: const Color(0xFFF5F3FF),
                          title: 'Delivery Area',
                          subtitle: state.deliveryArea,
                          isEditable: false,
                        ),
                        if (state.gstNumber != null)
                          _buildInfoCard(
                            index: 4,
                            icon: Icons.account_balance_outlined,
                            iconColor: const Color(0xFF64748B),
                            iconBgColor: const Color(0xFFF1F5F9),
                            title: 'GST Number',
                            subtitle: state.gstNumber!.isEmpty
                                ? 'Not set'
                                : state.gstNumber!,
                            isEditable: true,
                            onEdit: () {
                              _showEditDialog(
                                context,
                                'GST Number',
                                state.gstNumber ?? '',
                                (val) {
                                  context.read<SellerStoreDetailsBloc>().add(
                                    UpdateFieldEvent('gstNumber', val.trim().toUpperCase()),
                                  );
                                },
                              );
                            },
                          ),
                        if (state.fssaiNumber != null)
                          _buildInfoCard(
                            index: 5,
                            icon: Icons.restaurant_menu_outlined,
                            iconColor: const Color(0xFFEC4899),
                            iconBgColor: const Color(0xFFFDF2F8),
                            title: 'FSSAI License',
                            subtitle: state.fssaiNumber!.isEmpty
                                ? 'Not set'
                                : state.fssaiNumber!,
                            isEditable: true,
                            onEdit: () {
                              _showEditDialog(
                                context,
                                'FSSAI License Number',
                                state.fssaiNumber ?? '',
                                (val) {
                                  context.read<SellerStoreDetailsBloc>().add(
                                    UpdateFieldEvent('fssaiNumber', val.trim()),
                                  );
                                },
                              );
                            },
                          ),
                        if (state.fssaiExpiryDate != null)
                          _buildInfoCard(
                            index: 6,
                            icon: Icons.event_outlined,
                            iconColor: const Color(0xFFF97316),
                            iconBgColor: const Color(0xFFFFF7ED),
                            title: 'FSSAI Expiry Date',
                            subtitle: state.fssaiExpiryDate!.isEmpty
                                ? 'Not set'
                                : state.fssaiExpiryDate!,
                            isEditable: true,
                            onEdit: () {
                              _showEditDialog(
                                context,
                                'FSSAI Expiry Date',
                                state.fssaiExpiryDate ?? '',
                                (val) {
                                  context.read<SellerStoreDetailsBloc>().add(
                                    UpdateFieldEvent('fssaiExpiryDate', val.trim()),
                                  );
                                },
                              );
                            },
                          ),
                        if (state.panNumber != null)
                          _buildInfoCard(
                            index: 7,
                            icon: Icons.credit_card_outlined,
                            iconColor: const Color(0xFF14B8A6),
                            iconBgColor: const Color(0xFFF0FDFA),
                            title: 'PAN Number',
                            subtitle: state.panNumber!.isEmpty
                                ? 'Not set'
                                : state.panNumber!,
                            isEditable: true,
                            onEdit: () {
                              _showEditDialog(
                                context,
                                'PAN Number',
                                state.panNumber ?? '',
                                (val) {
                                  context.read<SellerStoreDetailsBloc>().add(
                                    UpdateFieldEvent('panNumber', val.trim().toUpperCase()),
                                  );
                                },
                              );
                            },
                          ),
                        _buildInfoCard(
                          index: 8,
                          icon: Icons.monetization_on_outlined,
                          iconColor: const Color(0xFFEF4444),
                          iconBgColor: const Color(0xFFFEF2F2),
                          title: 'Minimum Order Value',
                          subtitle:
                              '₹${state.minimumOrderValue.toStringAsFixed(2)}',
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(
                              context,
                              'Minimum Order Value',
                              state.minimumOrderValue.toStringAsFixed(0),
                              (val) {
                                final double? parsed = double.tryParse(val);
                                if (parsed != null) {
                                  context.read<SellerStoreDetailsBloc>().add(
                                    UpdateFieldEvent(
                                      'minimumOrderValue',
                                      parsed,
                                    ),
                                  );
                                }
                              },
                              isNumeric: true,
                            );
                          },
                        ),
                        _buildInfoCard(
                          index: 9,
                          icon: Icons.takeout_dining_outlined,
                          iconColor: const Color(0xFFF97316),
                          iconBgColor: const Color(0xFFFFF7ED),
                          title: 'Packaging Charges',
                          subtitle:
                              '₹${state.packagingCharges.toStringAsFixed(2)}',
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(
                              context,
                              'Packaging Charges',
                              state.packagingCharges.toStringAsFixed(0),
                              (val) {
                                final double? parsed = double.tryParse(val);
                                if (parsed != null) {
                                  context.read<SellerStoreDetailsBloc>().add(
                                    UpdateFieldEvent(
                                      'packagingCharges',
                                      parsed,
                                    ),
                                  );
                                }
                              },
                              isNumeric: true,
                            );
                          },
                        ),
                        _buildInfoCard(
                          index: 10,
                          icon: Icons.receipt_long_outlined,
                          iconColor: const Color(0xFF64748B),
                          iconBgColor: const Color(0xFFF1F5F9),
                          title: 'Invoice Prefix',
                          subtitle: state.invoicePrefix.isEmpty
                              ? 'Not set'
                              : state.invoicePrefix,
                          isEditable: true,
                          onEdit: () {
                            _showEditDialog(
                              context,
                              'Invoice Prefix',
                              state.invoicePrefix,
                              (val) {
                                context.read<SellerStoreDetailsBloc>().add(
                                  UpdateFieldEvent('invoicePrefix', val.trim()),
                                );
                              },
                            );
                          },
                        ),
                        _buildSwitchCard(
                          index: 11,
                          icon: Icons.percent,
                          iconColor: const Color(0xFF6366F1),
                          iconBgColor: const Color(0xFFEEF2FF),
                          title: 'Prices Include Tax (GST Inclusive)',
                          subtitle: 'Menu prices already include all taxes',
                          value: state.isTaxIncludedInPrice,
                          onChanged: (newValue) {
                            context.read<SellerStoreDetailsBloc>().add(
                              UpdateFieldEvent(
                                'isTaxIncludedInPrice',
                                newValue,
                              ),
                            );
                          },
                        ),
                      ];

                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children:
                            items
                                .map(
                                  (widget) =>
                                      SizedBox(width: itemWidth, child: widget),
                                )
                                .toList()
                              ..add(
                                SizedBox(
                                  width: itemWidth,
                                  child: _buildDropdownCard(
                                    index: 12,
                                    icon: Icons.percent,
                                    iconColor: const Color(0xFF6366F1),
                                    iconBgColor: const Color(0xFFEEF2FF),
                                    title: 'GST Percentage',
                                    subtitle: 'Applicable GST rate',
                                    value:
                                        [
                                          0.0,
                                          5.0,
                                          12.0,
                                          18.0,
                                          28.0,
                                        ].contains(state.gstPercentage)
                                        ? state.gstPercentage
                                        : 18.0,
                                    items: [0.0, 5.0, 12.0, 18.0, 28.0],
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        context
                                            .read<SellerStoreDetailsBloc>()
                                            .add(
                                              UpdateFieldEvent(
                                                'gstPercentage',
                                                newValue,
                                              ),
                                            );
                                      }
                                    },
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Order Processing Rules Section
                  _OrderProcessingSection(state: state),
                  if (isOnboardingFlow) ...[
                    const SizedBox(height: 32),
                    SellerWizardPrimaryButton(
                      buttonKey: const ValueKey('continue_to_business_hours_btn'),
                      label: 'Save & Continue to Business Hours',
                      onPressed: () async {
                        if (state.restaurantName.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter Restaurant/Store Name before proceeding.'),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        if (state.address.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please set Store Address before proceeding.'),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final repo = SellerRepository();
                        final uid = repo.currentUser?.uid;
                        if (uid != null && uid.isNotEmpty) {
                          try {
                            await repo.updateSellerData(uid, {'isStoreDetailsCompleted': true});
                          } catch (_) {}
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Store details saved! Moving to Step 3: Business Hours.'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            '/businessHours',
                            arguments: {
                              'isOnboardingFlow': true,
                              'sellerId': uid ?? '',
                            },
                          );
                        }
                      },
                    ),
                  ],
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

  String _formatOpeningHours(String raw) {
    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      List<String> parts = [];
      data.forEach((day, times) {
        parts.add(
          '${day.substring(0, 3)}: ${times['open']} - ${times['close']}',
        );
      });
      return parts.join('\n');
    } catch (e) {
      return raw;
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      int m = int.parse(hm[1]);
      if (parts.length > 1) {
        if (parts[1].toUpperCase() == 'PM' && h != 12) h += 12;
        if (parts[1].toUpperCase() == 'AM' && h == 12) h = 0;
      }
      return TimeOfDay(hour: h, minute: m);
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  void _showOpeningHoursDialog(
    BuildContext context,
    String initialValue,
    Function(String) onSave,
  ) {
    final List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    Map<String, Map<String, String>> schedule = {};

    try {
      final Map<String, dynamic> data = jsonDecode(initialValue);
      for (var day in days) {
        schedule[day] = {
          'open': data[day]?['open'] ?? '10:00 AM',
          'close': data[day]?['close'] ?? '11:00 PM',
        };
      }
    } catch (e) {
      String open = '10:00 AM';
      String close = '11:00 PM';
      if (initialValue.contains(' - ')) {
        final parts = initialValue.split(' - ');
        open = parts[0].trim();
        if (parts.length > 1) close = parts[1].trim();
      }
      for (var day in days) {
        schedule[day] = {'open': open, 'close': close};
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Opening Hours',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: _parseTime(
                                    schedule[day]!['open']!,
                                  ),
                                );
                                if (picked != null) {
                                  setState(
                                    () => schedule[day]!['open'] = picked
                                        .format(context),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  schedule[day]!['open']!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('-'),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: _parseTime(
                                    schedule[day]!['close']!,
                                  ),
                                );
                                if (picked != null) {
                                  setState(
                                    () => schedule[day]!['close'] = picked
                                        .format(context),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  schedule[day]!['close']!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52929),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    onSave(jsonEncode(schedule));
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave, {
    bool isNumeric = false,
  }) {
    _showEditValueDialog(context, title, initialValue, onSave, isNumeric: isNumeric);
  }
}

void _showEditValueDialog(
  BuildContext context,
  String title,
  String initialValue,
  Function(String) onSave, {
  bool isNumeric = false,
}) {
  final TextEditingController controller = TextEditingController(
    text: initialValue,
  );
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit $title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            labelText: title,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE52929),
                width: 2,
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

class _AnimatedStatusBanner extends StatefulWidget {
  final SellerStoreDetailsLoaded state;
  const _AnimatedStatusBanner({required this.state});

  @override
  State<_AnimatedStatusBanner> createState() => _AnimatedStatusBannerState();
}

class _AnimatedStatusBannerState extends State<_AnimatedStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
            border: Border.all(
              color: widget.state.isOnline
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFF1F5F9),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.state.isOnline
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.03),
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
                      color: widget.state.isOnline
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      color: widget.state.isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.state.isOnline
                            ? 'Store is Online'
                            : 'Store is Offline',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: widget.state.isOnline
                              ? const Color(0xFF065F46)
                              : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.state.isOnline
                            ? 'Customers can place orders'
                            : 'Store is currently not accepting orders',
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
                  context.read<SellerStoreDetailsBloc>().add(
                    ToggleStoreStatusEvent(value),
                  );
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

class _CardEntry extends StatefulWidget {
  final int index;
  final Widget child;

  const _CardEntry({required this.index, required this.child});

  @override
  State<_CardEntry> createState() => _CardEntryState();
}

class _CardEntryState extends State<_CardEntry>
    with SingleTickerProviderStateMixin {
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
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
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
        child: widget.child,
      ),
    );
  }
}

Widget _buildInfoCard({
  required int index,
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
  required String title,
  required String subtitle,
  required bool isEditable,
  VoidCallback? onEdit,
}) {
  return _CardEntry(
    index: index,
    child: HoverableCard(
      hoverScale: 1.02,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
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
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditable)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF9CA3AF),
                  onPressed: onEdit,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildDropdownCard({
  required int index,
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
  required String title,
  required String subtitle,
  required double value,
  required List<double> items,
  required ValueChanged<double?> onChanged,
}) {
  return _CardEntry(
    index: index,
    child: HoverableCard(
      hoverScale: 1.02,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
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
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
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
                    value: value,
                    isDense: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF64748B),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items: items.map((double item) {
                      return DropdownMenuItem<double>(
                        value: item,
                        child: Text('${item.toInt()}%'),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildSwitchCard({
  required int index,
  required IconData icon,
  required Color iconColor,
  required Color iconBgColor,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return _CardEntry(
    index: index,
    child: HoverableCard(
      hoverScale: 1.02,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
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
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF10B981),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCBD5E1),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _OrderProcessingSection extends StatelessWidget {
  final SellerStoreDetailsLoaded state;

  const _OrderProcessingSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFE52929), size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Processing Rules',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Auto-acceptance, kitchen capacity & scheduling rules',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 600;
            final double itemWidth = isDesktop
                ? (constraints.maxWidth - 24) / 2
                : constraints.maxWidth;

            final List<Widget> items = [
              _buildSwitchCard(
                index: 0,
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFE52929),
                iconBgColor: const Color(0xFFFEF2F2),
                title: 'Auto-Accept Incoming Orders',
                subtitle: 'Automatically accept valid orders without manual intervention.',
                value: state.autoAcceptOrders,
                onChanged: (newValue) {
                  context.read<SellerStoreDetailsBloc>().add(
                    UpdateFieldEvent('autoAcceptOrders', newValue),
                  );
                },
              ),
              _buildInfoCard(
                index: 1,
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFECFDF5),
                title: 'Preparation Buffer',
                subtitle: '${state.prepBufferTimeMinutes} minutes',
                isEditable: true,
                onEdit: () {
                  _showEditValueDialog(
                    context,
                    'Preparation Buffer (mins)',
                    state.prepBufferTimeMinutes.toString(),
                    (val) {
                      final int? parsed = int.tryParse(val);
                      if (parsed != null) {
                        context.read<SellerStoreDetailsBloc>().add(
                          UpdateFieldEvent('prepBufferTimeMinutes', parsed),
                        );
                      }
                    },
                    isNumeric: true,
                  );
                },
              ),
              _buildInfoCard(
                index: 2,
                icon: Icons.assessment_outlined,
                iconColor: const Color(0xFF3B82F6),
                iconBgColor: const Color(0xFFEFF6FF),
                title: 'Max Active Orders Limit',
                subtitle: '${state.maxActiveOrdersLimit} orders',
                isEditable: true,
                onEdit: () {
                  _showEditValueDialog(
                    context,
                    'Max Active Orders Limit',
                    state.maxActiveOrdersLimit.toString(),
                    (val) {
                      final int? parsed = int.tryParse(val);
                      if (parsed != null) {
                        context.read<SellerStoreDetailsBloc>().add(
                          UpdateFieldEvent('maxActiveOrdersLimit', parsed),
                        );
                      }
                    },
                    isNumeric: true,
                  );
                },
              ),
              _buildInfoCard(
                index: 3,
                icon: Icons.hourglass_bottom_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFFFBEB),
                title: 'Cancellation Grace Window',
                subtitle: '${state.cancellationWindowMinutes} minutes',
                isEditable: true,
                onEdit: () {
                  _showEditValueDialog(
                    context,
                    'Cancellation Grace Window (mins)',
                    state.cancellationWindowMinutes.toString(),
                    (val) {
                      final int? parsed = int.tryParse(val);
                      if (parsed != null) {
                        context.read<SellerStoreDetailsBloc>().add(
                          UpdateFieldEvent('cancellationWindowMinutes', parsed),
                        );
                      }
                    },
                    isNumeric: true,
                  );
                },
              ),
              _buildSwitchCard(
                index: 4,
                icon: Icons.schedule_send_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBgColor: const Color(0xFFF5F3FF),
                title: 'Allow Scheduled / Pre-Orders',
                subtitle: 'Customers can schedule orders for a later time slot.',
                value: state.allowScheduledOrders,
                onChanged: (newValue) {
                  context.read<SellerStoreDetailsBloc>().add(
                    UpdateFieldEvent('allowScheduledOrders', newValue),
                  );
                },
              ),
              _buildSwitchCard(
                index: 5,
                icon: Icons.note_alt_outlined,
                iconColor: const Color(0xFF06B6D4),
                iconBgColor: const Color(0xFFECFEFF),
                title: 'Allow Special / Cooking Notes',
                subtitle: 'Customers can write extra spice level or allergy instructions.',
                value: state.allowSpecialInstructions,
                onChanged: (newValue) {
                  context.read<SellerStoreDetailsBloc>().add(
                    UpdateFieldEvent('allowSpecialInstructions', newValue),
                  );
                },
              ),
            ];

            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: items
                  .map((widget) => SizedBox(width: itemWidth, child: widget))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}


