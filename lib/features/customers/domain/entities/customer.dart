import 'package:equatable/equatable.dart';
import 'customer_transaction.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String? nameOfficial;
  final String? phone;
  final String? email;
  final String? address;
  final double openingBalance;
  final double totalDebt;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double totalPurchases;
  final double totalPaid;
  final List<CustomerTransaction> transactions;

  const Customer({
    required this.id,
    required this.name,
    this.nameOfficial,
    this.phone,
    this.email,
    this.address,
    this.openingBalance = 0,
    this.totalDebt = 0,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.totalPurchases = 0,
    this.totalPaid = 0,
    this.transactions = const [],
  });

  Customer copyWith({
    String? id,
    String? name,
    String? nameOfficial,
    String? phone,
    String? email,
    String? address,
    double? openingBalance,
    double? totalDebt,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalPurchases,
    double? totalPaid,
    List<CustomerTransaction>? transactions,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      nameOfficial: nameOfficial ?? this.nameOfficial,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      openingBalance: openingBalance ?? this.openingBalance,
      totalDebt: totalDebt ?? this.totalDebt,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalPaid: totalPaid ?? this.totalPaid,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameOfficial,
    phone,
    email,
    address,
    openingBalance,
    totalDebt,
    imageUrl,
    createdAt,
    updatedAt,
    totalPurchases,
    totalPaid,
    transactions,
  ];
}
