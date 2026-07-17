import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/format_utils.dart';
import '../core/storage_service.dart';

class FinanceProvider extends ChangeNotifier {
  final _api = ApiClient();
  final _storage = StorageService();

  // ─── State ────────────────────────────────────────────────────────────────

  bool _isAuthenticated = false;

  List<dynamic> expenses = [];
  List<dynamic> incomes = [];
  List<dynamic> debts = [];
  List<dynamic> receivables = [];
  List<dynamic> friends = [];
  List<dynamic> pendingFriendRequests = [];
  List<dynamic> sentFriendRequests = [];
  List<dynamic> pendingLinkedTransactions = [];
  List<dynamic> pendingLinkedPayments = [];
  List<dynamic> notifications = [];
  List<dynamic> unreadNotifications = [];
  int unreadNotificationCount = 0;

  Map<String, double> totals = {'total': 0, 'cash': 0, 'online': 0};
  Map<String, double> incomeTotals = {'total': 0, 'cash': 0, 'online': 0};
  Map<String, dynamic> balances = {'cashInHand': null, 'bankBalance': null};

  bool isBootstrapping = true;
  bool isRefreshing = false;
  bool isDebtLoading = true;
  bool isIncomeLoading = true;
  bool isReceivableLoading = true;
  bool isFriendLoading = true;
  bool isLinkedTransactionLoading = true;
  bool isLinkedPaymentLoading = true;
  bool isNotificationLoading = true;

  String requestError = '';
  String? lastUpdatedAt;

  String activeCollection = 'all';

  // ─── Called by ProxyProvider when auth state changes ─────────────────────

  void updateAuthState(bool isAuth) {
    if (isAuth && !_isAuthenticated) {
      _isAuthenticated = true;
      _initLoad();
    } else if (!isAuth && _isAuthenticated) {
      _isAuthenticated = false;
      _reset();
    }
  }

  void _reset() {
    expenses = [];
    incomes = [];
    debts = [];
    receivables = [];
    friends = [];
    notifications = [];
    balances = {'cashInHand': null, 'bankBalance': null};
    notifyListeners();
  }

  void _initLoad() {
    loadAllExpenses(initial: true);
    loadAllDebts(initial: true);
    loadAllIncomes(initial: true);
    loadAllReceivables(initial: true);
    loadAllFriendsData(initial: true);
    loadPendingLinkedTransactions(initial: true);
    loadPendingLinkedPayments(initial: true);
    loadNotifications(initial: true);
  }

  // ─── Auth error handling ──────────────────────────────────────────────────

  bool _handleAuthError(dynamic error) {
    if (error is ApiException) {
      if (error.status == 401 || error.status == 403) {
        _storage.clearSession();
        return true;
      }
    }
    return false;
  }

  // ─── Balances ─────────────────────────────────────────────────────────────

