import 'api_client.dart';
import 'models.dart';

abstract class FinanceRepository {
  Future<void> signIn(String identifier, String password);
  Future<Wallet> getWallet();
  Future<List<TransactionItemData>> getTransactions();
  Future<List<PaymentServiceData>> getServices();
  Future<Profile> getProfile();
  Future<List<PaymentResult>> getRecentPayments();
  Future<PaymentResult> makePayment({
    required String serviceId,
    required num amount,
    required String reference,
  });
}

class ApiFinanceRepository implements FinanceRepository {
  final ApiClient _api;
  ApiFinanceRepository(this._api);

  @override
  Future<void> signIn(String identifier, String password) =>
      _api.signIn(identifier, password);

  List<Map<String, dynamic>> _list(dynamic json) =>
      (json as List).cast<Map<String, dynamic>>();

  @override
  Future<Wallet> getWallet() async =>
      Wallet.fromJson(await _api.get('/wallet'));

  @override
  Future<List<TransactionItemData>> getTransactions() async => _list(
    await _api.get('/transactions'),
  ).map(TransactionItemData.fromJson).toList();

  @override
  Future<List<PaymentServiceData>> getServices() async => _list(
    await _api.get('/services'),
  ).map(PaymentServiceData.fromJson).toList();

  @override
  Future<Profile> getProfile() async =>
      Profile.fromJson(await _api.get('/profile'));

  @override
  Future<List<PaymentResult>> getRecentPayments() async =>
      _list(await _api.get('/payments')).map(PaymentResult.fromJson).toList();

  @override
  Future<PaymentResult> makePayment({
    required String serviceId,
    required num amount,
    required String reference,
  }) async => PaymentResult.fromJson(
    await _api.post('/payments', {
      'serviceId': serviceId,
      'amount': amount,
      'reference': reference,
    }),
  );
}
