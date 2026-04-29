class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ParsingException implements Exception {
  final String message;
  ParsingException(this.message);
}
