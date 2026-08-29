import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_category_management_page_bloc.dart';
import 'menu_category_management_page_event.dart';
import 'menu_category_management_page_state.dart';
import 'menu_category_management_page_repository.dart';
import 'menu_category_management_page_service.dart';
import 'menu_category_management_page_model.dart';
import '../../../repositories/seller_repository.dart';
import '../seller_auth_shared/onboarding_back_handler.dart';
import '../seller_auth_shared/seller_wizard_container.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';

class MenuCategoryManagementPage extends StatelessWidget {
  final String sellerId;
  final bool isOnboardingFlow;
  const MenuCategoryManagementPage({
    Key? key,
    required this.sellerId,
    this.isOnboardingFlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuCategoryManagementBloc(
        repository: MenuCategoryManagementRepository(service: MenuCategoryManagementService()),
      )..add(LoadMenuCategoriesEvent(sellerId)),
      child: MenuCategoryManagementView(sellerId: sellerId, isOnboardingFlow: isOnboardingFlow),
    );
  }
}

class MenuCategoryManagementView extends StatelessWidget {
  final String sellerId;
  final bool isOnboardingFlow;
  const MenuCategoryManagementView({
    Key? key,
    required this.sellerId,
    this.isOnboardingFlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isOnboardingFlow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (isOnboardingFlow) {
          await OnboardingBackHandler.handleBack(context, previousRoute: '/sellerProfile');
        }
      },
      child: BlocConsumer<MenuCategoryManagementBloc, MenuCategoryManagementState>(
        listener: (context, state) {
          if (state is MenuCategoryManagementLoaded) {
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
        builder: (context, state) {
          if (isOnboardingFlow) {
            return SellerWizardContainer(
              stepIndex: 5,
              totalSteps: 8,
              stepBadge: 'Step 5 of 8 • Menu Categories',
              title: 'Menu Categories & Catalogue',
              subtitle: 'Select active food categories and configure your menu offerings',
              onBack: () => OnboardingBackHandler.handleBack(context, previousRoute: '/sellerProfile'),
              bottomAction: state is MenuCategoryManagementLoaded
                  ? SellerWizardPrimaryButton(
                      buttonKey: const ValueKey('continue_to_bank_setup_btn'),
                      label: 'Save & Continue to Bank & Payouts',
                      onPressed: () async {
                        final hasSelectedCategory = state.categories.any((c) => c.isSelected);
                        if (!hasSelectedCategory) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least 1 menu category for your store before proceeding.'),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (state.hasUnsavedChanges) {
                          context.read<MenuCategoryManagementBloc>().add(SaveCategoryPreferencesEvent(sellerId));
                        }
                        final repo = SellerRepository();
                        final uid = sellerId.isNotEmpty ? sellerId : repo.currentUser?.uid;
                        if (uid != null && uid.isNotEmpty) {
                          try {
                            await repo.updateSellerData(uid, {'isMenuSetupCompleted': true});
                          } catch (_) {}
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Categories saved! Moving to Step 6: Bank & Payout Setup.'),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            '/sellerPayment',
                            arguments: {'isOnboardingFlow': true},
                          );
                        }
                      },
                    )
                  : null,
              child: _buildCategoryList(context, state),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                                  onPressed: () => Navigator.of(context).pop(),
                                  color: const Color(0xFF111827),
                                  tooltip: 'Back',
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Manage Categories',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Select and reorder your menu categories',
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
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              child: _buildCategoryList(context, state),
                            ),
                          ),
                          if (state is MenuCategoryManagementLoaded)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: (!state.hasUnsavedChanges || state.isSaving)
                                      ? null
                                      : () {
                                          context.read<MenuCategoryManagementBloc>().add(SaveCategoryPreferencesEvent(sellerId));
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SellerAuthColors.primary,
                                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: state.isSaving
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Save Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, MenuCategoryManagementState state) {
    if (state is MenuCategoryManagementLoading || state is MenuCategoryManagementInitial) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: SellerAuthColors.primary)));
    } else if (state is MenuCategoryManagementError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Color(0xFFE52929))));
    } else if (state is MenuCategoryManagementLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Select the categories that apply to your shop. Drag and drop to reorder how they appear to customers.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return _CategoryListItem(
                  key: ValueKey(cat.id),
                  category: cat,
                  index: index,
                );
              },
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _CategoryListItem extends StatelessWidget {
  final MenuCategoryModel category;
  final int index;
  
  const _CategoryListItem({
    Key? key,
    required this.category,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), 
          width: category.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: category.isSelected 
                ? const Color(0xFF3B82F6).withValues(alpha: 0.08)
                : const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: category.isSelected,
              activeColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) {
                if (val != null) {
                  context.read<MenuCategoryManagementBloc>().add(
                    ToggleCategorySelectionEvent(category.id, val),
                  );
                }
              },
            ),
            const SizedBox(width: 4),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: category.isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: category.isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category.displayEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: category.isSelected ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          category.isSelected ? 'Active in store' : 'Disabled',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: category.isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          ),
        ),
        trailing: ReorderableDragStartListener(
          index: index,
          child: const MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.drag_indicator,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
