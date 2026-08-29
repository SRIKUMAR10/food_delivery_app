import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/audio_notification_service.dart';
import '../../../repositories/seller_repository.dart';
import '../seller_auth_shared/onboarding_back_handler.dart';
import '../seller_auth_shared/seller_wizard_container.dart';
import '../seller_auth_shared/seller_auth_shared_widgets.dart';
import 'seller_setting_page__bloc.dart';
import 'seller_setting_page__event.dart';
import 'seller_setting_page__state.dart';

/// Step 7: Delivery Logistics & Order Audio Alert Preferences (8-Step Wizard)
class SellerLogisticsAlertsPage extends StatefulWidget {
  final String sellerId;
  final bool isOnboardingFlow;

  const SellerLogisticsAlertsPage({
    super.key,
    required this.sellerId,
    this.isOnboardingFlow = true,
  });

  @override
  State<SellerLogisticsAlertsPage> createState() => _SellerLogisticsAlertsPageState();
}

class _SellerLogisticsAlertsPageState extends State<SellerLogisticsAlertsPage> {
  // Logistics local state
  double _deliveryRadiusKm = 10.0;
  int _estimatedPrepTimeMinutes = 20;
  int _maxConcurrentOrders = 15;
  bool _autoAcceptOrders = false;
  String _dispatchMode = 'broadcast'; // 'broadcast' or 'self'

  // Audio & Notification local state
  bool _pushNotifications = true;
  bool _newOrderSound = true;
  bool _soundLoopUntilAccepted = false;
  String _orderAlertRingtone = 'Bell Chime';
  double _soundVolume = 0.8;
  bool _lowStockAlerts = true;

