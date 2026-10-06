import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/quick_action.dart';
import '../widgets/section_header.dart';
import '../widgets/transaction_item.dart';
import 'payment_sheet.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenPayments;
  const HomeScreen({super.key, required this.onOpenPayments});

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : (h < 18 ? 'Good afternoon' : 'Good evening');
  }

  void _pay(BuildContext context, String serviceId) {
    final s = context.read<AppState>().services.where((e) => e.id == serviceId);
    if (s.isNotEmpty) showPaymentSheet(context, s.first);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final wallet = state.wallet;
    final profile = state.profile;

    if (state.loading && wallet == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (wallet == null || profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error ?? 'Something went wrong'),
            TextButton(onPressed: state.load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HeaderBackdrop(height: 260),
          ),
          RefreshIndicator(
            onRefresh: state.load,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                top + AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              children: [
                AppHeader(greeting: _greeting(), name: profile.firstName),
                const SizedBox(height: AppSpacing.lg),
                BalanceCard(
                  balance: wallet.balance,
                  walletLabel: wallet.maskedNumber,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Pay a Bill',
                  icon: Icons.add_rounded,
                  accent: true,
                  onPressed: () => _pay(context, 'electricity'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuickAction(
                      icon: Icons.send_rounded,
                      label: 'Send Money',
                      onTap: () => _comingSoon(context, 'Send Money'),
                    ),
                    QuickAction(
                      icon: Icons.receipt_long_rounded,
                      label: 'Pay Bills',
                      onTap: () => _pay(context, 'electricity'),
                    ),
                    QuickAction(
                      icon: Icons.smartphone_rounded,
                      label: 'Mobile Recharge',
                      onTap: () => _pay(context, 'recharge'),
                    ),
                    QuickAction(
                      icon: Icons.grid_view_rounded,
                      label: 'More',
                      onTap: onOpenPayments,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Recent Transactions',
                  actionLabel: 'View All',
                  onAction: () => _comingSoon(context, 'All transactions'),
                ),
                Container(
                  decoration: cardDecoration(),
                  child: Column(
                    children: [
                      for (final t in state.transactions.take(6))
                        TransactionItem(tx: t),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is not part of this demo yet')),
    );
  }
}
