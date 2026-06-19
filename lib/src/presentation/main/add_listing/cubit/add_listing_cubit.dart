import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/data/model/model_category.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/data/repository/list_repository.dart';
import 'package:your_app_name/src/presentation/main/add_listing/cubit/add_listing_state.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/logging/loggy_exp.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/model/model_recurring_rule.dart';

class AddListingCubit extends Cubit<AddListingState> {
  final ListRepository _repo;
  List<XFile> selectedAssets = [];

  AddListingCubit(this._repo) : super(const AddListingState.loaded());

  String? selectedCity;
  int? cityId;
  int? villageId;
  int? categoryId;
  int? subCategoryId;
  List listCity = [];
  List listVillage = [];
  List listCategory = [];
  List listSubCategory = [];
  String? selectedVillage;
  String? selectedCategory;
  String? selectedSubCategory;
  Map<int, RecurrenceRuleModel> recurrenceRuleModelMap = {};

  void addRecurringRule({
    required int key,
    String? freq,
    int? interval,
    List<String>? weekdays,
    String? start,
    String? end,
    String? repeatUntil,
    List<String>? exceptionDates,
    int? dayOrdinal,
  }) {
    List<ExceptionDate>? exceptions;

    if (exceptionDates != null && exceptionDates.isNotEmpty) {
      exceptions = exceptionDates?.map((e) => ExceptionDate(date: e)).toList();
    }

    final formattedWeekdays = weekdays?.map(formatWeekday).toList();

    if (!recurrenceRuleModelMap.containsKey(key)) {
      recurrenceRuleModelMap[key] = RecurrenceRuleModel(
        freq: freq,
        interval: interval ?? 1,
        weekdays: formattedWeekdays,
        start: start,
        end: end,
        repeatUntil: repeatUntil,
        exceptions: exceptions,
        dayOrdinal: dayOrdinal,
      );
    }
    emit(state);
  }

  void deleteRecurringRule(int key) {
    recurrenceRuleModelMap.remove(key);
    emit(state);
  }

  void formatRecurringRules() {
    recurrenceRuleModelMap.clear();
    emit(state);
  }

  void updateRecurringRule({
    required int key,
    String? freq,
    int? interval,
    List<String>? weekdays,
    String? start,
    String? end,
    String? repeatUntil,
    List<String>? exceptionDates,
    int? dayOrdinal,
    bool isReset = false,
    bool isResetRepeatUntil = false,
    bool isRepeatExceptionDates = false
  }) {
    List<ExceptionDate>? exceptions;
    if (exceptionDates != null && exceptionDates.isNotEmpty) {
      exceptions = exceptionDates?.map((e) => ExceptionDate(date: e)).toList();
    }

    final formattedWeekdays = weekdays?.map(formatWeekday).toList();


    final existing = recurrenceRuleModelMap[key];
    if (existing == null) return;

    if(isReset) {
      recurrenceRuleModelMap[key] = RecurrenceRuleModel(
        freq: freq,
        interval: 1,
        weekdays: [],
        start: null,
        end: null,
        repeatUntil: null,
        exceptions: [],
        dayOrdinal: null,
      );
    } else {
      recurrenceRuleModelMap[key] = existing.copyWith(
        freq: freq ?? existing.freq,
        interval: interval ?? existing.interval,
        weekdays: formattedWeekdays ?? existing.weekdays,
        start: start ?? existing.start,
        end: end ?? existing.end,
        repeatUntil:
            isResetRepeatUntil ? null : (repeatUntil ?? existing.repeatUntil),
        exceptions: isRepeatExceptionDates ? null : (exceptions ?? existing.exceptions),
        dayOrdinal: dayOrdinal ?? existing.dayOrdinal,
        isResetRepeatUntil : isResetRepeatUntil,
        isRepeatExceptionDates : isRepeatExceptionDates
      );
    }
    emit(state);
  }

  void clearRecurrenceRule() {
    recurrenceRuleModelMap.clear();
    emit(state);
  }

