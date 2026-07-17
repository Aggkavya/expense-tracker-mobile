import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class NewDebtScreen extends StatefulWidget {
  const NewDebtScreen({super.key});

  @override
  State<NewDebtScreen> createState() => _NewDebtScreenState();
}

class _NewDebtScreenState extends State<NewDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _paymentMode = kPaymentModes.first;
  bool _isHistorical = false;
  bool _isSubmitting = false;
  String _statusMessage = '';
  String _errorMessage = '';

  // Shared / linked form
  final _sharedFormKey = GlobalKey<FormState>();
  final _sharedTargetCtrl = TextEditingController();
  final _sharedAmountCtrl = TextEditingController();
  final _sharedDescCtrl = TextEditingController();
  String _sharedDirection = kLinkedDirections.first;
  bool _isSharedSubmitting = false;
  String _sharedStatusMessage = '';
  String _sharedErrorMessage = '';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _sharedTargetCtrl.dispose();
    _sharedAmountCtrl.dispose();
    _sharedDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _statusMessage = '';
      _errorMessage = '';
    });

    try {
      await context.read<FinanceProvider>().createDebtEntry({
        'amount': double.parse(_amountCtrl.text),
        'description': _descCtrl.text.trim(),
        'paymentMode': _paymentMode,
        'isHistorical': _isHistorical,
      });

      _amountCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _paymentMode = kPaymentModes.first;
        _isHistorical = false;
        _statusMessage = 'Debt created successfully.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSharedSubmit() async {
    if (!_sharedFormKey.currentState!.validate()) return;
    setState(() {
      _isSharedSubmitting = true;
      _sharedStatusMessage = '';
      _sharedErrorMessage = '';
    });

    try {
      await context.read<FinanceProvider>().sendLinkedTransactionRequest({
        'targetUsername': _sharedTargetCtrl.text.trim(),
        'amount': double.parse(_sharedAmountCtrl.text),
        'description': _sharedDescCtrl.text.trim(),
        'direction': _sharedDirection,
      });

      _sharedTargetCtrl.clear();
      _sharedAmountCtrl.clear();
      _sharedDescCtrl.clear();
      setState(() => _sharedStatusMessage = 'Request sent successfully.');
    } catch (e) {
      setState(() => _sharedErrorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSharedSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Personal debt form
          SectionCard(
            eyebrow: 'New Debt',
            title: 'Add Debt Entry',
            description: 'Record money you borrowed.',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  StatusBanner(tone: 'success', message: _statusMessage),
                  if (_statusMessage.isNotEmpty) const SizedBox(height: 12),
                  StatusBanner(tone: 'error', message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 12),

                  AppTextField(
                    label: 'Amount',
                    controller: _amountCtrl,
                    placeholder: '5000',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  AppDropdownField<String>(
                    label: 'Payment Mode',
                    value: _paymentMode,
                    items: kPaymentModes
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _paymentMode = v ?? kPaymentModes.first),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'Description',
                    controller: _descCtrl,
                    placeholder: 'Borrowed from friend',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Switch(
                        value: _isHistorical,
                        onChanged: (v) => setState(() => _isHistorical = v),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Historical entry (does not affect current balance)',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.appColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _isSubmitting ? 'Creating...' : 'Create Debt',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    isLoading: _isSubmitting,
                    icon: Icons.money_off_rounded,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Shared / linked transaction
          SectionCard(
            eyebrow: 'Shared',
            title: 'Send Linked Transaction Request',
            description:
                'Request a friend to link a shared debt/receivable.',
            child: Form(
              key: _sharedFormKey,
              child: Column(
                children: [
                  StatusBanner(tone: 'success', message: _sharedStatusMessage),
                  if (_sharedStatusMessage.isNotEmpty) const SizedBox(height: 12),
                  StatusBanner(tone: 'error', message: _sharedErrorMessage),
                  if (_sharedErrorMessage.isNotEmpty) const SizedBox(height: 12),

                  AppTextField(
                    label: 'Target Username',
                    controller: _sharedTargetCtrl,
                    placeholder: 'friend_username',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'Amount',
                    controller: _sharedAmountCtrl,
                    placeholder: '1000',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'Description',
                    controller: _sharedDescCtrl,
                    placeholder: 'Shared expense for trip',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  AppDropdownField<String>(
                    label: 'Direction',
                    value: _sharedDirection,
                    items: const [
                      DropdownMenuItem(
                          value: 'I_OWE_THEM', child: Text('I owe them')),
                      DropdownMenuItem(
                          value: 'THEY_OWE_ME', child: Text('They owe me')),
                    ],
                    onChanged: (v) =>
                        setState(() => _sharedDirection = v ?? kLinkedDirections.first),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _isSharedSubmitting ? 'Sending...' : 'Send Request',
                    onPressed: _isSharedSubmitting ? null : _handleSharedSubmit,
                    isLoading: _isSharedSubmitting,
                    icon: Icons.send_rounded,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
