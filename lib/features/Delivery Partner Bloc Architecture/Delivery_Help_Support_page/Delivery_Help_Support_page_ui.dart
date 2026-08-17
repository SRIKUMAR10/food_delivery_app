import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Delivery_Help_Support_page_bloc.dart';
import 'Delivery_Help_Support_page_event.dart';
import 'Delivery_Help_Support_page_repository.dart';
import 'Delivery_Help_Support_page_service.dart';
import 'Delivery_Help_Support_page_state.dart';
import '../../../core/theme/delivery_design_system.dart';

class DeliveryHelpSupportStrings {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Help & Support',
      'tagline':
          'Get emergency assistance, track support tickets and browse FAQs.',
      'emergencyTitle': 'Emergency Assistance',
      'emergencySub':
          'On-duty partner? Call our SOS hotline for road emergencies or order disputes.',
      'hotline': '1800 123 4567',
      'callNow': 'Call Now',
      'orderDispute': 'Order Dispute',
      'statsTotal': 'Total Tickets',
      'statsOpen': 'Open',
      'statsResolved': 'Resolved',
      'createTicket': 'Create Support Ticket',
      'createTicketTitle': 'New Support Ticket',
      'createTicketSub':
          'Tell us what went wrong and our partner support team will follow up.',
      'subject': 'Subject',
      'subjectHint': 'e.g. Payment not received for order',
      'category': 'Category',
      'priority': 'Priority',
      'description': 'Description',
      'descriptionHint': 'Describe the issue in detail...',
      'orderId': 'Order ID (optional)',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'liveTickets': 'Live Support Tickets',
      'liveTicketsSub': 'Real-time updates from our support team.',
      'noTickets': 'No support tickets yet',
      'noTicketsSub': 'Create a ticket and track it here in real time.',
      'noFilteredTickets': 'No tickets match the selected filter.',
      'all': 'All',
      'open': 'Open',
      'inProgress': 'In Progress',
      'resolved': 'Resolved',
      'escalated': 'Escalated',
      'ticketId': 'Ticket',
      'lastResponse': 'Last response',
      'noResponseYet': 'Awaiting first response from support.',
      'faqTitle': 'Frequently Asked Questions',
      'faqSub': 'Search or filter topics to find instant answers.',
      'searchPlaceholder': 'Search FAQs...',
      'feedbackTitle': 'Support Feedback',
      'feedbackSub': 'Rate how our support team resolved your issue.',
      'rateYourExperience': 'Tap a star to rate your experience',
      'feedbackCommentHint': 'Anything you would like us to know?',
      'sendFeedback': 'Send Feedback',
      'feedbackThanks': 'Thank you for your feedback!',
      'retry': 'Retry',
      'somethingWentWrong': 'Something went wrong while loading help & support.',
      'quickIssues': 'Quick Issue Reporting',
      'reportOrderIssue': 'Report Order Issue',
      'reportPaymentIssue': 'Report Payment Issue',
      'reportRestaurantIssue': 'Report Restaurant Issue',
      'reportCustomerIssue': 'Report Customer Issue',
      'emergencyContact': 'Emergency SOS',
    },
    'ta': {
      'title': 'உதவி & ஆதரவு',
      'tagline':
          'அவசர உதவி பெறுங்கள், சப்போர்ட் டிக்கெட்டுகளை கண்காணிக்கவும், FAQ-ஐ பார்க்கவும்.',
      'emergencyTitle': 'அவசர உதவி',
      'emergencySub':
          'பணியில் உள்ள பார்ட்னரா? சாலை அவசரம் அல்லது ஆர்டர் சிக்கல்களுக்கு எங்கள் SOS ஹாட்லைனை அழைக்கவும்.',
      'hotline': '1800 123 4567',
      'callNow': 'இப்போது அழைக்கவும்',
      'orderDispute': 'ஆர்டர் சர்ச்சை',
      'statsTotal': 'மொத்த டிக்கெட்டுகள்',
      'statsOpen': 'திறந்தவை',
      'statsResolved': 'தீர்க்கப்பட்டவை',
      'createTicket': 'சப்போர்ட் டிக்கெட் உருவாக்கு',
      'createTicketTitle': 'புதிய சப்போர்ட் டிக்கெட்',
      'createTicketSub':
          'என்ன சிக்கல் என்று சொல்லுங்கள், எங்கள் குழு பின்தொடரும்.',
      'subject': 'பொருள்',
      'subjectHint': 'எ.கா. ஆர்டருக்கான கட்டணம் பெறப்படவில்லை',
      'category': 'வகை',
      'priority': 'முன்னுரிமை',
      'description': 'விவரம்',
      'descriptionHint': 'சிக்கலை விரிவாக விவரிக்கவும்...',
      'orderId': 'ஆர்டர் ஐடி (விருப்பம்)',
      'submit': 'சமர்ப்பி',
      'cancel': 'ரத்து செய்',
      'liveTickets': 'நேரடி சப்போர்ட் டிக்கெட்டுகள்',
      'liveTicketsSub': 'எங்கள் குழுவிடமிருந்து நிகழ்நேர புதுப்பிப்புகள்.',
      'noTickets': 'இன்னும் சப்போர்ட் டிக்கெட்டுகள் இல்லை',
      'noTicketsSub': 'டிக்கெட்டை உருவாக்கி இங்கே நிகழ்நேரத்தில் கண்காணிக்கவும்.',
      'noFilteredTickets': 'தேர்ந்தெடுத்த வடிகட்டியுடன் டிக்கெட்டுகள் இல்லை.',
      'all': 'அனைத்தும்',
      'open': 'திறந்தது',
      'inProgress': 'செயல்பாட்டில்',
      'resolved': 'தீர்க்கப்பட்டது',
      'escalated': 'மேல்நிலைக்கு சென்றது',
      'ticketId': 'டிக்கெட்',
      'lastResponse': 'கடைசி பதில்',
      'noResponseYet': 'சப்போர்ட்டின் முதல் பதிலுக்காக காத்திருக்கிறது.',
      'faqTitle': 'அடிக்கடி கேட்கப்படும் கேள்விகள்',
      'faqSub': 'உடனடி பதில்களுக்கு தேடுங்கள் அல்லது வடிகட்டவும்.',
      'searchPlaceholder': 'FAQ-களை தேடு...',
      'feedbackTitle': 'சப்போர்ட் கருத்து',
      'feedbackSub': 'உங்கள் சிக்கலை எங்கள் குழு எவ்வாறு தீர்த்தது என மதிப்பிடுங்கள்.',
      'rateYourExperience': 'உங்கள் அனுபவத்தை மதிப்பிட ஒரு நட்சத்திரத்தைத் தட்டவும்',
      'feedbackCommentHint': 'நாங்கள் அறிய வேண்டியது ஏதேனும்?',
      'sendFeedback': 'கருத்து அனுப்பு',
      'feedbackThanks': 'உங்கள் கருத்துக்கு நன்றி!',
      'retry': 'மீண்டும் முயற்சிக்கவும்',
      'somethingWentWrong': 'உதவி & ஆதரவை ஏற்றுவதில் பிழை ஏற்பட்டது.',
      'quickIssues': 'விரைவு சிக்கல் அறிக்கை',
      'reportOrderIssue': 'ஆர்டர் சிக்கல் அறிக்கை',
      'reportPaymentIssue': 'கட்டண சிக்கல் அறிக்கை',
      'reportRestaurantIssue': 'உணவக சிக்கல் அறிக்கை',
      'reportCustomerIssue': 'வாடிக்கையாளர் சிக்கல் அறிக்கை',
      'emergencyContact': 'அவசர SOS',
    },
  };

  static String of(String key, String localeCode) {
    final map = _strings[localeCode] ?? _strings['en']!;
    return map[key] ?? _strings['en']![key]!;
  }
}

