import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_config.dart';
import '../../core/app_theme.dart';
import '../../core/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class ReceivableHistoryScreen extends StatefulWidget {
  const ReceivableHistoryScreen({super.key});

  @override
  State<ReceivableHistoryScreen> createState() =>
      _ReceivableHistoryScreenState();
}

class _ReceivableHistoryScreenState extends State<ReceivableHistoryScreen> {
  int? _expandedId;
  int? _deletingId;
  int? _collectingId;
  Map<int, List<dynamic>> _historyById = {};
  Map<int, Map<String, dynamic>> _collectForms = {};
  String _statusMessage = '';
  String _errorMessage = '';

  Map<String, dynamic> _getForm(int id) {
    return _collectForms[id] ??
        {'amount': '', 'paymentMode': kPaymentModes.first, 'description': ''};
  }

  void _updateForm(int id, String field, dynamic value) {
    setState(() {
      _collectForms[id] = {..._getForm(id), field: value};
    });
  }

  Future<void> _loadHistory(int receivableId) async {
    if (_historyById.containsKey(receivableId)) return;
    try {
      final res = await context.read<FinanceProvider>().getReceivableHistory(receivableId);
      setState(() {
        _historyById[receivableId] = res is List ? res : [];
      });
    } catch (_) {}
  }

  Future<void> _handleCollect(int receivableId) async {
    final form = _getForm(receivableId);
    final amount = double.tryParse(form['amount']?.toString() ?? '');
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid collection amount.');
      return;
    }

    setState(() {
      _collectingId = receivableId;
      _errorMessage = '';
    });

    try {
      await context.read<FinanceProvider>().collectReceivableEntry({
        'receivableId': receivableId,
        'amount': amount,
        'paymentMode': form['paymentMode'],
        'description': form['description'] ?? '',
      });

      setState(() {
        _collectForms.remove(receivableId);
        _historyById.remove(receivableId);
        _statusMessage = 'Collection recorded.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _collectingId = null);
    }
  }

  Future<void> _handleDelete(int receivableId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Receivable'),
        content: const Text(
            'Delete this receivable? This cannot be undone. Balance will be adjusted.'),
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
    setState(() => _deletingId = receivableId);

    try {
      await context.read<FinanceProvider>().removeReceivable(receivableId);
      setState(() => _statusMessage = 'Receivable deleted.');
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

    final recTotal = finance.receivables.fold<double>(
        0, (s, r) => s + (num.tryParse(r['amount']?.toString() ?? '0') ?? 0).toDouble());
    final recRemaining = finance.receivables.fold<double>(
        0, (s, r) => s + (num.tryParse(r['remainingAmount']?.toString() ?? '0') ?? 0).toDouble());

    return RefreshIndicator(
      onRefresh: () => finance.loadAllReceivables(initial: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionCard(
              eyebrow: 'Receivables',
              title: 'Receivable Summary',
              child: Row(
                children: [
                  Expanded(
                    child: StatTile(
                        label: 'Total Lent',
                        value: formatCurrency(recTotal),
                        accent: 'blue'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                        label: 'Remaining',
                        value: formatCurrency(recRemaining),
                        accent: 'emerald'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SectionCard(
              eyebrow: 'Ledger',
              title: 'Receivable Ledger',
              child: Column(
                children: [
                  StatusBanner(tone: 'success', message: _statusMessage),
                  if (_statusMessage.isNotEmpty) const SizedBox(height: 10),
                  StatusBanner(tone: 'error', message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 10),

                  if (finance.isReceivableLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ))
                  else if (finance.receivables.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text('No receivables yet.',
                            style: TextStyle(color: colors.muted)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: finance.receivables.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: colors.border, height: 1),
                      itemBuilder: (context, i) {
                        final rec = finance.receivables[i];
                        final id = rec['id'] as int;
                        final isExpanded = _expandedId == id;
                        final remaining = num.tryParse(
                                rec['remainingAmount']?.toString() ?? '0') ?? 0;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedId = isExpanded ? null : id;
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
                                        color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.trending_up_rounded,
                                          size: 18, color: Color(0xFF0EA5E9)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rec['description'] ?? '--',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: colors.text),
                                          ),
                                          Text(
                                            '${rec['paymentMode'] ?? ''} · ${formatShortDate(rec['date'])}',
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
                                          formatCurrency(rec['amount']),
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: colors.text),
                                        ),
                                        Text(
                                          'Left: ${formatCurrency(remaining)}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF10B981)),
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
                                    Text(
                                      'Record Collection',
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
                                            initialValue: _getForm(id)['amount'],
                                            onChanged: (v) => _updateForm(id, 'amount', v),
                                            keyboardType:
                                                const TextInputType.numberWithOptions(decimal: true),
                                            decoration: InputDecoration(
                                              hintText: 'Amount',
                                              hintStyle: TextStyle(color: colors.muted),
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: colors.border),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        DropdownButton<String>(
                                          value: _getForm(id)['paymentMode'],
                                          underline: const SizedBox(),
                                          onChanged: (v) => _updateForm(id, 'paymentMode', v),
                                          items: kPaymentModes
                                              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: _getForm(id)['description'],
                                      onChanged: (v) => _updateForm(id, 'description', v),
                                      decoration: InputDecoration(
                                        hintText: 'Description (optional)',
                                        hintStyle: TextStyle(color: colors.muted),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colors.border),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _collectingId == id
                                                ? null
                                                : () => _handleCollect(id),
                                            child: Text(_collectingId == id
                                                ? 'Collecting...'
                                                : 'Collect'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFFF43F5E)),
                                          onPressed: _deletingId == id
                                              ? null
                                              : () => _handleDelete(id),
                                          child: Text(_deletingId == id
                                              ? 'Deleting...'
                                              : 'Delete'),
                                        ),
                                      ],
                                    ),
                                    if (_historyById.containsKey(id) &&
                                        _historyById[id]!.isNotEmpty) ...[
                                      const SizedBox(height: 14),
                                      Text(
                                        'Collection History',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: colors.muted),
                                      ),
                                      const SizedBox(height: 6),
                                      ...(_historyById[id] ?? []).map((h) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${h['paymentMode'] ?? ''} · ${formatShortDate(h['collectionDate'] ?? h['date'])}',
                                                style: TextStyle(fontSize: 11, color: colors.muted),
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
