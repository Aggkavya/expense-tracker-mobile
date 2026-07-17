// ─── Backend base URL ──────────────────────────────────────────────────────
// Change this to your Render deployment URL.
// Example: 'https://expense-tracker-xyz.onrender.com'
const String kApiBaseUrl = 'https://expensetracker-backend-oe7e.onrender.com';

// Auth
const String kSignupPath = '/public/signup';
const String kLoginPath = '/public/login';

// User / Balance
const String kGetBalancePath = '/user/getBalance';
const String kUpdateBalancePath = '/user/updateBalance';
const String kSearchUsersPath = '/user/search';

// Notifications
const String kNotificationsPath = '/notifications';
const String kUnreadNotificationsPath = '/notifications/unread';
const String kUnreadNotificationCountPath = '/notifications/count';
const String kMarkAllReadPath = '/notifications/readAll';

// Expense
const String kNewExpensePath = '/expense/newExpense';
const String kAllExpensesPath = '/expense/allExpenses';
const String kFilterExpensesPath = '/expense/filter';
const String kExpenseTotalPath = '/expense/total';
const String kDeleteExpensePath = '/expense/delete';

// Income
const String kNewIncomePath = '/income/newIncome';
const String kAllIncomesPath = '/income/allIncomes';
const String kIncomeTotalPath = '/income/total';
const String kDeleteIncomePath = '/income/delete';

// Debt
const String kNewDebtPath = '/debt/newDebt';
const String kAllDebtsPath = '/debt/allDebts';
const String kPayDebtPath = '/debt/pay';
const String kDeleteDebtPath = '/debt/delete';

// Receivable
const String kNewReceivablePath = '/receivable/newReceivable';
const String kAllReceivablesPath = '/receivable/allReceivables';
const String kCollectReceivablePath = '/receivable/collect';
const String kDeleteReceivablePath = '/receivable/delete';

// Friends
const String kPendingFriendsPath = '/friend/pending';
const String kSentFriendsPath = '/friend/sent';
const String kAllFriendsPath = '/friend/all';
const String kAcceptFriendPath = '/friend/accept';
const String kRejectFriendPath = '/friend/reject';
const String kUnfriendPath = '/friend/unfriend';

// Linked Transactions
const String kPendingLinkedTxnPath = '/linked-transactions/pending';
const String kSendLinkedTxnPath = '/linked-transactions/send';
const String kPendingLinkedPayPath = '/linked-transactions/payments/pending';
const String kSendLinkedPayPath = '/linked-transactions/payments/send';

// Constants
const List<String> kExpenseCategories = [
  'FOOD',
  'STUDY',
  'TRAVEL',
  'MISCELLANEOUS',
  'SHOPPING',
  'ENTERTAINMENT',
  'HEALTH',
  'RENT',
  'BILLS',
  'OTHERS',
];

const List<String> kPaymentModes = ['CASH', 'ONLINE'];

const List<String> kLinkedDirections = ['I_OWE_THEM', 'THEY_OWE_ME'];
