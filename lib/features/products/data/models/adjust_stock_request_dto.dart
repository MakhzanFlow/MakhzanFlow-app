/// Request body for stock adjustment:
/// `{ quantity_change, reason }`
class AdjustStockRequestDto {
  final int quantityChange;
  final String reason;

  const AdjustStockRequestDto({
    required this.quantityChange,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'quantity_change': quantityChange,
        'reason': reason,
      };
}
