class Wallet {
  final String id;
  final num balance;
  final String currency;
  final String maskedNumber;
  const Wallet({
    required this.id,
    required this.balance,
    required this.currency,
    required this.maskedNumber,
  });

  factory Wallet.fromJson(Map<String, dynamic> j) => Wallet(
    id: j['id'] as String,
    balance: j['balance'] as num,
    currency: j['currency'] as String,
    maskedNumber: (j['maskedNumber'] ?? '') as String,
  );
}

class TransactionItemData {
  final String id;
  final String title;
  final String category;
  final bool isCredit;
  final num amount;
  final DateTime occurredAt;
  const TransactionItemData({
    required this.id,
    required this.title,
    required this.category,
    required this.isCredit,
    required this.amount,
    required this.occurredAt,
  });

  factory TransactionItemData.fromJson(Map<String, dynamic> j) =>
      TransactionItemData(
        id: j['id'] as String,
        title: j['title'] as String,
        category: j['category'] as String,
        isCredit: j['direction'] == 'credit',
        amount: j['amount'] as num,
        occurredAt: DateTime.parse(j['occurredAt'] as String),
      );
}

class PaymentServiceData {
  final String id;
  final String name;
  final String category;
  final String description;
  const PaymentServiceData({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  factory PaymentServiceData.fromJson(Map<String, dynamic> j) =>
      PaymentServiceData(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        description: (j['description'] ?? '') as String,
      );
}

class PaymentResult {
  final String id;
  final String serviceName;
  final num amount;
  final String reference;
  final String status;
  final DateTime createdAt;
  const PaymentResult({
    required this.id,
    required this.serviceName,
    required this.amount,
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> j) => PaymentResult(
    id: j['id'] as String,
    serviceName: j['serviceName'] as String,
    amount: j['amount'] as num,
    reference: j['reference'] as String,
    status: j['status'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

class Profile {
  final String id;
  final String name;
  final String phone;
  final String customerCode;
  const Profile({
    required this.id,
    required this.name,
    required this.phone,
    required this.customerCode,
  });

  String get firstName => name.split(' ').first;

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    id: j['id'] as String,
    name: j['name'] as String,
    phone: j['phone'] as String,
    customerCode: j['customerCode'] as String,
  );
}
