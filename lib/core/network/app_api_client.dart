import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import 'api_auth_gateway.dart';
import 'api_result.dart';
import 'app_error.dart';
import 'http_transport.dart';

/// The reusable HTTPS client for the versioned Express API (Frontend Spec
/// §9.1 "App-Owned API Contract") — the client-side half of this app's
/// write-path rule: auth and reads go direct via the Supabase SDK
/// (RLS-protected); all writes/mutations go through this client, no
/// exceptions.
///
/// Deliberately NOT named `ApiClient` and NOT placed under lib/core/api/
/// — there's already a pre-FT-004 `ApiClient` at lib/core/api/api_client.dart
/// with 4 live call sites (auth_service.dart, question_repository_impl.dart,
/// child_profile_service.dart). That file is out of scope for this ticket
/// (migrating its callers is endpoint-wiring work each feature ticket owns
/// as it touches that code) but is NOT superseded by this one — see this
/// ticket's Step 0 report for the full comparison. Different name (not
/// just different directory) so a future `import` can't silently grab the
/// wrong one.
///
/// Endpoints don't build responses by hand — pass a `parse` callback that
/// turns the envelope's `data` payload into your typed model; this client
/// only owns the envelope/transport/auth/error-mapping layer around it.
abstract class AppApiClient {
  Future<ApiResult<T>> get<T>(
    String path, {
    required T Function(dynamic json) parse,
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
    Duration? timeout,
  });

  Future<ApiResult<T>> post<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  });

  Future<ApiResult<T>> put<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  });

  Future<ApiResult<T>> patch<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  });

  Future<ApiResult<T>> delete<T>(
    String path, {
    required T Function(dynamic json) parse,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  });
}

class DioAppApiClient implements AppApiClient {
  DioAppApiClient({
    required String baseUrl,
    required ApiAuthGateway authGateway,
    HttpTransport? transport,
    Duration defaultTimeout = const Duration(seconds: 12),
    Uuid? uuid,
  })  : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _authGateway = authGateway,
        _transport = transport ?? DioHttpTransport(),
        _defaultTimeout = defaultTimeout,
        _uuid = uuid ?? const Uuid();

  final String _baseUrl;
  final ApiAuthGateway _authGateway;
  final HttpTransport _transport;
  final Duration _defaultTimeout;
  final Uuid _uuid;

