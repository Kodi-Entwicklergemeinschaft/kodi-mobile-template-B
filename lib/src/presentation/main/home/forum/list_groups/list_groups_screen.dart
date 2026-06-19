import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/data/model/model_multifilter.dart';
import 'package:your_app_name/src/data/model/model_setting.dart';
import 'package:your_app_name/src/presentation/main/home/list_product/cubit/cubit.dart';
import 'package:your_app_name/src/presentation/widget/app_filter_button.dart';
import 'package:your_app_name/src/presentation/widget/app_forum_group_item.dart';
import 'package:your_app_name/src/presentation/widget/app_navbar.dart';
import 'package:your_app_name/src/presentation/widget/app_product_item.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';

import 'cubit/cubit.dart';

class ListGroupScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ListGroupScreen({super.key, required this.arguments});

  @override
  State<ListGroupScreen> createState() => _ListGroupScreenState();
}

class _ListGroupScreenState extends State<ListGroupScreen> {
  GroupFilter? selectedFilter;
  int pageNo = 1;

  @override
  void initState() {
    super.initState();
    _checkFirstTime().then((isFirstTime) {
      if (isFirstTime) {
        _showForumPopup(context);
      }
    });
    loadListingsList();
  }

  Future<bool> _checkFirstTime() async {
    final prefs = await Preferences.openBox();
    final hasOpenedForumsBefore =
        prefs.getBool('hasOpenedForumsBefore', defaultValue: false);

    if (!hasOpenedForumsBefore) {
      await prefs.setBool('hasOpenedForumsBefore', true);
      return true;
    }
    return false;
  }

