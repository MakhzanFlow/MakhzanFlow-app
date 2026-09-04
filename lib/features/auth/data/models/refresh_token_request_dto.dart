/// Request body for `POST /auth/refresh`: `{ refreshToken }`
class RefreshTokenRequestDto {
  final String refreshToken;

  const RefreshTokenRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}