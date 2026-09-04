/// Request body for `PATCH /companies/:id/members/:userId`: `{ role?, permissions? }`
class UpdateMemberRequestDto {
  final String? role;
  final Map<String, dynamic>? permissions;

  const UpdateMemberRequestDto({this.role, this.permissions});

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role,
        if (permissions != null) 'permissions': permissions,
      };
}