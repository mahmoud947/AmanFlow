import 'package:amanflow/app.dart';
import 'package:amanflow/data/api_client.dart';
import 'package:amanflow/data/biometric_authenticator.dart';
import 'package:amanflow/data/models.dart';
import 'package:amanflow/data/repository.dart';
import 'package:amanflow/data/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const testSession = 'fictional-test-session';

class FakeStore implements SessionStore {
  String? session;
  bool rejectClear = false;
  @override
  Future<String?> read() async => session;
  @override
  Future<void> write(String value) async => session = value;
  @override
  Future<void> clear() async {
    if (rejectClear) throw StateError('Storage unavailable');
    session = null;
  }
}

class FakeBiometrics implements BiometricAuthenticator {
  bool available = true;
  bool result = true;
  int prompts = 0;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<bool> authenticate() async {
    prompts++;
    return result;
  }
}

class FakeRepository implements FinanceRepository {
  bool authenticated = false;
  bool rejectSignIn = false;
  int? validationError;
  String? _session;
  @override
  String? get sessionMaterial => _session;
  @override
  void clearSession() {
    _session = null;
    authenticated = false;
  }
  @override
  Future<void> validateSession(String session) async {
    if (validationError != null) throw ApiException('Not validated', statusCode: validationError);
    if (session != testSession) throw ApiException('Invalid', statusCode: 401);
    _session = session;
    authenticated = true;
  }
  @override
  Future<void> signIn(String identifier, String password) async {
    if (rejectSignIn) throw Exception('Invalid credentials');
    if (identifier == 'demo@amanflow.example' && password == 'Demo-only-2026!') {
      authenticated = true;
      _session = testSession;
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

Future<void> openProfile(WidgetTester tester) async {
  await tester.tap(find.text('Profile').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Protected content stays hidden until sign-in succeeds', (tester) async {
    final repo = FakeRepository()..rejectSignIn = true;
    await tester.pumpWidget(AmanFlowApp(repository: repo, sessionStore: FakeStore(), biometrics: FakeBiometrics()));
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
    final store = FakeStore();
    await tester.pumpWidget(AmanFlowApp(repository: FakeRepository(), sessionStore: store, biometrics: FakeBiometrics()));
    await tester.pumpAndSettle();
    await signIn(tester);
    expect(store.session, testSession);
    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('EGP 12,450.00'), findsOneWidget);
    expect(find.text('Vodafone Recharge'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    await tester.tap(find.text('Payments').last);
    await tester.pumpAndSettle();
    expect(find.text('Recent Payments'), findsOneWidget);
    await openProfile(tester);
    expect(find.text('Ahmed Hassan'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
  });

  testWidgets('Payments sheet submits a payment through the repository', (tester) async {
    final repo = FakeRepository();
    await tester.pumpWidget(AmanFlowApp(repository: repo, sessionStore: FakeStore(), biometrics: FakeBiometrics()));
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

  testWidgets('Stored session is offered but not exposed before validation', (tester) async {
    final repo = FakeRepository();
    final bio = FakeBiometrics();
    await tester.pumpWidget(AmanFlowApp(repository: repo, sessionStore: FakeStore()..session = testSession, biometrics: bio));
    await tester.pumpAndSettle();
    expect(find.text('Available Balance'), findsNothing);
    expect(find.text('Unlock with biometrics'), findsOneWidget);
    expect(find.text('Use password'), findsOneWidget);
    expect(bio.prompts, 0);
    await tester.tap(find.text('Unlock with biometrics'));
    await tester.pumpAndSettle();
    expect(bio.prompts, 1);
    expect(find.text('Available Balance'), findsOneWidget);
  });

  testWidgets('Unavailable biometrics or absent storage uses password without a prompt', (tester) async {
    final bio = FakeBiometrics()..available = false;
    await tester.pumpWidget(AmanFlowApp(repository: FakeRepository(), sessionStore: FakeStore()..session = testSession, biometrics: bio));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(bio.prompts, 0);
    await tester.pumpWidget(const SizedBox());
    final freshBio = FakeBiometrics();
    await tester.pumpWidget(AmanFlowApp(repository: FakeRepository(), sessionStore: FakeStore(), biometrics: freshBio));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(freshBio.prompts, 0);
  });

  testWidgets('Failure and explicit password fallback do not authenticate', (tester) async {
    final bio = FakeBiometrics()..result = false;
    final repo = FakeRepository();
    await tester.pumpWidget(AmanFlowApp(repository: repo, sessionStore: FakeStore()..session = testSession, biometrics: bio));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock with biometrics'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(find.text('Available Balance'), findsNothing);
    expect(repo.authenticated, false);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(AmanFlowApp(repository: FakeRepository(), sessionStore: FakeStore()..session = testSession, biometrics: FakeBiometrics()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use password'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });

  testWidgets('Invalid session is removed; service error fails closed without deletion', (tester) async {
    final store = FakeStore()..session = testSession;
    final repo = FakeRepository()..validationError = 401;
    await tester.pumpWidget(AmanFlowApp(repository: repo, sessionStore: store, biometrics: FakeBiometrics()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock with biometrics'));
    await tester.pumpAndSettle();
    expect(store.session, null);
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(find.text('Available Balance'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    final temporaryStore = FakeStore()..session = testSession;
    await tester.pumpWidget(AmanFlowApp(repository: FakeRepository()..validationError = 503, sessionStore: temporaryStore, biometrics: FakeBiometrics()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock with biometrics'));
    await tester.pumpAndSettle();
    expect(temporaryStore.session, testSession);
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(find.text('Available Balance'), findsNothing);
  });

  testWidgets('Logout clears stored session before password fallback', (tester) async {
    final store = FakeStore();
    final repo = FakeRepository();
    await tester.pumpWidget(AmanFlowApp(repository: repo, sessionStore: store, biometrics: FakeBiometrics()));
    await tester.pumpAndSettle();
    await signIn(tester);
    await openProfile(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('profile-logout')), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pumpAndSettle();
    expect(store.session, null);
    expect(repo.authenticated, false);
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(find.text('Available Balance'), findsNothing);
  });

  testWidgets('Clearing failure conceals account and requires retry', (tester) async {
    final store = FakeStore()..rejectClear = true;
    await tester.pumpWidget(AmanFlowApp(repository: FakeRepository(), sessionStore: store, biometrics: FakeBiometrics()));
    await tester.pumpAndSettle();
    await signIn(tester);
    await openProfile(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('profile-logout')), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pumpAndSettle();
    expect(find.text('Available Balance'), findsNothing);
    expect(find.byKey(const Key('login-submit')), findsNothing);
    expect(store.session, testSession);
    store.rejectClear = false;
    await tester.tap(find.text('Retry logout'));
    await tester.pumpAndSettle();
    expect(store.session, null);
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });
}
