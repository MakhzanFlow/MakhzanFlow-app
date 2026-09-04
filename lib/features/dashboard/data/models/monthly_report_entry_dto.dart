/// DTO for `GET /dashboard/monthly-report` item.
/// Backend shape: `{ month: "YYYY-MM", totalInvoices: number, totalRevenue: number, totalPayments: number }`
/// Supports both camelCase and snake_case.
class MonthlyReportEntryDto {
  final String month;
  final int totalInvoices;
  final double totalRevenue;
  final double totalPayments;

  const MonthlyReportEntryDto({
    required this.month,
    required this.totalInvoices,
    required this.totalRevenue,
    required this.totalPayments,
  });

  factory MonthlyReportEntryDto.fromJson(Map<String, dynamic> json) {
    return MonthlyReportEntryDto(
      month: json['month'] as String,
      totalInvoices: (json['totalInvoices'] as num?)?.toInt() ??
          (json['total_invoices'] as num?)?.toInt() ??
          0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ??
          (json['total_revenue'] as num?)?.toDouble() ??
          0.0,
      totalPayments: (json['totalPayments'] as num?)?.toDouble() ??
          (json['total_payments'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'totalInvoices': totalInvoices,
        'totalRevenue': totalRevenue,
        'totalPayments': totalPayments,
      };
}
