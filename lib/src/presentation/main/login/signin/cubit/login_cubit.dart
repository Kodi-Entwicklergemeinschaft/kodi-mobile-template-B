import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/main_dev.dart';
import 'package:your_app_name/main_prod.dart';
import 'package:your_app_name/src/data/remote/api/api.dart';
import 'package:your_app_name/src/data/remote/api/matomo_api.dart';
import 'package:your_app_name/src/data/repository/user_repository.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/login/signin/cubit/login_state.dart';
import 'package:your_app_name/src/services/firebase_messaging_service.dart';
import 'package:your_app_name/src/services/firebase_token_manager.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/logging/loggy_exp.dart';
import 'package:your_app_name/src/utils/user_data_util.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState.initial());

  void onLogin(
      {required String username,
      required String password,
      bool registered = false}) async {
    final response = await UserRepository.login(
      username: username,
      password: password,
    );
    if (response!.success) {
      final userDetailResponse =
          await UserRepository.requestUserDetails(response.data['userId']);
      if (userDetailResponse != null) {
        await AppBloc.authenticateCubit.onSave(userDetailResponse);
        await UserRepository.updateNotificationPreferenceForNewUser(
            response.data['userId']);
        if (!registered) {
          MatomoApi.checkUser();
        }
        final prefs = await Preferences.openBox();
        FirebaseMessagingService(globalNavKey, prefs).subscribeToAllForumChats();

        emit(const LoginState.loaded());
      } else {
        emit(const LoginState.initial());
        logError('Login Result Failed', userDetailResponse);
      }
      _registerFcmToken();
    } else {
      emit(const LoginState.initial());
      emit(LoginState.error(response.message));
      logError('Request User Detail Error', response.message);
    }
  }

  String? getTranslationKey(String sentence) {
    switch (sentence) {
      case "Invalid username":
        return "login_invalid_username";
      case "Invalid password":
        return "login_invalid_password";
      case "Verification email sent to your email id. Please verify first before trying to login.":
        return "login_verification_mail";
    }
    return null;
  }

  void onLogout({bool isSessionExpired=false}) async {
    try {
      // Get user data before cleaning it
      final prefs = await Preferences.openBox();
      final userId = prefs.getKeyValue(Preferences.userId, 0);
      final refreshToken = prefs.getKeyValue(Preferences.refreshToken, '');
      final deviceId = prefs.getKeyValue(Preferences.deviceId, '');

      // Call logout API if we have valid user data
      if (userId > 0 && refreshToken.isNotEmpty) {
        final params = {
          "refreshToken": refreshToken,
          "deviceId": deviceId,
        };
        await Api.requestLogout(userId, params);
      }
    } catch (e) {
      logError('Logout API Error', e);
    } finally {
      final prefs = await Preferences.openBox();
      FirebaseMessagingService(globalNavKey, prefs).unsubscribeFromAllForumChats();
      emit(const LoginState.initial());
      UserDataUtil.cleanUserData();
      AppBloc.authenticateCubit.onClear(isSessionExpired);
      AppBloc.userCubit.onDeleteUser();
    }
  }

  Future<void> _registerFcmToken() async {
    FirebaseTokenManager().fetchAndUploadToken();
  }
}
