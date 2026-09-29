# Flutter — Google Sign-In (shipped)

> Backend: `POST {API_BASE_URL}/auth/google` (`ApiEndpoints.google`) with `{ "idToken" }`.
> Returns our JWTs (`AuthResponseDto`). Flutter never validates tokens, never sends the
> Google access token, never caches the ID token.
> Web client ID: `.env` `GOOGLE_WEB_CLIENT_ID` via `MakhzanFlowEnv.googleWebClientId`.
> SDK: `google_sign_in` v6 (constructor + `signIn()`, **not** the v7 singleton API).

## Flow

`GoogleSignInButton` (login + register screens) → `AuthCubit.signInWithGoogle()` →
`SignInWithGoogleUseCase` → `AuthRepositoryImpl` → `AuthRemoteDataSourceImpl.signInWithGoogle()`
(`lib/features/auth/data/datasources/auth_remote_data_source_impl.dart`):

1. `GoogleSignIn(scopes: [email, profile], serverClientId: …).signIn()` — null = dismissed
   → `GoogleSignInCancelledFailure` → cubit emits `Unauthenticated` (no toast).
2. `account.authentication.idToken` — null → `AuthFailure`.
3. `POST /auth/google` (public endpoint, no `Bearer`) → `_saveSession` (our JWTs +
   `mf_last_user_v1` snapshot, so refresh + offline restore work unchanged).
4. Backend 401 (`invalidGoogleToken`) → sign out of Google, re-run `signIn()` **once**.

`UserModel` adds `avatar_url` → `avatarUrl`, `auth_provider` → `authProvider`
(`email`/`google`/`email+google`, nullable-safe, round-trips the offline snapshot).

## Errors

| Backend | Flutter |
|---|---|
| 401 `errors.useGoogleSignIn` (password login, Google-only account) | `AppStrings.googleAuthErrorMessage` → "continue with Google" hint (login + register) |
| 403 `errors.googleEmailNotVerified` | verify-Gmail prompt |
| 401 `errors.invalidGoogleToken` | silent single retry, then mapped error |
| 429 / 500 `errors.googleNotConfigured` | generic `mapDioExceptionToFailure` path |

Logout (`signOut`/`signOutEverywhere`): backend revoke → best-effort Google `signOut()` →
`TokenStorage.clearAll()` — local logout is never blocked by a Google SDK failure.

## Console / native checklist (manual, per release)

- [ ] GCP: **Android** OAuth client for `com.makhzan.flow` + debug SHA-1 (release SHA-1 before launch)
- [ ] GCP: **iOS** OAuth client for the bundle ID; add its **reversed client ID** as
      `CFBundleURLTypes` in `ios/Runner/Info.plist` (absent — app builds/works on Android without it)
- [ ] Consent screen testers added while in Testing mode; scopes `openid email profile` only
- [ ] Never commit a client secret, `google-services.json`, or `GoogleService-Info.plist` —
      none are needed (see `.gitignore`); no Firebase/Supabase auth packages
