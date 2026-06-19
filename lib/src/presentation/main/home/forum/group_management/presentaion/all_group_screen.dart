import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/presentation/main/home/forum/group_management/bloc/group_manage_bloc.dart';
import 'package:your_app_name/src/presentation/main/home/forum/group_management/bloc/group_manage_state.dart';
import 'package:your_app_name/src/presentation/main/home/forum/list_groups/list_groups_screen.dart';

import '../../../../../../utils/translate.dart';

class AllGroupScreen extends StatefulWidget {
  const AllGroupScreen({super.key});

  @override
  State<AllGroupScreen> createState() => _AllGroupScreenState();
}

class _AllGroupScreenState extends State<AllGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate("my_groups"),
        ),
      ),
      body: BlocBuilder<GroupManageCubit, GroupManageState>(
        builder: (context, state) => state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (list) => ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              var group = list[index];
              return ListTile(
                title: Text(group.forumName ?? ""),
                subtitle: Text(group.description ?? ""),
                trailing: DropdownButton<String>(
                  value: group.status,
                  items: <String>['active', 'inactive']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                          value == "active" ? "Active" : "Inactive"),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<GroupManageCubit>().updateGroupStatus(group.id, newValue);
                      setState(() {
                        group.status=newValue;
                      });
                    }
                  },
                ),
                onTap: () {
                  // Handle group tap, e.g., navigate to group details
                },
              );
            },
          ),
          error: (e) => Center(
            child: ErrorWidget(
                '${Translate.of(context).translate("failed_to_load")} $e'),
          ),
        ),
      ),
    );
  }
}