class DeliveryHelpSupportPage extends StatelessWidget {
  final DeliveryHelpSupportPageRepositoryBase? repository;
  final DeliveryHelpSupportPageServiceBase? service;
  final DeliveryHelpSupportPageBloc? bloc;
  final Future<void> Function(Uri uri)? launchCall;

  const DeliveryHelpSupportPage({
    super.key,
    this.repository,
    this.service,
    this.bloc,
    this.launchCall,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<DeliveryHelpSupportPageBloc>.value(
        value: bloc!,
        child: DeliveryHelpSupportPageView(launchCall: launchCall),
      );
    }

    return BlocProvider<DeliveryHelpSupportPageBloc>(
      create: (context) => DeliveryHelpSupportPageBloc(
        repository: repository ?? DeliveryHelpSupportPageRepository(),
        service: service ?? DeliveryHelpSupportPageService(),
      )..add(const DeliveryHelpSupportInitEvent()),
      child: DeliveryHelpSupportPageView(launchCall: launchCall),
    );
  }
}

class DeliveryHelpSupportPageView extends StatelessWidget {
  final Future<void> Function(Uri uri)? launchCall;

  const DeliveryHelpSupportPageView({super.key, this.launchCall});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryHelpSupportPageBloc, DeliveryHelpSupportPageState>(
      listenWhen: (previous, current) =>
          (previous.errorMessage != current.errorMessage &&
              current.errorMessage != null &&
              current.errorMessage!.isNotEmpty) ||
          (previous.successMessage != current.successMessage &&
              current.successMessage != null &&
              current.successMessage!.isNotEmpty),
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: DeliveryAppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.successMessage != null &&
            state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: DeliveryAppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == DeliveryHelpSupportStatus.initial ||
            state.status == DeliveryHelpSupportStatus.loading) {
          return const _HelpSupportSkeleton();
        }

