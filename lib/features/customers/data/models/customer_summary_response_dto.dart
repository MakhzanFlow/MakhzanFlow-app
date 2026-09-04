/// Response body for `GET /customers/summary`:
/// `{ total, with_debt, zero_debt, credit_balance }`
class CustomerSummaryResponseDto {
  final int total;
  final int withDebt;
  final int zeroDebt;
  final int creditBalance;

  const CustomerSummaryResponseDto({
    required this.total,
    required this.withDebt,
    required this.zeroDebt,
    required this.creditBalance,
  });

  factory CustomerSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return CustomerSummaryResponseDto(
      total: json['total'] as int? ?? 0,
      withDebt: json['with_debt'] as int? ?? 0,
      zeroDebt: json['zero_debt'] as int? ?? 0,
      creditBalance: json['credit_balance'] as int? ?? 0,
    );
  }
}
