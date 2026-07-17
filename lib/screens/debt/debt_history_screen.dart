import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class DebtHistoryScreen extends StatefulWidget {
  const DebtHistoryScreen({super.key});

  @override
  State<DebtHistoryScreen> createState() => _DebtHistoryScreenState();
}

class _DebtHistoryScreenState extends State<DebtHistoryScreen> {
  int? _expandedDebtId;
  int? _deletingId;
  int? _payingDebtId;
  Map<int, List<dynamic>> _historyByDebtId = {};
  Map<int, Map<String, dynamic>> _paymentForms = {};
  String _statusMessage = '';
  String _errorMessage = '';

  Map<String, dynamic> _getPayForm(int debtId) {
    return _paymentForms[debtId] ??
        {'amount': '', 'paymentMode': kPaymentModes.first, 'description': ''};
  }

  void _updatePayForm(int debtId, String field, dynamic value) {
    setState(() {
      _paymentForms[debtId] = {
        ..._getPayForm(debtId),
        field: value,
      };
    });
  }

  Future<void> _loadHistory(int debtId) async {
    if (_historyByDebtId.containsKey(debtId)) return;
    try {
      final res = await context.read<FinanceProvider>().getDebtHistory(debtId);
      setState(() {
        _historyByDebtId[debtId] = res is List ? res : [];
      });
    } catch (_) {}
  }

  Future<void> _handlePay(int debtId) async {
    final form = _getPayForm(debtId);
    final amount = double.tryParse(form['amount']?.toString() ?? '');
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid payment amount.');
      return;
    }

    setState(() {
      _payingDebtId = debtId;
      _errorMessage = '';
    });

    try {
      await context.read<FinanceProvider>().payDebtEntry({
        'debtId': debtId,
        'amount': amount,
        'paymentMode': form['paymentMode'],
        'description': form['description'] ?? '',
      });

      setState(() {
        _paymentForms.remove(debtId);
        _historyByDebtId.remove(debtId);
        _statusMessage = 'Payment recorded.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _payingDebtId = null);
    }
  }

  Future<void> _handleDelete(int debtId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Debt'),
        content: const Text(
            'Delete this debt? This cannot be undone. Balance will be adjusted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _deletingId = debtId);

    try {
      await context.read<FinanceProvider>().removeDebt(debtId);
      setState(() => _statusMessage = 'Debt deleted.');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _deletingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final colors = context.appColors;

    final debtTotal = finance.debts.fold<double>(
        0, (s, d) => s + (num.tryParse(d['amount']?.toString() ?? '0') ?? 0).toDouble());
    final debtRemaining = finance.debts.fold<double>(
        0, (s, d) => s + (num.tryParse(d['remainingAmount']?.toString() ?? '0') ?? 0).toDouble());

    return RefreshIndicator(
      onRefresh: () => finance.loadAllDebts(initial: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary
            SectionCard(
              eyebrow: 'Debts',
              title: 'Debt Summary',
              child: Row(
                children: [
                  Expanded(
                    child: StatTile(
                        label: 'Total Borrowed',
                        value: formatCurrency(debtTotal),
                        accent: 'orange'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                        label: 'Remaining',
                        value: formatCurrency(debtRemaining),
                        accent: 'rose'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                        label: 'Entries',
                        value: finance.debts.length.toString(),
                        accent: 'slate'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SectionCard(
              eyebrow: 'Ledger',
              title: 'Debt Ledger',
              child: Column(
                children: [
                  StatusBanner(tone: 'success', message: _statusMessage),
                  if (_statusMessage.isNotEmpty) const SizedBox(height: 10),
                  StatusBanner(tone: 'error', message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 10),

                  if (finance.isDebtLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ))
                  else if (finance.debts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text('No debts yet.',
                            style: TextStyle(color: colors.muted)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: finance.debts.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: colors.border, height: 1),
                      itemBuilder: (context, i) {
                        final debt = finance.debts[i];
                        final id = debt['id'] as int;
                        final isExpanded = _expandedDebtId == id;
                        final remaining = num.tryParse(
                                debt['remainingAmount']?.toString() ?? '0') ??
                            0;
                        final isDeleting = _deletingId == id;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedDebtId = isExpanded ? null : id;
                                });
                                if (!isExpanded) _loadHistory(id);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.money_off_rounded,
                                          size: 18,
                                          color: Color(0xFFF59E0B)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            debt['description'] ?? '--',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: colors.text),
                                          ),
                                          Text(
                                            '${debt['paymentMode'] ?? ''} · ${formatShortDate(debt['date'])}',
                                            style: TextStyle(
                                                fontSize: 11, color: colors.muted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatCurrency(debt['amount']),
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: colors.text),
                                        ),
                                        Text(
                                          'Left: ${formatCurrency(remaining)}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFFF43F5E)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less_rounded
                                          : Icons.expand_more_rounded,
                                      color: colors.muted,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Expanded section
                            if (isExpanded)
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.surfaceSoft,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pay form
                                    Text(
                                      'Make a Payment',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: colors.text),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: _getPayForm(id)['amount'],
                                            onChanged: (v) =>
                                                _updatePayForm(id, 'amount', v),
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                    decimal: true),
                                            decoration: InputDecoration(
                                              hintText: 'Amount',
                                              hintStyle: TextStyle(color: colors.muted),
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: colors.border),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        DropdownButton<String>(
                                          value: _getPayForm(id)['paymentMode'],
                                          underline: const SizedBox(),
                                          onChanged: (v) =>
                                              _updatePayForm(id, 'paymentMode', v),
                                          items: kPaymentModes
                                              .map((m) => DropdownMenuItem(
                                                  value: m, child: Text(m)))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: _getPayForm(id)['description'],
                                      onChanged: (v) =>
                                          _updatePayForm(id, 'description', v),
                                      decoration: InputDecoration(
                                        hintText: 'Description (optional)',
                                        hintStyle:
                                            TextStyle(color: colors.muted),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide:
                                              BorderSide(color: colors.border),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed:
                                                _payingDebtId == id ? null : () => _handlePay(id),
                                            child: Text(_payingDebtId == id
                                                ? 'Paying...'
                                                : 'Pay'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFFF43F5E)),
                                          onPressed: isDeleting
                                              ? null
                                              : () => _handleDelete(id),
                                          child: Text(
                                              isDeleting ? 'Deleting...' : 'Delete Debt'),
                                        ),
                                      ],
                                    ),

                                    // History
                                    if (_historyByDebtId.containsKey(id) &&
                                        _historyByDebtId[id]!.isNotEmpty) ...[
                                      const SizedBox(height: 14),
                                      Text(
                                        'Payment History',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: colors.muted),
                                      ),
                                      const SizedBox(height: 6),
                                      ...(_historyByDebtId[id] ?? []).map((h) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${h['paymentMode'] ?? ''} · ${formatShortDate(h['paymentDate'] ?? h['date'])}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: colors.muted),
                                              ),
                                              Text(
                                                formatCurrency(h['amount']),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF10B981)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
