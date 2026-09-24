import 'app_error.dart';

/// The outcome of a single app_api_client.dart call: exactly one of a
/// successfully parsed [T] or a safe, typed [AppError] — callers are
/// forced to handle both via a `switch` (this is a Dart 3 sealed class),
/// rather than throwing and hoping every call site remembers to catch.
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  final String? requestId;

  const ApiSuccess(this.data, {this.requestId});
}

class ApiFailure<T> extends ApiResult<T> {
  final AppError error;

  const ApiFailure(this.error);
}
