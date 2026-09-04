/// Request body for `POST /companies/join`: `{ invite_code }`
class JoinCompanyRequestDto {
  final String inviteCode;

  const JoinCompanyRequestDto({required this.inviteCode});

  Map<String, dynamic> toJson() => {'invite_code': inviteCode};
}