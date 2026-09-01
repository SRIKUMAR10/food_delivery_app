import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/core/services/bank_ifsc_service.dart';
import 'package:food_delivery_app/core/theme/delivery_app_colors.dart';

enum _IfscSearchTab { search, branchFinder, popularBanks }

/// Interactive Indian Bank & IFSC Code Search dialog / bottom sheet
/// designed specifically for the Delivery Partner onboarding workflow.
/// Conforms to Delivery Partner dark theme tokens (DeliveryAppColors).
class DeliveryBankIfscSearchDialog extends StatefulWidget {
  final BankIfscService? ifscService;
  final String? initialQuery;
  final ValueChanged<BankBranchInfo>? onBankSelected;

  const DeliveryBankIfscSearchDialog({
    super.key,
    this.ifscService,
    this.initialQuery,
    this.onBankSelected,
  });

  /// Displays the search modal responsively on Mobile, Web, or Desktop.
  static Future<BankBranchInfo?> show({
    required BuildContext context,
    BankIfscService? ifscService,
    String? initialQuery,
    ValueChanged<BankBranchInfo>? onBankSelected,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    if (isDesktop) {
      return showDialog<BankBranchInfo>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: DeliveryAppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
            child: DeliveryBankIfscSearchDialog(
              ifscService: ifscService,
              initialQuery: initialQuery,
              onBankSelected: onBankSelected,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<BankBranchInfo>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.90,
            decoration: const BoxDecoration(
              color: DeliveryAppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: DeliveryBankIfscSearchDialog(
              ifscService: ifscService,
              initialQuery: initialQuery,
              onBankSelected: onBankSelected,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<DeliveryBankIfscSearchDialog> createState() =>
      _DeliveryBankIfscSearchDialogState();
}

class _DeliveryBankIfscSearchDialogState
    extends State<DeliveryBankIfscSearchDialog>
    with SingleTickerProviderStateMixin {
  late final BankIfscService _ifscService;
  final TextEditingController _searchController = TextEditingController();
  _IfscSearchTab _activeTab = _IfscSearchTab.search;
  Timer? _debounceTimer;

  // Search tab state
  List<BankBranchInfo> _searchResults = [];
  bool _isSearching = false;
  bool _isLiveLookingUp = false;
  BankBranchInfo? _liveLookupResult;
  String? _lookupErrorMessage;

  // Branch Finder tab state
  String? _selectedBank;
  String? _selectedState;
  String? _selectedCity;
  BankBranchInfo? _selectedBranch;

  List<String> _availableStates = [];
  List<String> _availableCities = [];
  List<BankBranchInfo> _availableBranches = [];

  @override
  void initState() {
    super.initState();
    _ifscService = widget.ifscService ?? BankIfscService.instance;

    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _searchController.text = initial;
      _performSearch(initial);
    } else {
      _searchResults = _ifscService.searchBanks('');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    setState(() {
      _isSearching = true;
      _liveLookupResult = null;
      _lookupErrorMessage = null;
    });

    final results = _ifscService.searchBanks(q);

    // If the query looks like a specific 11-char IFSC code, trigger live lookup
    if (BankIfscService.isValidIfscFormat(q)) {
      _triggerLiveIfscLookup(q);
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _triggerLiveIfscLookup(String ifscCode) async {
    setState(() {
      _isLiveLookingUp = true;
      _lookupErrorMessage = null;
    });

    try {
      final info = await _ifscService.lookupIfsc(ifscCode);
      if (mounted) {
        setState(() {
          _liveLookupResult = info;
          _isLiveLookingUp = false;
          if (info == null) {
            _lookupErrorMessage = 'IFSC not found. Please verify the code.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiveLookingUp = false;
          _lookupErrorMessage = 'Unable to verify IFSC right now. Please try again.';
        });
      }
    }
  }

  void _selectAndReturn(BankBranchInfo info) {
    widget.onBankSelected?.call(info);
    Navigator.of(context).pop(info);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHandleAndHeader(),
        _buildTabBar(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildCurrentTabContent(),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Header & Tab Bar
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildHandleAndHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      decoration: const BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: DeliveryAppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: DeliveryAppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank & IFSC Finder',
                      style: TextStyle(
                        color: DeliveryAppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Search 150,000+ branches or find via Bank & City',
                      style: TextStyle(
                        color: DeliveryAppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: DeliveryAppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: DeliveryAppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: DeliveryAppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DeliveryAppColors.border),
        ),
        child: Row(
          children: [
            _buildTabItem(
              title: 'Quick Search',
              icon: Icons.search_rounded,
              tab: _IfscSearchTab.search,
            ),
            _buildTabItem(
              title: 'Branch Finder',
              icon: Icons.alt_route_rounded,
              tab: _IfscSearchTab.branchFinder,
            ),
            _buildTabItem(
              title: 'Popular Banks',
              icon: Icons.verified_rounded,
              tab: _IfscSearchTab.popularBanks,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required IconData icon,
    required _IfscSearchTab tab,
  }) {
    final isSelected = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = tab;
            if (tab == _IfscSearchTab.branchFinder && _selectedBank == null) {
              _selectedBank = 'State Bank of India';
              _updateBranchFinderStates();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? DeliveryAppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? DeliveryAppColors.buttonPrimaryText
                    : DeliveryAppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? DeliveryAppColors.buttonPrimaryText
                        : DeliveryAppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_activeTab) {
      case _IfscSearchTab.search:
        return _buildSearchTab();
      case _IfscSearchTab.branchFinder:
        return _buildBranchFinderTab();
      case _IfscSearchTab.popularBanks:
        return _buildPopularBanksTab();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: Quick Search
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search Input Field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: DeliveryAppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DeliveryAppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: const TextStyle(
                color: DeliveryAppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: _onSearchChanged,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Search IFSC (e.g. SBIN0001234) or Bank / City...',
                hintStyle: TextStyle(
                  color: DeliveryAppColors.textSecondary.withOpacity(0.5),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                icon: const Icon(
                  Icons.search_rounded,
                  color: DeliveryAppColors.primary,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            size: 18, color: DeliveryAppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),

        // Live Lookup Alert if user typed full IFSC code
        if (_isLiveLookingUp)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DeliveryAppColors.infoBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DeliveryAppColors.infoBorder),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(DeliveryAppColors.info),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Verifying IFSC with Official Banking Directory...',
                      style: TextStyle(
                          color: DeliveryAppColors.info, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (_liveLookupResult != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _buildLiveLookupBanner(_liveLookupResult!),
          ),

        if (_lookupErrorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DeliveryAppColors.errorBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DeliveryAppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: DeliveryAppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _lookupErrorMessage!,
                      style: const TextStyle(
                          color: DeliveryAppColors.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Search Results List
        Expanded(
          child: _isSearching
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(DeliveryAppColors.primary),
                  ),
                )
              : _searchResults.isEmpty
                  ? _buildEmptySearchState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final item = _searchResults[index];
                        return _buildBankBranchCard(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLiveLookupBanner(BankBranchInfo info) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DeliveryAppColors.successBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DeliveryAppColors.successBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: DeliveryAppColors.success, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Live Verified Bank Branch',
                style: TextStyle(
                  color: DeliveryAppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _selectAndReturn(info),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeliveryAppColors.primary,
                  foregroundColor: DeliveryAppColors.buttonPrimaryText,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Select',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${info.bankName} - ${info.branch}',
            style: const TextStyle(
              color: DeliveryAppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'IFSC: ${info.ifsc} • ${info.city}, ${info.state}',
            style: const TextStyle(
              color: DeliveryAppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankBranchCard(BankBranchInfo item) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DeliveryAppColors.border),
      ),
      child: InkWell(
        onTap: () => _selectAndReturn(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Icon / Initial
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DeliveryAppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DeliveryAppColors.borderSubtle),
                ),
                child: Center(
                  child: Text(
                    item.bankName.isNotEmpty
                        ? item.bankName.substring(0, 1).toUpperCase()
                        : 'B',
                    style: const TextStyle(
                      color: DeliveryAppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Bank & Branch Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.bankName,
                            style: const TextStyle(
                              color: DeliveryAppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: DeliveryAppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color:
                                    DeliveryAppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            item.ifsc,
                            style: const TextStyle(
                              color: DeliveryAppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.branch} Branch • ${item.city}, ${item.state}',
                      style: const TextStyle(
                        color: DeliveryAppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.address.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              DeliveryAppColors.textSecondary.withOpacity(0.65),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.upi) _buildFeatureBadge('UPI Payouts'),
                        if (item.imps) _buildFeatureBadge('IMPS Instant'),
                        if (item.neft) _buildFeatureBadge('NEFT'),
                        if (item.rtgs) _buildFeatureBadge('RTGS'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: DeliveryAppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: DeliveryAppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DeliveryAppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: DeliveryAppColors.border),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: DeliveryAppColors.textSecondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Matching Bank Branches Found',
              style: TextStyle(
                color: DeliveryAppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching with bank name (e.g. SBI, HDFC),\ncity (e.g. Chennai), or 11-digit IFSC code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DeliveryAppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _activeTab = _IfscSearchTab.branchFinder;
                  _selectedBank = 'State Bank of India';
                  _updateBranchFinderStates();
                });
              },
              icon: const Icon(Icons.alt_route_rounded, size: 16),
              label: const Text('Use Step-by-Step Branch Finder'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DeliveryAppColors.primary,
                side: const BorderSide(color: DeliveryAppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: Progressive Branch Finder (Bank -> State -> City -> Branch)
  // ───────────────────────────────────────────────────────────────────────────

  void _updateBranchFinderStates() {
    if (_selectedBank == null) return;
    _availableStates = _ifscService.getStatesForBank(_selectedBank!);
    _selectedState = _availableStates.isNotEmpty ? _availableStates.first : null;
    _updateBranchFinderCities();
  }

  void _updateBranchFinderCities() {
    if (_selectedBank == null || _selectedState == null) return;
    _availableCities =
        _ifscService.getCitiesForBankAndState(_selectedBank!, _selectedState!);
    _selectedCity = _availableCities.isNotEmpty ? _availableCities.first : null;
    _updateBranchFinderBranches();
  }

  void _updateBranchFinderBranches() {
    if (_selectedBank == null) return;
    _availableBranches = _ifscService.getBranches(
      _selectedBank!,
      _selectedState ?? '',
      _selectedCity ?? '',
    );
    _selectedBranch =
        _availableBranches.isNotEmpty ? _availableBranches.first : null;
  }

  Widget _buildBranchFinderTab() {
    final supportedBanks = _ifscService.getSupportedBanks();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Bank & Branch Details',
            style: TextStyle(
              color: DeliveryAppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Follow the steps below to find your branch and auto-generate IFSC.',
            style: TextStyle(
              color: DeliveryAppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Select Bank
          _buildSelectorLabel('1. Bank Name'),
          _buildDropdownContainer(
            value: _selectedBank,
            items: supportedBanks.map((b) => b.name).toList(),
            hint: 'Choose Bank',
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedBank = val;
                  _updateBranchFinderStates();
                });
              }
            },
          ),
          const SizedBox(height: 14),

          // 2. Select State
          _buildSelectorLabel('2. State'),
          _buildDropdownContainer(
            value: _selectedState,
            items: _availableStates,
            hint: 'Choose State',
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedState = val;
                  _updateBranchFinderCities();
                });
              }
            },
          ),
          const SizedBox(height: 14),

          // 3. Select City
          _buildSelectorLabel('3. City / District'),
          _buildDropdownContainer(
            value: _selectedCity,
            items: _availableCities,
            hint: 'Choose City',
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedCity = val;
                  _updateBranchFinderBranches();
                });
              }
            },
          ),
          const SizedBox(height: 14),

          // 4. Select Branch
          _buildSelectorLabel('4. Branch'),
          if (_availableBranches.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DeliveryAppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DeliveryAppColors.border),
              ),
              child: const Text(
                'No branches listed for this location in offline index. Try Quick Search tab for online lookup.',
                style: TextStyle(
                    color: DeliveryAppColors.textSecondary, fontSize: 12),
              ),
            )
          else
            _buildDropdownContainer(
              value: _selectedBranch?.branch,
              items: _availableBranches.map((b) => b.branch).toList(),
              hint: 'Choose Branch',
              onChanged: (branchName) {
                if (branchName != null) {
                  final found = _availableBranches.firstWhere(
                    (b) => b.branch == branchName,
                    orElse: () => _availableBranches.first,
                  );
                  setState(() {
                    _selectedBranch = found;
                  });
                }
              },
            ),
          const SizedBox(height: 20),

          // Branch Details Result Card
          if (_selectedBranch != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DeliveryAppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: DeliveryAppColors.primary.withOpacity(0.5),
                    width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: DeliveryAppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedBranch!.bankName,
                        style: const TextStyle(
                          color: DeliveryAppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('IFSC Code', _selectedBranch!.ifsc,
                      isHighlighted: true),
                  _buildDetailRow('Branch', _selectedBranch!.branch),
                  _buildDetailRow('City / State',
                      '${_selectedBranch!.city}, ${_selectedBranch!.state}'),
                  if (_selectedBranch!.address.isNotEmpty)
                    _buildDetailRow('Address', _selectedBranch!.address),
                  if (_selectedBranch!.micr.isNotEmpty)
                    _buildDetailRow('MICR Code', _selectedBranch!.micr),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _selectAndReturn(_selectedBranch!),
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: const Text('Apply This Bank & IFSC Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DeliveryAppColors.primary,
                        foregroundColor: DeliveryAppColors.buttonPrimaryText,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectorLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: DeliveryAppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DeliveryAppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DeliveryAppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint,
              style: TextStyle(
                  color: DeliveryAppColors.textSecondary.withOpacity(0.5),
                  fontSize: 13)),
          isExpanded: true,
          dropdownColor: DeliveryAppColors.surfaceElevated,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: DeliveryAppColors.primary),
          style: const TextStyle(
              color: DeliveryAppColors.textPrimary, fontSize: 13),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: DeliveryAppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isHighlighted
                    ? DeliveryAppColors.primary
                    : DeliveryAppColors.textPrimary,
                fontSize: isHighlighted ? 14 : 12,
                fontWeight:
                    isHighlighted ? FontWeight.w800 : FontWeight.w500,
                fontFamily: isHighlighted ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: Popular Banks
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildPopularBanksTab() {
    final popularBanks = _ifscService.getPopularBanks();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: popularBanks.length,
      itemBuilder: (ctx, index) {
        final bank = popularBanks[index];
        return Container(
          decoration: BoxDecoration(
            color: DeliveryAppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DeliveryAppColors.border),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _searchController.text = bank.name;
                _activeTab = _IfscSearchTab.search;
                _performSearch(bank.name);
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DeliveryAppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          bank.shortName.length > 4
                              ? bank.shortName.substring(0, 4)
                              : bank.shortName,
                          style: const TextStyle(
                            color: DeliveryAppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 13, color: DeliveryAppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bank.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DeliveryAppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
