import 'package:dio/dio.dart';

class ApiException extends DioException {
  ApiException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? "Something went wrong";
  }
}

class BadRequestException extends ApiException {
  BadRequestException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'Invalid request';
  }
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends ApiException {
  ConflictException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'Conflict occurred';
  }
}

class CancelException extends ApiException {
  CancelException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'Request cancelled';
  }
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'Access denied';
  }
}

class NotFoundException extends ApiException {
  NotFoundException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends ApiException {
  NoInternetConnectionException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'No internet connection detected, please try again.';
  }
}

class DeadlineExceededException extends ApiException {
  DeadlineExceededException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'The connection has timed out, please try again.';
  }
}

class UnknownException extends ApiException {
  UnknownException({super.message, required super.requestOptions});

  @override
  String toString() {
    return message ?? 'Something went wrong.';
  }
}

class ApiError implements Exception {
  ApiError({
    required this.error,
  });

  String error;

  @override
  String toString() {
    return error;
  }
}
