// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceItemDto _$InvoiceItemDtoFromJson(Map<String, dynamic> json) =>
    InvoiceItemDto(
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$InvoiceItemDtoToJson(InvoiceItemDto instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
    };
