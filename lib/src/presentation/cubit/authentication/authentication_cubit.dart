import 'package:bloc/bloc.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/data/remote/api/api.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/cubit/authentication/authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(const AuthenticationState.loading());

  Future<void> onCheck() async {
    emit(const AuthenticationState.loading());
    UserModel? user = await AppBloc.userCubit.onLoadUser();
    if (user != null) {
      AppBloc.wishListCubit.onLoad();

      AppBloc.userCubit.onFetchUser();

      emit(const AuthenticationState.loaded());
      AppBloc.userCubit.onFetchUser();
    } else {
      emit(const AuthenticationState.failed());
    }
  }

  Future<void> onSave(UserModel user) async {
    emit(const AuthenticationState.loading());
    Api.requestUser(userId: user.id);

    await AppBloc.userCubit.onSaveUser(user);

    AppBloc.wishListCubit.onLoad();

    emit(const AuthenticationState.loaded());
  }

  Future<void> onClear(bool isSessionExpired) async {
    if(isSessionExpired){
      emit(const AuthenticationState.failed());
    }
    else {
      emit(const AuthenticationState.loggedOut());
    }
  }
}
