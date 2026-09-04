/// DTO for `RecentActivity` from `GET /dashboard/stats` and `GET /dashboard/activity`.
/// Backend shape (RecentActivity):
/// `{ id, user_id, user_name, entity, entity_id, action, changes, created_at }`
/// Legacy shape (get_activity_log RPC): `{ id, user_id, user_name, action, entity_type, entity_id, details, created_at }`
class ActivityEntryDto {
  final String id;
  final String userId;
  final String userName;
  final String entity;
  final String? entityId;
  final String action;
  final Map<String, dynamic>? changes;
  final DateTime? createdAt;

  const ActivityEntryDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.entity,
    this.entityId,
    required this.action,
    this.changes,
    this.createdAt,
  });

  factory ActivityEntryDto.fromJson(Map<String, dynamic> json) {
    // Support both REST (entity/changes) and legacy RPC (entity_type/details)
    final entity = (json['entity'] as String?) ?? (json['entity_type'] as String?) ?? '';
    final changesRaw = json['changes'] ?? json['details'];
    Map<String, dynamic>? changes;
    if (changesRaw is Map<String, dynamic>) {
      changes = changesRaw;
    } else if (changesRaw is Map) {
      changes = Map<String, dynamic>.from(changesRaw);
    }

    final createdAtStr = json['created_at'] as String?;
    return ActivityEntryDto(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      entity: entity,
      entityId: json['entity_id'] as String?,
      action: json['action'] as String? ?? '',
      changes: changes,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'entity': entity,
        if (entityId != null) 'entity_id': entityId,
        'action': action,
        if (changes != null) 'changes': changes,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
