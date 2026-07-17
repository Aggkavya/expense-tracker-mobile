import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = kExpenseCategories.first;
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
      await context.read<FinanceProvider>().addExpense({
        'amount': double.parse(_amountCtrl.text),
        'description': _descCtrl.text.trim(),
        'category': _category,
        'paymentMode': _paymentMode,
      });

      _amountCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _category = kExpenseCategories.first;
        _paymentMode = kPaymentModes.first;
        _statusMessage = 'Expense created successfully.';
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
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Preview tiles
          SectionCard(
            eyebrow: 'Create Expense',
            title: 'New Expense',
            child: Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Category',
                    value: _category,
                    accent: 'blue',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: 'Mode',
                    value: _paymentMode,
                    accent: 'emerald',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: 'Amount',
                    value: formatCurrency(
                        double.tryParse(_amountCtrl.text) ?? 0),
                    accent: 'orange',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SectionCard(
            eyebrow: 'Form',
            title: 'Create Expense Entry',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cash: ${formatCurrency(finance.balances['cashInHand'])}',
                    style: TextStyle(fontSize: 11, color: colors.muted),
                  ),
                  Text(
                    'Bank: ${formatCurrency(finance.balances['bankBalance'])}',
                    style: TextStyle(fontSize: 11, color: colors.muted),
                  ),
                ],
              ),
            ),
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
                    placeholder: '320',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid amount';
                      if (double.parse(v) < 0) return 'Amount must be positive';
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

                  AppDropdownField<String>(
                    label: 'Category',
                    value: _category,
                    items: kExpenseCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _category = v ?? kExpenseCategories.first),
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'Description',
                    controller: _descCtrl,
                    placeholder: 'stationary',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _isSubmitting ? 'Creating...' : 'Create Expense',
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
