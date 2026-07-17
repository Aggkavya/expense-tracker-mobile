import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/format_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';

/// Main navigation shell — provides bottom nav bar and side drawer
/// Mirrors AppShell.jsx
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _bottomNavIndex = 0;

  static const _bottomRoutes = [
    '/overview',
    '/expenses/history',
    '/incomes/history',
    '/debts/history',
    '/friends',
  ];

  final _drawerNavItems = [
    _NavItem(label: 'Overview', icon: Icons.dashboard_rounded, route: '/overview'),
    _NavItem(label: 'Balances', icon: Icons.swap_horiz_rounded, route: '/balances'),
    _NavItem(label: 'New Expense', icon: Icons.add_circle_outline_rounded, route: '/expenses/new'),
    _NavItem(label: 'Expense History', icon: Icons.receipt_long_rounded, route: '/expenses/history'),
    _NavItem(label: 'New Income', icon: Icons.attach_money_rounded, route: '/incomes/new'),
    _NavItem(label: 'Income History', icon: Icons.account_balance_rounded, route: '/incomes/history'),
    _NavItem(label: 'New Receivable', icon: Icons.trending_up_rounded, route: '/receivables/new'),
    _NavItem(label: 'Receivable Ledger', icon: Icons.list_alt_rounded, route: '/receivables/history'),
    _NavItem(label: 'New Debt', icon: Icons.money_off_rounded, route: '/debts/new'),
    _NavItem(label: 'Debt Ledger', icon: Icons.account_balance_wallet_rounded, route: '/debts/history'),
    _NavItem(label: 'Friends', icon: Icons.people_rounded, route: '/friends'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final finance = context.watch<FinanceProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, colors, finance, auth, theme),
      drawer: _buildDrawer(context, colors, auth, theme),
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(context, colors),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppColors colors,
    FinanceProvider finance,
    AuthProvider auth,
    ThemeProvider theme,
  ) {
    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: colors.border, height: 1),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: colors.gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'FT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Finance Tracker',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        // Notification Bell
        _NotificationBell(finance: finance, colors: colors),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: colors.muted,
          ),
          onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          tooltip: theme.isDark ? 'Light mode' : 'Dark mode',
        ),
      ],
    );
  }

  Widget _buildDrawer(
      BuildContext context, AppColors colors, AuthProvider auth, ThemeProvider theme) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: colors.surface,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(gradient: colors.gradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'FT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Finance Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    auth.userName.isEmpty ? '--' : auth.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: _drawerNavItems.map((item) {
                final isActive = currentRoute == item.route;
                return _DrawerNavTile(
                  item: item,
                  isActive: isActive,
                  colors: colors,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(item.route);
                    final idx = _bottomRoutes.indexOf(item.route);
                    if (idx != -1) setState(() => _bottomNavIndex = idx);
                  },
                );
              }).toList(),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Divider(color: colors.border),
                ListTile(
                  leading: Icon(
                    theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: colors.muted,
                    size: 22,
                  ),
                  title: Text(
                    theme.isDark ? 'Light mode' : 'Dark mode',
                    style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onTap: () => context.read<ThemeProvider>().toggleTheme(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: colors.muted, size: 22),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/auth/login');
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppColors colors) {
    return NavigationBar(
      selectedIndex: _bottomNavIndex,
      backgroundColor: colors.surface,
      indicatorColor: colors.brand.withOpacity(0.15),
      surfaceTintColor: Colors.transparent,
      onDestinationSelected: (index) {
        setState(() => _bottomNavIndex = index);
        context.go(_bottomRoutes[index]);
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined, color: colors.muted),
          selectedIcon: Icon(Icons.dashboard_rounded, color: colors.brand),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined, color: colors.muted),
          selectedIcon: Icon(Icons.receipt_long_rounded, color: colors.brand),
          label: 'Expenses',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_outlined, color: colors.muted),
          selectedIcon: Icon(Icons.account_balance_rounded, color: colors.brand),
          label: 'Income',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined, color: colors.muted),
          selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: colors.brand),
          label: 'Debts',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline_rounded, color: colors.muted),
          selectedIcon: Icon(Icons.people_rounded, color: colors.brand),
          label: 'Friends',
        ),
      ],
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.route});
  final String label;
  final IconData icon;
  final String route;
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.item,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? colors.brand.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? colors.brand.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.icon,
          color: isActive ? colors.brand : colors.muted,
          size: 20,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isActive ? colors.brand : colors.text,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.finance, required this.colors});
  final FinanceProvider finance;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final count = finance.unreadNotificationCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: colors.muted),
          onPressed: () => _showNotificationPanel(context),
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationPanel(BuildContext context) {
    final finance = context.read<FinanceProvider>();
    finance.loadNotifications();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: finance,
        child: const _NotificationPanel(),
      ),
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final finance = context.watch<FinanceProvider>();

    final unreadIds = finance.unreadNotifications.map((n) => n['id']).toSet();
    final readItems = finance.notifications
        .where((n) => !unreadIds.contains(n['id']))
        .toList();
    final allItems = [...finance.unreadNotifications, ...readItems];

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                TextButton.icon(
                  onPressed: finance.unreadNotificationCount == 0
                      ? null
                      : () => context.read<FinanceProvider>().markAllNotificationsAsRead(),
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('Mark all read'),
                ),
              ],
            ),
          ),

          Divider(color: colors.border),

          // List
          Expanded(
            child: finance.isNotificationLoading
                ? const Center(child: CircularProgressIndicator())
                : allItems.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications yet.',
                          style: TextStyle(color: colors.muted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: allItems.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final n = allItems[i];
                          final isRead = n['isRead'] == true;
                          final isUnread = !isRead;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? colors.brand.withOpacity(0.08)
                                  : colors.surfaceSoft,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isUnread
                                    ? colors.brand.withOpacity(0.3)
                                    : colors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['message'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colors.text,
                                        ),
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: colors.brand,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatDate(n['createdAt']),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.muted,
                                  ),
                                ),
                                if (isUnread) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        final id = n['id'];
                                        if (id != null) {
                                          context
                                              .read<FinanceProvider>()
                                              .markNotificationAsRead(id as int);
                                        }
                                      },
                                      child: const Text('Mark read',
                                          style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
