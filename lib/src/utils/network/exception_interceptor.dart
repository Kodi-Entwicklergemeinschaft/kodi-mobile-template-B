import 'package:dio/dio.dart';

import 'base_model.dart';
import 'exceptions.dart';

class ExceptionInterceptor<E extends BaseModel> extends Interceptor {
  final CreateModel<E>? errorModel;
  ExceptionInterceptor({this.errorModel});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      return handler.next(err);
    }
    String? message;
    if (err.response?.data != null) {
      if (err.response?.data is String) {
        message = err.response?.data;
      } else {
        // message = errorModel?.call().fromJson(err.response?.data).message;
        message= err.response?.data['message'];

      }
    }
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DeadlineExceededException(
            message: message, requestOptions: err.requestOptions);
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(
                message: message, requestOptions: err.requestOptions);
          case 401:
            throw UnauthorizedException(
                message: message, requestOptions: err.requestOptions);
          case 404:
            throw NotFoundException(
                message: message, requestOptions: err.requestOptions);
          case 409:
            throw ConflictException(
                message: message, requestOptions: err.requestOptions);
          case 500:
            throw InternalServerErrorException(
                message: message, requestOptions: err.requestOptions);
        }
        break;
      case DioExceptionType.connectionError:
        throw NoInternetConnectionException(
            message: message, requestOptions: err.requestOptions);
      case DioExceptionType.unknown:
        throw UnknownException(
            message: message, requestOptions: err.requestOptions);
      case DioExceptionType.badCertificate:
        throw BadRequestException(
            message: message, requestOptions: err.requestOptions);
      case DioExceptionType.cancel:
        throw CancelException(
            message: message, requestOptions: err.requestOptions);
    }

    return handler.next(err);
  }
}
