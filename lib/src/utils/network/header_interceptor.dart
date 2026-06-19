import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../configs/application.dart';
import '../configs/preferences.dart';
import 'auth_interceptor.dart';
import 'omega_logger.dart';

class HeaderInterceptor extends Interceptor {
  final String _refreshEndpoint;
  HeaderInterceptor(this._refreshEndpoint);


  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await Preferences.openBox();
    Map<String, dynamic> headers = {
      "Device-Id": Application.device?.uuid,
      "osName": Application.device?.model,
      "Device-Version": Application.device?.version,
      "deviceType": '${Application.device?.type} ${Application.device?.model}',
      "Device-Token": Application.device?.token,
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    var token = prefs.getKeyValue(Preferences.token, '');
    if (token != '') {
      if(isTokenExpired(token)){
        try{
          token= await _refreshToken();
        }
        catch(e){
          debugPrint(e.toString());
        }
      }
      headers["Authorization"] = "Bearer $token";
    }
    options.headers.addAll(headers);
    super.onRequest(options, handler);
  }

  bool isTokenExpired( String token){
    return JwtDecoder.isExpired(token);
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
}
