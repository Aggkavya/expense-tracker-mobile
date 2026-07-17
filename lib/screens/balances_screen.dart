import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/format_utils.dart';
import '../providers/finance_provider.dart';
import '../widgets/common_widgets.dart';

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key});

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cashCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  bool _isSubmitting = false;
  String _statusMessage = '';
  String _errorMessage = '';

  @override
  void dispose() {
    _cashCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cash = double.tryParse(_cashCtrl.text);
    final bank = double.tryParse(_bankCtrl.text);

    if (cash == null || bank == null) {
      setState(() => _errorMessage = 'Please enter valid numbers for both balances.');
      return;
    }

    if (cash < 0) {
      setState(() => _errorMessage = 'Cash in hand cannot be negative.');
      return;
    }

    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() {
      _isSubmitting = true;
      _statusMessage = '';
      _errorMessage = '';
    });

    try {
      await context.read<FinanceProvider>().saveBalances({
        'cashInHand': cash,
        'bankBalance': bank,
      });

      _cashCtrl.clear();
      _bankCtrl.clear();
      setState(() => _statusMessage = 'Balances updated successfully.');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Update Balances'),
            content: const Text(
                'This will overwrite your current Cash in Hand and Bank Balance values.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Update'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current balances
          SectionCard(
            eyebrow: 'Balances',
            title: 'Current Balances',
            child: Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Bank Balance',
                    value: formatCurrency(finance.balances['bankBalance']),
                    accent: 'blue',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Cash in Hand',
                    value: formatCurrency(finance.balances['cashInHand']),
                    accent: 'emerald',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Update form
          SectionCard(
            eyebrow: 'Form',
            title: 'Set Cash & Bank Balance',
            description: 'Cash cannot be negative. Bank balance can be negative.',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  StatusBanner(tone: 'success', message: _statusMessage),
                  if (_statusMessage.isNotEmpty) const SizedBox(height: 12),
                  StatusBanner(tone: 'error', message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 12),
                  const StatusBanner(
                    tone: 'warning',
                    message: 'Warning: this action overwrites both balances directly.',
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Cash in Hand',
                    controller: _cashCtrl,
                    placeholder: '12000',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      if (double.parse(v) < 0) return 'Cannot be negative';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'Bank Balance',
                    controller: _bankCtrl,
                    placeholder: '25000',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: _isSubmitting ? 'Saving...' : 'Update Balance',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    isLoading: _isSubmitting,
                    icon: Icons.save_rounded,
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
