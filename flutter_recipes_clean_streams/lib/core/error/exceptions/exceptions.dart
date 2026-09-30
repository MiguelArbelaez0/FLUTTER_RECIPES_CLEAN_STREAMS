class ServerException implements Exception {
  const ServerException(this.message);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;
}

class ParsingException implements Exception {
  const ParsingException(this.message);
  final String message;
}

class RecipeNotFoundException implements Exception {
  const RecipeNotFoundException(this.message);
  final String message;
}
