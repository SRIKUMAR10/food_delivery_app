import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/inventory_item_model.dart';
import '../../../../core/models/inventory_history_log_model.dart';
import 'inventory_low_stock_page_bloc.dart';
import 'inventory_low_stock_page_event.dart';
import 'inventory_low_stock_page_state.dart';
import '../../../../core/repositories/i_inventory_repository.dart';
import 'product_details_page_ui.dart';

/// ─── Localization Dictionary (English & Tamil) ──────────────────────────────
class _InvLoc {
  static bool isTamil(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ta';
  }

  static String t(BuildContext context, String en, String ta) {
    return isTamil(context) ? ta : en;
  }
}

class InventoryLowStockPage extends StatelessWidget {
  const InventoryLowStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    String sellerId = 'test_seller_id';
    try {
      sellerId = FirebaseAuth.instance.currentUser?.uid ?? 'test_seller_id';
    } catch (_) {
      sellerId = 'test_seller_id';
    }

    return BlocProvider(
      create: (context) => InventoryBloc(
        repository: context.read<IInventoryRepository>(),
      )..add(LoadInventoryStream(sellerId: sellerId)),
      child: const _InventoryLowStockView(),
    );
  }
}

class _InventoryLowStockView extends StatefulWidget {
  const _InventoryLowStockView();

  @override
  State<_InventoryLowStockView> createState() => _InventoryLowStockViewState();
}

