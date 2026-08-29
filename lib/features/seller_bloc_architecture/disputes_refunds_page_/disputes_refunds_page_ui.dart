import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_date_formatter.dart';
import 'disputes_refunds_page_bloc.dart';
import 'disputes_refunds_page_event.dart';
import 'disputes_refunds_page_state.dart';
import 'disputes_refunds_page_repository.dart';
import 'disputes_refunds_page_service.dart';
import 'disputes_refunds_page_model.dart';
import '../../../core/widgets/status_badge.dart';
import '../seller_app_bar_page/seller_app_bar_page_ui.dart';
import '../seller_ui_tokens.dart';

class DisputesRefundsPage extends StatelessWidget {
  final String sellerId;
  const DisputesRefundsPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DisputesRefundsBloc(
        repository: DisputesRefundsRepository(service: DisputesRefundsService()),
      )..add(LoadDisputesEvent(sellerId)),
      child: const DisputesRefundsView(),
    );
  }
}

class DisputesRefundsView extends StatelessWidget {
  const DisputesRefundsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SellerUiTokens.pageBackground,
      appBar: const SellerAppBarPageUI(
        title: 'Disputes & Refunds',
        subtitle: 'Manage customer disputes and refund requests',
        showNotification: false,
      ),
      body: SafeArea(
        child: BlocConsumer<DisputesRefundsBloc, DisputesRefundsState>(
          listener: (context, state) {
            if (state is DisputesRefundsLoaded) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!), backgroundColor: SellerUiTokens.brand),
                );
              } else if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.successMessage!), backgroundColor: SellerUiTokens.successLight),
                );
              }
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: SellerUiTokens.maxWidthForm),
                    child: Column(
                      children: [
                        if (state is DisputesRefundsLoading || state is DisputesRefundsInitial)
                          const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))))
                        else if (state is DisputesRefundsError)
                          Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: Color(0xFFE52929)))))
                        else if (state is DisputesRefundsLoaded)
                          if (state.disputes.isEmpty)
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'No active disputes or refunds.',
                                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(24),
                                itemCount: state.disputes.length,
                                itemBuilder: (context, index) {
                                  final dispute = state.disputes[index];
                                  final isProcessing = state.processingIds.contains(dispute.id);
                                  return _DisputeCard(dispute: dispute, isProcessing: isProcessing);
                                },
                              ),
                            )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final DisputeModel dispute;
  final bool isProcessing;

  const _DisputeCard({required this.dispute, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isPending = dispute.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SellerUiTokens.radiusCard),
        border: Border.all(color: SellerUiTokens.borderSubtle, width: 1.5),
        boxShadow: SellerUiTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ${dispute.orderId}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
              ),
              _buildStatusBadge(dispute.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Customer: ${dispute.customerName}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          Text(
            'Reason: "${dispute.reason}"',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Refund Amount: ${currencyFormat.format(dispute.refundAmount)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
              ),
              Text(
                AppDateFormatter.formatDisplayDateTime(dispute.createdAt),
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          if (isPending) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : () {
                      context.read<DisputesRefundsBloc>().add(DeclineRefundEvent(dispute.id));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      minimumSize: const Size.fromHeight(SellerUiTokens.secondaryButtonHeight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton)),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : () {
                      context.read<DisputesRefundsBloc>().add(ApproveRefundEvent(dispute.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SellerUiTokens.successLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(SellerUiTokens.primaryButtonHeight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SellerUiTokens.radiusButton)),
                    ),
                    child: isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Approve'),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;

    switch (status) {
      case 'Pending':
        color = const Color(0xFF854D0E);
        break;
      case 'Refunded':
        color = const Color(0xFF166534);
        break;
      case 'Declined':
        color = const Color(0xFF991B1B);
        break;
      default:
        color = const Color(0xFF475569);
    }

    return StatusBadge(label: status, color: color);
  }
}
