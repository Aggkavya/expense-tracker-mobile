import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/format_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common_widgets.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Friend request search
  final _friendSearchCtrl = TextEditingController();
  bool _isSendingFriend = false;
  String _friendStatusMessage = '';
  String _friendErrorMessage = '';

  // Linked pending lists
  int? _activeRequestId;
  int? _activeLinkedId;
  int? _activeLinkedPayId;

  // Per-tab status
  String _tabStatusMessage = '';
  String _tabErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendFriendRequest() async {
    final userName = _friendSearchCtrl.text.trim();
    if (userName.isEmpty) return;

    setState(() {
      _isSendingFriend = true;
      _friendStatusMessage = '';
      _friendErrorMessage = '';
    });

    try {
      await context.read<FinanceProvider>().sendFriendRequest(userName);
      _friendSearchCtrl.clear();
      setState(() => _friendStatusMessage = 'Friend request sent to $userName.');
    } catch (e) {
      setState(() => _friendErrorMessage = e.toString());
    } finally {
      setState(() => _isSendingFriend = false);
    }
  }

  Future<void> _handleAcceptFriend(int requestId) async {
    setState(() => _activeRequestId = requestId);
    try {
      await context.read<FinanceProvider>().acceptFriendRequest(requestId);
      setState(() => _tabStatusMessage = 'Friend request accepted.');
    } catch (e) {
      setState(() => _tabErrorMessage = e.toString());
    } finally {
      setState(() => _activeRequestId = null);
    }
  }

  Future<void> _handleRejectFriend(int requestId) async {
    setState(() => _activeRequestId = requestId);
    try {
      await context.read<FinanceProvider>().rejectFriendRequest(requestId);
      setState(() => _tabStatusMessage = 'Friend request rejected.');
    } catch (e) {
      setState(() => _tabErrorMessage = e.toString());
    } finally {
      setState(() => _activeRequestId = null);
    }
  }

  Future<void> _handleUnfriend(int requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unfriend'),
        content: const Text('Are you sure you want to remove this friend?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unfriend'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await context.read<FinanceProvider>().unfriend(requestId);
    } catch (e) {
      setState(() => _tabErrorMessage = e.toString());
    }
  }

  Future<void> _handleAcceptLinkedTxn(int requestId) async {
    setState(() => _activeLinkedId = requestId);
    try {
      await context.read<FinanceProvider>().acceptLinkedTransaction(requestId);
      setState(() => _tabStatusMessage = 'Linked transaction accepted.');
    } catch (e) {
      setState(() => _tabErrorMessage = e.toString());
    } finally {
      setState(() => _activeLinkedId = null);
    }
  }

  Future<void> _handleRejectLinkedTxn(int requestId) async {
    setState(() => _activeLinkedId = requestId);
    try {
      await context.read<FinanceProvider>().rejectLinkedTransaction(requestId);
      setState(() => _tabStatusMessage = 'Linked transaction rejected.');
    } catch (e) {
      setState(() => _tabErrorMessage = e.toString());
    } finally {
      setState(() => _activeLinkedId = null);
    }
  }

  Future<void> _handleAcceptLinkedPay(int requestId) async {
    setState(() => _activeLinkedPayId = requestId);
    try {
      await context.read<FinanceProvider>().acceptLinkedPayment(requestId);
      setState(() => _tabStatusMessage = 'Payment accepted.');
    } catch (e) {
      setState(() => _tabErrorMessage = e.toString());
    } finally {
      setState(() => _activeLinkedPayId = null);
    }
  }

  Future<void> _handleRejectLinkedPay(int requestId) async {
    setState(() => _activeLinkedPayId = requestId);
    try {
      await context.read<FinanceProvider>().rejectLinkedPayment(requestId);
      setState(() => _tabStatusMessage = 'Payment rejected.');
    } catch (e) {
      setState(() => _tabErrorMessage = e.toString());
    } finally {
      setState(() => _activeLinkedPayId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final auth = context.watch<AuthProvider>();
    final colors = context.appColors;

    return Column(
      children: [
        // Stat row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: StatTile(
                    label: 'Friends',
                    value: finance.friends.length.toString(),
                    accent: 'blue'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                    label: 'Pending',
                    value: finance.pendingFriendRequests.length.toString(),
                    accent: 'orange'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                    label: 'Linked',
                    value: finance.pendingLinkedTransactions.length.toString(),
                    accent: 'emerald'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Send friend request
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionCard(
            eyebrow: 'Add Friend',
            title: 'Send Friend Request',
            child: Column(
              children: [
                StatusBanner(tone: 'success', message: _friendStatusMessage),
                if (_friendStatusMessage.isNotEmpty) const SizedBox(height: 10),
                StatusBanner(tone: 'error', message: _friendErrorMessage),
                if (_friendErrorMessage.isNotEmpty) const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Username',
                        controller: _friendSearchCtrl,
                        placeholder: 'friend_username',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: ElevatedButton(
                        onPressed: _isSendingFriend
                            ? null
                            : _handleSendFriendRequest,
                        child: _isSendingFriend
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white)),
                              )
                            : const Icon(Icons.person_add_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Status
        if (_tabStatusMessage.isNotEmpty || _tabErrorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                StatusBanner(tone: 'success', message: _tabStatusMessage),
                StatusBanner(tone: 'error', message: _tabErrorMessage),
              ],
            ),
          ),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: colors.brand,
            unselectedLabelColor: colors.muted,
            indicator: BoxDecoration(
              color: colors.brand.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            tabs: [
              Tab(
                child: _TabLabel(
                  label: 'Pending',
                  badge: finance.pendingFriendRequests.length,
                ),
              ),
              const Tab(text: 'Sent'),
              Tab(
                child: _TabLabel(
                  label: 'Friends',
                  badge: finance.friends.length,
                ),
              ),
              Tab(
                child: _TabLabel(
                  label: 'Shared',
                  badge: finance.pendingLinkedTransactions.length +
                      finance.pendingLinkedPayments.length,
                ),
              ),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Pending requests
              _buildPendingTab(finance, colors),
              // Sent requests
              _buildSentTab(finance, colors),
              // Friends list
              _buildFriendsTab(finance, colors, auth),
              // Shared/linked
              _buildSharedTab(finance, colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTab(FinanceProvider finance, AppColors colors) {
    if (finance.isFriendLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (finance.pendingFriendRequests.isEmpty) {
      return Center(
          child: Text('No pending requests.',
              style: TextStyle(color: colors.muted)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: finance.pendingFriendRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final req = finance.pendingFriendRequests[i];
        final reqId = req['id'] as int;
        final isBusy = _activeRequestId == reqId;

        return _FriendRequestCard(
          title: req['senderUsername'] ?? req['sender'] ?? '--',
          subtitle: 'Wants to be your friend',
          isBusy: isBusy,
          actions: [
            ElevatedButton(
              onPressed: isBusy ? null : () => _handleAcceptFriend(reqId),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(isBusy ? '...' : 'Accept',
                  style: const TextStyle(fontSize: 12)),
            ),
            OutlinedButton(
              onPressed: isBusy ? null : () => _handleRejectFriend(reqId),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF43F5E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(isBusy ? '...' : 'Reject',
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
          colors: colors,
        );
      },
    );
  }

  Widget _buildSentTab(FinanceProvider finance, AppColors colors) {
    if (finance.isFriendLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (finance.sentFriendRequests.isEmpty) {
      return Center(
          child: Text('No sent requests.',
              style: TextStyle(color: colors.muted)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: finance.sentFriendRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final req = finance.sentFriendRequests[i];
        return _FriendRequestCard(
          title: req['receiverUsername'] ?? req['receiver'] ?? '--',
          subtitle: 'Request pending',
          isBusy: false,
          actions: const [],
          colors: colors,
        );
      },
    );
  }

  Widget _buildFriendsTab(
      FinanceProvider finance, AppColors colors, AuthProvider auth) {
    if (finance.isFriendLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (finance.friends.isEmpty) {
      return Center(
          child: Text('No friends yet. Send a request!',
              style: TextStyle(color: colors.muted)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: finance.friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final f = finance.friends[i];
        final friendName = f['senderUsername'] == auth.userName
            ? f['receiverUsername']
            : f['senderUsername'];
        final reqId = f['id'] as int;

        return _FriendRequestCard(
          title: friendName ?? '--',
          subtitle: 'Friend',
          isBusy: false,
          colors: colors,
          actions: [
            OutlinedButton(
              onPressed: () => _handleUnfriend(reqId),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF43F5E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Unfriend', style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSharedTab(FinanceProvider finance, AppColors colors) {
    final txnItems = finance.pendingLinkedTransactions;
    final payItems = finance.pendingLinkedPayments;

    if (finance.isLinkedTransactionLoading && finance.isLinkedPaymentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (txnItems.isEmpty && payItems.isEmpty) {
      return Center(
          child: Text('No pending shared requests.',
              style: TextStyle(color: colors.muted)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (txnItems.isNotEmpty) ...[
          Text(
            'LINKED TRANSACTION REQUESTS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colors.muted),
          ),
          const SizedBox(height: 8),
          ...txnItems.map((txn) {
            final id = txn['id'] as int;
            final isBusy = _activeLinkedId == id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FriendRequestCard(
                title: txn['senderUsername'] ?? '--',
                subtitle:
                    '${txn['direction'] == 'I_OWE_THEM' ? 'They owe you' : 'You owe them'} · ${formatCurrency(txn['amount'])} · ${txn['description'] ?? ''}',
                isBusy: isBusy,
                colors: colors,
                actions: [
                  ElevatedButton(
                    onPressed:
                        isBusy ? null : () => _handleAcceptLinkedTxn(id),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(isBusy ? '...' : 'Accept',
                        style: const TextStyle(fontSize: 12)),
                  ),
                  OutlinedButton(
                    onPressed:
                        isBusy ? null : () => _handleRejectLinkedTxn(id),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF43F5E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(isBusy ? '...' : 'Reject',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
        if (payItems.isNotEmpty) ...[
          Text(
            'LINKED PAYMENT REQUESTS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colors.muted),
          ),
          const SizedBox(height: 8),
          ...payItems.map((pay) {
            final id = pay['id'] as int;
            final isBusy = _activeLinkedPayId == id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FriendRequestCard(
                title: pay['senderUsername'] ?? '--',
                subtitle:
                    '${formatCurrency(pay['amount'])} · ${pay['description'] ?? ''} · ${pay['paymentMode'] ?? ''}',
                isBusy: isBusy,
                colors: colors,
                actions: [
                  ElevatedButton(
                    onPressed:
                        isBusy ? null : () => _handleAcceptLinkedPay(id),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(isBusy ? '...' : 'Accept',
                        style: const TextStyle(fontSize: 12)),
                  ),
                  OutlinedButton(
                    onPressed:
                        isBusy ? null : () => _handleRejectLinkedPay(id),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF43F5E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(isBusy ? '...' : 'Reject',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _FriendRequestCard extends StatelessWidget {
  const _FriendRequestCard({
    required this.title,
    required this.subtitle,
    required this.isBusy,
    required this.actions,
    this.colors,
  });

  final String title;
  final String subtitle;
  final bool isBusy;
  final List<Widget> actions;
  final AppColors? colors;

  @override
  Widget build(BuildContext context) {
    final c = colors ?? context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.brand.withOpacity(0.7), c.brand],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.text),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: c.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 8),
            Column(
              children: actions
                  .map((a) => Padding(padding: const EdgeInsets.only(bottom: 4), child: a))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, this.badge = 0});
  final String label;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (badge > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge.toString(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }
}
