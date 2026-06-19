import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/data/model/model_multifilter.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/data/repository/list_repository.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/logging/loggy_exp.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'cubit.dart';

enum ProductFilter {
  week,
  month,
}

class ListCubit extends Cubit<ListState> {
  final ListRepository repo;

  ListCubit(this.repo) : super(const ListStateLoading()) {
    // final isEvent = categoryPreferencesCall();
  }

  int pageNo = 1;
  List<ProductModel> list = [];
  PaginationModel? pagination;
  List<ProductModel> listLoaded = [];
  List<ProductModel> filteredList = [];
  List listCity = [];
  bool isSearching = false;
  String? searchTerm;
  String? currentEventType;
  String? searchEventType;

  String? currentStartDate;
  String? currentEndDate;

  Future<void> onLoad(cityId, {String? eventType, String? startDate, String? endDate}) async {
    pageNo = 1;
    currentEventType = eventType;
    currentStartDate = startDate;
    currentEndDate = endDate;
    isSearching = false;
    searchTerm = "";


    final prefs = await Preferences.openBox();
    final categoryId = prefs.getKeyValue(Preferences.categoryId, 0);
    final type = prefs.getKeyValue(Preferences.type, '');
    listCity = await getCityList() ?? [];
    dynamic result;
    if (cityId is List) {
      result = [];
      for (var city in cityId) {
        final list = await ListRepository.loadList(
          categoryId: (categoryId == 0) ? "" : categoryId,
          type: type,
          pageNo: pageNo,
          cityId: city,
          eventType: eventType,
          startDate: startDate,
          endDate: endDate,
        );
        result.addAll(list);
      }
    } else {
      result = await ListRepository.loadList(
        categoryId: (categoryId == 0) ? "" : categoryId,
        type: type,
        pageNo: pageNo,
        cityId: cityId,
        eventType: eventType,
        startDate: startDate,
        endDate: endDate,
      );
    }
    if (result != null) {
      list = result[0];
      pagination = result[1];
      listLoaded = list;
      emit(ListStateLoaded(list, listCity));
    }
  }

  Future<void> setCategoryFilter(int filter, int? cityId) async {
    final prefs = await Preferences.openBox();

    if (filter == 0) {
      prefs.setKeyValue(Preferences.categoryId, 0);
    } else {
      prefs.setKeyValue(Preferences.categoryId, filter);
    }
    if (cityId != null) {
      pageNo = 1;
      onLoad(cityId);
    }
  }

  Future<List<ProductModel>> newListings(int pageNo, city,
      {String? eventType, String? startDate, String? endDate}) async {
    final prefs = await Preferences.openBox();
    // final cityId = prefs.getKeyValue(Preferences.cityId, 0);
    final categoryId = prefs.getKeyValue(Preferences.categoryId, 0);
    final type = prefs.getKeyValue(Preferences.type, '');

    dynamic result;

    if (city is List) {
      result = [];
      for (var cityId in city) {
        final list = await ListRepository.loadList(
          categoryId: (categoryId == 0) ? "" : categoryId,
          type: type,
          pageNo: pageNo,
          cityId: cityId,
          eventType: eventType ?? currentEventType,
          startDate: startDate ?? currentStartDate,
          endDate: endDate ?? currentEndDate,
        );
        result.addAll(list);
      }
    } else {
      result = await ListRepository.loadList(
        categoryId: (categoryId == 0) ? "" : categoryId,
        type: type,
        pageNo: pageNo,
        cityId: city,
        eventType: eventType ?? currentEventType,
        startDate: startDate ?? currentStartDate,
        endDate: endDate ?? currentEndDate,
      );
    }

    final listUpdated = result?[0] ?? [];
    if (listUpdated.isNotEmpty) {
      list.addAll(listUpdated);
    }
    return list;
  }

  List<ProductModel> getLoadedList() => listLoaded;

  Future<List<ProductModel>> updateLoadedList(cityId,
      {String? eventType, String? startDate, String? endDate}) async {

    pageNo = 1;

    final prefs = await Preferences.openBox();
    final categoryId = prefs.getKeyValue(Preferences.categoryId, 0);
    final type = prefs.getKeyValue(Preferences.type, '');
    List<ProductModel> result = [];
    // for (var cityId in city) {
    final list = await ListRepository.loadList(
      categoryId: (categoryId == 0) ? "" : categoryId,
      type: type,
      pageNo: pageNo,
      cityId: cityId,
      eventType: eventType ?? currentEventType,
      startDate: startDate ?? currentStartDate,
      endDate: endDate ?? currentEndDate,
    );
    result.addAll(list?[0] as List<ProductModel>? ?? []);
    // }
    listLoaded = result;
    return listLoaded;
  }

