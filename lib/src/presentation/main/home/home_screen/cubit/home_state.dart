import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_app_name/src/data/model/model_category.dart';
import 'package:your_app_name/src/data/model/model_product.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeStateInitial;

  const factory HomeState.loading() = HomeStateLoading;

  const factory HomeState.categoryLoading(List<CategoryModel>? location) =
      HomeStatecategoryLoading;

  const factory HomeState.loaded(
    String banner,
    List<CategoryModel> category,
    List<CategoryModel> location,
    List<ProductModel> recent,
    bool isRefreshLoader,
    CategoryModel? selectedCity,
  ) = HomeStateLoaded;

  const factory HomeState.error(String error) = HomeStateError;
}
