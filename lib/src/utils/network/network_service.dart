import 'package:flutter/foundation.dart';
import 'package:your_app_name/src/utils/network/api_helper.dart';

import '../../services/remot_config_service.dart';
import 'auth_interceptor.dart';
import 'dio_factory.dart';
import 'header_interceptor.dart';

class NetworkService {
  // Private static instance
  static NetworkService? _instance;

  // Private named constructor
  NetworkService._internal(
      {required this.baseApiHelper, required this.forumApiHelper});

  final ApiHelper baseApiHelper;
  final ApiHelper forumApiHelper;

  ApiHelper get baseApi => baseApiHelper;
  ApiHelper get forumApi => forumApiHelper;

  // Factory constructor returns the same instance every time
  factory NetworkService() {
    final config = RemoteConfigService();

    final apiHelper = ApiHelper(
      dioHelper: DioHelper(
        baseUrl: config.getBaseUrl(forum: false),
        showLogs: kDebugMode ? true : false,
        timeoutDuration: const Duration(seconds: 45),
        dioInterceptors: [HeaderInterceptor("${config.getBaseUrl(forum: false)}users/userId/refresh")],
      ),
      fallbackErrorMessage: "Something went wrong!",
    );
    apiHelper.dio.interceptors.add(AuthInterceptor(
      apiHelper.dio,
      "${config.getBaseUrl(forum: false)}users/userId/refresh",
    ));

    final forumApiHelper = ApiHelper(
      dioHelper: DioHelper(
        baseUrl: config.getBaseUrl(forum: true),
        showLogs: kDebugMode ? true : false,
        timeoutDuration: const Duration(seconds: 45),
        dioInterceptors: [HeaderInterceptor("${config.getBaseUrl(forum: false)}users/userId/refresh")],
      ),
      fallbackErrorMessage: "Something went wrong!",
    );

    forumApiHelper.dio.interceptors.add(AuthInterceptor(
      forumApiHelper.dio,
      "${config.getBaseUrl(forum: false)}users/userId/refresh",
    ));

    _instance ??= NetworkService._internal(
        baseApiHelper: apiHelper, forumApiHelper: forumApiHelper);
    return _instance!;
  }
}
