import 'package:dio/dio.dart';

import '../error/exceptions/exceptions.dart';

/// Translate transport errors without exposing request URLs or internal messages.
Exception apiException(DioException error) {
  if (error.error is FormatException || error.error is TypeError) {
    return const ParsingException('La respuesta del servicio no es válida.');
  }
  if (error.response == null ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.connectionError) {
    return const NetworkException(
      'No pudimos conectar con el servicio. Reintenta.',
    );
  }
  return ServerException(
    'El servicio respondió con HTTP ${error.response?.statusCode}.',
  );
}
