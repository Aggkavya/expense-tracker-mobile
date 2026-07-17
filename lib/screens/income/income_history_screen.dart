import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class IncomeHistoryScreen extends StatefulWidget {
  const IncomeHistoryScreen({super.key});

  @override
  State<IncomeHistoryScreen> createState() => _IncomeHistoryScreenState();
}

class _IncomeHistoryScreenState extends State<IncomeHistoryScreen> {
  int? _deletingId;
  String _statusMessage = '';
  String _errorMessage = '';

  Future<void> _handleDelete(dynamic incomeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Income'),
        content: const Text('Delete this income entry? This cannot be undone.'),
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

    setState(() {
      _deletingId = incomeId is int ? incomeId : int.tryParse(incomeId.toString());
      _errorMessage = '';
    });

    try {
      await context.read<FinanceProvider>().removeIncome(incomeId);
      setState(() => _statusMessage = 'Income deleted.');
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

    return RefreshIndicator(
      onRefresh: () => finance.loadAllIncomes(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionCard(
              eyebrow: 'Income',
              title: 'Income Totals',
              child: Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Total Income',
                      value: formatCurrency(finance.incomeTotals['total']),
                      accent: 'emerald',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'Cash Income',
                      value: formatCurrency(finance.incomeTotals['cash']),
                      accent: 'blue',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'Online Income',
                      value: formatCurrency(finance.incomeTotals['online']),
                      accent: 'orange',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SectionCard(
              eyebrow: 'Entries',
              title: 'Income List',
              child: Column(
                children: [
                  StatusBanner(tone: 'success', message: _statusMessage),
                  if (_statusMessage.isNotEmpty) const SizedBox(height: 10),
                  StatusBanner(tone: 'error', message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 10),

                  if (finance.isIncomeLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ))
                  else if (finance.incomes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No incomes yet.',
                          style: TextStyle(color: colors.muted),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: finance.incomes.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: colors.border, height: 1),
                      itemBuilder: (context, i) {
                        final inc = finance.incomes[i];
                        final id = inc['id'];
                        final isDeleting = _deletingId == id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 18,
                                    color: Color(0xFF10B981)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inc['description'] ?? '--',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text),
                                    ),
                                    Text(
                                      '${inc['paymentMode'] ?? ''} · ${formatShortDate(inc['date'])}',
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
                                    formatCurrency(inc['amount']),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF10B981)),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: isDeleting ? null : () => _handleDelete(id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF43F5E).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFFF43F5E)
                                                .withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        isDeleting ? 'Deleting...' : 'Delete',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFF43F5E)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