  Future<void> refreshBalances() async {
    try {
      final res = await _api.getBalance();
      balances = {
        'cashInHand': res['cashInHand'],
        'bankBalance': res['bankBalance'],
      };
      await _storage.setBalances(balances);
      notifyListeners();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<Map<String, dynamic>?> saveBalances(Map<String, dynamic> payload) async {
    try {
      final res = await _api.updateBalance(payload);
      balances = {
        'cashInHand': res['cashInHand'],
        'bankBalance': res['bankBalance'],
      };
      await _storage.setBalances(balances);
      notifyListeners();
      return balances;
    } catch (e) {
      if (!_handleAuthError(e)) rethrow;
      return null;
    }
  }

  // ─── Expenses ─────────────────────────────────────────────────────────────

  Future<void> loadAllExpenses({bool initial = false}) async {
    requestError = '';
    if (initial) {
      isBootstrapping = true;
    } else {
      isRefreshing = true;
    }
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getAllExpenses(),
        _api.getExpenseTotals({}),
        _api.getBalance(),
      ]);

      final expList = results[0] is List ? results[0] as List : [];
      expenses = expList;
      totals = normaliseTotalsResponse(results[1], expList);
      final b = results[2] as Map;
      balances = {'cashInHand': b['cashInHand'], 'bankBalance': b['bankBalance']};
      await _storage.setBalances(balances);
      activeCollection = 'all';
      lastUpdatedAt = DateTime.now().toIso8601String();
    } catch (e) {
      if (!_handleAuthError(e)) requestError = e.toString();
    } finally {
      if (initial) {
        isBootstrapping = false;
      } else {
        isRefreshing = false;
      }
      notifyListeners();
    }
  }

  Future<void> applyExpenseFilters(Map<String, String> filters) async {
    isRefreshing = true;
    requestError = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getFilteredExpenses(filters),
        _api.getExpenseTotals(filters),
        _api.getBalance(),
      ]);

      final expList = results[0] is List ? results[0] as List : [];
      expenses = expList;
      totals = normaliseTotalsResponse(results[1], expList);
      final b = results[2] as Map;
      balances = {'cashInHand': b['cashInHand'], 'bankBalance': b['bankBalance']};
      await _storage.setBalances(balances);
      activeCollection = 'filtered';
      lastUpdatedAt = DateTime.now().toIso8601String();
    } catch (e) {
      if (!_handleAuthError(e)) requestError = e.toString();
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Map<String, dynamic> payload) async {
    await _api.createExpense(payload);
    await loadAllExpenses();
  }

  Future<void> removeExpense(dynamic expenseId,
      {Map<String, String>? filters}) async {
    await _api.deleteExpense(expenseId is int ? expenseId : int.parse(expenseId.toString()));
    await refreshBalances();
    if (filters != null && filters.isNotEmpty) {
      await applyExpenseFilters(filters);
    } else {
      await loadAllExpenses();
    }
  }

  Future<void> updateExpenseEntry(int expenseId, Map<String, dynamic> payload,
      {Map<String, String>? filters}) async {
    await _api.updateExpense(expenseId, payload);
    await refreshBalances();
    if (filters != null && filters.isNotEmpty) {
      await applyExpenseFilters(filters);
    } else {
      await loadAllExpenses();
    }
  }

  // ─── Income ───────────────────────────────────────────────────────────────

  Future<void> loadAllIncomes({bool initial = false}) async {
    if (initial) {
      isIncomeLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _api.getAllIncomes(),
        _api.getIncomeTotals({}),
      ]);

      final incList = results[0] is List ? results[0] as List : [];
      incomes = incList;
      incomeTotals = normaliseIncomeTotalsResponse(results[1], incList);
    } catch (e) {
      if (!_handleAuthError(e)) requestError = e.toString();
    } finally {
      if (initial) {
        isIncomeLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addIncomeEntry(Map<String, dynamic> payload) async {
    await _api.createIncome(payload);
    await Future.wait([refreshBalances(), loadAllIncomes()]);
  }

  Future<void> removeIncome(dynamic incomeId) async {
    await _api.deleteIncome(
        incomeId is int ? incomeId : int.parse(incomeId.toString()));
    await Future.wait([refreshBalances(), loadAllIncomes()]);
  }

  // ─── Debts ────────────────────────────────────────────────────────────────

  Future<void> loadAllDebts({bool initial = false}) async {
    if (initial) {
      isDebtLoading = true;
      notifyListeners();
    }

    try {
      final res = await _api.getAllDebts();
      debts = res is List ? res : [];
    } catch (e) {
      if (!_handleAuthError(e)) requestError = e.toString();
    } finally {
      if (initial) {
        isDebtLoading = false;
        notifyListeners();
      }
    }
  }

  Future<dynamic> getDebtHistory(int debtId) async {
    return await _api.getDebtHistory(debtId);
  }

  Future<void> createDebtEntry(Map<String, dynamic> payload) async {
    await _api.createDebt(payload);
    await Future.wait([refreshBalances(), loadAllDebts()]);
  }

  Future<void> payDebtEntry(Map<String, dynamic> payload) async {
    await _api.payDebt(payload);
    await Future.wait([refreshBalances(), loadAllDebts()]);
  }

  Future<void> removeDebt(dynamic debtId) async {
    await _api.deleteDebt(
        debtId is int ? debtId : int.parse(debtId.toString()));
    await Future.wait([refreshBalances(), loadAllDebts()]);
  }

  // ─── Receivables ──────────────────────────────────────────────────────────

  Future<void> loadAllReceivables({bool initial = false}) async {
    if (initial) {
      isReceivableLoading = true;
      notifyListeners();
    }

    try {
      final res = await _api.getAllReceivables();
      receivables = res is List ? res : [];
    } catch (e) {
      if (!_handleAuthError(e)) requestError = e.toString();
    } finally {
      if (initial) {
        isReceivableLoading = false;
        notifyListeners();
      }
    }
  }

  Future<dynamic> getReceivableHistory(int receivableId) async {
    return await _api.getReceivableHistory(receivableId);
  }

  Future<void> createReceivableEntry(Map<String, dynamic> payload) async {
    await _api.createReceivable(payload);
    await Future.wait([refreshBalances(), loadAllReceivables()]);
  }

  Future<void> collectReceivableEntry(Map<String, dynamic> payload) async {
    await _api.collectReceivable(payload);
    await Future.wait([refreshBalances(), loadAllReceivables()]);
  }

  Future<void> removeReceivable(dynamic receivableId) async {
    await _api.deleteReceivable(
        receivableId is int ? receivableId : int.parse(receivableId.toString()));
    await Future.wait([refreshBalances(), loadAllReceivables()]);
  }

  // ─── Friends ──────────────────────────────────────────────────────────────

  Future<void> loadAllFriendsData({bool initial = false}) async {
    if (initial) {
      isFriendLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _api.getAllFriends(),
        _api.getPendingFriendRequests(),
        _api.getSentFriendRequests(),
      ]);

      friends = results[0] is List ? results[0] as List : [];
      pendingFriendRequests = results[1] is List ? results[1] as List : [];
      sentFriendRequests = results[2] is List ? results[2] as List : [];
    } catch (e) {
      if (!_handleAuthError(e)) requestError = e.toString();
    } finally {
      if (initial) {
        isFriendLoading = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> sendFriendRequest(String userName) async {
    await _api.sendFriendRequest(userName);
    await loadAllFriendsData();
  }

  Future<void> acceptFriendRequest(int requestId) async {
    await _api.acceptFriendRequest(requestId);
    await loadAllFriendsData();
  }

  Future<void> rejectFriendRequest(int requestId) async {
    await _api.rejectFriendRequest(requestId);
    await loadAllFriendsData();
  }

  Future<void> unfriend(int requestId) async {
    await _api.unfriend(requestId);
    await loadAllFriendsData();
  }

  Future<List<dynamic>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _api.searchUsers(query.trim());
    return res is List ? res : [];
  }

  // ─── Linked Transactions ──────────────────────────────────────────────────

  Future<void> loadPendingLinkedTransactions({bool initial = false}) async {
    if (initial) {
      isLinkedTransactionLoading = true;
      notifyListeners();
    }

    try {
      final res = await _api.getPendingLinkedTransactions();
      pendingLinkedTransactions = res is List ? res : [];
    } catch (e) {
      _handleAuthError(e);
    } finally {
      if (initial) {
        isLinkedTransactionLoading = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> sendLinkedTransactionRequest(Map<String, dynamic> payload) async {
    await _api.sendLinkedTransactionRequest(payload);
  }

  Future<void> acceptLinkedTransaction(int requestId) async {
    await _api.acceptLinkedTransaction(requestId);
    await Future.wait([
      loadPendingLinkedTransactions(),
      loadAllDebts(),
      loadAllReceivables(),
    ]);
  }

  Future<void> rejectLinkedTransaction(int requestId) async {
    await _api.rejectLinkedTransaction(requestId);
    await loadPendingLinkedTransactions();
  }

  Future<void> loadPendingLinkedPayments({bool initial = false}) async {
    if (initial) {
      isLinkedPaymentLoading = true;
      notifyListeners();
    }

    try {
      final res = await _api.getPendingLinkedPayments();
      pendingLinkedPayments = res is List ? res : [];
    } catch (e) {
      _handleAuthError(e);
    } finally {
      if (initial) {
        isLinkedPaymentLoading = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> sendLinkedPaymentRequest(Map<String, dynamic> payload) async {
    await _api.sendLinkedPaymentRequest(payload);
  }

  Future<void> acceptLinkedPayment(int requestId) async {
    await _api.acceptLinkedPayment(requestId);
    await Future.wait([
      loadPendingLinkedPayments(),
      loadAllDebts(),
      loadAllReceivables(),
      refreshBalances(),
      loadNotifications(),
    ]);
  }

  Future<void> rejectLinkedPayment(int requestId) async {
    await _api.rejectLinkedPayment(requestId);
    await Future.wait([loadPendingLinkedPayments(), loadNotifications()]);
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  Future<void> loadNotifications({bool initial = false}) async {
    if (initial) {
      isNotificationLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _api.getAllNotifications(),
        _api.getUnreadNotifications(),
        _api.getUnreadNotificationCount(),
      ]);

      final allN = results[0] is List ? results[0] as List : [];
      final unreadN = results[1] is List ? results[1] as List : [];
      final countPayload = results[2];

      notifications = allN;
      unreadNotifications = unreadN;
      unreadNotificationCount = int.tryParse(
              countPayload?['count']?.toString() ?? '') ??
          unreadN.length;
    } catch (e) {
      _handleAuthError(e);
    } finally {
      if (initial) {
        isNotificationLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    await _api.markNotificationRead(id);
    await loadNotifications();
  }

  Future<void> markAllNotificationsAsRead() async {
    await _api.markAllNotificationsRead();
    await loadNotifications();
  }
}
