import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  String _filterCategory = '';
  String _startDate = '';
  String _endDate = '';
  String _sortKey = 'date';
  String _sortDir = 'desc';
  String _statusMessage = '';
  String _errorMessage = '';
  int? _deletingId;

  Future<void> _applyFilters() async {
    setState(() {
      _statusMessage = '';
      _errorMessage = '';
    });

    final filters = <String, String>{
      if (_filterCategory.isNotEmpty) 'category': _filterCategory,
      if (_startDate.isNotEmpty) 'startDate': _startDate,
      if (_endDate.isNotEmpty) 'endDate': _endDate,
    };

    try {
      await context.read<FinanceProvider>().applyExpenseFilters(filters);
      setState(() => _statusMessage = 'Filters applied.');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _resetFilters() async {
    setState(() {
      _filterCategory = '';
      _startDate = '';
      _endDate = '';
      _statusMessage = '';
      _errorMessage = '';
    });
    await context.read<FinanceProvider>().loadAllExpenses();
  }

  Future<void> _handleDelete(dynamic expenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
            'Delete this expense? This cannot be undone. Balance will be adjusted automatically.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _deletingId = expenseId is int ? expenseId : int.tryParse(expenseId.toString());
      _errorMessage = '';
    });

    try {
      final hasFilters =
          _filterCategory.isNotEmpty || _startDate.isNotEmpty || _endDate.isNotEmpty;
      await context.read<FinanceProvider>().removeExpense(
            expenseId,
            filters: hasFilters
                ? {
                    if (_filterCategory.isNotEmpty) 'category': _filterCategory,
                    if (_startDate.isNotEmpty) 'startDate': _startDate,
                    if (_endDate.isNotEmpty) 'endDate': _endDate,
                  }
                : null,
          );
      setState(() => _statusMessage = 'Expense deleted.');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _deletingId = null);
    }
  }

  List<dynamic> _sorted(List<dynamic> expenses) {
    final list = [...expenses];
    list.sort((a, b) {
      dynamic av = a[_sortKey];
      dynamic bv = b[_sortKey];

      int cmp;
      if (_sortKey == 'amount' || _sortKey == 'id') {
        cmp = (num.tryParse(av?.toString() ?? '0') ?? 0)
            .compareTo(num.tryParse(bv?.toString() ?? '0') ?? 0);
      } else if (_sortKey == 'date') {
        final ad = DateTime.tryParse(av?.toString() ?? '') ?? DateTime(0);
        final bd = DateTime.tryParse(bv?.toString() ?? '') ?? DateTime(0);
        cmp = ad.compareTo(bd);
      } else {
        cmp = (av?.toString() ?? '').compareTo(bv?.toString() ?? '');
      }

      return _sortDir == 'asc' ? cmp : -cmp;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final colors = context.appColors;
    final sorted = _sorted(finance.expenses);

    return RefreshIndicator(
      onRefresh: () => finance.loadAllExpenses(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Totals
            SectionCard(
              eyebrow: 'Expenses',
              title: finance.activeCollection == 'filtered'
                  ? 'Filtered Totals'
                  : 'Expense Totals',
              child: Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: finance.activeCollection == 'filtered'
                          ? 'Filtered Total'
                          : 'Total Spend',
                      value: formatCurrency(finance.totals['total']),
                      accent: 'slate',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'Cash Spend',
                      value: formatCurrency(finance.totals['cash']),
                      accent: 'emerald',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'Online Spend',
                      value: formatCurrency(finance.totals['online']),
                      accent: 'blue',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filters
            SectionCard(
              eyebrow: 'Filters',
              title: 'Filter & Sort',
              child: Column(
                children: [
                  StatusBanner(tone: 'success', message: _statusMessage),
                  if (_statusMessage.isNotEmpty) const SizedBox(height: 10),
                  StatusBanner(tone: 'error', message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 10),

                  AppDropdownField<String>(
                    label: 'Category',
                    value: _filterCategory.isEmpty ? null : _filterCategory,
                    hint: 'All categories',
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All categories')),
                      ...kExpenseCategories.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) =>
                        setState(() => _filterCategory = v ?? ''),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'Start Date',
                          value: _startDate,
                          onChanged: (v) => setState(() => _startDate = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'End Date',
                          value: _endDate,
                          onChanged: (v) => setState(() => _endDate = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<String>(
                          label: 'Sort By',
                          value: _sortKey,
                          items: ['date', 'amount', 'category', 'paymentMode', 'description', 'id']
                              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                              .toList(),
                          onChanged: (v) => setState(() => _sortKey = v ?? 'date'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppDropdownField<String>(
                          label: 'Direction',
                          value: _sortDir,
                          items: const [
                            DropdownMenuItem(value: 'desc', child: Text('Newest first')),
                            DropdownMenuItem(value: 'asc', child: Text('Oldest first')),
                          ],
                          onChanged: (v) => setState(() => _sortDir = v ?? 'desc'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: finance.isRefreshing ? null : _resetFilters,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: finance.isRefreshing ? 'Applying...' : 'Apply Filters',
                          onPressed: finance.isRefreshing ? null : _applyFilters,
                          isLoading: finance.isRefreshing,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Expense list
            SectionCard(
              eyebrow: 'Entries',
              title: 'Expense List',
              child: Column(
                children: [
                  if (finance.requestError.isNotEmpty) ...[
                    StatusBanner(tone: 'error', message: finance.requestError),
                    const SizedBox(height: 12),
                  ],
                  if (finance.isBootstrapping)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ))
                  else if (sorted.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No expenses found.',
                          style: TextStyle(color: context.appColors.muted),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => Divider(
                          color: colors.border, height: 1),
                      itemBuilder: (context, i) {
                        final exp = sorted[i];
                        final id = exp['id'];
                        final isDeleting = _deletingId == id;
                        return _ExpenseTile(
                          expense: exp,
                          isDeleting: isDeleting,
                          onDelete: () => _handleDelete(id),
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

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.isDeleting,
    required this.onDelete,
  });

  final dynamic expense;
  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_upward_rounded,
                size: 18, color: Color(0xFFF43F5E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['description'] ?? '--',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${expense['category'] ?? ''} · ${expense['paymentMode'] ?? ''} · ${formatShortDate(expense['date'])}',
                  style: TextStyle(fontSize: 11, color: colors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(expense['amount']),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF43F5E)),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: isDeleting ? null : onDelete,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFF43F5E).withOpacity(0.3)),
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
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: colors.muted),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value.isNotEmpty
                  ? DateTime.tryParse(value) ?? DateTime.now()
                  : DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onChanged(picked.toIso8601String().split('T').first);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16, color: colors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Pick date' : value,
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            value.isEmpty ? colors.muted : colors.text),
                  ),
                ),
                if (value.isNotEmpty)
                  GestureDetector(
                    onTap: () => onChanged(''),
                    child: Icon(Icons.clear_rounded, size: 16, color: colors.muted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
