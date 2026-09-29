import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/storage/token_storage.dart';
import 'package:makhzanflow/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

class _MockSecure extends Mock implements FlutterSecureStorage {}

void main() {
  group('offline session restore', () {
    Future<AuthRemoteDataSourceImpl> dataSource({
      required bool withTokens,
      required bool withSnapshot,
    }) async {
      SharedPreferences.setMockInitialValues(
        withSnapshot
            ? {
                'mf_last_user_v1':
                    '{"id":"u1","email":"a@b.c","name":"Ali","is_verified":true}'
              }
            : {},
      );
      final prefs = await SharedPreferences.getInstance();
      final secure = _MockSecure();
      when(() => secure.read(key: any(named: 'key'))).thenAnswer((inv) {
        final key = inv.namedArguments[#key] as String;
        if (withTokens &&
            (key == 'refresh_token' || key == 'access_token')) {
          return Future.value('tok');
        }
        return Future.value(null);
      });
      final dio = _MockDio();
      when(() => dio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          type: DioExceptionType.connectionError,
        ),
      );
      final apiClient = _MockApiClient();
      when(() => apiClient.dio).thenReturn(dio);
      return AuthRemoteDataSourceImpl(
        apiClient: apiClient,
        tokenStorage: TokenStorage(storage: secure),
        prefs: prefs,
      );
    }

    test('restores cached user offline when tokens exist', () async {
      final ds =
          await dataSource(withTokens: true, withSnapshot: true);
      final result = await ds.getCurrentUser();
      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse((_) => throw StateError('expected Right'))?.id,
        'u1',
      );
    });

    test('no restore without tokens', () async {
      final ds =
          await dataSource(withTokens: false, withSnapshot: true);
      final result = await ds.getCurrentUser();
      expect(result.isLeft(), isTrue);
      expect(
        result.fold((f) => f, (_) => null),
        isA<NetworkFailure>(),
      );
    });

    test('no restore without snapshot', () async {
      final ds =
          await dataSource(withTokens: true, withSnapshot: false);
      final result = await ds.getCurrentUser();
      expect(result.isLeft(), isTrue);
    });
  });
}
