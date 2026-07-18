import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/inventory_item_model.dart';
import 'inventory_low_stock_page_bloc.dart';
import 'inventory_low_stock_page_event.dart';
import 'inventory_low_stock_page_state.dart';
import '../../../../core/repositories/i_inventory_repository.dart';
import 'product_details_page_ui.dart';

class InventoryLowStockPage extends StatelessWidget {
  const InventoryLowStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryBloc(
        repository: context.read<IInventoryRepository>(),
      )..add(LoadInventoryStream(sellerId: FirebaseAuth.instance.currentUser?.uid ?? 'test_seller_id')),
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
  Set<String> _selectedIds = {};
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

  void _showBulkUpdateDialog() {
    if (_selectedIds.isEmpty) return;
    
    double quantityChange = 0;
    String reason = 'Supplier Restock';
    final List<String> reasons = ['Supplier Restock', 'Wastage', 'Damaged', 'Expired', 'Manual Adjustment'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Bulk Update ${_selectedIds.length} Items', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setStateDialog(() => quantityChange -= 1),
                      ),
                      Text(quantityChange.toInt().toString(), style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setStateDialog(() => quantityChange += 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setStateDialog(() => reason = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(
                      BulkUpdateStockEvent(
                        productIds: _selectedIds.toList(),
                        quantityChange: quantityChange,
                        reason: reason,
                      )
                    );
                    Navigator.pop(ctx);
                    _toggleBulkMode();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  child: Text('Apply Update', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is InventoryLoaded) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green));
            context.read<InventoryBloc>().add(ClearInventoryMessage());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red));
            context.read<InventoryBloc>().add(ClearInventoryMessage());
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InventoryLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(state.summary),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Products', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: _toggleBulkMode,
                            child: Text(_isBulkMode ? 'Cancel Bulk' : 'Select Multiple', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF4F46E5))),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.filteredItems.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.all(32), child: Text("No items found.")))
                      else
                        ...state.filteredItems.map((item) => _buildItemCard(context, item, state.updatingItemIds.contains(item.id))),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        floatingActionButton: _isBulkMode && _selectedIds.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _showBulkUpdateDialog,
                backgroundColor: const Color(0xFF4F46E5),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text('Update ${_selectedIds.length} items', style: const TextStyle(color: Colors.white)),
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
              decoration: const InputDecoration(hintText: 'Search products...', border: InputBorder.none),
            )
          : Text('Inventory Management', style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold)),
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
        BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onSelected: (val) => context.read<InventoryBloc>().add(FilterInventory(val)),
              itemBuilder: (context) => ['All', 'Normal', 'Low Stock', 'Out of Stock', 'Expiring Soon'].map((f) {
                return PopupMenuItem(value: f, child: Text(f));
              }).toList(),
            );
          }
        )
      ],
    );
  }

  Widget _buildSummaryCards(InventorySummary summary) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _summaryCard('Total', summary.totalItems, Colors.blue),
          _summaryCard('Normal', summary.normalStock, Colors.green),
          _summaryCard('Low Stock', summary.lowStock, Colors.orange),
          _summaryCard('Out of Stock', summary.outOfStock, Colors.red),
          if (summary.expiringSoon > 0) _summaryCard('Expiring', summary.expiringSoon, Colors.purple),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(count.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, InventoryItemModel item, bool isUpdating) {
    final bool isSelected = _selectedIds.contains(item.id);
    Color statusColor = Colors.green;
    String statusText = 'Normal';
    
    if (item.isOutOfStock) {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
    } else if (item.isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
    }

    if (item.isExpired) {
      statusText = 'Expired';
      statusColor = Colors.red.shade900;
    } else if (item.isExpiringSoon) {
      statusText = 'Expiring Soon';
      statusColor = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2)
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
              MaterialPageRoute(builder: (_) => BlocProvider.value(
                value: context.read<InventoryBloc>(),
                child: ProductDetailsPage(item: item),
              )),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                    Text(item.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('SKU: ${item.sku}', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              if (isUpdating)
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${item.quantity.toInt()} ${item.unit}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText, style: GoogleFonts.plusJakartaSans(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
