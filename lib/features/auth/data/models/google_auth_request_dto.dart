/// Request body for `POST /auth/google`: `{ idToken }`.
///
/// Only the Google **ID token** is ever sent — never the Google access token,
/// and the ID token is never cached: it is single-use identity proof, while
/// our own JWTs (saved via `_saveSession`) are the session.
class GoogleAuthRequestDto {
  final String idToken;

  const GoogleAuthRequestDto({required this.idToken});

  Map<String, dynamic> toJson() => {'idToken': idToken};
}
