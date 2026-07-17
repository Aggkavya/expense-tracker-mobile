import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/format_utils.dart';
import '../providers/finance_provider.dart';
import '../widgets/common_widgets.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final colors = context.appColors;

    final debtSummary = finance.debts.fold<Map<String, double>>(
      {'total': 0, 'remaining': 0},
      (acc, d) {
        acc['total'] = (acc['total'] ?? 0) + (num.tryParse(d['amount']?.toString() ?? '0') ?? 0).toDouble();
        acc['remaining'] = (acc['remaining'] ?? 0) + (num.tryParse(d['remainingAmount']?.toString() ?? '0') ?? 0).toDouble();
        return acc;
      },
    );

    final receivableSummary = finance.receivables.fold<Map<String, double>>(
      {'total': 0, 'remaining': 0},
      (acc, r) {
        acc['total'] = (acc['total'] ?? 0) + (num.tryParse(r['amount']?.toString() ?? '0') ?? 0).toDouble();
        acc['remaining'] = (acc['remaining'] ?? 0) + (num.tryParse(r['remainingAmount']?.toString() ?? '0') ?? 0).toDouble();
        return acc;
      },
    );

    final monthlySummary = _createMonthlySummary(
        finance.expenses, finance.incomes, finance.debts, finance.receivables);

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        finance.loadAllExpenses(),
        finance.loadAllIncomes(),
        finance.loadAllDebts(),
        finance.loadAllReceivables(),
      ]),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: colors.gradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colors.brand.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FINANCE TRACKER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    finance.lastUpdatedAt != null
                        ? 'Updated ${formatDate(finance.lastUpdatedAt)}'
                        : 'Pull down to refresh',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Quick action chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickActionChip(
                          label: 'Add Expense',
                          onTap: () => context.go('/expenses/new'),
                          primary: true),
                      _QuickActionChip(
                          label: 'Add Income',
                          onTap: () => context.go('/incomes/new')),
                      _QuickActionChip(
                          label: 'Add Debt',
                          onTap: () => context.go('/debts/new')),
                      _QuickActionChip(
                          label: 'Receivable',
                          onTap: () => context.go('/receivables/new')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (finance.requestError.isNotEmpty)
              StatusBanner(tone: 'error', message: finance.requestError),

            const SizedBox(height: 8),

            // ── Balance stats ──────────────────────────────────────────────
            _SectionLabel(label: 'Balances'),
            const SizedBox(height: 8),
            Row(
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

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Expense Total',
                    value: formatCurrency(finance.totals['total']),
                    accent: 'slate',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Income Total',
                    value: formatCurrency(finance.incomeTotals['total']),
                    accent: 'orange',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Cash Expense',
                    value: formatCurrency(finance.totals['cash']),
                    accent: 'blue',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Online Expense',
                    value: formatCurrency(finance.totals['online']),
                    accent: 'slate',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Debt Principal',
                    value: formatCurrency(debtSummary['total']),
                    accent: 'orange',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Debt Remaining',
                    value: finance.isDebtLoading
                        ? '...'
                        : formatCurrency(debtSummary['remaining']),
                    accent: 'emerald',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Receivable',
                    value: formatCurrency(receivableSummary['total']),
                    accent: 'blue',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Rec. Remaining',
                    value: finance.isReceivableLoading
                        ? '...'
                        : formatCurrency(receivableSummary['remaining']),
                    accent: 'emerald',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Monthly chart ──────────────────────────────────────────────
            SectionCard(
              eyebrow: 'Monthly view',
              title: 'Income & Expense',
              child: monthlySummary.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Add income or expense records to see charts.',
                          style: TextStyle(color: colors.muted, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _MonthlyChart(monthlySummary: monthlySummary),
            ),

            const SizedBox(height: 16),

            // ── Recent Expenses ────────────────────────────────────────────
            SectionCard(
              eyebrow: 'Expenses',
              title: 'Recent Expenses',
              trailing: TextButton(
                onPressed: () => context.go('/expenses/history'),
                child: const Text('See all', style: TextStyle(fontSize: 12)),
              ),
              child: finance.isBootstrapping
                  ? const Center(child: CircularProgressIndicator())
                  : finance.expenses.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('No expenses yet.',
                                style: TextStyle(color: colors.muted)),
                          ),
                        )
                      : Column(
                          children: finance.expenses.take(5).map((expense) {
                            return _TransactionTile(
                              title: expense['description'] ?? '--',
                              subtitle: expense['category'] ?? '',
                              amount: formatCurrency(expense['amount']),
                              date: formatShortDate(expense['date']),
                              isExpense: true,
                              mode: expense['paymentMode'] ?? '',
                            );
                          }).toList(),
                        ),
            ),

            const SizedBox(height: 16),

            // ── Recent Income ──────────────────────────────────────────────
            SectionCard(
              eyebrow: 'Income',
              title: 'Recent Income',
              trailing: TextButton(
                onPressed: () => context.go('/incomes/history'),
                child: const Text('See all', style: TextStyle(fontSize: 12)),
              ),
              child: finance.isIncomeLoading
                  ? const Center(child: CircularProgressIndicator())
                  : finance.incomes.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('No incomes yet.',
                                style: TextStyle(color: colors.muted)),
                          ),
                        )
                      : Column(
                          children: finance.incomes.take(5).map((income) {
                            return _TransactionTile(
                              title: income['description'] ?? '--',
                              subtitle: income['paymentMode'] ?? '',
                              amount: formatCurrency(income['amount']),
                              date: formatShortDate(income['date']),
                              isExpense: false,
                              mode: income['paymentMode'] ?? '',
                            );
                          }).toList(),
                        ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: colors.muted,
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: primary ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: primary ? const Color(0xFF1E3A8A) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.mode,
  });

  final String title, subtitle, amount, date, mode;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (isExpense
                      ? const Color(0xFFF43F5E)
                      : const Color(0xFF10B981))
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 18,
              color: isExpense
                  ? const Color(0xFFF43F5E)
                  : const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle.isEmpty ? date : '$subtitle · $date',
                  style: TextStyle(fontSize: 11, color: colors.muted),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isExpense
                  ? const Color(0xFFF43F5E)
                  : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.monthlySummary});
  final List<Map<String, dynamic>> monthlySummary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final chartPeak = monthlySummary.fold<double>(1, (peak, m) {
      final inc = (m['income'] as double?) ?? 0;
      final exp = (m['expense'] as double?) ?? 0;
      return [peak, inc, exp].reduce((a, b) => a > b ? a : b);
    });

    return Column(
      children: [
        // Legend
        Row(
          children: [
            _LegendDot(color: const Color(0xFF10B981), label: 'Income'),
            const SizedBox(width: 16),
            _LegendDot(color: const Color(0xFFF43F5E), label: 'Expense'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: monthlySummary.map((month) {
              final incPct = ((month['income'] as double? ?? 0) / chartPeak).clamp(0.05, 1.0);
              final expPct = ((month['expense'] as double? ?? 0) / chartPeak).clamp(0.05, 1.0);
              final savings = (month['savings'] as double? ?? 0);

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Bar(fraction: incPct, color: const Color(0xFF10B981)),
                        const SizedBox(width: 3),
                        _Bar(fraction: expPct, color: const Color(0xFFF43F5E)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      month['label'] as String? ?? '',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors.text),
                    ),
                    Text(
                      formatCurrency(savings),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: savings >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF43F5E),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 14,
      height: 130 * fraction,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.muted)),
      ],
    );
  }
}

