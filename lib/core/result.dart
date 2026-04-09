/// A Result type for handling success and failure cases.
///
/// This provides a type-safe way to handle API responses and errors
/// without throwing exceptions.
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  /// Creates a successful result with data
  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  /// Creates a failed result with an error message
  factory Result.failure(String error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  /// Returns true if this is a failure result
  bool get isFailure => !isSuccess;

  /// Executes a function if this is a success result
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return Result.success(transform(data as T));
      } catch (e) {
        return Result.failure(e.toString());
      }
    }
    return Result.failure(error ?? 'Unknown error');
  }

  /// Executes a function if this is a failure result
  Result<T> mapError(String Function(String error) transform) {
    if (isFailure && error != null) {
      return Result.failure(transform(error!));
    }
    return this;
  }

  /// Folds the result into a single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onFailure,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }
    return onFailure(error ?? 'Unknown error');
  }
}
