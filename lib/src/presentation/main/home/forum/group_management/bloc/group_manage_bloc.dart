import 'package:bloc/bloc.dart';

import '../../../../../../data/repository/forum_repository.dart';
import 'group_manage_state.dart';

class GroupManageCubit extends Cubit<GroupManageState> {
  final ForumRepository repo;

  GroupManageCubit(this.repo) : super(const GroupManageLoading()) {
    onLoad();
  }

  Future<void> onLoad() async {
    try {
      final result = await repo.loadAllForumsListForAdmin();
      if (result != null) {
        final groupList = result;
        emit(GroupManageLoaded(groupList));
      } else {
        emit(const GroupManageLoaded([]));
      }
    } catch (e) {
      emit(GroupManageError(e.toString()));
    }
  }

  void updateGroupStatus(int? id, String newValue) {
    final currentState = state as GroupManageLoaded;
    int statusIndex=newValue=="active"?1:2;
    try {
      final result = repo.changeGroupStatus(id, statusIndex);
      if (result != null) {
      } else {

      }
    }
    catch (e) {
      emit(GroupManageError(e.toString()));
    }
  }
}