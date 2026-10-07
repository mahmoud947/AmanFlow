import 'package:amanflow/app.dart';
import 'package:amanflow/data/models.dart';
import 'package:amanflow/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepository implements FinanceRepository {
  bool authenticated = false;
  bool rejectSignIn = false;
  @override
  Future<void> signIn(String identifier, String password) async {
    if (rejectSignIn) throw Exception('Invalid credentials');
    if (identifier == 'demo@amanflow.example' && password == 'Demo-only-2026!') {
      authenticated = true;
      return;
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<Wallet> getWallet() async {
    if (!authenticated) throw StateError('Not authenticated');
    return const Wallet(id: 'w1', balance: 12450, currency: 'EGP', maskedNumber: '•••• 4821');
  }
  @override
  Future<Profile> getProfile() async =>
      const Profile(id: 'c1', name: 'Ahmed Hassan', phone: '+20 10 *** **67', customerCode: 'AF-102938');
  @override
  Future<List<TransactionItemData>> getTransactions() async => [
        TransactionItemData(id: '1', title: 'Vodafone Recharge', category: 'recharge', isCredit: false, amount: 150, occurredAt: DateTime(2026, 10, 5)),
        TransactionItemData(id: '2', title: 'Cashback', category: 'cashback', isCredit: true, amount: 75, occurredAt: DateTime(2026, 10, 2)),
      ];
  @override
  Future<List<PaymentServiceData>> getServices() async =>
      const [PaymentServiceData(id: 'recharge', name: 'Mobile Recharge', category: 'telecom', description: 'Top up')];
  @override
  Future<List<PaymentResult>> getRecentPayments() async => [];
  String? lastPayment;
  @override
  Future<PaymentResult> makePayment({required String serviceId, required num amount, required String reference}) async {
    lastPayment = '$serviceId|$amount|$reference';
    return PaymentResult(id: 'p1', serviceName: 'Mobile Recharge', amount: amount, reference: reference, status: 'completed', createdAt: DateTime.now());
  }
}

Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('login-identifier')), 'demo@amanflow.example');
  await tester.enterText(find.byKey(const Key('login-password')), 'Demo-only-2026!');
  await tester.tap(find.byKey(const Key('login-submit')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Protected content stays hidden until sign-in succeeds', (tester) async {
    final repo = FakeRepository()..rejectSignIn = true;
    await tester.pumpWidget(AmanFlowApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Available Balance'), findsNothing);
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Enter an email or mobile number.'), findsOneWidget);
    await signIn(tester);
    expect(find.text('Available Balance'), findsNothing);
    expect(find.textContaining('Sign in could not be completed'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email or mobile number'), findsOneWidget);
    repo.rejectSignIn = false;
    await signIn(tester);
    expect(find.text('Available Balance'), findsOneWidget);
  });

  testWidgets('Home renders API data and navigation reaches all areas', (tester) async {
    await tester.pumpWidget(AmanFlowApp(repository: FakeRepository()));
    await tester.pumpAndSettle();
    await signIn(tester);

    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('EGP 12,450.00'), findsOneWidget);
    expect(find.text('Vodafone Recharge'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);

    await tester.tap(find.text('Payments').last);
    await tester.pumpAndSettle();
    expect(find.text('Recent Payments'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Ahmed Hassan'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
  });

  testWidgets('Payments sheet submits a payment through the repository', (tester) async {
    final repo = FakeRepository();
    await tester.pumpWidget(AmanFlowApp(repository: repo));
    await tester.pumpAndSettle();
    await signIn(tester);

    await tester.tap(find.text('Payments').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile Recharge').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment-reference')), '01012345678');
    await tester.enterText(find.byKey(const Key('payment-amount')), '150');
    await tester.tap(find.text('Pay now'));
    await tester.pumpAndSettle();

    expect(repo.lastPayment, 'recharge|150|01012345678');
  });
}