class _InventoryLowStockViewState extends State<_InventoryLowStockView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  final Set<String> _selectedIds = {};
  bool _isBulkMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBulkMode() {
    setState(() {
      _isBulkMode = !_isBulkMode;
      if (!_isBulkMode) _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _showQuickStockAdjustDialog(InventoryItemModel item) {
    double adjustment = 0;
    double absoluteVal = item.quantity;
    bool isAbsoluteMode = false;
    String selectedReason = 'Supplier Restock';
    final TextEditingController noteCtrl = TextEditingController();

    final List<String> reasonsEn = [
      'Supplier Restock',
      'Wastage / Spoiled',
      'Damaged in Transit',
      'Customer Return',
      'Manual Adjustment',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final double previewStock = isAbsoluteMode
                ? absoluteVal
                : (item.quantity + adjustment);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.inventory_2_rounded, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _InvLoc.t(context, 'Update Stock: ${item.name}', 'இருப்பு திருத்தம்: ${item.name}'),
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current vs Preview Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _InvLoc.t(context, 'Current Stock', 'தற்போதைய இருப்பு'),
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade700),
                              ),
                              Text(
                                '${item.quantity.toInt()} ${item.unit}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF4F46E5), size: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _InvLoc.t(context, 'New Stock', 'புதிய இருப்பு'),
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade700),
                              ),
                              Text(
                                '${previewStock.toInt()} ${item.unit}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: previewStock <= 0 ? Colors.red : const Color(0xFF4F46E5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mode Toggle: Relative (+/-) vs Set Absolute
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(_InvLoc.t(context, 'Adjust (+/-)', 'கூட்டு / குறை (+/-)')),
                            selected: !isAbsoluteMode,
                            onSelected: (val) => setDlgState(() => isAbsoluteMode = !val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(_InvLoc.t(context, 'Set Value', 'நேரடி அளவு')),
                            selected: isAbsoluteMode,
                            onSelected: (val) => setDlgState(() => isAbsoluteMode = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Adjust controls
                    if (!isAbsoluteMode) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.remove),
                            onPressed: () => setDlgState(() {
                              if ((item.quantity + adjustment) > 0) {
                                adjustment -= 1;
                              }
                            }),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              (adjustment >= 0 ? '+$adjustment' : '$adjustment').replaceAll('.0', ''),
                              style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.add),
                            onPressed: () => setDlgState(() => adjustment += 1),
                          ),
                        ],
                      ),
                    ] else ...[
                      TextFormField(
                        initialValue: absoluteVal.toInt().toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _InvLoc.t(context, 'Absolute Stock', 'நேரடி இருப்பு அளவு'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) {
                          final p = double.tryParse(v);
                          if (p != null && p >= 0) {
                            setDlgState(() => absoluteVal = p);
                          }
                        },
                      ),
                    ],

                    const SizedBox(height: 16),
                    Text(
                      _InvLoc.t(context, 'Reason for Update', 'மாற்றத்திற்கான காரணம்'),
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedReason,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: reasonsEn.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setDlgState(() => selectedReason = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: _InvLoc.t(context, 'Optional Note', 'குறிப்பு (விருப்பப்பட்டால்)'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(_InvLoc.t(context, 'Cancel', 'ரத்து செய்'), style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isAbsoluteMode) {
                      context.read<InventoryBloc>().add(
                        SetAbsoluteStockEvent(
                          productId: item.id,
                          newQuantity: absoluteVal,
                          reason: selectedReason,
                          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                        ),
                      );
                    } else {
                      if (adjustment == 0) {
                        Navigator.pop(ctx);
                        return;
                      }
                      context.read<InventoryBloc>().add(
                        UpdateStockEvent(
                          productId: item.id,
                          quantityChange: adjustment,
                          reason: selectedReason,
                          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                        ),
                      );
                    }
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_InvLoc.t(context, 'Save Changes', 'சேமிக்கவும்'), style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showThresholdEditorDialog(InventoryItemModel item) {
    int currentThreshold = item.lowStockThreshold;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                _InvLoc.t(context, 'Low Stock Alert Threshold', 'குறைந்த இருப்பு எச்சரிக்கை வரம்பு'),
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _InvLoc.t(
                      context,
                      'Notify me when ${item.name} stock falls below this quantity:',
                      '${item.name} இருப்பு இந்த அளவுக்குக் கீழே குறையும் போது அறிவிக்கவும்:',
                    ),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (currentThreshold > 1) {
                            setDlgState(() => currentThreshold--);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$currentThreshold',
                          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () => setDlgState(() => currentThreshold++),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(_InvLoc.t(context, 'Cancel', 'ரத்து'), style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(
                      UpdateLowStockThresholdEvent(productId: item.id, threshold: currentThreshold),
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  child: Text(_InvLoc.t(context, 'Update Threshold', 'வரம்பை மாற்றுக'), style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStockHistoryBottomSheet({InventoryItemModel? item}) {
    context.read<InventoryBloc>().add(LoadInventoryHistoryEvent(productId: item?.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            final List<InventoryHistoryLogModel> logs =
                (state is InventoryLoaded) ? state.historyLogs : [];
            final bool isLoading = (state is InventoryLoaded) && state.isLoadingHistory;

            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.history_rounded, color: Color(0xFF4F46E5)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item != null
                                  ? _InvLoc.t(context, '${item.name} History', '${item.name} இருப்பு வரலாறு')
                                  : _InvLoc.t(context, 'All Stock Movement Logs', 'அனைத்து இருப்பு வரலாற்றுப் பதிவுகள்'),
                              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const Expanded(child: Center(child: CircularProgressIndicator()))
                      else if (logs.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              _InvLoc.t(context, 'No stock history records found.', 'இருப்பு வரலாற்றுப் பதிவுகள் எதுவும் இல்லை.'),
                              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final isPos = log.quantityChanged > 0;
                              final sign = isPos ? '+' : '';
                              final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp);

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isPos
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    child: Icon(
                                      isPos ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                      size: 18,
                                      color: isPos ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          log.reason,
                                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        if (log.productName.isNotEmpty && item == null)
                                          Text(
                                            log.productName,
                                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                                          ),
                                        Text(
                                          '$dateStr • ${log.actionType}',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                        if (log.note != null && log.note!.isNotEmpty)
                                          Text(
                                            'Note: ${log.note}',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$sign${log.quantityChanged.toInt()}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isPos ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      Text(
                                        '${log.previousQuantity.toInt()} → ${log.newQuantity.toInt()}',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showBulkUpdateDialog() {
    if (_selectedIds.isEmpty) return;
    
    double quantityChange = 0;
    String reason = 'Supplier Restock';
    final List<String> reasons = ['Supplier Restock', 'Wastage / Spoiled', 'Damaged in Transit', 'Customer Return', 'Manual Adjustment'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                _InvLoc.t(context, 'Bulk Update ${_selectedIds.length} Items', 'மொத்த இருப்பு மாற்றம் (${_selectedIds.length} பொருட்கள்)'),
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setStateDialog(() => quantityChange -= 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          (quantityChange >= 0 ? '+$quantityChange' : '$quantityChange').replaceAll('.0', ''),
                          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () => setStateDialog(() => quantityChange += 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setStateDialog(() => reason = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(_InvLoc.t(context, 'Cancel', 'ரத்து'), style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(
                      BulkUpdateStockEvent(
                        productIds: _selectedIds.toList(),
                        quantityChange: quantityChange,
                        reason: reason,
                      ),
                    );
                    Navigator.pop(ctx);
                    _toggleBulkMode();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  child: Text(_InvLoc.t(context, 'Apply Bulk Update', 'மொத்த மாற்றம் செய்'), style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is InventoryLoaded) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
            );
            context.read<InventoryBloc>().add(ClearInventoryMessage());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
            context.read<InventoryBloc>().add(ClearInventoryMessage());
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return BlocBuilder<InventoryBloc, InventoryState>(
                buildWhen: (previous, current) => previous.runtimeType != current.runtimeType || previous != current,
                builder: (context, state) {
                  if (state is InventoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is InventoryLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        final sellerId = FirebaseAuth.instance.currentUser?.uid ?? 'test_seller_id';
                        context.read<InventoryBloc>().add(LoadInventoryStream(sellerId: sellerId));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Health bar & Summary Cards
                            _buildHealthAndSummary(state.summary, isWide),
                            const SizedBox(height: 24),

                            // Filter Chips Row
                            _buildFilterChips(state.activeFilter),
                            const SizedBox(height: 16),

                            // Section header with Bulk & History triggers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _InvLoc.t(context, 'Inventory List', 'பொருட்கள் பட்டியல்'),
                                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.history_rounded, color: Color(0xFF4F46E5)),
                                      tooltip: _InvLoc.t(context, 'Store Stock History', 'இருப்பு வரலாறு'),
                                      onPressed: () => _showStockHistoryBottomSheet(),
                                    ),
                                    TextButton(
                                      onPressed: _toggleBulkMode,
                                      child: Text(
                                        _isBulkMode
                                            ? _InvLoc.t(context, 'Cancel Bulk', 'ரத்து செய்')
                                            : _InvLoc.t(context, 'Bulk Select', 'மொத்த தேர்வு'),
                                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (state.filteredItems.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(48),
                                  child: Column(
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      Text(
                                        _InvLoc.t(context, 'No matching products found.', 'பொருட்கள் எதுவும் காணப்படவில்லை.'),
                                        style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (isWide)
                              _buildWideGrid(state.filteredItems, state.updatingItemIds)
                            else
                              ...state.filteredItems.map(
                                (item) => _buildMobileItemCard(item, state.updatingItemIds.contains(item.id)),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              );
            },
          ),
        ),
        floatingActionButton: _isBulkMode && _selectedIds.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _showBulkUpdateDialog,
                backgroundColor: const Color(0xFF4F46E5),
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                label: Text(
                  _InvLoc.t(context, 'Update (${_selectedIds.length}) Items', '(${_selectedIds.length}) பொருட்களை மாற்றுக'),
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: _isSearchActive
          ? TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) => context.read<InventoryBloc>().add(SearchInventory(val)),
              decoration: InputDecoration(
                hintText: _InvLoc.t(context, 'Search products by name, SKU...', 'தயாரிப்பு பெயர், SKU மூலம் தேடவும்...'),
                border: InputBorder.none,
              ),
            )
          : Text(
              _InvLoc.t(context, 'Inventory Management', 'இருப்பு மேலாண்மை'),
              style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold),
            ),
      actions: [
        IconButton(
          icon: Icon(_isSearchActive ? Icons.close : Icons.search, color: Colors.black),
          onPressed: () {
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) {
                _searchController.clear();
                context.read<InventoryBloc>().add(const SearchInventory(''));
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildHealthAndSummary(InventorySummary summary, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _InvLoc.t(context, 'Inventory Health Index', 'இருப்பு நிலை குறியீடு'),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              Text(
                '${summary.healthScorePercentage.toStringAsFixed(0)}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: summary.healthScorePercentage > 75
                      ? Colors.green
                      : (summary.healthScorePercentage > 40 ? Colors.orange : Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: summary.healthScorePercentage / 100.0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.healthScorePercentage > 75
                    ? Colors.green
                    : (summary.healthScorePercentage > 40 ? Colors.orange : Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _summaryCard(_InvLoc.t(context, 'Total SKUs', 'மொத்தம்'), summary.totalItems, Colors.blue),
                _summaryCard(_InvLoc.t(context, 'In Stock', 'இருப்பில் உள்ளது'), summary.normalStock, Colors.green),
                _summaryCard(_InvLoc.t(context, 'Low Stock', 'குறைந்த இருப்பு'), summary.lowStock, Colors.orange),
                _summaryCard(_InvLoc.t(context, 'Out of Stock', 'இருப்பு இல்லை'), summary.outOfStock, Colors.red),
                if (summary.expiringSoon > 0)
                  _summaryCard(_InvLoc.t(context, 'Expiring Soon', 'விரைவில் காலாவதி'), summary.expiringSoon, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(String activeFilter) {
    final List<Map<String, String>> filters = [
      {'en': 'All', 'ta': 'அனைத்தும்'},
      {'en': 'Normal', 'ta': 'இருப்பில் உள்ளது'},
      {'en': 'Low Stock', 'ta': 'குறைந்த இருப்பு'},
      {'en': 'Out of Stock', 'ta': 'இருப்பு இல்லை'},
      {'en': 'Expiring Soon', 'ta': 'விரைவில் காலாவதி'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = activeFilter == f['en'];
          final label = _InvLoc.t(context, f['en']!, f['ta']!);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(label),
              selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
              checkmarkColor: const Color(0xFF4F46E5),
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (val) {
                if (val) {
                  context.read<InventoryBloc>().add(FilterInventory(f['en']!));
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileItemCard(InventoryItemModel item, bool isUpdating) {
    final bool isSelected = _selectedIds.contains(item.id);
    Color statusColor = Colors.green;
    String statusText = _InvLoc.t(context, 'Normal', 'சரியான இருப்பு');

    if (item.isOutOfStock) {
      statusColor = Colors.red;
      statusText = _InvLoc.t(context, 'Out of Stock', 'இருப்பு தீர்ந்தது');
    } else if (item.isLowStock) {
      statusColor = Colors.orange;
      statusText = _InvLoc.t(context, 'Low Stock', 'குறைந்த இருப்பு');
    }

    if (item.isExpired) {
      statusText = _InvLoc.t(context, 'Expired', 'காலாவதியானது');
      statusColor = Colors.red.shade900;
    } else if (item.isExpiringSoon) {
      statusText = _InvLoc.t(context, 'Expiring Soon', 'விரைவில் காலாவதி');
      statusColor = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          width: 2,
        ),
      ),
      elevation: 0,
      color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (_isBulkMode) {
            _toggleSelection(item.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<InventoryBloc>(),
                  child: ProductDetailsPage(item: item),
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  if (_isBulkMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (val) => _toggleSelection(item.id),
                      activeColor: const Color(0xFF4F46E5),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'SKU: ${item.sku} • Alert Threshold: ${item.lowStockThreshold}',
                          style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (isUpdating)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.quantity.toInt()} ${item.unit}',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (!_isBulkMode) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history_rounded, size: 20, color: Colors.grey),
                      tooltip: _InvLoc.t(context, 'History', 'வரலாறு'),
                      onPressed: () => _showStockHistoryBottomSheet(item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20, color: Colors.grey),
                      tooltip: _InvLoc.t(context, 'Threshold', 'எச்சரிக்கை வரம்பு'),
                      onPressed: () => _showThresholdEditorDialog(item),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                      label: Text(_InvLoc.t(context, 'Adjust Stock', 'இருப்பு மாற்றம்'), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showQuickStockAdjustDialog(item),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideGrid(List<InventoryItemModel> items, Set<String> updatingIds) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 180,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMobileItemCard(item, updatingIds.contains(item.id));
      },
    );
  }
}
