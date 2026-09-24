// Verifies app_api_client.dart end to end against a fake HttpTransport and
// a fake ApiAuthGateway — no real network call, no live Supabase session.
// See the "DI seam" group at the bottom for proof the client itself is
// mockable via Riverpod (FT-004 AC: "can be mocked in unit/widget tests").
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/network/api_auth_gateway.dart';
import 'package:bloomora/core/network/api_result.dart';
import 'package:bloomora/core/network/app_api_client.dart';
import 'package:bloomora/core/network/app_error.dart';
import 'package:bloomora/core/network/http_transport.dart';

class _FakeTransport implements HttpTransport {
  final List<RawHttpRequest> requests = [];

  /// Queue of responses to return, in order — one per call to [send].
  /// Falls back to [defaultResponse] once exhausted.
  final List<RawHttpResponse> queue = [];
  RawHttpResponse? defaultResponse;

  /// If set, thrown instead of returning a response (simulates a
  /// transport-level failure — timeout/offline).
  Object? throwOnNextSend;

  @override
  Future<RawHttpResponse> send(RawHttpRequest request) async {
    requests.add(request);
    if (throwOnNextSend != null) {
      final e = throwOnNextSend!;
      throwOnNextSend = null;
      throw e;
    }
    if (queue.isNotEmpty) return queue.removeAt(0);
    return defaultResponse ??
        const RawHttpResponse(statusCode: 200, body: '{"success":true,"data":null}');
  }
}

class _FakeAuthGateway implements ApiAuthGateway {
  String? _token;
  bool refreshShouldSucceed = true;
  int refreshCallCount = 0;
  int unrecoverableCallCount = 0;

  _FakeAuthGateway({String? initialToken = 'initial-token'}) : _token = initialToken;

  @override
  String? get accessToken => _token;

  @override
  Future<bool> refreshSession() async {
    refreshCallCount++;
    if (refreshShouldSucceed) {
      _token = 'refreshed-token';
      return true;
    }
    return false;
  }

  @override
  Future<void> handleUnrecoverableSession() async {
    unrecoverableCallCount++;
    _token = null;
  }
}

String _successBody(dynamic data, {String requestId = 'srv-req-1'}) =>
    jsonEncode({'success': true, 'data': data, 'requestId': requestId});

String _errorBody(
  String code,
  String userMessage, {
  String requestId = 'srv-req-1',
  Map<String, String>? fieldErrors,
}) =>
    jsonEncode({
      'success': false,
      'error': {
        'code': code,
        'userMessage': userMessage,
        'requestId': requestId,
        if (fieldErrors != null) 'fieldErrors': fieldErrors,
      },
    });

