import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../data/model/model_forum_group.dart';

part 'group_manage_state.freezed.dart';

@freezed
abstract class GroupManageState with _$GroupManageState {
  const factory GroupManageState.loading() = GroupManageLoading;
  const factory GroupManageState.loaded(
      List<ForumGroupModel> list,
      ) = GroupManageLoaded;
  const factory GroupManageState.error(String error) = GroupManageError;
}

