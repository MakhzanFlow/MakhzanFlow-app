import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/error_messages.dart';
import '../../../../core/env.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_response_dto.dart';
import '../models/google_auth_request_dto.dart';
import '../models/login_request_dto.dart';
import '../models/refresh_token_request_dto.dart';
import '../models/register_request_dto.dart';
import '../models/user_model.dart';
import '../models/verify_email_request_dto.dart';
import 'auth_remote_data_source.dart';

/// REST implementation of [AuthRemoteDataSource] backed by Dio.
///
/// Google sign-in exchanges a Google ID token for our own JWTs via
/// `POST /auth/google` — Flutter never validates tokens and never talks to
/// anything but this backend.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final SharedPreferences? _prefs;
  final GoogleSignIn? _googleSignIn;

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
    SharedPreferences? prefs,
    GoogleSignIn? googleSignIn,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage,
       _prefs = prefs,
       _googleSignIn = googleSignIn;

  /// The shared Google SDK session. Built lazily (not in the constructor) so
  /// constructing this data source never requires dotenv (tests) and never
  /// touches the native SDK until the user taps the Google button. Production
  /// always injects the singleton from the service locator.
  GoogleSignIn get _google =>
      _googleSignIn ??
      GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: MakhzanFlowEnv.googleWebClientId,
      );

  @override
  Future<Either<Failure, UserModel>> register(RegisterRequestDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: dto.toJson(),
      );
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(UserModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyEmail(
    VerifyEmailRequestDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyEmail,
        data: dto.toJson(),
      );
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      // The verify-email endpoint issues the first session tokens.
      return Right(await _saveSession(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail(String email) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.verifyEmailResend,
        data: {'email': email},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> login(LoginRequestDto dto) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: dto.toJson(),
      );
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(await _saveSession(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      _gLog('start');
      // 1. Google identity (system account picker). Null = user dismissed.
      final account = await _google.signIn();
      if (account == null) {
        _gLog('account picker dismissed (null account)');
        throw const GoogleSignInCancelledException();
      }
      _gLog('account: ${account.email} id=${account.id}');

      // 2. ID token — the ONLY Google credential our backend needs.
      final idToken = (await account.authentication).idToken;
      if (idToken == null || idToken.isEmpty) {
        _gLog('ERROR: authentication returned null/empty idToken');
        throw const AuthException('Google did not return an ID token.');
      }
      _gLog('idToken obtained (length=${idToken.length})');

      // 3+4. Exchange with OUR backend for MakhzanFlow JWTs, then persist
      // OUR tokens (never the Google idToken). A 401 here means the token was
      // bad/expired/audience-mismatched → re-run authenticate() exactly once.
      try {
        final user = await _exchangeGoogleToken(idToken);
        _gLog('exchange OK: user=${user.email} provider=${user.authProvider}');
        return Right(user);
      } on DioException catch (e) {
        _gLog(
          'exchange failed: status=${e.response?.statusCode} '
          'type=${e.type} msg=${e.response?.data}',
        );
        if (e.response?.statusCode != 401) rethrow;
        _gLog('401 → single retry with fresh authenticate()');
        await _signOutGoogle();
        final retryAccount = await _google.signIn();
        if (retryAccount == null) {
          _gLog('retry picker dismissed');
          throw const GoogleSignInCancelledException();
        }
        final retryToken = (await retryAccount.authentication).idToken;
        if (retryToken == null || retryToken.isEmpty) {
          _gLog('ERROR: retry returned null/empty idToken');
          throw const AuthException('Google did not return an ID token.');
        }
        final user = await _exchangeGoogleToken(retryToken);
        _gLog('retry exchange OK: user=${user.email}');
        return Right(user);
      }
    } on GoogleSignInCancelledException {
      _gLog('cancelled by user');
      return Left(GoogleSignInCancelledFailure());
    } on AuthException catch (e) {
      _gLog('AuthException: ${e.message}');
      return Left(AuthFailure(e.message));
    } on PlatformException catch (e) {
      // Native Google SDK rejection — translate the cryptic platform code
      // into the actual console/config fix (see docs/flutter-google-auth.md).
      _gLog(
        'PlatformException: code=${e.code} message=${e.message} '
        'details=${e.details}',
      );
      return Left(AuthFailure(_friendlyGooglePlatformError(e)));
    } on DioException catch (e) {
      _gLog(
        'DioException: status=${e.response?.statusCode} type=${e.type} '
        'data=${e.response?.data}',
      );
      return Left(mapDioExceptionToFailure(e));
    } catch (e, s) {
      _gLog('UNEXPECTED ${e.runtimeType}: $e\n$s');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Debug-only trace for the Google flow. The ID token itself is NEVER
  /// printed — only its presence/length. Visible via `flutter run` console
  /// or `adb logcat | grep google-auth`.
  void _gLog(String msg) {
    if (kDebugMode) debugPrint('[google-auth] $msg');
  }

  /// Posts the Google ID token to `POST /auth/google` and saves the session.
  /// Throws [DioException] on transport/backend failure for the caller to map.
  Future<UserModel> _exchangeGoogleToken(String idToken) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.google,
      data: GoogleAuthRequestDto(idToken: idToken).toJson(),
    );
    final data = _data(response);
    if (data == null) {
      throw ServerException(ErrorMessages.unexpectedError);
    }
    return _saveSession(data);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    Failure? failure;
    try {
      final refreshToken = await _tokenStorage.refreshToken;
      if (refreshToken != null) {
        await _apiClient.dio.post(
          ApiEndpoints.logout,
          data: RefreshTokenRequestDto(refreshToken: refreshToken).toJson(),
        );
      }
    } on DioException catch (e) {
      failure = mapDioExceptionToFailure(e);
    } catch (e) {
      failure = ServerFailure(e.toString());
    }
    // Always clear local tokens so the app never stays signed in when the
    // server session is gone.
    await _signOutGoogle();
    await _tokenStorage.clearAll();
    return failure == null ? const Right(null) : Left(failure);
  }

  @override
  Future<Either<Failure, void>> signOutEverywhere() async {
    Failure? failure;
    try {
      final refreshToken = await _tokenStorage.refreshToken;
      if (refreshToken != null) {
        await _apiClient.dio.post(
          ApiEndpoints.logoutAll,
          data: RefreshTokenRequestDto(refreshToken: refreshToken).toJson(),
        );
      }
    } on DioException catch (e) {
      failure = mapDioExceptionToFailure(e);
    } catch (e) {
      failure = ServerFailure(e.toString());
    }
    // Same guarantee as signOut: local session is always cleared.
    await _signOutGoogle();
    await _tokenStorage.clearAll();
    return failure == null ? const Right(null) : Left(failure);
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      final data = _data(response);
      if (data == null) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(UserModel.fromJson(data));
    } on DioException catch (e) {
      // Offline launch with stored tokens: restore the last signed-in user
      // instead of dropping to login. The session re-validates on reconnect.
      if (isConnectionLossError(e)) {
        final hasRefresh = await _tokenStorage.refreshToken != null;
        final cached = await _cachedUser();
        if (kDebugMode) {
          debugPrint(
            '[auth] offline restore: hasRefresh=$hasRefresh '
            'hasSnapshot=${cached != null}',
          );
        }
        if (cached != null && hasRefresh) {
          return Right(cached);
        }
      }
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();

  /// Translates native Google SDK failures into actionable messages.
  /// The raw platform text is appended for bug reports.
  String _friendlyGooglePlatformError(PlatformException e) {
    final raw = '${e.code} ${e.message ?? ''}';
    // ApiException: 10 (DEVELOPER_ERROR) — app identity unknown to Google:
    // Android OAuth client missing, wrong package name, or SHA-1 not registered.
    if (raw.contains('ApiException: 10') || raw.contains('statusCode=10')) {
      return 'Google sign-in is not configured for this app build '
          '(console: Android OAuth client + SHA-1). $raw';
    }
    // ApiException: 12500 — OAuth consent / verification problem.
    if (raw.contains('ApiException: 12500') ||
        raw.contains('statusCode=12500')) {
      return 'Google rejected the sign-in request (consent screen / app '
          'verification). $raw';
    }
    if (e.code == 'network_error') {
      return 'No connection to Google. Check connectivity and retry. $raw';
    }
    return 'Google sign-in failed. $raw';
  }

  /// Best-effort Google sign-out: revoking the backend session + clearing
  /// local tokens is what logs the user out — a Google SDK failure must never
  /// block that or leave the app signed in.
  Future<void> _signOutGoogle() async {
    // Nothing to sign out from when no Google session was ever created
    // (also keeps logout dotenv-free in tests).
    final gsi = _googleSignIn;
    if (gsi == null) return;
    try {
      await gsi.signOut();
    } catch (_) {
      // Ignore: local logout already guaranteed below.
    }
  }

  Map<String, dynamic>? _data(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  Future<UserModel> _saveSession(Map<String, dynamic> data) async {
    final auth = AuthResponseDto.fromJson(data);
    // Awaited: killing the app right after login must not lose the session.
    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
    await _prefs?.setString(
      AppConstants.lastUserKey,
      jsonEncode(auth.user.toJson()),
    );
    return auth.user;
  }

  Future<UserModel?> _cachedUser() async {
    try {
      final raw = _prefs?.getString(AppConstants.lastUserKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final user = UserModel.fromJson(decoded);
      return user.id.isEmpty ? null : user;
    } catch (_) {
      return null;
    }
  }
}