  Future<ResultApiModel?> onSubmit({
    required String title,
    required String description,
    required int cityId,
    int? categoryId,
    int? subCategoryId,
    CategoryModel? country,
    CategoryModel? state,
    String? city,
    int? statusId,
    int? sourceId,
    required String address,
    required String place,
    String? zipcode,
    required String? phone,
    String? email,
    String? website,
    String? status,
    String? expiryDate,
    String? startDate,
    String? endDate,
    String? price,
    TimeOfDay? expiryTime,
    int? timeless,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<File>? imagesList,
    isImageChanged,
    required List<String> allCities,
    Function(String)? error,
    bool isRecurringDayEvent = false
  }) async {
    List<RecurrenceRuleModel> recurrenceRuleList =
    recurrenceRuleModelMap.values.toList();
    try {
      final response = await _repo.saveProduct(
          title,
          categoryId,
          subCategoryId,
          description,
          place,
          country,
          state,
          city,
          statusId,
          sourceId,
          address,
          phone,
          email,
          website,
          status,
          expiryDate,
          startDate,
          endDate,
          expiryTime,
          timeless,
          startTime,
          endTime,
          imagesList,
          isImageChanged,
          allCities,
          isRecurringDayEvent ? recurrenceRuleList : [],
          isRecurringDayEvent
      );

      if (response.success) {
        return response;
      } else {
        if(error!=null){
          error(response.message);
        }
        logError('save Product Response Failed', response.message);
        return null;
      }
    } catch (e, stackTrace) {
      logError('save Product Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<int?> getCurrentCityId() async {
    final prefs = await Preferences.openBox();
    return prefs.getKeyValue(Preferences.cityId, 0);
  }

  Future<bool> onEdit({
    int? cityId,
    int? categoryId,
    int? subCategoryId,
    int? listingId,
    required String title,
    required String description,
    CategoryModel? country,
    CategoryModel? state,
    CategoryModel? city,
    int? statusId,
    int? sourceId,
    required String address,
    required String place,
    String? zipcode,
    required String? phone,
    String? email,
    String? website,
    String? status,
    String? expiryDate,
    String? startDate,
    String? endDate,
    String? createdAt,
    String? price,
    TimeOfDay? expiryTime,
    int? timeless,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    required bool isImageChanged,
    List<File>? imagesList,
    required List<String> allCities,
    Function(String)? error,
    bool isRecurringDayEvent = false,
  }) async {
    List<RecurrenceRuleModel> recurrenceRuleList =
    recurrenceRuleModelMap.values.toList();
    try {
      final response = await _repo.editProduct(
          listingId,
          categoryId,
          subCategoryId,
          cityId,
          title,
          description,
          place,
          country,
          state,
          city,
          statusId,
          sourceId,
          address,
          phone,
          email,
          website,
          status,
          expiryDate,
          startDate,
          endDate,
          createdAt,
          price,
          isImageChanged,
          expiryTime,
          timeless,
          startTime,
          endTime,
          imagesList,
          allCities,
          isRecurringDayEvent ? recurrenceRuleList : [],
          isRecurringDayEvent
      );
      if (response.success) {
        return true;
      } else {
        if(error!=null){
          error(response.message);
        }
        logError('edit Product Response Failed', response.message);
        return false;
      }
    } catch (e, stackTrace) {
      logError('edit Product Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> changeStatus(ProductModel item, int newStatus) async {
    int listingId = item.id;
    int? cityId = item.cityId;
    int? statusId = newStatus;

    try {
      final response =
          await _repo.editProductStatus(listingId, cityId, statusId);
      if (response.success) {
        return true;
      } else {
        logError('save Product Response Failed', response.message);
        return false;
      }
    } catch (e, stackTrace) {
      logError('save Product Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }

  void setImagePref(imagePath) async {
    await _repo.setImagePrefs(imagePath);
  }

  void clearVillage() async {
    _repo.clearVillageId();
  }

  Future<void> deletePdf(cityId, listingId) async {
    await _repo.deletePdf(cityId, listingId);
  }

  Future<void> deleteImage(cityId, listingId) async {
    await _repo.deleteImage(cityId, listingId);
  }

  void clearCityId() async {
    _repo.clearCityId();
  }

  void clearCategoryId() async {
    _repo.clearCategoryId();
  }

  Future<ResultApiModel?> getVillageId(value) async {
    try {
      return _repo.requestVillages(value);
    } catch (e, stackTrace) {
      logError('request Village Error', e);
      emit(AddListingState.error(e.toString()));
      await Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    }
  }

  void setCategoryId(value) async {
    try {
      _repo.setCategoryId(value);
    } catch (e, stackTrace) {
      logError('request categoryID Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void getSubCategoryId(value) async {
    try {
      _repo.getSubCategoryId(value);
    } catch (e, stackTrace) {
      logError('request subCategoryID Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void setSubCategoryId(value) async {
    try {
      _repo.setSubCategoryId(value);
    } catch (e, stackTrace) {
      logError('set subCategoryID Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void saveAssets(assetList) {
    selectedAssets = assetList;
  }

  void removeAssetsByIndex(index) {
    if (selectedAssets.isNotEmpty && index <= selectedAssets.length - 1) {
      selectedAssets.removeAt(index);
    }
  }

  void removeAssets(assets) {
    if (selectedAssets.isNotEmpty) {
      selectedAssets.remove(assets);
    }
  }

  void clearAssets() {
    selectedAssets.clear();
  }

  List<XFile> getSelectedAssets() {
    return selectedAssets;
  }

  Future<ResultApiModel?> loadSubCategory(value) async {
    try {
      if (value != null) {
        final subCategoryResponse = await _repo.loadSubCategory(value);
        return subCategoryResponse;
      }
      return null;
    } catch (e, stackTrace) {
      logError('request subCategoryID Error', e);
      await Sentry.captureException(e, stackTrace: stackTrace);

      return null;
    }
  }

  void clearSubCategory() async {
    _repo.clearSubCategory();
  }

  Future<ResultApiModel?> loadCities() async {
    try {
      final loadCitiesResponse = ListRepository.loadCities();
      return loadCitiesResponse;
    } catch (e, stackTrace) {
      logError('load cities error', e.toString());
      await Sentry.captureException(e, stackTrace: stackTrace);

      return null;
    }
  }

  Future<ResultApiModel?> loadCategory() async {
    try {
      final loadCategoryResponse = _repo.loadCategory();
      return loadCategoryResponse;
    } catch (e, stackTrace) {
      logError('load category error', e.toString());
      await Sentry.captureException(e, stackTrace: stackTrace);

      return null;
    }
  }

  Future<ResultApiModel> loadVillages(value) async {
    final response = await ListRepository.loadVillages(value);
    return response;
  }

  Future<void> clearImagePath() async {
    _repo.clearImagePath();
  }

  String formatWeekday(String day) {
    if (day.isEmpty) return day;
    return day[0].toUpperCase() + day.substring(1).toLowerCase();
  }
}

class ParsedDateTime {
  final String date;
  final TimeOfDay time;

  ParsedDateTime(this.date, this.time);
}
