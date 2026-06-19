import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:your_app_name/src/data/model/model_user.dart';
import 'package:your_app_name/src/data/repository/user_repository.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/account/edit_profile/cubit/edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(const EditProfileState.loaded());

  Future<bool> onUpdateUser({
    required String username,
    required String firstname,
    required String lastname,
    required String email,
    required String url,
    required String description,
    String? image,
  }) async {
    final changeProfileResponse = await UserRepository.changeProfile(
      username: username,
      firstname: firstname,
      lastname: lastname,
      email: email,
      url: url,
      description: description,
      image: image,
    );

    if (changeProfileResponse) {
      await AppBloc.userCubit.onFetchUser();
      await AppBloc.userCubit.onLoadUser();
    }
    return changeProfileResponse;
  }

  Future<void> deleteProfileImage() async {
    final response = await UserRepository.deleteProfileImage();
    if (response.success) {
      await AppBloc.userCubit.onFetchUser();
      emit(const EditProfileState.imageDeleted());
      emit(const EditProfileState.loaded());
    } else {
      emit(const EditProfileState.error());
      emit(const EditProfileState.loaded());
    }
  }

  UserModel getUserDetails() {
    return AppBloc.userCubit.state!;
  }
}
