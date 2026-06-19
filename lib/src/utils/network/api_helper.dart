import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';

import 'base_model.dart';
import 'dio_factory.dart';
import 'exceptions.dart';

class ApiHelper<E extends BaseModel> {
  final Dio _dio;

  get dio => _dio;
  CreateModel<E>? errorModel;
  final String fallbackErrorMessage;

  ApiHelper._internal(
    this._dio, {
    this.errorModel,
    required this.fallbackErrorMessage,
  });

  factory ApiHelper({
    required DioHelper dioHelper,
    CreateModel<E>? errorModel,
    String? fallbackErrorMessage,
  }) {
    return ApiHelper._internal(
      dioHelper.createDio(),
      fallbackErrorMessage: fallbackErrorMessage ??
          "Unknown error occurred, please try again later.",
      errorModel: errorModel,
    );
  }

  Left<Exception, Never> _handleDioError(DioException e) {
    if (e.response?.data != null) {
      try {
        if (e.response!.data is String) {
          return Left(ApiError(error: e.response!.data));
        } else if (errorModel != null) {
          final model = errorModel!().fromJson(e.response!.data);
          if (model.message?.isNotEmpty ?? false) {
            return Left(ApiError(error: model.message!));
          }
        } else if (e.response!.data['message'] != null) {
          return Left(ApiError(error: e.response!.data['message']));
        }
      } catch (error) {
        return Left(ApiError(error: fallbackErrorMessage));
      }
    }
    return Left(ApiError(error: e.message ?? fallbackErrorMessage));
  }

  Future<Either<Exception, T>> postRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    List<dynamic>? bodyList,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.post(
        path,
        data: body ?? bodyList,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, T>> patchRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    List<dynamic>? bodyList,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.patch(
        path,
        data: body ?? bodyList,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, T>> postFormRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    FormData? body,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
    bool isConvertResponse = false,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.post(
        path,
        data: body,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      if (isConvertResponse) {
        final convertResponse = {
          "success": response.data['id'] != null,
          "data": response.data
        };
        return Right(create().fromJson(convertResponse));
      }
      return Right(create().fromJson(response.data));
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, List<T>>> postListRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.post(
        path,
        data: body,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      if (response.data is List) {
        return Right((response.data as List)
            .map<T>((e) => create().fromJson(e))
            .toList());
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, T>> getRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.get(
        path,
        queryParameters: params,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, T>> getFormRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    FormData? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio.get(
        path,
        data: params,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on DioException catch (e) {
      return _handleDioError(e);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, List<T>>> getListRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.get(
        path,
        queryParameters: params,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      if (response.data is List) {
        return Right((response.data as List)
            .map<T>((e) => create().fromJson(e))
            .toList());
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, List<String>>>
      getStringListRequest<T extends BaseModel>({
    required String path,
    CancelToken? cancelToken,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.get(
        path,
        queryParameters: params,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is List) {
        return Right(
            (response.data as List).map<String>((e) => e.toString()).toList());
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, List<int>>> getByteArray({
    required String path,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await Dio().post<List<int>>(
        path,
        data: body,
        options: Options(responseType: ResponseType.bytes),
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data != null && response.data is List<int>) {
        return Right(response.data!);
      } else {
        return Left(ApiError(error: "Response is not list type"));
      }
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    } catch (error) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(ApiError(error: fallbackErrorMessage));
    }
  }

  Future<Either<Exception, T>> putRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    ProgressCallback? onReceiveProgress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.put(
        path,
        data: body,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }

  Future<Either<Exception, T>> deleteRequest<T extends BaseModel>({
    required String path,
    required CreateModel<T> create,
    CancelToken? cancelToken,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      var response = await _dio.delete(
        path,
        data: body,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      if (response.data is String) {
        return Right(create().fromJson({"message": response.data}));
      }
      return Right(create().fromJson(response.data));
    } on DioException catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return _handleDioError(e);
    } on Exception catch (e) {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
      return Left(e);
    }
  }
}
