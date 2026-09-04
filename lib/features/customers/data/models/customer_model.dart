import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_transaction.dart';

class CustomerModel {
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

  const CustomerModel({
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

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final rawInvoices = json['invoices'] as List<dynamic>? ?? [];
    final rawPayments = json['payments'] as List<dynamic>? ?? [];

    double totalPurchases = 0;
    if (json.containsKey('total_purchases')) {
      totalPurchases = (json['total_purchases'] as num?)?.toDouble() ?? 0;
    } else {
      for (final inv in rawInvoices) {
        totalPurchases += (inv['total_amount'] as num?)?.toDouble() ?? 0;
      }
    }

    double totalPaid = 0;
    if (json.containsKey('total_paid')) {
      totalPaid = (json['total_paid'] as num?)?.toDouble() ?? 0;
    } else {
      for (final pay in rawPayments) {
        totalPaid += (pay['amount'] as num?)?.toDouble() ?? 0;
      }
    }

    final transactions = <CustomerTransaction>[];
    double sumOpening = 0;

    for (final inv in rawInvoices) {
      if (inv is! Map<String, dynamic>) continue;
      final invId = inv['id']?.toString() ?? '';
      if (invId.isEmpty) continue;
      final rawDate = inv['created_at']?.toString();
      final date = rawDate != null ? DateTime.tryParse(rawDate) : null;
      if (date == null) continue;
      final amount = (inv['total_amount'] as num?)?.toDouble() ?? 0.0;
      final status = inv['payment_status'] as String? ?? 'debt';
      final isOpening = inv['is_opening_balance'] == true ||
          inv['invoice_type'] == 'opening_balance';

      if (isOpening) {
        sumOpening += amount;
        transactions.add(CustomerTransaction(
          id: invId,
          type: 'opening_debt',
          amount: amount,
          createdAt: date,
          title: AppStrings.transactionOpeningDebt,
          subtitle: AppStrings.transactionOpeningDebtSubtitle,
          statusLabel: AppStrings.transactionPending,
        ));
      } else {
        String statusLabel = AppStrings.transactionDeferred;
        if (status == 'paid') statusLabel = AppStrings.transactionPaid;
        if (status == 'partial') statusLabel = AppStrings.transactionPartial;

        final shortId = invId.substring(0, invId.length > 8 ? 8 : invId.length);
        transactions.add(CustomerTransaction(
          id: invId,
          type: 'invoice',
          amount: amount,
          createdAt: date,
          title: AppStrings.transactionSalesInvoice(shortId),
          subtitle: AppStrings.transactionRemaining(
            '${(inv['remaining_amount'] as num?)?.toDouble() ?? 0}',
          ),
          statusLabel: statusLabel,
        ));
      }
    }

    for (final pay in rawPayments) {
      if (pay is! Map<String, dynamic>) continue;
      final payId = pay['id']?.toString() ?? '';
      if (payId.isEmpty) continue;
      final rawDate = pay['created_at']?.toString();
      final date = rawDate != null ? DateTime.tryParse(rawDate) : null;
      if (date == null) continue;
      final amount = (pay['amount'] as num?)?.toDouble() ?? 0.0;

      transactions.add(CustomerTransaction(
        id: payId,
        type: 'payment',
        amount: amount,
        createdAt: date,
        title: AppStrings.transactionCashPayment,
        subtitle: AppStrings.transactionCashPaymentSubtitle,
        statusLabel: AppStrings.transactionReceived,
      ));
    }

    // Parse debt from multiple possible keys (REST snake/camel, legacy)
    final jsonDebt = (json['total_debt'] as num?)?.toDouble() ??
        (json['current_debt'] as num?)?.toDouble() ??
        (json['computed_debt'] as num?)?.toDouble() ??
        (json['totalDebt'] as num?)?.toDouble() ??
        (json['currentDebt'] as num?)?.toDouble() ??
        0;
    // Backend totalDebt is authoritative; sumOpening is fallback only when jsonDebt is zero
    final double totalDebt = jsonDebt != 0 ? jsonDebt : sumOpening;

    final createdAtStr = json['created_at'] as String?;
    final updatedAtStr = json['updated_at'] as String?;

    // Synthetic opening_debt for legacy total_debt without an opening invoice
    // NOTE: id is kept as 'opening_debt' for backward compat with existing tests/
    // widgets that key on this id. In production each customer list has at most
    // one synthetic entry, so cross-customer duplication is not a ListView issue.
    // For true uniqueness use 'synthetic_${customerId}_opening'.
    final hasOpening = transactions.any((t) => t.type == 'opening_debt');
    if (!hasOpening && totalDebt > 0) {
      final syntheticDate = createdAtStr != null
          ? DateTime.tryParse(createdAtStr) ?? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0);
      transactions.add(CustomerTransaction(
        id: 'opening_debt',
        type: 'opening_debt',
        amount: totalDebt,
        createdAt: syntheticDate,
        title: AppStrings.transactionOpeningDebt,
        subtitle: AppStrings.transactionOpeningDebtSubtitle,
        statusLabel: AppStrings.transactionPending,
      ));
    }

    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameOfficial: json['name_official'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      openingBalance:
          (json['opening_balance'] as num?)?.toDouble() ?? 0,
      totalDebt: totalDebt,
      imageUrl: json['image_url'] as String?,
      createdAt:
          createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
      updatedAt:
          updatedAtStr != null ? DateTime.tryParse(updatedAtStr) : null,
      totalPurchases: totalPurchases,
      totalPaid: totalPaid,
      transactions: transactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (nameOfficial != null) 'name_official': nameOfficial,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (totalPurchases > 0) 'total_purchases': totalPurchases,
      if (totalPaid > 0) 'total_paid': totalPaid,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      if (nameOfficial != null) 'name_official': nameOfficial,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      if (nameOfficial != null) 'name_official': nameOfficial,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      'image_url': imageUrl,
    };
  }

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      nameOfficial: nameOfficial,
      phone: phone,
      email: email,
      address: address,
      openingBalance: openingBalance,
      totalDebt: totalDebt,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalPurchases: totalPurchases,
      totalPaid: totalPaid,
      transactions: transactions,
    );
  }

  factory CustomerModel.fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      nameOfficial: entity.nameOfficial,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      openingBalance: entity.openingBalance,
      totalDebt: entity.totalDebt,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      totalPurchases: entity.totalPurchases,
      totalPaid: entity.totalPaid,
      transactions: entity.transactions,
    );
  }
}
