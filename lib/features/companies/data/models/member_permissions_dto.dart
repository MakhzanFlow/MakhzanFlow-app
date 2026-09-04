/// Response for `GET /companies/:id/members/:userId/permissions`:
/// `{ role, permissions: [ "products.create", ... ] }`
class MemberPermissionsDto {
  final String role;
  final List<String> permissions;

  const MemberPermissionsDto({required this.role, this.permissions = const []});

  factory MemberPermissionsDto.fromJson(Map<String, dynamic> json) {
    return MemberPermissionsDto(
      role: json['role'] as String? ?? 'member',
      permissions:
          (json['permissions'] as List?)?.whereType<String>().toList() ??
          const [],
    );
  }

  /// Converts the flat permission keys into the nested map shape
  /// (`{ section: { action: true } }`) expected by the UI.
  Map<String, dynamic> toPermissionMap() {
    final result = <String, dynamic>{};
    for (final key in permissions) {
      final parts = key.split('.');
      if (parts.length == 1) {
        result[parts[0]] = true;
      } else {
        result.putIfAbsent(parts[0], () => <String, dynamic>{});
        (result[parts[0]] as Map<String, dynamic>)[parts[1]] = true;
      }
    }
    return result;
  }
}