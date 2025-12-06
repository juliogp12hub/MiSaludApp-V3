/// Global error definitions for the app
library;

class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppError: $message ${code != null ? "($code)" : ""}';
}

class NetworkError extends AppError {
  NetworkError({String message = 'Error de conexión', dynamic originalError})
      : super(message, code: 'NETWORK_ERROR', originalError: originalError);
}

class ServerError extends AppError {
  ServerError({String message = 'Error del servidor', int? statusCode})
      : super(message, code: 'SERVER_ERROR_$statusCode');
}

class NotFoundError extends AppError {
  NotFoundError({String message = 'Recurso no encontrado'})
      : super(message, code: 'NOT_FOUND');
}
