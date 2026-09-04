import 'package:equatable/equatable.dart';

class CustomerSummary extends Equatable {
  final int total;
  final int withDebt;
  final int zeroDebt;
  final int creditBalance;

  const CustomerSummary({
    required this.total,
    required this.withDebt,
    required this.zeroDebt,
    required this.creditBalance,
  });

  const CustomerSummary.zero()
      : total = 0,
        withDebt = 0,
        zeroDebt = 0,
        creditBalance = 0;

  @override
  List<Object?> get props => [total, withDebt, zeroDebt, creditBalance];
}