  void _showForumPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('welcomeForumTitle')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Translate.of(context).translate('welcomeForum')),
              const SizedBox(height: 16),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadListingsList() async {
    await context.read<ListCubit>().onLoad(widget.arguments['id']);
  }

  void _onAddGroup() async {
    final userId = await context.read<ListGroupsCubit>().getLoggedInUserId();
    if (userId == 0) {
      if (!mounted) return;
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.addGroups,
      ).then((value) {
        // Only refresh if user successfully logged in
        if (value == true) {
          context.read<ListGroupsCubit>().onLoad();
        }
      });
      if (result == null) return;
    } else {
      if (!mounted) return;
      Navigator.pushNamed(context, Routes.addGroups,
          arguments: {'isNewGroup': true}).then((value) async {
        if (!mounted) return;
        // Only refresh if a new group was actually created
        if (value == true) {
          await context.read<ListGroupsCubit>().onLoad();
        }
      });
    }
  }

  void _updateSelectedFilter(GroupFilter? filter) {
    final loadedList = context.read<ListGroupsCubit>().getLoadedList();
    setState(() {
      selectedFilter = filter;
      context.read<ListGroupsCubit>().onGroupFilter(filter, loadedList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            Translate.of(context).translate(widget.arguments['title']),
          ),
          actions: <Widget>[
            AppFilterButton(
                multiFilter: MultiFilter(
                    hasForumGroupFilter: true,
                    currentForumGroupFilter: selectedFilter),
                filterCallBack: (filter) {
                  _updateSelectedFilter(filter.currentForumGroupFilter);
                }),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add') {
                  _onAddGroup();
                } else if (value == 'manage_group') {
                  Navigator.pushNamed(context, Routes.allGroupScreen);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'add',
                  child: Row(
                    children: [
                      const Icon(Icons.add),
                      const SizedBox(width: 8),
                      Text(Translate.of(context).translate('add')),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'manage_group',
                  child: Row(
                    children: [
                      const Icon(Icons.settings),
                      const SizedBox(width: 8),
                      Text(Translate.of(context).translate('manage_group')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocConsumer<ListGroupsCubit, ListGroupsState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (msg) => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(msg))),
              orElse: () {},
            );
          },
          builder: (context, state) => state.when(
            loading: () => const ListLoading(),
            loaded: (list, userId) => ListLoaded(
              list: list,
              selectedCityId: widget.arguments['id'],
              userId: userId,
              selectedFilter: selectedFilter,
            ),
            updated: (list, userId) {
              return ListLoaded(
                list: list,
                selectedCityId: widget.arguments['id'],
                userId: userId,
                selectedFilter: selectedFilter,
              );
            },
            error: (e) => ErrorWidget('Failed to load listings.'),
            initial: () {
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class ListLoading extends StatelessWidget {
  const ListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class ListLoaded extends StatefulWidget {
  final List<ForumGroupModel> list;
  final int selectedCityId;
  final int userId;
  GroupFilter? selectedFilter;

   ListLoaded(
      {super.key,
      required this.list,
      required this.selectedCityId,
      required this.userId,
      this.selectedFilter});

  @override
  State<ListLoaded> createState() => _ListLoadedState();
}

class _ListLoadedState extends State<ListLoaded> {
  final _scrollController = ScrollController(initialScrollOffset: 0.0);
  bool isLoadingMore = false;
  final PageType _pageType = PageType.list;
  final ProductViewType _listMode = Application.setting.listMode;
  double previousScrollPosition = 0;
  int pageNo = 1;
  List<ForumGroupModel>? list;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    if (widget.selectedFilter == GroupFilter.myGroups) {
      list = widget.list.where((product) => product.isJoined == true).toList();
    } else {
      list = widget.list;
    }
  }

  @override
  void didUpdateWidget(covariant ListLoaded oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.list != oldWidget.list) {
      setState(() {
        list = widget.list;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        setState(() {
          isLoadingMore = true;
          previousScrollPosition = _scrollController.position.pixels;
        });
        final allItems =
            await context.read<ListGroupsCubit>().newListings(++pageNo);

        if (widget.selectedFilter == GroupFilter.myGroups) {
          list = allItems.where((product) => product.isJoined == true).toList();
        } else {
          list = allItems;
        }

        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _buildContent(list!),
          )
        ],
      ),
    );
  }

  Widget _buildItem({
    ForumGroupModel? item,
    required ProductViewType type,
  }) {
    if (item != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ForumGroupItem(
          userId: widget.userId,
          onPressed: (value) async {
            if (value) {
              Navigator.pushNamed(context, Routes.groupChat,
                  arguments: {'group': item}).then((value) async {
                // Only refresh if changes were made (value indicates refresh needed)
                if (value == true) {
                  await context.read<ListGroupsCubit>().onLoad();
                }
              });
            } else {
              final popUpResult = await _showLoginPopup(context);
              if (popUpResult == true) {
                if (!mounted) return;
                await Navigator.pushNamed(
                  context,
                  Routes.signIn,
                  arguments: Routes.submit,
                ).then((value) async {
                  await context.read<ListGroupsCubit>().onLoad();
                });
              }
            }
          },
          item: item,
          fromGroupList: true,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppProductItem(
        type: _listMode,
        isRefreshLoader: true,
      ),
    );
  }

  Widget _buildContent(List<ForumGroupModel> list) {
    return BlocBuilder<ListCubit, ListState>(
      builder: (context, state) {
        if (_pageType == PageType.list) {
          Widget contentList = RefreshIndicator(
            onRefresh: () async {
              setState(() {
                pageNo = 1;
              });
              await context.read<ListGroupsCubit>().onLoad();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final item = list[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildItem(item: item, type: _listMode),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              ],
            ),
          );

          if (list.isEmpty) {
            contentList = Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.sentiment_satisfied),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      Translate.of(context).translate('list_is_empty'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Stack(
              children: [
                contentList,
                if (isLoadingMore)
                  const Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  Future<dynamic> _showLoginPopup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('login_required')),
          content: Text(Translate.of(context)
              .translate('Please_log_in_to_enter_any_group.')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text(Translate.of(context).translate('login')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Close the dialog
              },
              child: Text(Translate.of(context).translate('cancel')),
            ),
          ],
        );
      },
    );
  }
}
