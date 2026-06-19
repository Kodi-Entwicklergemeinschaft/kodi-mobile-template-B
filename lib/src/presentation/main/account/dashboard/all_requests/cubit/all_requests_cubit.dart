import 'package:bloc/bloc.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/data/model/model_result_api.dart';
import 'package:your_app_name/src/data/remote/api/api.dart';
import 'package:your_app_name/src/presentation/main/account/dashboard/all_requests/cubit/all_requests_state.dart';
import 'package:your_app_name/src/utils/common_enums.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:loggy/loggy.dart';

class AllRequestsCubit extends Cubit<AllRequestsState> {
  AllRequestsCubit() : super(const AllRequestsState.loading()) {
    onLoad(isRefreshLoader: false,status:PostStatusType.pending);
  }

  dynamic posts;
  int currentCityFilter = 0;

  Future<void> onLoad({required bool isRefreshLoader, required PostStatusType status}) async {
    if (!isRefreshLoader) emit(const AllRequestsState.loading());

    late ResultApiModel listingsRequestResponse;
    if (currentCityFilter == 0) {
      listingsRequestResponse = await Api.requestStatusListings(status.value, 1);
    } else {
      listingsRequestResponse =
          await Api.requestStatusLocList(currentCityFilter, 1, status.value);
    }

    posts = List.from(listingsRequestResponse.data ?? []).map((item) {
      return ProductModel.fromJson(item);
    }).toList();

    emit(AllRequestsState.loaded(posts, isRefreshLoader,status));
  }

  void updateSelectedStatus(PostStatusType status) {
    state.maybeWhen(
      loaded: (posts, isRefreshLoader, _) {
        // Re-emit the same posts but with the new status and refresh
        emit(AllRequestsState.loaded(posts, isRefreshLoader, status));
        onLoad(status: status, isRefreshLoader: false);
      },
      orElse: () {},
    );
  }

  Future<dynamic> newListings({required int pageNo, required PostStatusType status}) async {
    if (pageNo == 1) posts = [];
    final ResultApiModel listingsRequestResponse =
        await Api.requestStatusListings(status, pageNo);

    final newRecent = List.from(listingsRequestResponse.data ?? []).map((item) {
      return ProductModel.fromJson(item);
    }).toList();
    posts.addAll(newRecent);
    return posts;
  }

  Future<bool> deleteUserList(int? cityId, int listingId) async {
    final response = await Api.deleteUserList(cityId, listingId);
    if (response.success) {
      return true;
    } else {
      logError('Remove UserList Response Failed', response.message);
      return false;
    }
  }

  Future<int> getCurrentStatus() async {
    final prefs = await Preferences.openBox();
    int status = await prefs.getKeyValue(Preferences.listingStatusFilter, 0);
    return status;
  }

  Future<void> setCurrentStatus(int status) async {
    final prefs = await Preferences.openBox();
    prefs.setKeyValue(Preferences.listingStatusFilter, status);
  }
}
