import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class NewReceivableScreen extends StatefulWidget {
  const NewReceivableScreen({super.key});

  @override
  State<NewReceivableScreen> createState() => _NewReceivableScreenState();
}

class _NewReceivableScreenState extends State<NewReceivableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _paymentMode = kPaymentModes.first;
  bool _isHistorical = false;
  bool _isSubmitting = false;
  String _statusMessage = '';
  String _errorMessage = '';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
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
      await context.read<FinanceProvider>().createReceivableEntry({
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
        _statusMessage = 'Receivable created successfully.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionCard(
            eyebrow: 'New Receivable',
            title: 'Add Receivable Entry',
            description: 'Record money someone owes you.',
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
                    placeholder: '2000',
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
                    onChanged: (v) =>
                        setState(() => _paymentMode = v ?? kPaymentModes.first),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'Description',
                    controller: _descCtrl,
                    placeholder: 'Lent to friend',
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
                    label: _isSubmitting ? 'Creating...' : 'Create Receivable',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    isLoading: _isSubmitting,
                    icon: Icons.trending_up_rounded,
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
