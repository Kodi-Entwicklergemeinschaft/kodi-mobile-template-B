import 'package:your_app_name/src/data/model/model_category.dart';
import 'package:your_app_name/src/presentation/main/home/list_product/cubit/cubit.dart';

import '../../presentation/main/home/forum/list_groups/cubit/list_groups_cubit.dart';

class MultiFilter {
  final ProductFilter? currentProductEventFilter; //ListProduct filter
  final GroupFilter? currentForumGroupFilter; //Forum group filter
  final int? currentListingStatus; //Listing status in All Listings
  final int? currentCategory; //Listing category in ListProduct city

  final List<CategoryModel>? cities; //All cities
  final List<CategoryModel>? categories;
  final dynamic currentLocation; //Location IDs

  final bool hasListingStatusFilter;
  final bool hasForumGroupFilter;
  final bool hasProductEventFilter;
  final bool hasLocationFilter;
  final bool hasCategoryFilter;

  final bool multipleCityFilter;

  final String? eventType;

  final String? startDate;
  final String? endDate;
  final bool hasDateRangeFilter;

  MultiFilter({
    this.currentLocation,
    this.cities,
    this.categories,
    this.currentForumGroupFilter,
    this.currentListingStatus,
    this.currentProductEventFilter,
    this.currentCategory,
    this.hasListingStatusFilter = false,
    this.hasForumGroupFilter = false,
    this.hasProductEventFilter = false,
    this.hasLocationFilter = false,
    this.hasCategoryFilter = false,
    this.multipleCityFilter = false,
    this.eventType,
    this.startDate,
    this.endDate,
    this.hasDateRangeFilter = false,
  });

  MultiFilter copyWith({
    ProductFilter? currentProductEventFilter,
    GroupFilter? currentForumGroupFilter,
    int? currentListingStatus,
    int? currentCategory,
    List<CategoryModel>? cities,
    List<CategoryModel>? categories,
    dynamic currentLocation,
    bool? hasListingStatusFilter,
    bool? hasForumGroupFilter,
    bool? hasProductEventFilter,
    bool? hasLocationFilter,
    bool? hasCategoryFilter,
    bool? multipleCityFilter,
    String? eventType,
    String? startDate,
    String? endDate,
    bool? hasDateRangeFilter,
  }) {
    return MultiFilter(
      currentProductEventFilter:
          currentProductEventFilter ?? this.currentProductEventFilter,
      currentForumGroupFilter:
          currentForumGroupFilter ?? this.currentForumGroupFilter,
      currentListingStatus: currentListingStatus ?? this.currentListingStatus,
      currentCategory: currentCategory ?? this.currentCategory,
      cities: cities ?? this.cities,
      categories: categories ?? this.categories,
      currentLocation: currentLocation ?? this.currentLocation,
      hasListingStatusFilter:
          hasListingStatusFilter ?? this.hasListingStatusFilter,
      hasForumGroupFilter: hasForumGroupFilter ?? this.hasForumGroupFilter,
      hasProductEventFilter:
          hasProductEventFilter ?? this.hasProductEventFilter,
      hasLocationFilter: hasLocationFilter ?? this.hasLocationFilter,
      hasCategoryFilter: hasCategoryFilter ?? this.hasCategoryFilter,
      multipleCityFilter: multipleCityFilter ?? this.multipleCityFilter,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hasDateRangeFilter: hasDateRangeFilter ?? this.hasDateRangeFilter,
    );
  }
}