  static const _badRequestFallback = 'Please check your details and try again.';

  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    required T Function(dynamic json) parse,
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
    Duration? timeout,
  }) {
    return _execute(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      parse: parse,
      requiresAuth: requiresAuth,
      timeout: timeout,
    );
  }

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) {
    return _execute(
      method: 'POST',
      path: path,
      body: body,
      parse: parse,
      requiresAuth: requiresAuth,
      timeout: timeout,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) {
    return _execute(
      method: 'PUT',
      path: path,
      body: body,
      parse: parse,
      requiresAuth: requiresAuth,
      timeout: timeout,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    required T Function(dynamic json) parse,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) {
    return _execute(
      method: 'PATCH',
      path: path,
      body: body,
      parse: parse,
      requiresAuth: requiresAuth,
      timeout: timeout,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    required T Function(dynamic json) parse,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) {
    return _execute(
      method: 'DELETE',
      path: path,
      parse: parse,
      requiresAuth: requiresAuth,
      timeout: timeout,
      idempotencyKey: idempotencyKey,
    );
  }

  // ── Core request flow ──────────────────────────────────────────────────
  //
  // Handles: request-ID generation, header assembly, the 401 refresh-then-
  // retry-once flow (AC: "401 triggers safe session refresh/sign-out
  // handling"), and delegating to _parseResponse for everything else.
  Future<ApiResult<T>> _execute<T>({
    required String method,
    required String path,
    required T Function(dynamic json) parse,
    Map<String, String>? queryParameters,
    Object? body,
    bool requiresAuth = true,
    Duration? timeout,
    String? idempotencyKey,
  }) async {
    final requestId = _uuid.v4();
    final effectiveTimeout = timeout ?? _defaultTimeout;

    RawHttpResponse response;
    try {
      response = await _sendOnce(
        method: method,
        path: path,
        queryParameters: queryParameters,
        body: body,
        timeout: effectiveTimeout,
        idempotencyKey: idempotencyKey,
        requestId: requestId,
        accessToken: requiresAuth ? _authGateway.accessToken : null,
      );
    } on HttpTimeoutException {
      return ApiFailure(OfflineError(requestId: requestId));
    } on HttpConnectionException {
      return ApiFailure(OfflineError(requestId: requestId));
    } catch (_) {
      // Never let an unrecognized transport-level failure surface a raw
      // exception/stack trace to the user — fold it into the same safe
      // "no connection" bucket as everything else that never got a valid
      // response back.
      return ApiFailure(OfflineError(requestId: requestId));
    }

    if (response.statusCode == 401 && requiresAuth) {
      final refreshed = await _authGateway.refreshSession();
      if (!refreshed) {
        await _authGateway.handleUnrecoverableSession();
        return ApiFailure(UnauthorizedError(requestId: requestId));
      }

      RawHttpResponse retryResponse;
      try {
        retryResponse = await _sendOnce(
          method: method,
          path: path,
          queryParameters: queryParameters,
          body: body,
          timeout: effectiveTimeout,
          idempotencyKey: idempotencyKey,
          requestId: requestId,
          accessToken: _authGateway.accessToken,
        );
      } on HttpTimeoutException {
        return ApiFailure(OfflineError(requestId: requestId));
      } on HttpConnectionException {
        return ApiFailure(OfflineError(requestId: requestId));
      } catch (_) {
        return ApiFailure(OfflineError(requestId: requestId));
      }

      if (retryResponse.statusCode == 401) {
        await _authGateway.handleUnrecoverableSession();
        return ApiFailure(UnauthorizedError(requestId: requestId));
      }

      return _parseResponse(retryResponse, parse, requestId);
    }

    return _parseResponse(response, parse, requestId);
  }

  Future<RawHttpResponse> _sendOnce({
    required String method,
    required String path,
    required Duration timeout,
    required String requestId,
    Map<String, String>? queryParameters,
    Object? body,
    String? idempotencyKey,
    String? accessToken,
  }) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath').replace(
      queryParameters: queryParameters?.isNotEmpty == true ? queryParameters : null,
    );

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'X-Request-ID': requestId,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
    };

    return _transport.send(RawHttpRequest(
      method: method,
      uri: uri,
      headers: headers,
      timeout: timeout,
      body: body != null ? jsonEncode(body) : null,
    ));
  }

  // ── Envelope parsing / error mapping ─────────────────────────────────────
  ApiResult<T> _parseResponse<T>(
    RawHttpResponse response,
    T Function(dynamic json) parse,
    String fallbackRequestId,
  ) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    final envelope = decoded is Map ? decoded : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (envelope != null && envelope['success'] == true) {
        final envelopeRequestId = envelope['requestId'] as String? ?? fallbackRequestId;
        try {
          return ApiSuccess(parse(envelope['data']), requestId: envelopeRequestId);
        } catch (_) {
          // The server returned 2xx + the right envelope shape, but the
          // payload inside `data` didn't match what the caller's `parse`
          // expected — a contract mismatch, not a network/auth problem.
          return ApiFailure(UnknownApiError(requestId: envelopeRequestId));
        }
      }
      return ApiFailure(UnknownApiError(requestId: fallbackRequestId));
    }

    final errorMap = envelope != null && envelope['error'] is Map
        ? envelope['error'] as Map
        : null;
    final requestId = errorMap?['requestId'] as String? ?? fallbackRequestId;
    final serverMessage = errorMap?['userMessage'] as String?;
    final fieldErrors = errorMap?['fieldErrors'] is Map
        ? Map<String, String>.from(errorMap!['fieldErrors'] as Map)
        : null;

    switch (response.statusCode) {
      case 400:
        return ApiFailure(BadRequestError(
          message: serverMessage ?? _badRequestFallback,
          requestId: requestId,
          fieldErrors: fieldErrors,
        ));
      case 401:
        // Only reached if requiresAuth was false (an unauthenticated call
        // that got a 401 anyway) — the authenticated 401 flow is handled
        // entirely in _execute and never falls through to here.
        return ApiFailure(UnauthorizedError(requestId: requestId));
      case 403:
        // Fixed message regardless of `serverMessage` — see app_error.dart.
        return ApiFailure(ForbiddenError(requestId: requestId));
      case 404:
        // Fixed message regardless of `serverMessage` — see app_error.dart.
        return ApiFailure(NotFoundError(requestId: requestId));
      case 409:
        return ApiFailure(ConflictError(requestId: requestId));
      case 422:
        return ApiFailure(ValidationError(
          message: serverMessage ?? _badRequestFallback,
          requestId: requestId,
          fieldErrors: fieldErrors,
        ));
      case 429:
        return ApiFailure(RateLimitedError(
          requestId: requestId,
          retryAfterSeconds: _parseRetryAfter(response.headers['retry-after']),
        ));
      default:
        if (response.statusCode >= 500 && response.statusCode < 600) {
          return ApiFailure(ServerError(requestId: requestId));
        }
        return ApiFailure(UnknownApiError(requestId: requestId));
    }
  }

  int? _parseRetryAfter(String? headerValue) {
    if (headerValue == null) return null;
    return int.tryParse(headerValue.trim());
  }
}

/// Overridden in tests with a fake AppApiClient implementation — see
/// test/core/network/app_api_client_test.dart's "DI seam" group.
final appApiClientProvider = Provider<AppApiClient>((ref) {
  return DioAppApiClient(
    baseUrl: '${AppConfig.apiBaseUrl}/v1',
    authGateway: const SupabaseApiAuthGateway(),
  );
});
