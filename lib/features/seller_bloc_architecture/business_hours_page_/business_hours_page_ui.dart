import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'business_hours_page_bloc.dart';
import 'business_hours_page_event.dart';
import 'business_hours_page_state.dart';
import 'business_hours_page_repository.dart';
import 'business_hours_page_service.dart';
import 'business_hours_page_model.dart';

class BusinessHoursPage extends StatelessWidget {
  final String sellerId;
  const BusinessHoursPage({Key? key, required this.sellerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessHoursBloc(
        repository: BusinessHoursRepository(service: BusinessHoursService()),
      )..add(LoadBusinessHoursEvent(sellerId)),
      child: const BusinessHoursView(),
    );
  }
}

class BusinessHoursView extends StatelessWidget {
  const BusinessHoursView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocConsumer<BusinessHoursBloc, BusinessHoursState>(
          listener: (context, state) {
            if (state is BusinessHoursLoaded) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: const Color(0xFFE52929),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage!),
                    backgroundColor: const Color(0xFF22C55E),
                    behavior: SnackBarBehavior.floating,
                  ),
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
                                      'Business Hours',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Set your store opening and closing times',
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
                        if (state is BusinessHoursLoading || state is BusinessHoursInitial)
                          const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))))
                        else if (state is BusinessHoursError)
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFE52929)),
                                    const SizedBox(height: 12),
                                    Text(
                                      state.message,
                                      style: const TextStyle(color: Color(0xFFE52929), fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (state is BusinessHoursLoaded)
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _EmergencyCloseToggle(
                                    isEmergencyClosed: state.isEmergencyClosed,
                                    isUpdating: state.isUpdating,
                                  ),
                                  const SizedBox(height: 28),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        'Weekly Schedule',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        'Tap time to edit',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
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
                                    child: state.schedule.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(32.0),
                                            child: Center(
                                              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                                            ),
                                          )
                                        : ListView.separated(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: state.schedule.length,
                                            separatorBuilder: (context, index) =>
                                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                            itemBuilder: (context, index) {
                                              return _DayScheduleRow(
                                                day: state.schedule[index],
                                                isUpdating: state.isUpdating,
                                              );
                                            },
                                          ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
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

class _EmergencyCloseToggle extends StatelessWidget {
  final bool isEmergencyClosed;
  final bool isUpdating;

  const _EmergencyCloseToggle({required this.isEmergencyClosed, required this.isUpdating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEmergencyClosed 
              ? [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)]
              : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmergencyClosed ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEmergencyClosed ? 'Store Temporarily Closed' : 'Store is Open',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEmergencyClosed ? const Color(0xFF991B1B) : const Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEmergencyClosed 
                      ? 'Customers cannot place new orders right now.' 
                      : 'You are currently accepting new orders.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isEmergencyClosed ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
          if (isUpdating)
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Switch(
              value: !isEmergencyClosed,
              activeThumbColor: const Color(0xFF22C55E),
              inactiveThumbColor: const Color(0xFFEF4444),
              onChanged: (val) {
                context.read<BusinessHoursBloc>().add(ToggleEmergencyCloseEvent(!val));
              },
            ),
        ],
      ),
    );
  }
}

class _DayScheduleRow extends StatelessWidget {
  final BusinessDayModel day;
  final bool isUpdating;

  const _DayScheduleRow({required this.day, required this.isUpdating});

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      if (parts.isEmpty) return const TimeOfDay(hour: 9, minute: 0);
      final timeParts = parts[0].split(':');
      int hour = int.tryParse(timeParts[0]) ?? 9;
      final minute = timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;
      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hourOfPeriod.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickTime(BuildContext context, bool isOpenTime) async {
    if (isUpdating || !day.isOpen) return;

    final initialTime = _parseTimeString(isOpenTime ? day.openTime : day.closeTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (pickerContext, child) {
        return Theme(
          data: Theme.of(pickerContext).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null && context.mounted) {
      final formatted = _formatTimeOfDay(picked);
      final updatedDay = isOpenTime
          ? day.copyWith(openTime: formatted)
          : day.copyWith(closeTime: formatted);
      context.read<BusinessHoursBloc>().add(UpdateBusinessDayEvent(updatedDay));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              day.dayOfWeek,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (day.isOpen) ...[
                  _TimeBox(
                    time: day.openTime,
                    label: 'opening time',
                    isInteractive: !isUpdating,
                    onTap: () => _pickTime(context, true),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('–', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                  ),
                  _TimeBox(
                    time: day.closeTime,
                    label: 'closing time',
                    isInteractive: !isUpdating,
                    onTap: () => _pickTime(context, false),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Text(
                      'Closed',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: day.isOpen,
            activeThumbColor: const Color(0xFF3B82F6),
            onChanged: isUpdating ? null : (val) {
              final updatedDay = day.copyWith(isOpen: val);
              context.read<BusinessHoursBloc>().add(UpdateBusinessDayEvent(updatedDay));
            },
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String time;
  final String label;
  final VoidCallback? onTap;
  final bool isInteractive;

  const _TimeBox({
    required this.time,
    required this.label,
    this.onTap,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isInteractive ? 'Click to change $label' : time,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isInteractive ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

