import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final _dateFormatter = DateFormat('d MMM yy, h:mm a', 'en_IN');
final _shortDateFormatter = DateFormat('d MMM yy', 'en_IN');

String formatCurrency(dynamic value) {
  final num numVal = num.tryParse(value?.toString() ?? '') ?? 0;
  return _currencyFormatter.format(numVal.isFinite ? numVal : 0);
}

String formatDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return '--';
  try {
    final date = DateTime.parse(value.toString()).toLocal();
    return _dateFormatter.format(date);
  } catch (_) {
    return value.toString();
  }
}

String formatShortDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return '--';
  try {
    final date = DateTime.parse(value.toString()).toLocal();
    return _shortDateFormatter.format(date);
  } catch (_) {
    return value.toString();
  }
}

/// Normalises the backend totals payload into {total, cash, online}.
/// Mirrors normaliseTotalsResponse from format.js
Map<String, double> normaliseTotalsResponse(
    dynamic payload, List<dynamic> expenses) {
  final computed = expenses.fold<Map<String, double>>(
    {'total': 0, 'cash': 0, 'online': 0},
    (acc, expense) {
      final amount = double.tryParse(expense['amount']?.toString() ?? '0') ?? 0;
      final mode =
          (expense['paymentMode']?.toString() ?? '').toUpperCase();
      acc['total'] = (acc['total'] ?? 0) + amount;
      if (mode == 'CASH') acc['cash'] = (acc['cash'] ?? 0) + amount;
      if (mode == 'ONLINE') acc['online'] = (acc['online'] ?? 0) + amount;
      return acc;
    },
  );

  if (payload == null) return computed;

  if (payload is num) {
    return {'total': payload.toDouble(), 'cash': computed['cash']!, 'online': computed['online']!};
  }

  if (payload is Map) {
    return {
      'total': _extractDouble(payload, ['total', 'totalAmount', 'totalExpense', 'totalAmountSpend', 'totalAmountSpent']) ?? computed['total']!,
      'cash': _extractDouble(payload, ['cash', 'cashAmount', 'totalCashExpense', 'totalCash', 'totalAmountSpendInCash', 'totalAmountSpentInCash']) ?? computed['cash']!,
      'online': _extractDouble(payload, ['online', 'onlineAmount', 'totalOnlineExpense', 'totalOnline', 'totalAmountSpentInOnline', 'totalAmountSpendInOnline', 'totalAmountSpentOnline']) ?? computed['online']!,
    };
  }

  return computed;
}

Map<String, double> normaliseIncomeTotalsResponse(
    dynamic payload, List<dynamic> incomes) {
  final computed = incomes.fold<Map<String, double>>(
    {'total': 0, 'cash': 0, 'online': 0},
    (acc, income) {
      final amount = double.tryParse(income['amount']?.toString() ?? '0') ?? 0;
      final mode = (income['paymentMode']?.toString() ?? '').toUpperCase();
      acc['total'] = (acc['total'] ?? 0) + amount;
      if (mode == 'CASH') acc['cash'] = (acc['cash'] ?? 0) + amount;
      if (mode == 'ONLINE') acc['online'] = (acc['online'] ?? 0) + amount;
      return acc;
    },
  );

  if (payload == null || payload is! Map) return computed;

  return {
    'total': _extractDouble(payload, ['totalIncome', 'total']) ?? computed['total']!,
    'cash': _extractDouble(payload, ['totalCashIncome', 'cash']) ?? computed['cash']!,
    'online': _extractDouble(payload, ['totalOnlineIncome', 'online']) ?? computed['online']!,
  };
}

double? _extractDouble(Map payload, List<String> keys) {
  for (final key in keys) {
    if (payload.containsKey(key) && payload[key] != null) {
      return double.tryParse(payload[key].toString());
    }
  }
  return null;
}

String getMonthKey(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  } catch (_) {
    return '';
  }
}

String getMonthLabel(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) return monthKey;
  final year = int.tryParse(parts[0]) ?? 0;
  final month = int.tryParse(parts[1]) ?? 1;
  return DateFormat('MMM yy').format(DateTime(year, month));
}
