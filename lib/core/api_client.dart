import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = StorageService();

  // ─── Core request ──────────────────────────────────────────────────────────

  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool auth = true,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = await _buildHeaders(body != null, auth);

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null);
        case 'PUT':
          response = await http.put(uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null);
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
        default:
          response = await http.get(uri, headers: headers);
      }
    } catch (_) {
      throw ApiException(
          "Can't connect to the server. Check your internet connection and try again.");
    }

    return _handleResponse(response);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final base = Uri.parse('$kApiBaseUrl$path');
    if (queryParams == null || queryParams.isEmpty) return base;
    final filtered = Map<String, String>.fromEntries(
      queryParams.entries.where((e) => e.value.isNotEmpty),
    );
    return base.replace(queryParameters: filtered);
  }

  Future<Map<String, String>> _buildHeaders(bool hasBody, bool auth) async {
    final headers = <String, String>{};
    if (hasBody) headers['Content-Type'] = 'application/json';
    if (auth) {
      final token = await _storage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json');

    dynamic payload;
    if (isJson && response.body.isNotEmpty) {
      try {
        payload = jsonDecode(response.body);
      } catch (_) {
        payload = response.body;
      }
    } else {
      payload = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    String message;
    if (payload is Map) {
      message = payload['message'] as String? ??
          payload['error'] as String? ??
          'Request failed with status ${response.statusCode}.';
    } else if (payload is String && payload.isNotEmpty) {
      message = payload;
    } else {
      message = 'Request failed with status ${response.statusCode}.';
    }

    throw ApiException(message, response.statusCode);
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<dynamic> signup(Map<String, dynamic> payload) =>
      request(kSignupPath, method: 'POST', body: payload, auth: false);

  Future<dynamic> login(Map<String, dynamic> payload) =>
      request(kLoginPath, method: 'POST', body: payload, auth: false);

  // ─── User / Balance ────────────────────────────────────────────────────────

  Future<dynamic> getBalance() => request(kGetBalancePath);

  Future<dynamic> updateBalance(Map<String, dynamic> payload) =>
      request(kUpdateBalancePath, method: 'PUT', body: payload);

  Future<dynamic> searchUsers(String query) =>
      request(kSearchUsersPath, queryParams: {'query': query});

  // ─── Notifications ─────────────────────────────────────────────────────────

  Future<dynamic> getAllNotifications() => request(kNotificationsPath);

  Future<dynamic> getUnreadNotifications() =>
      request(kUnreadNotificationsPath);

  Future<dynamic> getUnreadNotificationCount() =>
      request(kUnreadNotificationCountPath);

  Future<dynamic> markNotificationRead(int id) =>
      request('/notifications/$id/read', method: 'PUT');

  Future<dynamic> markAllNotificationsRead() =>
      request(kMarkAllReadPath, method: 'PUT');

  // ─── Expenses ──────────────────────────────────────────────────────────────

  Future<dynamic> createExpense(Map<String, dynamic> payload) =>
      request(kNewExpensePath, method: 'POST', body: payload);

  Future<dynamic> getAllExpenses() => request(kAllExpensesPath);

  Future<dynamic> getFilteredExpenses(Map<String, String> filters) =>
      request(kFilterExpensesPath, queryParams: filters);

  Future<dynamic> getExpenseTotals(Map<String, String> filters) =>
      request(kExpenseTotalPath, queryParams: filters);

  Future<dynamic> deleteExpense(int expenseId) =>
      request(kDeleteExpensePath,
          method: 'DELETE',
          queryParams: {'expenseId': expenseId.toString()});

  Future<dynamic> updateExpense(int expenseId, Map<String, dynamic> payload) =>
      request('/expense/updateExpense/$expenseId', method: 'PUT', body: payload);

  // ─── Income ────────────────────────────────────────────────────────────────

  Future<dynamic> createIncome(Map<String, dynamic> payload) =>
      request(kNewIncomePath, method: 'POST', body: payload);

  Future<dynamic> getAllIncomes() => request(kAllIncomesPath);

  Future<dynamic> getIncomeTotals(Map<String, String> filters) =>
      request(kIncomeTotalPath, queryParams: filters);

  Future<dynamic> deleteIncome(int incomeId) =>
      request(kDeleteIncomePath,
          method: 'DELETE',
          queryParams: {'incomeId': incomeId.toString()});

  // ─── Debt ──────────────────────────────────────────────────────────────────

  Future<dynamic> createDebt(Map<String, dynamic> payload) =>
      request(kNewDebtPath, method: 'POST', body: payload);

  Future<dynamic> getAllDebts() => request(kAllDebtsPath);

  Future<dynamic> getDebtHistory(int debtId) =>
      request('/debt/$debtId/history');

  Future<dynamic> payDebt(Map<String, dynamic> payload) =>
      request(kPayDebtPath, method: 'POST', body: payload);

  Future<dynamic> deleteDebt(int debtId) =>
      request(kDeleteDebtPath,
          method: 'DELETE',
          queryParams: {'debtId': debtId.toString()});

  // ─── Receivable ────────────────────────────────────────────────────────────

  Future<dynamic> createReceivable(Map<String, dynamic> payload) =>
      request(kNewReceivablePath, method: 'POST', body: payload);

  Future<dynamic> getAllReceivables() => request(kAllReceivablesPath);

  Future<dynamic> getReceivableHistory(int receivableId) =>
      request('/receivable/$receivableId/history');

  Future<dynamic> collectReceivable(Map<String, dynamic> payload) =>
      request(kCollectReceivablePath, method: 'POST', body: payload);

  Future<dynamic> deleteReceivable(int receivableId) =>
      request(kDeleteReceivablePath,
          method: 'DELETE',
          queryParams: {'receivableId': receivableId.toString()});

  // ─── Friends ───────────────────────────────────────────────────────────────

  Future<dynamic> getPendingFriendRequests() =>
      request(kPendingFriendsPath);

  Future<dynamic> getSentFriendRequests() => request(kSentFriendsPath);

  Future<dynamic> getAllFriends() => request(kAllFriendsPath);

  Future<dynamic> sendFriendRequest(String userName) =>
      request('/friend/sendRequest/${Uri.encodeComponent(userName)}',
          method: 'POST');

  Future<dynamic> acceptFriendRequest(int requestId) =>
      request('$kAcceptFriendPath/$requestId', method: 'POST');

  Future<dynamic> rejectFriendRequest(int requestId) =>
      request('$kRejectFriendPath/$requestId', method: 'POST');

  Future<dynamic> unfriend(int requestId) =>
      request('$kUnfriendPath/$requestId', method: 'DELETE');

  // ─── Linked Transactions ───────────────────────────────────────────────────

  Future<dynamic> getPendingLinkedTransactions() =>
      request(kPendingLinkedTxnPath);

  Future<dynamic> sendLinkedTransactionRequest(Map<String, dynamic> payload) =>
      request(kSendLinkedTxnPath, method: 'POST', body: payload);

  Future<dynamic> acceptLinkedTransaction(int requestId) =>
      request('/linked-transactions/$requestId/accept', method: 'POST');

  Future<dynamic> rejectLinkedTransaction(int requestId) =>
      request('/linked-transactions/$requestId/reject', method: 'POST');

  Future<dynamic> getPendingLinkedPayments() =>
      request(kPendingLinkedPayPath);

  Future<dynamic> sendLinkedPaymentRequest(Map<String, dynamic> payload) =>
      request(kSendLinkedPayPath, method: 'POST', body: payload);

  Future<dynamic> acceptLinkedPayment(int requestId) =>
      request('/linked-transactions/payments/$requestId/accept', method: 'POST');

  Future<dynamic> rejectLinkedPayment(int requestId) =>
      request('/linked-transactions/payments/$requestId/reject', method: 'POST');
}