void main() {
  late _FakeTransport transport;
  late _FakeAuthGateway authGateway;
  late DioAppApiClient client;

  setUp(() {
    transport = _FakeTransport();
    authGateway = _FakeAuthGateway();
    client = DioAppApiClient(
      baseUrl: 'https://api.example.com/v1',
      authGateway: authGateway,
      transport: transport,
    );
  });

  group('1. Auth header attachment', () {
    test('a request with a current session attaches Authorization: Bearer <token>', () async {
      transport.defaultResponse =
          RawHttpResponse(statusCode: 200, body: _successBody({'ok': true}));

      await client.get('/children', parse: (j) => j);

      expect(transport.requests.single.headers['Authorization'], 'Bearer initial-token');
    });

    test('a request explicitly marked as not requiring auth does not force one', () async {
      transport.defaultResponse =
          RawHttpResponse(statusCode: 200, body: _successBody({'ok': true}));

      await client.get('/health', parse: (j) => j, requiresAuth: false);

      expect(transport.requests.single.headers.containsKey('Authorization'), isFalse);
    });

    test('every request carries a generated X-Request-ID', () async {
      transport.defaultResponse =
          RawHttpResponse(statusCode: 200, body: _successBody({'ok': true}));

      await client.get('/children', parse: (j) => j);

      final requestId = transport.requests.single.headers['X-Request-ID'];
      expect(requestId, isNotNull);
      expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(requestId!), isTrue);
    });

    test('Idempotency-Key is sent only when the caller supplies one', () async {
      transport.defaultResponse =
          RawHttpResponse(statusCode: 200, body: _successBody({'ok': true}));

      await client.post('/children', parse: (j) => j, body: {}, idempotencyKey: 'abc-123');
      await client.post('/children', parse: (j) => j, body: {});

      expect(transport.requests[0].headers['Idempotency-Key'], 'abc-123');
      expect(transport.requests[1].headers.containsKey('Idempotency-Key'), isFalse);
    });

    test('success envelope parses into typed data and surfaces the server requestId', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 200,
        body: _successBody({'id': 'child-1', 'name': 'Test'}, requestId: 'srv-xyz'),
      );

      final result = await client.get<String>(
        '/children/child-1',
        parse: (j) => (j as Map)['name'] as String,
      );

      expect(result, isA<ApiSuccess<String>>());
      final success = result as ApiSuccess<String>;
      expect(success.data, 'Test');
      expect(success.requestId, 'srv-xyz');
    });
  });

  group('2. Status -> typed AppError mapping (one case per status)', () {
    test('timeout maps to OfflineError with the safe network message', () async {
      transport.throwOnNextSend = const HttpTimeoutException();
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error, isA<OfflineError>());
      expect(error.message, 'No connection. Check your internet and try again.');
    });

    test('offline/connection failure maps to OfflineError with the safe network message', () async {
      transport.throwOnNextSend = const HttpConnectionException();
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error, isA<OfflineError>());
      expect(error.message, 'No connection. Check your internet and try again.');
    });

    test('401 (unauthenticated call) maps to UnauthorizedError', () async {
      // requiresAuth: false so this exercises _parseResponse's direct 401
      // mapping, not the refresh-then-retry orchestration in _execute
      // (that flow has its own dedicated group below).
      transport.defaultResponse = RawHttpResponse(
        statusCode: 401,
        body: _errorBody('UNAUTHENTICATED', 'nope'),
      );
      final result = await client.get('/health', parse: (j) => j, requiresAuth: false);
      final error = (result as ApiFailure).error;
      expect(error, isA<UnauthorizedError>());
      expect(error.message, 'Please sign in again.');
    });

    test('403 maps to ForbiddenError with the fixed generic message', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 403,
        body: _errorBody('FORBIDDEN', 'this resource belongs to another user'),
      );
      final result = await client.get('/children/other-id', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error, isA<ForbiddenError>());
      expect(error.message, "You don't have access to this.");
    });

    test('404 maps to NotFoundError with the fixed generic message', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 404,
        body: _errorBody('NOT_FOUND', 'no row with that id'),
      );
      final result = await client.get('/children/missing', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error, isA<NotFoundError>());
      expect(error.message, 'This item is no longer available.');
    });

    test('409 maps to ConflictError', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 409,
        body: _errorBody('CONFLICT', 'This changed somewhere else. Refresh to continue.'),
      );
      final result = await client.put('/children/child-1', parse: (j) => j, body: {});
      final error = (result as ApiFailure).error;
      expect(error, isA<ConflictError>());
      expect(error.message, 'This changed somewhere else. Refresh to continue.');
    });

    test('422 maps to ValidationError and surfaces fieldErrors', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 422,
        body: _errorBody(
          'VALIDATION_FAILED',
          'Please fix the highlighted fields.',
          fieldErrors: {'name': 'Name is required'},
        ),
      );
      final result = await client.post('/children', parse: (j) => j, body: {});
      final error = (result as ApiFailure).error as ValidationError;
      expect(error.message, 'Please fix the highlighted fields.');
      expect(error.fieldErrors, {'name': 'Name is required'});
    });

    test('429 maps to RateLimitedError and parses Retry-After', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 429,
        body: _errorBody('RATE_LIMITED', 'slow down'),
        headers: const {'retry-after': '30'},
      );
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error as RateLimitedError;
      expect(error.message, 'Too many requests. Please wait and try again.');
      expect(error.retryAfterSeconds, 30);
    });

    test('5xx maps to ServerError', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 503,
        body: _errorBody('SERVICE_UNAVAILABLE', 'db is down'),
      );
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error, isA<ServerError>());
      expect(error.message, 'Something went wrong on our side. Please try again.');
    });
  });

  group('3. Server-internal-looking bodies never leak into the message', () {
    test('a SQL-error-shaped userMessage on a 500 never reaches the AppError message', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 500,
        body: _errorBody(
          'INTERNAL',
          'duplicate key value violates unique constraint "children_pkey"',
        ),
      );
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error.message, 'Something went wrong on our side. Please try again.');
      expect(error.message.contains('constraint'), isFalse);
      expect(error.message.contains('children_pkey'), isFalse);
    });

    test('a stack-trace-shaped body on a 500 never reaches the AppError message', () async {
      transport.defaultResponse = const RawHttpResponse(
        statusCode: 500,
        body: 'TypeError: Cannot read properties of undefined\n'
            '    at ChildController.create (/app/src/controllers/child.js:42:19)\n'
            '    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)',
      );
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error, isA<ServerError>());
      expect(error.message, 'Something went wrong on our side. Please try again.');
      expect(error.message.contains('ChildController'), isFalse);
      expect(error.message.contains('.js:42'), isFalse);
    });

    test('a leaky userMessage on a 403 is ignored in favor of the fixed message', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 403,
        body: _errorBody('FORBIDDEN', 'child abc123 belongs to parent_id=other-user-uuid'),
      );
      final result = await client.get('/children/abc123', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error.message, "You don't have access to this.");
      expect(error.message.contains('other-user-uuid'), isFalse);
    });

    // 401/403/404/409/429/5xx are ALWAYS the fixed safe message regardless
    // of what the server sends — only 400/422 (genuine field-level
    // validation) pass a server-supplied message through. These three
    // close the loop for 409/429/5xx the same way the 403 test above does,
    // so the guarantee is locked in by an assertion, not just true because
    // the relevant class happens not to expose a settable message today.
    test('a leaky userMessage on a 409 is ignored in favor of the fixed message', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 409,
        body: _errorBody('CONFLICT', 'row version 7 conflicts with row version 9 in children'),
      );
      final result = await client.put('/children/child-1', parse: (j) => j, body: {});
      final error = (result as ApiFailure).error;
      expect(error.message, 'This changed somewhere else. Refresh to continue.');
      expect(error.message.contains('row version'), isFalse);
      expect(error.message.contains('children'), isFalse);
    });

    test('a leaky userMessage on a 429 is ignored in favor of the fixed message', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 429,
        body: _errorBody(
          'RATE_LIMITED',
          'client 203.0.113.5 exceeded 100 req/min on /v1/children route',
        ),
      );
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error.message, 'Too many requests. Please wait and try again.');
      expect(error.message.contains('203.0.113.5'), isFalse);
      expect(error.message.contains('req/min'), isFalse);
    });

    test('a leaky userMessage on a 5xx is ignored in favor of the fixed message', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 500,
        body: _errorBody(
          'INTERNAL',
          'ECONNREFUSED 10.0.4.12:5432 connecting to postgres pool "primary"',
        ),
      );
      final result = await client.get('/children', parse: (j) => j);
      final error = (result as ApiFailure).error;
      expect(error.message, 'Something went wrong on our side. Please try again.');
      expect(error.message.contains('10.0.4.12'), isFalse);
      expect(error.message.contains('postgres'), isFalse);
    });
  });

  group('4. 401 refresh-then-retry-once flow', () {
    test('401 -> refresh succeeds -> retry with new token -> success', () async {
      transport.queue.add(RawHttpResponse(
        statusCode: 401,
        body: _errorBody('UNAUTHENTICATED', 'expired'),
      ));
      transport.queue.add(RawHttpResponse(
        statusCode: 200,
        body: _successBody({'id': 'child-1'}),
      ));

      final result = await client.get('/children', parse: (j) => j);

      expect(result, isA<ApiSuccess>());
      expect(authGateway.refreshCallCount, 1);
      expect(authGateway.unrecoverableCallCount, 0);
      expect(transport.requests, hasLength(2));
      expect(transport.requests[0].headers['Authorization'], 'Bearer initial-token');
      expect(transport.requests[1].headers['Authorization'], 'Bearer refreshed-token');
    });

    test('401 -> refresh fails -> session cleared, no retry attempted', () async {
      authGateway.refreshShouldSucceed = false;
      transport.defaultResponse = RawHttpResponse(
        statusCode: 401,
        body: _errorBody('UNAUTHENTICATED', 'expired'),
      );

      final result = await client.get('/children', parse: (j) => j);

      final error = (result as ApiFailure).error;
      expect(error, isA<UnauthorizedError>());
      expect(error.message, 'Please sign in again.');
      expect(authGateway.refreshCallCount, 1);
      expect(authGateway.unrecoverableCallCount, 1);
      expect(transport.requests, hasLength(1), reason: 'must not retry if refresh itself failed');
    });

    test('401 -> refresh succeeds -> retry also 401 -> session cleared, gives up', () async {
      transport.queue.add(RawHttpResponse(
        statusCode: 401,
        body: _errorBody('UNAUTHENTICATED', 'expired'),
      ));
      transport.queue.add(RawHttpResponse(
        statusCode: 401,
        body: _errorBody('UNAUTHENTICATED', 'still expired'),
      ));

      final result = await client.get('/children', parse: (j) => j);

      final error = (result as ApiFailure).error;
      expect(error, isA<UnauthorizedError>());
      expect(authGateway.refreshCallCount, 1, reason: 'refresh is attempted at most once');
      expect(authGateway.unrecoverableCallCount, 1);
      expect(transport.requests, hasLength(2), reason: 'exactly one retry, never more');
    });

    test('a 401 on a call marked requiresAuth: false never triggers refresh/sign-out', () async {
      transport.defaultResponse = RawHttpResponse(
        statusCode: 401,
        body: _errorBody('UNAUTHENTICATED', 'n/a'),
      );

      await client.get('/health', parse: (j) => j, requiresAuth: false);

      expect(authGateway.refreshCallCount, 0);
      expect(authGateway.unrecoverableCallCount, 0);
      expect(transport.requests, hasLength(1));
    });
  });

  group('5. 403 vs 404 message safety', () {
    test('403 gives the identical message whether the cause is "not found" or "not yours"', () async {
      transport.queue.add(RawHttpResponse(
        statusCode: 403,
        body: _errorBody('FORBIDDEN', 'no such resource'),
      ));
      transport.queue.add(RawHttpResponse(
        statusCode: 403,
        body: _errorBody('FORBIDDEN', 'owned by a different user'),
      ));

      final notFoundCause = await client.get('/children/a', parse: (j) => j);
      final notYoursCause = await client.get('/children/b', parse: (j) => j);

      final message1 = ((notFoundCause as ApiFailure).error as ForbiddenError).message;
      final message2 = ((notYoursCause as ApiFailure).error as ForbiddenError).message;
      expect(message1, message2);
      expect(message1, "You don't have access to this.");
    });

    test('403 and 404 are different AppError types but both generic, non-revealing messages', () async {
      transport.queue.add(RawHttpResponse(
        statusCode: 403,
        body: _errorBody('FORBIDDEN', 'x'),
      ));
      transport.queue.add(RawHttpResponse(
        statusCode: 404,
        body: _errorBody('NOT_FOUND', 'x'),
      ));

      final forbidden = (await client.get('/children/a', parse: (j) => j) as ApiFailure).error;
      final notFound = (await client.get('/children/b', parse: (j) => j) as ApiFailure).error;

      expect(forbidden, isA<ForbiddenError>());
      expect(notFound, isA<NotFoundError>());
      expect(forbidden, isNot(isA<NotFoundError>()));
      // Different types (fine — internal detail), but neither message
      // reveals which underlying case triggered it.
      expect(forbidden.message, "You don't have access to this.");
      expect(notFound.message, 'This item is no longer available.');
    });
  });

  group('6. DI seam — the client is mockable', () {
    testWidgets(
      'a widget tree can get a fake AppApiClient through the provider, no real network call',
      (tester) async {
        final fake = _FakeAppApiClient();
        late AppApiClient injected;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [appApiClientProvider.overrideWithValue(fake)],
            child: MaterialApp(
              home: Consumer(builder: (context, ref, _) {
                injected = ref.watch(appApiClientProvider);
                return const SizedBox();
              }),
            ),
          ),
        );
        await tester.pump();

        expect(injected, same(fake));

        final result = await injected.get<String>(
          '/anything',
          parse: (j) => (j as Map)['id'] as String,
        );

        expect(fake.wasCalled, isTrue);
        expect(result, isA<ApiSuccess<String>>());
        expect((result as ApiSuccess<String>).data, 'fake-1');
      },
    );
  });
}

class _FakeAppApiClient implements AppApiClient {
  bool wasCalled = false;

  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    required T Function(dynamic json) parse,
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
    Duration? timeout,
  }) async {
    wasCalled = true;
    return ApiSuccess(parse({'id': 'fake-1'}));
  }

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) async {
    wasCalled = true;
    return ApiSuccess(parse({'id': 'fake-1'}));
  }

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) async {
    wasCalled = true;
    return ApiSuccess(parse({'id': 'fake-1'}));
  }

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) async {
    wasCalled = true;
    return ApiSuccess(parse({'id': 'fake-1'}));
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    required T Function(dynamic json) parse,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) async {
    wasCalled = true;
    return ApiSuccess(parse({'id': 'fake-1'}));
  }
}

