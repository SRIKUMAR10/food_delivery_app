import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'promotions_coupons_page_bloc.dart';
import 'promotions_coupons_page_event.dart';
import 'promotions_coupons_page_state.dart';
import 'promotions_coupons_page_repository.dart';
import 'promotions_coupons_page_service.dart';
import 'promotions_coupons_page_model.dart';

class PromotionsCouponsPage extends StatelessWidget {
  final String sellerId;
  const PromotionsCouponsPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PromotionsCouponsBloc(
        repository: PromotionsCouponsRepository(service: PromotionsCouponsService()),
      )..add(LoadCouponsEvent(sellerId)),
      child: const PromotionsCouponsView(),
    );
  }
}

class PromotionsCouponsView extends StatelessWidget {
  const PromotionsCouponsView({Key? key}) : super(key: key);

  void _showAddCouponDialog(BuildContext context) {
    final bloc = context.read<PromotionsCouponsBloc>();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: const _CouponFormDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocListener<PromotionsCouponsBloc, PromotionsCouponsState>(
          listener: (context, state) {
            if (state is PromotionsCouponsLoaded) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!), backgroundColor: const Color(0xFFE52929)),
                );
              } else if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.successMessage!), backgroundColor: const Color(0xFF22C55E)),
                );
              }
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Promotions & Coupons',
                                      style: TextStyle(
                                        fontSize: 32, // Adjusted for better mobile fit
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Create and manage special offers',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => Navigator.pop(context),
                                    color: const Color(0xFF111827),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddCouponDialog(context),
                                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                    label: const Text('Add Coupon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      BlocBuilder<PromotionsCouponsBloc, PromotionsCouponsState>(
                        builder: (context, state) {
                          if (state is PromotionsCouponsLoading || state is PromotionsCouponsInitial) {
                            return const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
                            );
                          } else if (state is PromotionsCouponsError) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Text(state.message, style: const TextStyle(color: Color(0xFFE52929))),
                              ),
                            );
                          } else if (state is PromotionsCouponsLoaded) {
                            if (state.coupons.isEmpty) {
                              return const SliverFillRemaining(
                                child: Center(
                                  child: Text(
                                    'No coupons available. Add one to boost sales!',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                                  ),
                                ),
                              );
                            }
                            
                            return SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final coupon = state.coupons[index];
                                    final isProcessing = state.processingCouponIds.contains(coupon.id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _CouponCard(coupon: coupon, isProcessing: isProcessing),
                                    );
                                  },
                                  childCount: state.coupons.length,
                                ),
                              ),
                            );
                          }
                          return const SliverToBoxAdapter(child: SizedBox.shrink());
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final bool isProcessing;

  const _CouponCard({required this.coupon, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    final discountText = coupon.isPercentage
        ? '${coupon.discountAmount.toStringAsFixed(0)}%'
        : '₹${coupon.discountAmount.toStringAsFixed(0)}';
    final isExpired = coupon.expiryDate.isBefore(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  coupon.code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              if (isProcessing)
                const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                )
              else
                Switch(
                  value: coupon.isActive && !isExpired,
                  activeThumbColor: const Color(0xFF22C55E),
                  onChanged: isExpired ? null : (val) {
                    context.read<PromotionsCouponsBloc>().add(ToggleCouponStatusEvent(coupon.id, val));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$discountText OFF',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            coupon.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: isExpired ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Expires: ${DateFormat('MMM dd, yyyy').format(coupon.expiryDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                onPressed: () {
                  context.read<PromotionsCouponsBloc>().add(DeleteCouponEvent(coupon.id));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _CouponFormDialog extends StatefulWidget {
  const _CouponFormDialog({Key? key}) : super(key: key);

  @override
  State<_CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<_CouponFormDialog> {
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _isPercentage = true;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Coupon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeCtrl,
                decoration: InputDecoration(
                  labelText: 'Coupon Code',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Discount',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<bool>(
                    value: _isPercentage,
                    items: const [
                      DropdownMenuItem(value: true, child: Text('% Off')),
                      DropdownMenuItem(value: false, child: Text('Flat Off')),
                    ],
                    onChanged: (val) {
                      setState(() => _isPercentage = val ?? true);
                    },
                  )
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final newCoupon = CouponModel(
                      id: '',
                      code: _codeCtrl.text.toUpperCase(),
                      description: _descCtrl.text,
                      discountAmount: double.tryParse(_amountCtrl.text) ?? 0.0,
                      isPercentage: _isPercentage,
                      expiryDate: _expiryDate,
                      isActive: true,
                    );
                    context.read<PromotionsCouponsBloc>().add(AddCouponEvent(newCoupon));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Coupon', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
