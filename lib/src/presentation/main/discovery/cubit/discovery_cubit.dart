import 'package:bloc/bloc.dart';
import 'package:your_app_name/src/data/model/model_category.dart';
import 'package:your_app_name/src/data/model/model_citizen_service.dart';
import 'package:your_app_name/src/utils/configs/image.dart';
import 'package:your_app_name/src/data/remote/api/api.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';

import 'discovery_state.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit() : super(const DiscoveryState.loading());

  List<CitizenServiceModel> list = [];
  List<CitizenServiceModel> listLoaded = [];
  List<CitizenServiceModel> filteredList = [];
  List<CategoryModel> location = [];
  final List<CitizenServiceModel> hiddenServices = [];
  late List<CitizenServiceModel> services;
  bool doesScroll = false;
  int? currentCity;

  Future<void> onLoad(int id) async {
    emit(const DiscoveryState.loading());
    final cityRequestResponse = await Api.requestCities();
    location = List.from(cityRequestResponse.data ?? []).map((item) {
      return CategoryModel.fromJson(item);
    }).toList();
    if (id == 1) {
      services = initializeServices();
    } else if (id == 14) {
      services = initializeServices14();
    } else if (id == 15) {
      services = initializeServices15();
    }
    // services = initializeServices();

    List<CitizenServiceModel> servicesCopy = List.from(services);

    for (var element in servicesCopy) {
      if (element.categoryId != null || element.type == "subCategoryService") {
        // bool hasContent = await element.hasContent();
        // if (!hasContent) {
        //   hiddenServices.add(element);
        // }
      }
    }

    //Remove to see all services
    services.removeWhere((element) => hiddenServices.contains(element));

    await getCitySelected();

    emit(DiscoveryStateLoaded(
      services,
    ));
  }

  Future<void> onLocationFilter(int locationId, bool calledExternal) async {
    await saveCityId(locationId);
    emit(const DiscoveryState.loading());
    await onLoad(1);
    if (calledExternal) {
      await AppBloc.homeCubit.onLoad(false);
    }
  }

  Future<void> updateLocationFilter(int locationId) async {
    emit(const DiscoveryState.loading());
    await onLocationFilter(locationId, true);
  }

  Future<void> saveCityId(int cityId) async {
    final prefs = await Preferences.openBox();
    prefs.setKeyValue(Preferences.cityId, cityId);
  }

  Future<int> getCityId() async {
    final prefs = await Preferences.openBox();
    return prefs.getKeyValue(Preferences.cityId, 0);
  }

  Future<String?> getCityLink() async {
    final prefs = await Preferences.openBox();
    int cityId = await prefs.getKeyValue(Preferences.cityId, 0);
    Map<int, String> cityWebsites = {
      0: "https://your-service-portal-url.com",
      1: "https://your-service-portal-url.com?city=1",
      2: "https://your-service-portal-url.com?city=2",
      3: "https://your-service-portal-url.com?city=3",
    };

    return cityWebsites[cityId];
  }

  Future<void> setServiceValue(String preference, String? type, int? id) async {
    final prefs = await Preferences.openBox();
    prefs.setKeyValue(preference, type ?? id);
  }

  bool getDoesScroll() {
    return doesScroll;
  }

  void setDoesScroll(bool scroll) {
    doesScroll = scroll;
  }

  void scrollUp() {
    emit(const DiscoveryStateLoading());
    emit(DiscoveryStateLoaded(services));
  }

  List<CitizenServiceModel> initializeServices() {
    return [
      // CitizenServiceModel(imageUrl: Images.service2, imageLink: "2"),
      // CitizenServiceModel(
      //     imageUrl: Images.service3,
      //     imageLink: "3",
      //     type: "subCategoryService",
      //     arguments: 4),
      CitizenServiceModel(
          imageUrl: Images.service4,
          imageLink: "4",
          arguments: 4,
          categoryId: 1),
      CitizenServiceModel(
        imageUrl: Images.service10,
        imageLink: "10",
        arguments: 10,
      ),
      CitizenServiceModel(
          imageUrl: Images.service5,
          imageLink: "5",
          arguments: 5,
          categoryId: 3),
      CitizenServiceModel(
          imageUrl: Images.service6,
          imageLink: "6",
          arguments: 6,
          categoryId: 4),
      CitizenServiceModel(
          imageUrl: Images.service3,
          imageLink: "3",
          arguments: 3,
          categoryId: 16),
      CitizenServiceModel(
          imageUrl: Images.service8,
          imageLink: "8",
          arguments: 8,
          categoryId: 13),
      CitizenServiceModel(
          imageUrl: Images.service14,
          imageLink: "14",
          categoryId: 14,
          arguments: 0),
      CitizenServiceModel(
          imageUrl: Images.service15,
          imageLink: "15",
          categoryId: 15,
          arguments: 0),

      CitizenServiceModel(
          imageUrl: Images.service17,
          imageLink: "17",
          arguments: 9,
          categoryId: 0),
      CitizenServiceModel(
          imageUrl: Images.service9,
          imageLink: "9",
          arguments: 9,
          categoryId: 6),
      // CitizenServiceModel(
      //     imageUrl: Images.service6,
      //     imageLink: "6",
      //     arguments: 6,
      //     categoryId: 4),
      // CitizenServiceModel(
      //     imageUrl: Images.service7,
      //     imageLink: "7",
      //     arguments: 7,
      //     categoryId: 10),

      // CitizenServiceModel(
      //     imageUrl: Images.service13,
      //     imageLink: "13",
      //     categoryId: 15,
      //     arguments: 0),
    ];
  }

  List<CitizenServiceModel> initializeServices14() {
    return [
      CitizenServiceModel(
          imageUrl: Images.service14_1,
          imageLink: "14",
          arguments: 141,
          categoryId: 0),
      CitizenServiceModel(
          imageUrl: Images.service14_2,
          imageLink: "14",
          arguments: 142,
          categoryId: 0),
      CitizenServiceModel(
          imageUrl: Images.service14_3,
          imageLink: "14",
          categoryId: 0,
          arguments: 143),
    ];
  }

  List<CitizenServiceModel> initializeServices15() {
    return [
      CitizenServiceModel(
          imageUrl: Images.service15_1,
          imageLink: "15",
          arguments: 151,
          categoryId: 0),
      // CitizenServiceModel(
      //     imageUrl: Images.service15_2,
      //     imageLink: "15",
      //     arguments: 152,
      //     categoryId: 0),
      CitizenServiceModel(
          imageUrl: Images.service15_3,
          imageLink: "15",
          categoryId: 0,
          arguments: 153),
    ];
  }

  Future<int?> getCitySelected() async {
    final prefs = await Preferences.openBox();
    int cityId = await prefs.getKeyValue(Preferences.cityId, 0);
    currentCity = cityId;
    return cityId;
  }
}
