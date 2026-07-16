import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_category_management_page_bloc.dart';
import 'menu_category_management_page_event.dart';
import 'menu_category_management_page_state.dart';
import 'menu_category_management_page_repository.dart';
import 'menu_category_management_page_service.dart';
import 'menu_category_management_page_model.dart';

class MenuCategoryManagementPage extends StatelessWidget {
  final String sellerId;
  const MenuCategoryManagementPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuCategoryManagementBloc(
        repository: MenuCategoryManagementRepository(service: MenuCategoryManagementService()),
      )..add(LoadMenuCategoriesEvent(sellerId)),
      child: MenuCategoryManagementView(sellerId: sellerId), // Renamed properly
    );
  }
}

class MenuCategoryManagementView extends StatelessWidget {
  final String sellerId;
  const MenuCategoryManagementView({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
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
            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Manage Categories',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Select and reorder your menu categories',
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
                        ),
                        if (state is MenuCategoryManagementLoading || state is MenuCategoryManagementInitial)
                          const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))))
                        else if (state is MenuCategoryManagementError)
                          Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: Color(0xFFE52929)))))
                        else if (state is MenuCategoryManagementLoaded) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text(
                              'Select the categories that apply to your shop. Drag and drop to reorder how they appear to customers.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: ReorderableListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: state.categories.length,
                                onReorder: (oldIndex, newIndex) {
                                  context.read<MenuCategoryManagementBloc>().add(
                                        ReorderCategoriesEvent(oldIndex, newIndex),
                                      );
                                },
                                itemBuilder: (context, index) {
                                  final cat = state.categories[index];
                                  return _CategoryListItem(
                                    key: ValueKey(cat.id),
                                    category: cat,
                                  );
                                },
                              ),
                            ),
                          ),
                          SafeArea(
                            child: Padding(
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
                                    backgroundColor: const Color(0xFF3B82F6),
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
                          ),
                        ] else
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

class _CategoryListItem extends StatelessWidget {
  final MenuCategoryModel category;
  
  const _CategoryListItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFF1F5F9), 
          width: 2
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
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
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: category.isSelected ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
        trailing: const Icon(Icons.drag_indicator, color: Color(0xFFCBD5E1)),
      ),
    );
  }
}
