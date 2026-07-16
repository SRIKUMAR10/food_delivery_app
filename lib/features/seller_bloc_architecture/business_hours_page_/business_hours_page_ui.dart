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
                                      'Business Hours',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Set your store opening and closing times',
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
                        if (state is BusinessHoursLoading || state is BusinessHoursInitial)
                          const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))))
                        else if (state is BusinessHoursError)
                          Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: Color(0xFFE52929)))))
                        else if (state is BusinessHoursLoaded)
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _EmergencyCloseToggle(
                                    isEmergencyClosed: state.isEmergencyClosed,
                                    isUpdating: state.isUpdating,
                                  ),
                                  const SizedBox(height: 32),
                                  const Text(
                                    'Weekly Schedule',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
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
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: state.schedule.length,
                                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                      itemBuilder: (context, index) {
                                        return _DayScheduleRow(
                                          day: state.schedule[index],
                                          isUpdating: state.isUpdating,
                                        );
                                      },
                                    ),
                                  ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day.dayOfWeek,
              style: const TextStyle(
                fontSize: 16,
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
                  _TimeBox(time: day.openTime),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-', style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                  _TimeBox(time: day.closeTime),
                ] else
                  const Text(
                    'Closed',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
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
  const _TimeBox({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}
