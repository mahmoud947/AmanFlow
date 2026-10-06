import 'package:flutter/foundation.dart';
import '../data/models.dart';
import '../data/repository.dart';

/// Single small ChangeNotifier holding everything the three tabs display.
class AppState extends ChangeNotifier {
  final FinanceRepository repo;
  AppState(this.repo);

  Wallet? wallet;
  Profile? profile;
  List<TransactionItemData> transactions = [];
  List<PaymentServiceData> services = [];
  List<PaymentResult> recentPayments = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        repo.getWallet(),
        repo.getProfile(),
        repo.getTransactions(),
        repo.getServices(),
        repo.getRecentPayments(),
      ]);
      wallet = results[0] as Wallet;
      profile = results[1] as Profile;
      transactions = results[2] as List<TransactionItemData>;
      services = results[3] as List<PaymentServiceData>;
      recentPayments = results[4] as List<PaymentResult>;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<PaymentResult> pay({
    required String serviceId,
    required num amount,
    required String reference,
  }) async {
    final result = await repo.makePayment(
      serviceId: serviceId,
      amount: amount,
      reference: reference,
    );
    await load();
    return result;
  }
}