  late final AudioNotificationService _audioService;
  bool _isPreviewPlaying = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _audioService = AudioNotificationService(
      onRingtoneComplete: () {
        if (mounted) setState(() => _isPreviewPlaying = false);
      },
    );
    _loadExistingSettings();
  }

  Future<void> _loadExistingSettings() async {
    final uid = widget.sellerId.isNotEmpty
        ? widget.sellerId
        : SellerRepository().currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final doc = await SellerRepository().fetchSeller(uid);
      if (mounted) {
        setState(() {
          if (doc.deliveryRadius > 0) {
            _deliveryRadiusKm = doc.deliveryRadius.clamp(1.0, 30.0);
          }
          if (doc.estimatedPrepTimeMinutes > 0) {
            _estimatedPrepTimeMinutes = doc.estimatedPrepTimeMinutes.clamp(5, 90);
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _previewRingtone() async {
    setState(() => _isPreviewPlaying = true);
    await _audioService.playRingtone(
      ringtoneName: _orderAlertRingtone,
      volume: _soundVolume,
    );
  }

  void _stopPreview() {
    setState(() => _isPreviewPlaying = false);
    _audioService.stop();
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    final repo = SellerRepository();
    final uid = widget.sellerId.isNotEmpty
        ? widget.sellerId
        : repo.currentUser?.uid;

    if (uid != null && uid.isNotEmpty) {
      try {
        await repo.updateSellerData(uid, {
          'deliveryRadius': _deliveryRadiusKm,
          'estimatedDeliveryTime': _estimatedPrepTimeMinutes,
          'maxConcurrentOrders': _maxConcurrentOrders,
          'autoAcceptOrders': _autoAcceptOrders,
          'dispatchMode': _dispatchMode,
          'pushNotifications': _pushNotifications,
          'newOrderSound': _newOrderSound,
          'soundLoopUntilAccepted': _soundLoopUntilAccepted,
          'orderAlertRingtone': _orderAlertRingtone,
          'soundVolume': _soundVolume,
          'lowStockAlerts': _lowStockAlerts,
          'isLogisticsCompleted': true,
        });
      } catch (e) {
        debugPrint('Error saving logistics & alerts: $e');
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logistics & Audio settings saved! Moving to Step 8: Store Readiness Checklist.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        '/sellerStoreLaunch',
        arguments: {
          'isOnboardingFlow': true,
          'sellerId': uid ?? '',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isOnboardingFlow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (widget.isOnboardingFlow) {
          await OnboardingBackHandler.handleBack(context, previousRoute: '/sellerPayment');
        }
      },
      child: SellerWizardContainer(
        stepIndex: 7,
        totalSteps: 8,
        stepBadge: 'Step 7 of 8 • Delivery & Audio Alerts',
        title: 'Delivery Logistics & Audio Alerts',
        subtitle: 'Configure order notifications, ringtone chimes, and delivery operational settings',
        onBack: () => OnboardingBackHandler.handleBack(context, previousRoute: '/sellerPayment'),
        bottomAction: SellerWizardPrimaryButton(
          buttonKey: const ValueKey('continue_to_store_launch_btn'),
          label: 'Save & Continue to Store Readiness Checklist',
          isLoading: _isSaving,
          onPressed: _saveAndContinue,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Delivery Logistics Settings Card
            _buildLogisticsCard(),
            const SizedBox(height: 20),

            // 2. Order Audio & Notification Preferences Card
            _buildAudioAlertsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SellerAuthColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delivery_dining_rounded,
                  color: SellerAuthColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Logistics Rules',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Manage radius coverage and automated dispatch limits',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // Delivery Radius Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Radius',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SellerAuthColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_deliveryRadiusKm.toStringAsFixed(1)} km',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: SellerAuthColors.primary),
                ),
              ),
            ],
          ),
          Slider(
            value: _deliveryRadiusKm,
            min: 1.0,
            max: 25.0,
            divisions: 24,
            activeColor: SellerAuthColors.primary,
            inactiveColor: const Color(0xFFE2E8F0),
            onChanged: (val) => setState(() => _deliveryRadiusKm = val),
          ),
          const SizedBox(height: 12),

          // Prep time and concurrent orders
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avg Prep Time',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$_estimatedPrepTimeMinutes mins', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_estimatedPrepTimeMinutes > 5) {
                                    setState(() => _estimatedPrepTimeMinutes -= 5);
                                  }
                                },
                                child: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  if (_estimatedPrepTimeMinutes < 90) {
                                    setState(() => _estimatedPrepTimeMinutes += 5);
                                  }
                                },
                                child: const Icon(Icons.add_circle_outline, size: 20, color: SellerAuthColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Max Orders Capacity',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$_maxConcurrentOrders slots', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_maxConcurrentOrders > 5) {
                                    setState(() => _maxConcurrentOrders -= 5);
                                  }
                                },
                                child: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  if (_maxConcurrentOrders < 50) {
                                    setState(() => _maxConcurrentOrders += 5);
                                  }
                                },
                                child: const Icon(Icons.add_circle_outline, size: 20, color: SellerAuthColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Auto-Accept Orders Switch
          _buildToggleRow(
            title: 'Auto-Accept Incoming Orders',
            subtitle: 'Automatically accept new orders without manual tap confirmation',
            value: _autoAcceptOrders,
            onChanged: (val) => setState(() => _autoAcceptOrders = val),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SellerAuthColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: SellerAuthColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Alert & Chime Preferences',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Customize ringtones, push banners, and sound volume',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          _buildToggleRow(
            title: 'Push Notifications',
            subtitle: 'Receive instant visual alerts when an order arrives',
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          const SizedBox(height: 12),

          _buildToggleRow(
            title: 'New Order Chime Sound',
            subtitle: 'Play chime ringtone alert upon order placement',
            value: _newOrderSound,
            onChanged: (val) => setState(() => _newOrderSound = val),
          ),
          const SizedBox(height: 12),

          _buildToggleRow(
            title: 'Continuous Alert Loop',
            subtitle: 'Repeat ringtone until accepted or dismissed',
            value: _soundLoopUntilAccepted,
            onChanged: (val) => setState(() => _soundLoopUntilAccepted = val),
          ),
          const SizedBox(height: 18),

          // Ringtone Selection & Preview
          Text(
            'Order Alert Ringtone Chime',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _orderAlertRingtone,
                      isExpanded: true,
                      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'Bell Chime', child: Text('Bell Chime (Standard)')),
                        DropdownMenuItem(value: 'Digital Siren', child: Text('Digital Siren (Loud)')),
                        DropdownMenuItem(value: 'Classic Phone Ring', child: Text('Classic Phone Ring')),
                        DropdownMenuItem(value: 'Kitchen Buzzer', child: Text('Kitchen Buzzer')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _orderAlertRingtone = val);
                          _previewRingtone();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isPreviewPlaying ? _stopPreview : _previewRingtone,
                  icon: Icon(_isPreviewPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, size: 18, color: SellerAuthColors.primary),
                  label: Text(_isPreviewPlaying ? 'Stop' : 'Test', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: SellerAuthColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SellerAuthColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Volume Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alert Sound Volume',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
              Text(
                '${(_soundVolume * 100).toInt()}%',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: SellerAuthColors.primary),
              ),
            ],
          ),
          Slider(
            value: _soundVolume,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            activeColor: SellerAuthColors.primary,
            inactiveColor: const Color(0xFFE2E8F0),
            onChanged: (val) => setState(() => _soundVolume = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: SellerAuthColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
