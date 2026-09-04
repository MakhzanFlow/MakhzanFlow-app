import 'package:makhzanflow/features/dashboard/domain/entities/activity_entry.dart';

class ActivityEntryModel extends ActivityEntry {
  const ActivityEntryModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.action,
    required super.entityType,
    super.entityId,
    super.details,
    required super.createdAt,
  });

  /// Supports both REST `{entity,changes}` and legacy RPC `{entity_type,details}` shapes.
  factory ActivityEntryModel.fromJson(Map<String, dynamic> json) {
    final entity = (json['entity'] as String?) ?? (json['entity_type'] as String?) ?? '';
    final detailsRaw = json['details'] ?? json['changes'];
    Map<String, dynamic>? details;
    if (detailsRaw is Map<String, dynamic>) {
      details = detailsRaw;
    } else if (detailsRaw is Map) {
      details = Map<String, dynamic>.from(detailsRaw);
    }
    final createdStr = json['created_at'] as String?;
    return ActivityEntryModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      action: json['action'] as String? ?? '',
      entityType: entity,
      entityId: json['entity_id'] as String?,
      details: details,
      createdAt: createdStr != null ? DateTime.tryParse(createdStr) ?? DateTime.now() : DateTime.now(),
    );
  }
}