        if (state.status == DeliveryHelpSupportStatus.error) {
          return _HelpSupportErrorShell(state: state);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            return ListView(
              key: const Key('dp_help_page'),
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              children: [
                _EmergencyAssistanceBanner(
                  state: state,
                  launchCall: launchCall,
                ),
                const SizedBox(height: 20),
                _SupportOverviewHeader(state: state, isDesktop: isDesktop),
                const SizedBox(height: 16),
                _SupportStatsRow(state: state),
                const SizedBox(height: 20),
                _QuickIssueActionsBar(state: state),
                const SizedBox(height: 16),
                _CreateTicketButton(state: state),
                const SizedBox(height: 24),
                _SupportTicketsSection(state: state),
                const SizedBox(height: 24),
                _FaqSection(state: state),
                const SizedBox(height: 24),
                _FeedbackCard(state: state),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmergencyAssistanceBanner extends StatelessWidget {
  final DeliveryHelpSupportPageState state;
  final Future<void> Function(Uri uri)? launchCall;

  const _EmergencyAssistanceBanner({
    required this.state,
    this.launchCall,
  });

  Future<void> _callHotline() async {
    final uri = Uri.parse(
      'tel:${DeliveryHelpSupportPageService.hotlineNumber}',
    );
    final launcher = launchCall ?? launchUrl;
    try {
      await launcher(uri);
    } catch (_) {
      // Launch failures must never crash the dashboard.
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Container(
      key: const Key('dp_help_emergency_banner'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D0F13), Color(0xFF7F1D1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.sos,
                  color: Color(0xFFFECACA),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryHelpSupportStrings.of('emergencyTitle', lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliveryHelpSupportStrings.of('emergencySub', lang),
                      style: const TextStyle(
                        color: Color(0xFFFECACA),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    key: const Key('dp_help_call_button'),
                    onPressed: _callHotline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text(
                      '${DeliveryHelpSupportStrings.of('callNow', lang)} · '
                      '${DeliveryHelpSupportStrings.of('hotline', lang)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  key: const Key('dp_help_dispute_button'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${DeliveryHelpSupportStrings.of('orderDispute', lang)}: '
                          'create a Customer Issue ticket below to log the dispute.',
                        ),
                        backgroundColor: const Color(0xFF7F1D1D),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFECACA),
                    side: const BorderSide(
                      color: Color(0xFFFECACA),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.gavel, size: 18),
                  label: Text(
                    DeliveryHelpSupportStrings.of('orderDispute', lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportOverviewHeader extends StatelessWidget {
  final DeliveryHelpSupportPageState state;
  final bool isDesktop;

  const _SupportOverviewHeader({
    required this.state,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DeliveryAppColors.primary, Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: DeliveryAppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(
            Icons.headset_mic,
            color: Colors.black,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DeliveryHelpSupportStrings.of('title', lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DeliveryHelpSupportStrings.of('tagline', lang),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupportStatsRow extends StatelessWidget {
  final DeliveryHelpSupportPageState state;

  const _SupportStatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Row(
      key: const Key('dp_help_stats'),
      children: [
        Expanded(
          child: _StatCard(
            label: DeliveryHelpSupportStrings.of('statsTotal', lang),
            value: '${state.totalTickets}',
            color: DeliveryAppColors.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: DeliveryHelpSupportStrings.of('statsOpen', lang),
            value: '${state.openTickets}',
            color: DeliveryAppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: DeliveryHelpSupportStrings.of('statsResolved', lang),
            value: '${state.resolvedTickets}',
            color: DeliveryAppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickIssueActionsBar extends StatelessWidget {
  final DeliveryHelpSupportPageState state;

  const _QuickIssueActionsBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;

    final issues = [
      (
        'Order Issue',
        DeliveryHelpSupportStrings.of('reportOrderIssue', lang),
        Icons.inventory_2_outlined,
        const Color(0xFF38BDF8),
        'dp_help_report_order_btn',
      ),
      (
        'Payment Issue',
        DeliveryHelpSupportStrings.of('reportPaymentIssue', lang),
        Icons.payments_outlined,
        const Color(0xFFFBBF24),
        'dp_help_report_payment_btn',
      ),
      (
        'Restaurant Issue',
        DeliveryHelpSupportStrings.of('reportRestaurantIssue', lang),
        Icons.storefront_outlined,
        const Color(0xFF34D399),
        'dp_help_report_restaurant_btn',
      ),
      (
        'Customer Issue',
        DeliveryHelpSupportStrings.of('reportCustomerIssue', lang),
        Icons.person_pin_circle_outlined,
        const Color(0xFFA78BFA),
        'dp_help_report_customer_btn',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DeliveryHelpSupportStrings.of('quickIssues', lang),
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: issues.map((issue) {
            final category = issue.$1;
            final label = issue.$2;
            final icon = issue.$3;
            final color = issue.$4;
            final keyName = issue.$5;

            return InkWell(
              key: Key(keyName),
              onTap: () => _showCreateTicketDialog(
                context,
                state,
                preselectedCategory: category,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D141C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CreateTicketButton extends StatelessWidget {
  final DeliveryHelpSupportPageState state;

  const _CreateTicketButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        key: const Key('dp_help_create_ticket_button'),
        onPressed: state.isSubmitting
            ? null
            : () => _showCreateTicketDialog(context, state),
        style: ElevatedButton.styleFrom(
          backgroundColor: DeliveryAppColors.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.add_comment, size: 20),
        label: Text(
          DeliveryHelpSupportStrings.of('createTicket', lang),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

Future<void> _showCreateTicketDialog(
  BuildContext context,
  DeliveryHelpSupportPageState state, {
  String? preselectedCategory,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => _CreateTicketDialog(
      state: state,
      initialCategory: preselectedCategory,
    ),
  );
}

class _CreateTicketDialog extends StatefulWidget {
  final DeliveryHelpSupportPageState state;
  final String? initialCategory;

  const _CreateTicketDialog({
    required this.state,
    this.initialCategory,
  });

  @override
  State<_CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<_CreateTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _orderIdController;
  late String _category;
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
    _orderIdController = TextEditingController();
    _category = (widget.initialCategory != null &&
            kDeliverySupportCategories.contains(widget.initialCategory))
        ? widget.initialCategory!
        : kDeliverySupportCategories.first;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<DeliveryHelpSupportPageBloc>();
    bloc.add(
      DeliveryHelpSupportCreateTicketEvent(
        subject: _subjectController.text,
        category: _category,
        priority: _priority,
        description: _descriptionController.text,
        orderId: _orderIdController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.localeCode;
    return Dialog(
      backgroundColor: const Color(0xFF0D141C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: DeliveryAppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DeliveryHelpSupportStrings.of(
                            'createTicketTitle',
                            lang,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DeliveryHelpSupportStrings.of('createTicketSub', lang),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                key: const Key('dp_help_ticket_subject'),
                controller: _subjectController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: DeliveryHelpSupportStrings.of('subject', lang),
                  hintText: DeliveryHelpSupportStrings.of('subjectHint', lang),
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0B1219),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Subject is required'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const Key('dp_help_ticket_category'),
                      initialValue: _category,
                      dropdownColor: const Color(0xFF161B22),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _dropdownDecoration(
                        DeliveryHelpSupportStrings.of('category', lang),
                      ),
                      items: [
                        for (final category in kDeliverySupportCategories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _category = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const Key('dp_help_ticket_priority'),
                      initialValue: _priority,
                      dropdownColor: const Color(0xFF161B22),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _dropdownDecoration(
                        DeliveryHelpSupportStrings.of('priority', lang),
                      ),
                      items: [
                        for (final priority in kDeliverySupportPriorities)
                          DropdownMenuItem(
                            value: priority,
                            child: Text(priority[0].toUpperCase() +
                                priority.substring(1)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _priority = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('dp_help_ticket_description'),
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: DeliveryHelpSupportStrings.of('description', lang),
                  hintText: DeliveryHelpSupportStrings.of(
                    'descriptionHint',
                    lang,
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: const Color(0xFF0B1219),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('dp_help_ticket_order_id'),
                controller: _orderIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: DeliveryHelpSupportStrings.of('orderId', lang),
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFF0B1219),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        DeliveryHelpSupportStrings.of('cancel', lang),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('dp_help_ticket_submit'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DeliveryAppColors.primary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        DeliveryHelpSupportStrings.of('submit', lang),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFF0B1219),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
    );
  }
}

class _SupportTicketsSection extends StatelessWidget {
  final DeliveryHelpSupportPageState state;

  const _SupportTicketsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final filtered = state.filteredTickets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DeliveryHelpSupportStrings.of('liveTickets', lang),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DeliveryHelpSupportStrings.of('liveTicketsSub', lang),
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final filter in DeliverySupportTicketFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: _filterLabel(filter, lang),
                    isSelected: state.ticketFilter == filter,
                    onTap: () => context
                        .read<DeliveryHelpSupportPageBloc>()
                        .add(DeliveryHelpSupportSelectTicketFilterEvent(filter)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          _EmptyTickets(state: state)
        else
          Column(
            key: const Key('dp_help_ticket_list'),
            children: [
              for (final ticket in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SupportTicketCard(ticket: ticket, state: state),
                ),
            ],
          ),
      ],
    );
  }

  String _filterLabel(DeliverySupportTicketFilter filter, String lang) {
    return switch (filter) {
      DeliverySupportTicketFilter.all =>
        DeliveryHelpSupportStrings.of('all', lang),
      DeliverySupportTicketFilter.open =>
        DeliveryHelpSupportStrings.of('open', lang),
      DeliverySupportTicketFilter.inProgress =>
        DeliveryHelpSupportStrings.of('inProgress', lang),
      DeliverySupportTicketFilter.resolved =>
        DeliveryHelpSupportStrings.of('resolved', lang),
      DeliverySupportTicketFilter.escalated =>
        DeliveryHelpSupportStrings.of('escalated', lang),
    };
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? DeliveryAppColors.primaryDark.withValues(alpha: 0.18)
                : const Color(0xFF0D141C),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? DeliveryAppColors.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? DeliveryAppColors.primary : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTickets extends StatelessWidget {
  final DeliveryHelpSupportPageState state;

  const _EmptyTickets({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final hasAny = state.totalTickets > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(
            hasAny ? Icons.filter_alt_off : Icons.confirmation_number_outlined,
            color: const Color(0xFF64748B),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            hasAny
                ? DeliveryHelpSupportStrings.of('noFilteredTickets', lang)
                : DeliveryHelpSupportStrings.of('noTickets', lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!hasAny) ...[
            const SizedBox(height: 4),
            Text(
              DeliveryHelpSupportStrings.of('noTicketsSub', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _SupportTicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final DeliveryHelpSupportPageState state;

  const _SupportTicketCard({required this.ticket, required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    final color = _statusColor(ticket.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _statusLabel(ticket.status, lang),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _TicketMetaChip(
                icon: Icons.category_outlined,
                text: ticket.category,
              ),
              _TicketMetaChip(
                icon: Icons.flag_outlined,
                text: ticket.priority[0].toUpperCase() +
                    ticket.priority.substring(1),
              ),
              _TicketMetaChip(
                icon: Icons.tag,
                text:
                    '${DeliveryHelpSupportStrings.of('ticketId', lang)}: #'
                    '${ticket.id.length > 8 ? ticket.id.substring(ticket.id.length - 8) : ticket.id}',
              ),
              if (ticket.orderId.isNotEmpty)
                _TicketMetaChip(icon: Icons.receipt_long, text: ticket.orderId),
            ],
          ),
          if (ticket.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              ticket.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 13,
                color: color.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                ticket.createdAt == null
                    ? '-'
                    : _formatDate(ticket.createdAt!),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
              const SizedBox(width: 14),
              Icon(Icons.chat_bubble_outline,
                  size: 13, color: const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  ticket.lastResponse.isEmpty
                      ? DeliveryHelpSupportStrings.of('noResponseYet', lang)
                      : ticket.lastResponse,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  Color _statusColor(DeliverySupportTicketStatus status) {
    return switch (status) {
      DeliverySupportTicketStatus.open => DeliveryAppColors.warning,
      DeliverySupportTicketStatus.inProgress => DeliveryAppColors.info,
      DeliverySupportTicketStatus.resolved => DeliveryAppColors.success,
      DeliverySupportTicketStatus.escalated => DeliveryAppColors.error,
    };
  }

  String _statusLabel(DeliverySupportTicketStatus status, String lang) {
    return switch (status) {
      DeliverySupportTicketStatus.open =>
        DeliveryHelpSupportStrings.of('open', lang),
      DeliverySupportTicketStatus.inProgress =>
        DeliveryHelpSupportStrings.of('inProgress', lang),
      DeliverySupportTicketStatus.resolved =>
        DeliveryHelpSupportStrings.of('resolved', lang),
      DeliverySupportTicketStatus.escalated =>
        DeliveryHelpSupportStrings.of('escalated', lang),
    };
  }
}

class _TicketMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TicketMetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final DeliveryHelpSupportPageState state;

  const _FaqSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DeliveryHelpSupportStrings.of('faqTitle', lang),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          DeliveryHelpSupportStrings.of('faqSub', lang),
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('dp_help_faq_search'),
          onChanged: (value) => context
              .read<DeliveryHelpSupportPageBloc>()
              .add(DeliveryHelpSupportSearchFAQEvent(value)),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: DeliveryHelpSupportStrings.of('searchPlaceholder', lang),
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF64748B),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFF0D141C),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FaqCategoryChip(
                label: DeliveryHelpSupportStrings.of('all', lang),
                isSelected: state.selectedCategory == null,
                onTap: () => context
                    .read<DeliveryHelpSupportPageBloc>()
                    .add(const DeliveryHelpSupportSelectCategoryEvent('all')),
              ),
              for (final category in kDeliverySupportCategories)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _FaqCategoryChip(
                    label: category,
                    isSelected: state.selectedCategory == category,
                    onTap: () => context
                        .read<DeliveryHelpSupportPageBloc>()
                        .add(DeliveryHelpSupportSelectCategoryEvent(category)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (state.filteredFaqs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D141C),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'No FAQs found for your search.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          )
        else
          Column(
            key: const Key('dp_help_faq_list'),
            children: [
              for (final faq in state.filteredFaqs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _FaqAccordionTile(faq: faq, state: state),
                ),
            ],
          ),
      ],
    );
  }
}

class _FaqCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FaqCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? DeliveryAppColors.primaryDark.withValues(alpha: 0.18)
                : const Color(0xFF0D141C),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? DeliveryAppColors.primary.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? DeliveryAppColors.primary : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqAccordionTile extends StatelessWidget {
  final FAQItem faq;
  final DeliveryHelpSupportPageState state;

  const _FaqAccordionTile({required this.faq, required this.state});

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('dp_help_faq_${faq.id}'),
      color: const Color(0xFF0D141C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DeliveryAppColors.primaryDark.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.help_outline,
              color: DeliveryAppColors.primary,
              size: 18,
            ),
          ),
          title: Text(
            faq.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            faq.category,
            style: const TextStyle(color: DeliveryAppColors.primary, fontSize: 11),
          ),
          iconColor: DeliveryAppColors.primary,
          collapsedIconColor: const Color(0xFF64748B),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: const TextStyle(color: Color(0xFFB6C2CF), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatefulWidget {
  final DeliveryHelpSupportPageState state;

  const _FeedbackCard({required this.state});

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  int _rating = 0;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<DeliveryHelpSupportPageBloc>();
    bloc.add(
      DeliveryHelpSupportSubmitFeedbackEvent(
        rating: _rating,
        comment: _commentController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.localeCode;
    final submitted = widget.state.feedbackSuccess;
    return Container(
      key: const Key('dp_help_feedback_card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B14), Color(0xFF0A1410)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DeliveryAppColors.primaryDark.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: DeliveryAppColors.primaryDark.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.thumb_up_alt_outlined,
                  color: DeliveryAppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeliveryHelpSupportStrings.of('feedbackTitle', lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DeliveryHelpSupportStrings.of('feedbackSub', lang),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (submitted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DeliveryAppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: DeliveryAppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: DeliveryAppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DeliveryHelpSupportStrings.of('feedbackThanks', lang),
                    style: const TextStyle(
                      color: DeliveryAppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              DeliveryHelpSupportStrings.of('rateYourExperience', lang),
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              key: const Key('dp_help_rating_stars'),
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    key: ValueKey('dp_help_star_$i'),
                    onPressed: () => setState(() => _rating = i),
                    icon: Icon(
                      i <= _rating ? Icons.star : Icons.star_border,
                      color: i <= _rating
                          ? DeliveryAppColors.warning
                          : const Color(0xFF64748B),
                      size: 26,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('dp_help_feedback_comment'),
              controller: _commentController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: DeliveryHelpSupportStrings.of(
                  'feedbackCommentHint',
                  lang,
                ),
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFF0B1219),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                key: const Key('dp_help_feedback_submit'),
                onPressed: widget.state.isSubmitting || _rating == 0
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeliveryAppColors.primaryDark,
                  foregroundColor: const Color(0xFF06120B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send, size: 16),
                label: Text(
                  DeliveryHelpSupportStrings.of('sendFeedback', lang),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpSupportSkeleton extends StatelessWidget {
  const _HelpSupportSkeleton();

  Widget _box({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D141C),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('dp_help_skeleton'),
      padding: const EdgeInsets.all(16),
      children: [
        _box(width: double.infinity, height: 110),
        const SizedBox(height: 20),
        _box(width: double.infinity, height: 52),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _box(width: double.infinity, height: 70)),
            const SizedBox(width: 10),
            Expanded(child: _box(width: double.infinity, height: 70)),
            const SizedBox(width: 10),
            Expanded(child: _box(width: double.infinity, height: 70)),
          ],
        ),
        const SizedBox(height: 20),
        _box(width: double.infinity, height: 50),
        const SizedBox(height: 20),
        _box(width: double.infinity, height: 140),
        const SizedBox(height: 20),
        _box(width: double.infinity, height: 180),
      ],
    );
  }
}

class _HelpSupportErrorShell extends StatelessWidget {
  final DeliveryHelpSupportPageState state;

  const _HelpSupportErrorShell({required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.localeCode;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFF87171),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.errorMessage ??
                    DeliveryHelpSupportStrings.of(
                      'somethingWentWrong',
                      lang,
                    ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<DeliveryHelpSupportPageBloc>()
                  .add(const DeliveryHelpSupportInitEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryAppColors.primaryDark,
                foregroundColor: const Color(0xFF06120B),
                minimumSize: const Size(140, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                DeliveryHelpSupportStrings.of('retry', lang),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