  Future<void> searchListing(content, bool newSearch, int? selectedCityId,
      {String? eventType}) async {
    if (newSearch) {
      emit(const ListState.loading());
      pageNo = 1;
    }
    isSearching = true;
    searchTerm = content.toString();
    searchEventType = eventType ?? currentEventType;

    final prefs = await Preferences.openBox();

    final categoryId = prefs.getKeyValue(Preferences.categoryId, 0);
    final cityId = selectedCityId ?? prefs.getKeyValue(Preferences.cityId, 0);
    List<ProductModel>? listDataList = [];
    MultiFilter multiFilter = MultiFilter(
        hasCategoryFilter: true,
        hasLocationFilter: true,
        currentLocation: cityId,
        currentCategory: categoryId,
        eventType: searchEventType);

    final result = await ListRepository.searchListing(
        content: content, multiFilter: multiFilter, pageNo: pageNo++);
    final List<ProductModel>? listUpdated = result?[0];
    if (listUpdated != null) {
      if (newSearch) {
        list = [];
      }
      list.addAll(listUpdated);
    }
    for (final product in list) {
      listDataList.add(
        ProductModel(
            id: product.id,
            cityId: product.cityId,
            title: product.title,
            image: product.image,
            pdf: product.pdf,
            category: product.category,
            categoryId: product.categoryId,
            subcategoryId: product.subcategoryId,
            startDate: product.startDate,
            endDate: product.endDate,
            createDate: product.createDate,
            favorite: product.favorite,
            address: product.address,
            phone: product.phone,
            email: product.email,
            website: product.website,
            description: product.description,
            statusId: product.statusId,
            userId: product.userId,
            sourceId: product.sourceId,
            imageLists: product.imageLists,
            expiryDate: product.expiryDate,
            externalId: product.externalId,
            recurrenceRules: product.recurrenceRules
        ),
      );
    }

    emit(ListStateUpdated(listDataList, listCity));
  }

  Future<void> cancelSearch(int cityId, {String? eventType, String? startDate, String? endDate}) async {
    isSearching = false;
    searchTerm = "";
    searchEventType = null;
    pageNo = 1;
    onLoad(cityId, eventType: eventType, startDate: startDate, endDate: endDate);
  }

  void clearSearchOnTabChange() {
    if (isSearching) {
      isSearching = false;
      searchTerm = "";
      searchEventType = null;
      pageNo = 1;
    }
  }

  void onDateProductFilter(ProductFilter? type, List<ProductModel> loadedList,
      bool filterLocation, int? currentCity) {
    pageNo = 1;
    final currentDate = DateTime.now();
    if (type == ProductFilter.month) {
      filteredList = loadedList.where((product) {
        final startDate = _parseDate(product.startDate);
        if (startDate != null) {
          final startMonth = startDate.month;
          final currentMonth = currentDate.month;
          if (filterLocation && currentCity != null) {
            return (startMonth == currentMonth) &&
                (currentCity == product.cityId);
          } else {
            return startMonth == currentMonth;
          }
        }
        return false;
      }).toList();

      emit(ListStateUpdated(filteredList, listCity));
    } else if (type == ProductFilter.week) {
      filteredList = loadedList.where((product) {
        final startDate = _parseDate(product.startDate);
        if (startDate != null) {
          final startWeek = _getWeekNumber(startDate);
          final currentWeek = _getWeekNumber(currentDate);
          if (filterLocation && currentCity != null) {
            return (startWeek == currentWeek) && currentCity == product.cityId;
          } else {
            return startWeek == currentWeek;
          }
        }
        return false;
      }).toList();

      emit(ListStateUpdated(filteredList, listCity));
    } else if (type == null && filterLocation && currentCity != null) {
      if (currentCity == 0) {
        filteredList = loadedList;
      } else {
        filteredList = loadedList.where((product) {
          return currentCity == product.cityId;
        }).toList();
      }
      emit(ListStateUpdated(filteredList, listCity));
    } else {
      emit(ListStateUpdated(loadedList, listCity));
    }
  }

  DateTime? _parseDate(String dateTimeString) {
    try {
      final dateAndTimeParts = dateTimeString.split(' ');
      if (dateAndTimeParts.isNotEmpty) {
        final datePart = dateAndTimeParts[0];
        final dateParts = datePart.split('.');
        if (dateParts.length == 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      logError("Error parsing date: $dateTimeString");
    }
    return null;
  }

  static Future<List?> getCityList() async {
    ResultApiModel? loadCitiesResponse;
    try {
      loadCitiesResponse = await ListRepository.loadCities();
    } catch (e, stackTrace) {
      logError('load cities error', e.toString());
      await Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    }

    List listCity = loadCitiesResponse.data;
    return listCity;
  }

  static String getCityNameFromId(List listCity, int cityId) {
    if (listCity.isNotEmpty) {
      final city = listCity.firstWhere((cityData) => cityData["id"] == cityId);
      return city["name"];
    }
    return "";
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStartOfYear = date.difference(startOfYear).inDays;
    return (daysSinceStartOfYear / 7).ceil();
  }

  Future<bool?> categoryPreferencesCall() async {
    final prefs = await Preferences.openBox();
    final categoryId = prefs.getKeyValue(Preferences.categoryId, '');
    if (categoryId == 3) {
      return true;
    } else {
      return null;
    }
  }

  Future<String?> getCategory() async {
    final categoryId = await repo.getCategoryId();
    Map<int, String> categories = {
      1: "category_news",
      2: "category_traffic",
      3: "category_events",
      4: "category_clubs",
      5: "category_products",
      6: "category_offer_search",
      7: "category_free",
      8: "category_defect_report",
      9: "category_lost_found",
      10: "category_companies",
      11: "category_public_transport",
      12: "category_offers",
      13: "category_food",
      14: "category_rathaus",
      15: "category_newsletter",
      16: "category_official_notification"
    };
    return categories[categoryId];
  }

  static String? getCategoryFromId(int categoryId) {
    Map<int, String> categories = {
      1: "category_news",
      2: "category_traffic",
      3: "category_events",
      4: "category_clubs",
      5: "category_products",
      6: "category_offer_search",
      7: "category_free",
      8: "category_defect_report",
      9: "category_lost_found",
      10: "category_companies",
      11: "category_public_transport",
      12: "category_offers",
      13: "category_food",
      14: "category_rathaus",
      15: "category_newsletter",
      16: "category_official_notification"
    };
    return categories[categoryId];
  }
}
