import 'package:json_annotation/json_annotation.dart';

part 'invoice_item_dto.g.dart';

@JsonSerializable()
class InvoiceItemDto {
  @JsonKey(name: 'product_id')
  final String productId;
  final int quantity;

  InvoiceItemDto({
    required this.productId,
    required this.quantity,
  });

  factory InvoiceItemDto.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceItemDtoToJson(this);
}
