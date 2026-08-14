enum ProviderErrorType {
  networkUnavailable,
  timeout,
  unauthorized,
  rateLimited,
  serviceUnavailable,
  malformedResponse,
  unknown,
}

class ProviderException implements Exception {
  const ProviderException(this.type, this.message);

  final ProviderErrorType type;
  final String message;

  @override
  String toString() => 'ProviderException($type, $message)';
}
