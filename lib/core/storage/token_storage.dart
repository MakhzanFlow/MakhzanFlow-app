import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps FlutterSecureStorage — injected via constructor.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  // Same key as CompanyCubit._lastCompanyKey so the selected company is
  // automatically available for the x-company-id header.
  static const _companyIdKey = 'last_company_id';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> get accessToken =>
      _storage.read(key: _accessTokenKey);

  Future<String?> get refreshToken =>
      _storage.read(key: _refreshTokenKey);

  Future<void> saveCompanyId(String companyId) =>
      _storage.write(key: _companyIdKey, value: companyId);

  Future<String?> get companyId => _storage.read(key: _companyIdKey);

  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _companyIdKey);
  }
}
