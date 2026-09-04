/// Request body for `POST /companies/:id/members`: `{ targetUserId, role, permissions }`
class AddMemberRequestDto {
  final String targetUserId;
  final String role;
  final List<String> permissions;

  const AddMemberRequestDto({
    required this.targetUserId,
    this.role = 'member',
    this.permissions = const [],
  });

  Map<String, dynamic> toJson() => {
        'targetUserId': targetUserId,
        'role': role,
        'permissions': permissions,
      };
}