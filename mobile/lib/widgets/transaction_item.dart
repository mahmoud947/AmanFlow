import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'icons.dart';

class TransactionItem extends StatelessWidget {
  final TransactionItemData tx;
  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = tx.isCredit ? AppColors.credit : AppColors.debit;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      leading: CircleAvatar(
        backgroundColor: tx.isCredit
            ? color.withValues(alpha: 0.12)
            : AppColors.primaryLight,
        child: Icon(
          iconForCategory(tx.category),
          color: tx.isCredit ? color : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(tx.title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        formatDate(tx.occurredAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        '${tx.isCredit ? '+' : '-'} ${formatEgp(tx.amount)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
