import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/primary_button.dart';

/// Lightweight payment form. Submits to POST /payments through AppState.
Future<void> showPaymentSheet(
  BuildContext context,
  PaymentServiceData service,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppState>(),
      child: _PaymentSheet(service: service),
    ),
  );
}

class _PaymentSheet extends StatefulWidget {
  final PaymentServiceData service;
  const _PaymentSheet({required this.service});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _reference = TextEditingController();
  final _amount = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reference.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = num.tryParse(_amount.text.trim());
    if (_reference.text.trim().isEmpty || amount == null || amount <= 0) {
      setState(
        () => _error = 'Enter a reference and an amount greater than 0.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final r = await state.pay(
        serviceId: widget.service.id,
        amount: amount,
        reference: _reference.text.trim(),
      );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${r.serviceName}: ${formatEgp(r.amount)} paid successfully',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay ${widget.service.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('payment-reference'),
            controller: _reference,
            decoration: const InputDecoration(
              labelText: 'Phone / account number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md - 4),
          TextField(
            key: const Key('payment-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (EGP)',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Pay now',
            loading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
