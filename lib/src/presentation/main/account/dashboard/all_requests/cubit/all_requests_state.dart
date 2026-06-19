import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/utils/common_enums.dart';

part 'all_requests_state.freezed.dart';

@freezed
class AllRequestsState with _$AllRequestsState {
  const factory AllRequestsState.initial() = AllRequestsStateInitial;

  const factory AllRequestsState.loading() = AllRequestsStateLoading;

  const factory AllRequestsState.loaded(
      List<ProductModel> recent,
      bool isRefreshLoader,
      PostStatusType selectedStatus,
      ) = AllRequestsStateLoaded;

}
