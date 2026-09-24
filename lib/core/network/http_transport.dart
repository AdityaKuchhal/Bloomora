import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// A single outgoing request, already fully assembled (headers, body,
/// timeout) — [HttpTransport] just sends it. Kept independent of any
/// particular HTTP package so app_api_client.dart's envelope-parsing and
/// error-mapping logic never has to know about Dio (or any replacement)
/// directly, and so tests can fake this one narrow seam instead of the
/// whole HTTP stack.
class RawHttpRequest {
  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final String? body;
  final Duration timeout;

  const RawHttpRequest({
    required this.method,
    required this.uri,
    required this.headers,
    required this.timeout,
    this.body,
  });
}

class RawHttpResponse {
  final int statusCode;
  final String body;

  /// Header names are lower-cased on the way in (HTTP header names are
  /// case-insensitive; Dio doesn't guarantee a casing) so lookups like
  /// `headers['retry-after']` are reliable regardless of what the server
  /// actually sent.
  final Map<String, String> headers;

  const RawHttpResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });
}

abstract class HttpTransport {
  Future<RawHttpResponse> send(RawHttpRequest request);
}

/// Thrown by [HttpTransport.send] for a request that timed out — maps to
/// [OfflineError] one layer up (app_api_client.dart), same as an outright
/// offline/DNS failure; the user can't act differently on the distinction.
class HttpTimeoutException implements Exception {
  const HttpTimeoutException();
}

/// Thrown by [HttpTransport.send] for anything that never reached a
/// server at all (offline, DNS failure, connection refused, ...).
class HttpConnectionException implements Exception {
  const HttpConnectionException();
}

class DioHttpTransport implements HttpTransport {
  DioHttpTransport([Dio? dio]) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<RawHttpResponse> send(RawHttpRequest request) async {
    try {
      final response = await _dio.requestUri<String>(
        request.uri,
        data: request.body,
        options: Options(
          method: request.method,
          headers: request.headers,
          responseType: ResponseType.plain,
          // We map every status code ourselves (see app_api_client.dart) —
          // don't let Dio throw on 4xx/5xx before we get a chance to.
          validateStatus: (_) => true,
          sendTimeout: request.timeout,
          receiveTimeout: request.timeout,
        ),
      );

      final headers = <String, String>{};
      for (final entry in response.headers.map.entries) {
        headers[entry.key.toLowerCase()] = entry.value.join(', ');
      }

      return RawHttpResponse(
        statusCode: response.statusCode ?? 0,
        body: response.data ?? '',
        headers: headers,
      );
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw const HttpTimeoutException();
        case DioExceptionType.connectionError:
          throw const HttpConnectionException();
        default:
          if (e.error is SocketException) {
            throw const HttpConnectionException();
          }
          rethrow;
      }
    } on SocketException {
      throw const HttpConnectionException();
    } on TimeoutException {
      throw const HttpTimeoutException();
    }
  }
}
