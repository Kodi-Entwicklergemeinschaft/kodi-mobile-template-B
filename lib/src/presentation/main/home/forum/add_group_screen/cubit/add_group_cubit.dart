import 'package:bloc/bloc.dart';
import 'package:your_app_name/src/data/repository/forum_repository.dart';
import 'package:your_app_name/src/presentation/main/home/forum/add_group_screen/cubit/add_group_state.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/logging/loggy_exp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AddGroupCubit extends Cubit<AddGroupState> {
  final ForumRepository _repo;

  AddGroupCubit(this._repo) : super(const AddGroupState.loaded());

  String? selectedCity;
  int? cityId;
  List listCity = [];

  Future<bool> onSubmit(
      {required String title,
      required String description,
      required List<int> cityIds,
      List<String>? cities,
      String? type,
      String? selectedImagePath}) async {
    try {
      final response = await _repo.saveForum(
          title, description, cityIds, type, selectedImagePath);
      if (response.success) {
        return true;
      } else {
        logError('Save Forum Response Failed', response.message);
        return false;
      }
    } catch (e, stackTrace) {
      logError('Save Forum Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> onEditForum(
    String title,
    String description,
    String? type,
    String? selectedImagePath,
    forumId,
    createdDate,
  ) async {
    try {
      final response = await _repo.editForum(
        title,
        description,
        type,
        selectedImagePath,
        forumId,
        createdDate,
      );
      if (response.success) {
        return true;
      } else {
        logError('Edit Forum Response Failed', response.message);
        return false;
      }
    } catch (e, stackTrace) {
      logError('Edit Forum Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<int?> getCurrentCityId() async {
    final prefs = await Preferences.openBox();
    return prefs.getKeyValue(Preferences.cityId, 0);
  }

  void setImagePref(imagePath) async {
    await _repo.setImagePrefs(imagePath);
  }

  Future<void> deleteImage(cityId, listingId) async {
    await _repo.deleteImage(cityId, listingId);
  }

  void clearCityId() async {
    _repo.clearCityId();
  }

  Future<List<dynamic>?> loadCities() async {
    try {
      final loadForumCitiesResponse = await _repo.loadForumCities();
      if (loadForumCitiesResponse.success) {
        return loadForumCitiesResponse.data;
      }
    } catch (e, stackTrace) {
      logError('load cities error', e.toString());
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
    return null;
  }

  Future<void> clearImagePath() async {
    _repo.clearImagePath();
  }
}
