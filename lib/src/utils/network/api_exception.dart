import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiException {
  late String? errorCode = "";
  late String? errorMessage = "";
  late DioException _exception;
  late dynamic errType;

  DioException get exception => _exception;

  ApiException({required DioException exception}) {
    _exception = exception;
    errType = _exception.type;
    debugPrint("Exception: ${exception.type} ${exception.message}");
    String message =
        exception.message ?? "Something went wrong, Please try after sometime";
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = "Connection timed out. Please try again later.";
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = "Connection timed out. Please try again later.";
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = "Connection timed out. Please try again later.";
        break;
      case DioExceptionType.badCertificate:
        errorMessage = message;
        break;
      case DioExceptionType.badResponse:
        switch(exception.response?.statusCode){
          case 401:
            errorMessage = "Unauthorized Access";
            break;
          default:
            errorMessage = message;
            break;
        }

        break;
      case DioExceptionType.cancel:
        errorMessage = message;
        break;
      case DioExceptionType.connectionError:
        errorMessage = message;
        break;
      case DioExceptionType.unknown:
        errorMessage = message;
        break;
    }
  }

  @override
  String toString() {
    return errorMessage??"Something went wrong,Please try again later";
  }

}
