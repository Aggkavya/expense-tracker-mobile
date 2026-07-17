import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main_shell.dart';
import '../screens/overview_screen.dart';
import '../screens/balances_screen.dart';
import '../screens/expense/new_expense_screen.dart';
import '../screens/expense/expense_history_screen.dart';
import '../screens/income/new_income_screen.dart';
import '../screens/income/income_history_screen.dart';
import '../screens/debt/new_debt_screen.dart';
import '../screens/debt/debt_history_screen.dart';
import '../screens/receivable/new_receivable_screen.dart';
import '../screens/receivable/receivable_history_screen.dart';
import '../screens/friends/friends_screen.dart';

GoRouter buildRouter(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  return GoRouter(
    initialLocation: '/overview',
    redirect: (context, state) async {
      final isAuth = await authProvider.checkAuth();
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return '/overview';
      return null;
    },
    routes: [
      // ── Auth routes ──────────────────────────────────────────────────────
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (_, __) => const SignupScreen(),
      ),

      // ── App shell ────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/overview',
            builder: (_, __) => const OverviewScreen(),
          ),
          GoRoute(
            path: '/balances',
            builder: (_, __) => const BalancesScreen(),
          ),
          GoRoute(
            path: '/expenses/new',
            builder: (_, __) => const NewExpenseScreen(),
          ),
          GoRoute(
            path: '/expenses/history',
            builder: (_, __) => const ExpenseHistoryScreen(),
          ),
          GoRoute(
            path: '/incomes/new',
            builder: (_, __) => const NewIncomeScreen(),
          ),
          GoRoute(
            path: '/incomes/history',
            builder: (_, __) => const IncomeHistoryScreen(),
          ),
          GoRoute(
            path: '/debts/new',
            builder: (_, __) => const NewDebtScreen(),
          ),
          GoRoute(
            path: '/debts/history',
            builder: (_, __) => const DebtHistoryScreen(),
          ),
          GoRoute(
            path: '/receivables/new',
            builder: (_, __) => const NewReceivableScreen(),
          ),
          GoRoute(
            path: '/receivables/history',
            builder: (_, __) => const ReceivableHistoryScreen(),
          ),
          GoRoute(
            path: '/friends',
            builder: (_, __) => const FriendsScreen(),
          ),
        ],
      ),
    ],
  );
}
