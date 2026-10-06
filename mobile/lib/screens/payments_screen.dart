import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/icons.dart';
import '../widgets/section_header.dart';
import '../widgets/service_card.dart';
import 'payment_sheet.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: state.load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Payments', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                for (final s in state.services)
                  ServiceCard(
                    category: s.id,
                    name: s.name,
                    description: s.description,
                    onTap: () => showPaymentSheet(context, s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Recent Payments'),
            if (state.recentPayments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'No payments yet. Pick a service above to make one.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              Container(
                decoration: cardDecoration(),
                child: Column(
                  children: [
                    for (final p in state.recentPayments.take(5))
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            iconForCategory(
                              p.serviceName.toLowerCase().split(' ').last,
                            ),
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          p.serviceName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '${p.reference} · ${formatDate(p.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          formatEgp(p.amount),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
