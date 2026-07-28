import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'PaymentMethods_Bloc.dart';
import 'PaymentMethods_Event.dart';
import 'PaymentMethods_State.dart';

class PaymentMethodsUI extends StatefulWidget {
  const PaymentMethodsUI({super.key});

  @override
  State<PaymentMethodsUI> createState() => _PaymentMethodsUIState();
}

class _PaymentMethodsUIState extends State<PaymentMethodsUI> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentMethodsBloc, PaymentMethodsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          _showSnack(context, state.errorMessage!, isError: true);
          context.read<PaymentMethodsBloc>().add(ClearPaymentMethodsMessage());
        }
        if (state.successMessage != null) {
          _showSnack(context, state.successMessage!);
          context.read<PaymentMethodsBloc>().add(ClearPaymentMethodsMessage());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text('Payment Methods'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PaymentMethodsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF2A39)),
      );
    }

    if (state.status == PaymentMethodsStatus.error && state.methods.isEmpty) {
      return _buildErrorView(context);
    }

    return Column(
      children: [
        Expanded(child: _buildMethodsList(context, state)),
        _buildBottomButton(context),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Could not load payment methods',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                context.read<PaymentMethodsBloc>().add(LoadPaymentMethods());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsList(BuildContext context, PaymentMethodsState state) {
    if (state.methods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.credit_card_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No payment methods saved',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a credit card, debit card, or UPI ID',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: state.methods.length,
      itemBuilder: (context, index) {
        return _buildMethodCard(context, state.methods[index], state.isSaving);
      },
    );
  }

  Widget _buildMethodCard(
    BuildContext context,
    PaymentMethodModel method,
    bool isSaving,
  ) {
    final isCard = method.type == 'credit_card' || method.type == 'debit_card';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isSaving
                ? null
                : () => _showEditBottomSheet(context, method),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF2A39).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCard ? Icons.credit_card_rounded : Icons.phone_android_rounded,
                      color: const Color(0xFFEF2A39),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isCard ? method.maskedNumber : (method.upiId ?? method.maskedNumber),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212529),
                              ),
                            ),
                            if (method.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF2A39).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEF2A39),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.typeLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (isCard && method.expiryDate != null)
                          Text(
                            'Expires ${method.expiryDate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isSaving)
                    GestureDetector(
                      onTap: () => _confirmDelete(context, method),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () => _showAddBottomSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF2A39),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    _showFormSheet(context, isEditing: false);
  }

  void _showEditBottomSheet(BuildContext context, PaymentMethodModel method) {
    _showFormSheet(context, isEditing: true, method: method);
  }

  void _showFormSheet(
    BuildContext context, {
    required bool isEditing,
    PaymentMethodModel? method,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _PaymentMethodFormSheet(
          isEditing: isEditing,
          method: method,
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, PaymentMethodModel method) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Payment Method'),
        content: Text(
          'Are you sure you want to remove ${method.typeLabel} ending in ${method.lastFourDigits}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PaymentMethodsBloc>().add(DeletePaymentMethod(method.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _PaymentMethodFormSheet extends StatefulWidget {
  final bool isEditing;
  final PaymentMethodModel? method;

  const _PaymentMethodFormSheet({
    required this.isEditing,
    this.method,
  });

  @override
  State<_PaymentMethodFormSheet> createState() => _PaymentMethodFormSheetState();
}

class _PaymentMethodFormSheetState extends State<_PaymentMethodFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedType;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cardholderController;
  late final TextEditingController _upiController;
  bool _isDefault = false;

  bool get _isCardType =>
      _selectedType == 'credit_card' || _selectedType == 'debit_card';

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.method != null) {
      final m = widget.method!;
      _selectedType = m.type;
      _cardNumberController = TextEditingController(text: m.maskedNumber);
      _expiryController = TextEditingController(text: m.expiryDate ?? '');
      _cardholderController = TextEditingController(text: m.cardholderName ?? '');
      _upiController = TextEditingController(text: m.upiId ?? '');
      _isDefault = m.isDefault;
    } else {
      _selectedType = 'credit_card';
      _cardNumberController = TextEditingController();
      _expiryController = TextEditingController();
      _cardholderController = TextEditingController();
      _upiController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cardholderController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEditing) {
      context.read<PaymentMethodsBloc>().add(UpdatePaymentMethod(
            methodId: widget.method!.id,
            expiryDate: _isCardType ? _expiryController.text.trim() : null,
            cardholderName: _isCardType ? _cardholderController.text.trim() : null,
            isDefault: _isDefault,
          ));
    } else {
      context.read<PaymentMethodsBloc>().add(AddPaymentMethod(
            type: _selectedType,
            cardNumber: _cardNumberController.text.trim(),
            expiryDate: _isCardType ? _expiryController.text.trim() : null,
            cardholderName: _isCardType ? _cardholderController.text.trim() : null,
            upiId: !_isCardType ? _upiController.text.trim() : null,
            isDefault: _isDefault,
          ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.isEditing ? 'Edit Payment Method' : 'Add Payment Method',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212529),
                ),
              ),
              const SizedBox(height: 24),

              if (!widget.isEditing) ...[
                _buildLabel('Payment Type'),
                const SizedBox(height: 8),
                _buildTypeSelector(),
                const SizedBox(height: 20),
              ],

              if (_isCardType) ...[
                if (!widget.isEditing) ...[
                  _buildLabel('Card Number'),
                  const SizedBox(height: 8),
                  _buildCardNumberField(),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    Expanded(child: _buildDateField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCardholderField()),
                  ],
                ),
                const SizedBox(height: 20),
              ] else ...[
                _buildLabel('UPI ID'),
                const SizedBox(height: 8),
                _buildUpiField(),
                const SizedBox(height: 20),
              ],

              _buildDefaultSwitch(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF2A39),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.isEditing ? 'Save Changes' : 'Add Payment Method',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'credit_card',
          label: Text('Credit'),
          icon: Icon(Icons.credit_card_outlined, size: 18),
        ),
        ButtonSegment(
          value: 'debit_card',
          label: Text('Debit'),
          icon: Icon(Icons.credit_card_rounded, size: 18),
        ),
        ButtonSegment(
          value: 'upi',
          label: Text('UPI'),
          icon: Icon(Icons.phone_android_rounded, size: 18),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (v) {
        setState(() => _selectedType = v.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      maxLength: 19,
      inputFormatters: [
        _CardNumberFormatter(),
      ],
      decoration: _inputDecoration(
        hint: '1234 5678 9012 4532',
        icon: Icons.credit_card_outlined,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Card number is required';
        final digits = v.replaceAll(RegExp(r'\s+'), '');
        if (digits.length < 13 || digits.length > 19) {
          return 'Enter a valid card number';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _expiryController,
      keyboardType: TextInputType.datetime,
      maxLength: 5,
      inputFormatters: [
        _ExpiryDateFormatter(),
      ],
      decoration: _inputDecoration(
        hint: 'MM/YY',
        icon: Icons.calendar_today_outlined,
      ),
      validator: (v) {
        if (!widget.isEditing && _isCardType) {
          if (v == null || v.trim().isEmpty) return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildCardholderField() {
    return TextFormField(
      controller: _cardholderController,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration(
        hint: 'Cardholder name',
        icon: Icons.person_outline,
      ),
      validator: (v) {
        if (!widget.isEditing && _isCardType) {
          if (v == null || v.trim().isEmpty) return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildUpiField() {
    return TextFormField(
      controller: _upiController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(
        hint: 'username@upi',
        icon: Icons.alternate_email_rounded,
      ),
      validator: (v) {
        if (!_isCardType) {
          if (v == null || v.trim().isEmpty) return 'UPI ID is required';
          if (!v.contains('@')) return 'Enter a valid UPI ID (e.g. name@upi)';
        }
        return null;
      },
    );
  }

  Widget _buildDefaultSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: const Text(
          'Set as default',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'This will be your preferred payment method',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        value: _isDefault,
        activeTrackColor: const Color(0xFFEF2A39).withValues(alpha: 0.4),
        activeThumbColor: const Color(0xFFEF2A39),
        onChanged: (v) => setState(() => _isDefault = v),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
