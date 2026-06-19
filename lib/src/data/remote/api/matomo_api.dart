// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/home/list_product/cubit/cubit.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

abstract class MatomoApi {
  static const String category_signup = 'Registrierung';
  static const String category_category = 'Kategorie';
  static const String category_contribution = 'Beitrag';

  static const String action_signup = 'Registrierungen abgeschlossen';
  static const String action_category = 'Kategorien besucht';
  static const String action_contribution = 'Beiträge erstellt';

  static Future<void> initialize(String siteId, String url) async {
    await MatomoTracker.instance.initialize(
      siteId: siteId,
      url: url,
    );
    checkUser();
  }

  static Future<void> checkUser({int? id}) async {
    final UserModel? user = await AppBloc.userCubit.onLoadUser();
    if (user != null) {
      MatomoTracker.instance.setVisitorUserId(user.id.toString());
    } else if (id != null) {
      //If no user could be found (user == null), it means the user registered
      MatomoTracker.instance.trackEvent(
          eventInfo: EventInfo(
        category: category_signup,
        name: '${category_signup}_Nutzer_${id.toString()}',
        action: action_signup,
        value: 1,
      ));
    }
  }

  static Future<void> trackMatomoEvent(BuildContext context,
      {required bool isCategory,
      required int categoryId,
      required int cityId,
      String? listingTitle,
      int? listingId}) async {
    List cityList = await ListCubit.getCityList() ?? [];
    late String eventName;
    late String type;
    late String action;
    late String cityName;
    late Map<String, String> dimensions;

    if (cityId == 0) {
      cityName = "Alle-Orte";
    } else {
      cityName = ListCubit.getCityNameFromId(cityList, cityId);
    }

    String categoryName = Translate.of(context)
        .translate(ListCubit.getCategoryFromId(categoryId));

    if (isCategory) {
      eventName = "${category_category}_$categoryName";
      type = category_category;
      action = action_category;
      dimensions = {'dimension3': cityName};
    } else {
      if (listingTitle == null || listingId == null) {
        return;
      } else if (listingTitle.length > 50) {
        listingTitle = '${listingTitle.substring(0, 47)}...';
      }
      eventName = "${category_contribution}_${listingTitle}_$listingId";
      type = category_contribution;
      action = action_contribution;
      dimensions = {'dimension1': categoryName, 'dimension2': cityName};
    }
    MatomoTracker.instance.trackEvent(
        eventInfo: EventInfo(
          category: type,
          name: eventName,
          action: action,
          value: 1,
        ),
        dimensions: dimensions);
  }
}
