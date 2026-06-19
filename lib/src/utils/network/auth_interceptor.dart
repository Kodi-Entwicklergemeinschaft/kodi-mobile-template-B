import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

import '../../presentation/cubit/app_bloc.dart';
import '../configs/preferences.dart';
import '../user_data_util.dart';
import 'omega_logger.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final String _refreshEndpoint;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedRequests = [];


  AuthInterceptor(this._dio, this._refreshEndpoint);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final prefs = await Preferences.openBox();
    // Only handle 401 errors
    if (err.response?.statusCode != 401 || prefs.getKeyValue(Preferences.refreshToken, '').toString().isEmpty) {
      handler.next(err);
      return;
    }

    // Don't refresh token for the refresh endpoint itself
    if (err.requestOptions.path == _refreshEndpoint) {
      handler.next(err);
      return;
    }

    try {
      // If already refreshing, queue the request
      if (_isRefreshing) {
        _failedRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;

      // Attempt to refresh the token
      final newToken = await _refreshToken();

      if (newToken != null) {
        // Update the failed request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // Retry the original request
        final response = await _dio.fetch(err.requestOptions);

        // Process any queued requests
        await _processQueuedRequests(newToken);

        handler.resolve(response);
      } else {
        // authErrorNotifier.notifyAuthError();
        //TODO Clear Session
        AppBloc.loginCubit.onLogout(isSessionExpired: true);
        UserDataUtil.cleanUserData();
        // Token refresh failed, clear tokens and proceed with error
        await _processQueuedRequests(null);
        handler.next(err);
      }
    } catch (refreshError) {
      // authErrorNotifier.notifyAuthError();
      //TODO Clear Session
      AppBloc.loginCubit.onLogout(isSessionExpired: true);
      UserDataUtil.cleanUserData();
      // Token refresh failed, clear tokens
      await _processQueuedRequests(null);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final prefs = await Preferences.openBox();
      var token = prefs.getKeyValue(Preferences.token, '');
      var refreshToken = prefs.getKeyValue(Preferences.refreshToken, '');
      final userId = prefs.getKeyValue(Preferences.userId, '');
      if (refreshToken == null) {
        return null;
      }

      // Create a new Dio instance to avoid interceptor loops
      final refreshDio = Dio();
      refreshDio.interceptors.add(
        const OmegaDioLogger(
          convertFormData: true,
          showError: true,
          showRequest: true,
          showRequestBody: true,
          showRequestHeaders: true,
          showRequestQueryParameters: true,
          showResponse: true,
          showResponseBody: true,
          showResponseHeaders: true,
          showCurl: true,
          showLog: true,
        ),
      );

      final response = await refreshDio.post(
        _refreshEndpoint.replaceAll("userId", "${userId}"),
        data: {
          'refreshToken': refreshToken,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        })
      );

      if (response.statusCode == 200) {
        final data = RefreshTokenResponse.fromJson(response.data);
        final newAccessToken = data.data.accessToken;
        final newRefreshToken = data.data.refreshToken;
        // Store the new tokens
        prefs.setKeyValue(Preferences.token, newAccessToken);
        prefs.setKeyValue(
            Preferences.refreshToken, newRefreshToken);

        return newAccessToken;
      }

      return null;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
    }
  }

  Future<void> _processQueuedRequests(String? newToken) async {
    for (final requestOptions in _failedRequests) {
      try {
        if (newToken != null) {
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          await _dio.fetch(requestOptions);
        }
      } catch (e) {
        debugPrint('Failed to retry queued request: $e');
      }
    }
    _failedRequests.clear();
  }
}

class RefreshTokenResponse {
  final String status;
  // final String message;
  final RefreshTokenData data;

  RefreshTokenResponse({
    required this.status,
    // required this.message,
    required this.data,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      status: json['status'] as String,
      // message: json['message'] as String,
      data: RefreshTokenData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

}

class RefreshTokenData {
  final String refreshToken;
  final String accessToken;

  RefreshTokenData({
    required this.refreshToken,
    required this.accessToken,
  });

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(
      refreshToken: json['refreshToken'] as String,
      accessToken: json['accessToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
      'accessToken': accessToken,
    };
  }
}
