import 'dart:async';

class FirestoreRetry {
  static const int defaultMaxRetries = 3;
  static const Duration defaultBaseDelay = Duration(milliseconds: 200);

  /// Retries [operation] up to [maxRetries] times with exponential backoff.
  /// Rethrows the last error if all attempts fail.
  static Future<T> run<T>(
    Future<T> Function() operation, {
    int maxRetries = defaultMaxRetries,
    Duration baseDelay = defaultBaseDelay,
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await Future.delayed(baseDelay * (attempt + 1));
      }
    }
    throw StateError('Unreachable');
  }
}
