/// Request body for stock adjustment:
/// `{ quantity_change, reason, version? }` — version gates the delta write.
class AdjustStockRequestDto {
  final int quantityChange;
  final String reason;
  final int? version;

  const AdjustStockRequestDto({
    required this.quantityChange,
    required this.reason,
    this.version,
  });

  Map<String, dynamic> toJson() => {
        'quantity_change': quantityChange,
        'reason': reason,
        if (version != null) 'version': version,
      };
}