// ─── Monthly summary logic ────────────────────────────────────────────────────

List<Map<String, dynamic>> _createMonthlySummary(
    List expenses, List incomes, List debts, List receivables) {
  final monthMap = <String, Map<String, dynamic>>{};

  void ensure(String key) {
    monthMap.putIfAbsent(key, () => {
      'monthKey': key,
      'label': getMonthLabel(key),
      'income': 0.0,
      'expense': 0.0,
      'debtCreated': 0.0,
      'receivableCreated': 0.0,
    });
  }

  for (final inc in incomes) {
    final key = getMonthKey(inc['date']?.toString() ?? '');
    if (key.isEmpty) continue;
    ensure(key);
    monthMap[key]!['income'] =
        (monthMap[key]!['income'] as double) + (num.tryParse(inc['amount']?.toString() ?? '0') ?? 0).toDouble();
  }

  for (final exp in expenses) {
    final key = getMonthKey(exp['date']?.toString() ?? '');
    if (key.isEmpty) continue;
    ensure(key);
    monthMap[key]!['expense'] =
        (monthMap[key]!['expense'] as double) + (num.tryParse(exp['amount']?.toString() ?? '0') ?? 0).toDouble();
  }

  final sorted = monthMap.values.toList()
    ..sort((a, b) => (a['monthKey'] as String).compareTo(b['monthKey'] as String));

  return sorted.reversed.take(6).toList().reversed.map((m) {
    return {
      ...m,
      'savings': (m['income'] as double) - (m['expense'] as double),
    };
  }).toList();
}
