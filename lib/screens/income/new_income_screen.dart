import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class NewIncomeScreen extends StatefulWidget {
  const NewIncomeScreen({super.key});

  @override
  State<NewIncomeScreen> createState() => _NewIncomeScreenState();
}

class _NewIncomeScreenState extends State<NewIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _paymentMode = kPaymentModes.first;
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
      await context.read<FinanceProvider>().addIncomeEntry({
        'amount': double.parse(_amountCtrl.text),
        'description': _descCtrl.text.trim(),
        'paymentMode': _paymentMode,
      });

      _amountCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _paymentMode = kPaymentModes.first;
        _statusMessage = 'Income added successfully.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SectionCard(
            eyebrow: 'Create Income',
            title: 'New Income',
            child: Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Payment Mode',
                    value: _paymentMode,
                    accent: 'emerald',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: 'Amount',
                    value: formatCurrency(double.tryParse(_amountCtrl.text) ?? 0),
                    accent: 'orange',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SectionCard(
            eyebrow: 'Form',
            title: 'Add Income Entry',
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
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
                    placeholder: 'Monthly salary',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _isSubmitting ? 'Adding...' : 'Add Income',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    isLoading: _isSubmitting,
                    icon: Icons.add_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
