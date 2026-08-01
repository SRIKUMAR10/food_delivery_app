import 'package:flutter/material.dart';
import '../theme/delivery_app_colors.dart';

/// Item model representing a navigation sidebar item
class DeliverySidebarItemData {
  final String id;
  final String label;
  final IconData icon;
  final int badgeCount;

  const DeliverySidebarItemData({
    required this.id,
    required this.label,
    required this.icon,
    this.badgeCount = 0,
  });
}

/// Centralized responsive navigation sidebar component for Delivery Partner module.
class DeliverySidebar extends StatelessWidget {
  final String partnerName;
  final String partnerId;
  final bool isOffline;
  final int selectedIndex;
  final List<DeliverySidebarItemData> items;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onToggleOnline;

  const DeliverySidebar({
    super.key,
    this.partnerName = 'Delivery Partner',
    this.partnerId = 'ID: #DP-8842',
    this.isOffline = false,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
    this.onToggleOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DeliveryAppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.two_wheeler,
                        color: DeliveryAppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FOOD EXPRESS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            'Delivery Console',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF334155),
                        child: Icon(Icons.person, color: Colors.white70, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partnerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isOffline ? 'Offline' : 'Online',
                              style: TextStyle(
                                color: isOffline
                                    ? DeliveryAppColors.error
                                    : DeliveryAppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: isSelected
                          ? DeliveryAppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      leading: Icon(
                        item.icon,
                        color: isSelected
                            ? DeliveryAppColors.primary
                            : Colors.white60,
                        size: 20,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: item.badgeCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: DeliveryAppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.badgeCount}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () => onItemSelected(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
