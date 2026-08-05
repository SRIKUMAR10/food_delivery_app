import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'HelpSupport_Bloc.dart';
import 'HelpSupport_Event.dart';
import 'HelpSupport_State.dart';

class HelpSupportContent extends StatefulWidget {
  const HelpSupportContent({super.key});

  @override
  State<HelpSupportContent> createState() => _HelpSupportContentState();
}

class _HelpSupportContentState extends State<HelpSupportContent> {
  @override
  void initState() {
    super.initState();
    context.read<HelpSupportBloc>().add(const LoadHelpContent());
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpSupportBloc, HelpSupportState>(
      listenWhen: (previous, current) =>
          current.status == HelpSupportStatus.success ||
          current.status == HelpSupportStatus.failure,
      listener: (context, state) {
        if (state.successMessage != null) {
          _showSnack(state.successMessage!);
          context.read<HelpSupportBloc>().add(const LoadHelpContent());
        }
        if (state.errorMessage != null) {
          _showSnack(state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        if (state.status == HelpSupportStatus.loading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFEF2A39)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHelpItem(
              icon: Icons.help_outline_rounded,
              title: 'FAQ',
              onTap: () => _openFaq(context, state.faqItems),
            ),
            _buildDivider(),
            _buildHelpItem(
              icon: Icons.call_outlined,
              title: 'Contact Us',
              onTap: () => _contactUs(context),
            ),
            _buildDivider(),
            _buildHelpItem(
              icon: Icons.access_time_rounded,
              title: 'Order Issues',
              onTap: () => _openIssueForm(context, 'order'),
            ),
            _buildDivider(),
            _buildHelpItem(
              icon: Icons.credit_card_outlined,
              title: 'Payment Issues',
              onTap: () => _openIssueForm(context, 'payment'),
            ),
            _buildDivider(),
            _buildHelpItem(
              icon: Icons.local_shipping_outlined,
              title: 'Delivery Issues',
              onTap: () => _openIssueForm(context, 'delivery'),
            ),
            _buildDivider(),
            _buildHelpItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'App Feedback',
              onTap: () => _openFeedbackForm(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF1C1C1C)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212529),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F3F3));
  }

  void _openFaq(BuildContext context, List<FaqItem> faqItems) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FaqPage(faqItems: faqItems),
      ),
    );
  }

  Future<void> _contactUs(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Us'),
        content: const Text('How would you like to reach us?'),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (Navigator.canPop(ctx)) Navigator.pop(ctx, 'email');
            },
            icon: const Icon(Icons.email_outlined, size: 18),
            label: const Text('Email'),
          ),
          TextButton.icon(
            onPressed: () {
              if (Navigator.canPop(ctx)) Navigator.pop(ctx, 'phone');
            },
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Phone'),
          ),
        ],
      ),
    );

    if (result == 'email') {
      final uri = Uri(scheme: 'mailto', path: 'support@foodgo.app');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } else if (result == 'phone') {
      if (!kIsWeb) {
        final uri = Uri(scheme: 'tel', path: '+1800123456');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      }
    }
  }

  void _openIssueForm(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _IssueFormPage(type: type),
      ),
    );
  }

  void _openFeedbackForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _FeedbackFormPage(),
      ),
    );
  }
}

class _FaqPage extends StatelessWidget {
  final List<FaqItem> faqItems;

  const _FaqPage({required this.faqItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: faqItems
            .map((item) => _FaqAccordion(faqItem: item))
            .toList(),
      ),
    );
  }
}

class _FaqAccordion extends StatefulWidget {
  final FaqItem faqItem;
  const _FaqAccordion({required this.faqItem});

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faqItem.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212529),
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.faqItem.answer,
                style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _IssueFormPage extends StatefulWidget {
  final String type;
  const _IssueFormPage({required this.type});

  @override
  State<_IssueFormPage> createState() => _IssueFormPageState();
}

class _IssueFormPageState extends State<_IssueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _orderIdController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  String get _typeLabel {
    switch (widget.type) {
      case 'order': return 'Order Issue';
      case 'payment': return 'Payment Issue';
      case 'delivery': return 'Delivery Issue';
      default: return 'Issue';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<HelpSupportBloc>().add(SubmitSupportTicket(
      type: widget.type,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      orderId: _orderIdController.text.trim().isEmpty
          ? null
          : _orderIdController.text.trim(),
    ));
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_typeLabel),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: _inputDecoration('Subject', Icons.subject),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderIdController,
                decoration: _inputDecoration('Order ID (optional)', Icons.receipt_long_outlined),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: _inputDecoration('Describe your issue...', Icons.message_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please describe your issue' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF2A39),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Submit Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF2A39)),
      ),
    );
  }
}

class _FeedbackFormPage extends StatefulWidget {
  const _FeedbackFormPage();

  @override
  State<_FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<_FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      _showSnack('Please select a rating');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    context.read<HelpSupportBloc>().add(SubmitFeedback(
      rating: _rating,
      comments: _commentsController.text.trim(),
    ));
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Rate your experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    icon: Icon(
                      star <= _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFA726),
                      size: 40,
                    ),
                    onPressed: () => setState(() => _rating = star),
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _commentsController,
                maxLines: 4,
                decoration: _inputDecoration('Tell us more...', Icons.edit_outlined),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please share your feedback' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF2A39),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF2A39)),
      ),
    );
  }
}
