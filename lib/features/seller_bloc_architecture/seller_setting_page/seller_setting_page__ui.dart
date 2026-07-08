import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'seller_setting_page__bloc.dart';
import 'seller_setting_page__event.dart';
import 'seller_setting_page__state.dart';

class SellerSettingPage extends StatelessWidget {
  const SellerSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold for Settings page
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocBuilder<SellerSettingBloc, SellerSettingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Settings'),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    value: state.pushNotifications,
                    onChanged: (val) {
                      context.read<SellerSettingBloc>().add(
                        UpdatePushNotifications(val),
                      );
                    },
                  ),
                  _buildSwitchTile(
                    title: 'New Order Sound',
                    value: state.newOrderSound,
                    onChanged: (val) {
                      context.read<SellerSettingBloc>().add(
                        UpdateNewOrderSound(val),
                      );
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Promo & Offers',
                    value: state.promoAndOffers,
                    onChanged: (val) {
                      context.read<SellerSettingBloc>().add(
                        UpdatePromoAndOffers(val),
                      );
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Low Stock Alerts',
                    value: state.lowStockAlerts,
                    onChanged: (val) {
                      context.read<SellerSettingBloc>().add(
                        UpdateLowStockAlerts(val),
                      );
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Order Updates',
                    value: state.orderUpdates,
                    onChanged: (val) {
                      context.read<SellerSettingBloc>().add(
                        UpdateOrderUpdates(val),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('App Theme'),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: state.appTheme,
                    items: const ['Light', 'Dark', 'System Default'],
                    onChanged: (val) {
                      if (val != null) {
                        context.read<SellerSettingBloc>().add(
                          UpdateAppTheme(val),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Language'),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: state.language,
                    items: const ['English', 'Tamil', 'Spanish', 'French'],
                    onChanged: (val) {
                      if (val != null) {
                        context.read<SellerSettingBloc>().add(
                          UpdateLanguage(val),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2C3241),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF20C976),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A5568)),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
