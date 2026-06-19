import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/data/model/model_user.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/account/profile/cubit/profile_cubit.dart';
import 'package:your_app_name/src/presentation/main/account/profile/cubit/profile_state.dart';
import 'package:your_app_name/src/presentation/widget/app_placeholder.dart';
import 'package:your_app_name/src/utils/common.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';

import '../widgets/chat_now/chat_now_option_widget.dart';

class MyListingsScreen extends StatelessWidget {
  final UserModel user;
  final bool isEditable;

  const MyListingsScreen(
      {required this.user, required this.isEditable, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (msg) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg))),
          orElse: () {},
        );
      },
      builder: (context, state) => state.maybeWhen(
        loading: () => const ProfileLoading(),
        loaded: (userListing) => ProfileLoaded(user, userListing, isEditable),
        orElse: () => ErrorWidget('Failed to load Accounts.'),
      ),
    );
  }
}

class ProfileLoading extends StatelessWidget {
  const ProfileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

class ProfileLoaded extends StatefulWidget {
  final UserModel user;
  final List<ProductModel> userListings;
  final bool isEditable;

  const ProfileLoaded(this.user, this.userListings, this.isEditable,
      {super.key});

  @override
  State<ProfileLoaded> createState() => _ProfileLoadedState();
}

class _ProfileLoadedState extends State<ProfileLoaded> {
  bool isLoading = false;
  bool isSwiped = false;
  bool isLoadingMore = false;
  int pageNo = 1;
  List<ProductModel> userListingsList = [];
  final _scrollController = ScrollController(initialScrollOffset: 0.0);

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    userListingsList.addAll(widget.userListings);
  }

  Future _onRefreshLoader() async {
    pageNo=1;
    userListingsList=
      await context.read<ProfileCubit>().loadUserListing(widget.user.id, 1);
  }

  @override
  Widget build(BuildContext context) {
    final memoryCacheManager = DefaultCacheManager();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('my_listings'),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Stack(children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  controller: _scrollController,
                  slivers: <Widget>[
                    CupertinoSliverRefreshControl(
                      onRefresh: _onRefreshLoader,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: userListingsList.length,
                        (BuildContext context, int index) {
                          final item = userListingsList[index];
                          return userListingsList == []
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Slidable(
                                      endActionPane: !widget.isEditable
                                          ? null
                                          : ActionPane(
                                              motion: const ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (aContext) {
                                                    updateListings(index);
                                                  },
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.edit,
                                                  label: Translate.of(context)
                                                      .translate('edit'),
                                                ),
                                                SlidableAction(
                                                  onPressed: (aContext) async {
                                                    showDeleteConfirmation(
                                                        context, index);
                                                  },
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                  label: Translate.of(context)
                                                      .translate('delete'),
                                                ),
                                              ],
                                            ),
                                      key: Key(item.id.toString() +
                                          isSwiped.toString()),
                                      child: InkWell(
                                        onTap: () {
                                          _onProductDetail(item);
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Stack(
                                              children: [
                                                Row(
                                                  children: <Widget>[
                                                    CachedNetworkImage(
                                                      imageUrl: item.sourceId ==
                                                              2
                                                          ? item.image
                                                          : "${Application.picturesURL}${item.image}",
                                                      cacheManager:
                                                          memoryCacheManager,
                                                      placeholder:
                                                          (context, url) {
                                                        return AppPlaceholder(
                                                          child: Container(
                                                            height: 140,
                                                            width: 120,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      imageBuilder: (context,
                                                          imageProvider) {
                                                        return Container(
                                                          width: 120,
                                                          height: 140,
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorWidget: (context,
                                                          url, error) {
                                                        return AppPlaceholder(
                                                          child: Container(
                                                            width: 120,
                                                            height: 140,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        8),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        8),
                                                              ),
                                                            ),
                                                            child: const Icon(
                                                                Icons.error),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                userListingsList[
                                                                            index]
                                                                        .category ??
                                                                    '',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              ),
                                                              // if (userListingsList[
                                                              //             index]
                                                              //         .viewCount !=
                                                              //     null)
                                                              //   Text(
                                                              //     '${Translate.of(context).translate('views')}: ${userListingsList[index].viewCount}',
                                                              //     style: Theme.of(
                                                              //             context)
                                                              //         .textTheme
                                                              //         .bodySmall!
                                                              //         .copyWith(
                                                              //           fontWeight:
                                                              //               FontWeight.w100,
                                                              //         ),
                                                              //   ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            userListingsList[
                                                                    index]
                                                                .title,
                                                            maxLines: 2,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall!
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            userListingsList[
                                                                            index]
                                                                        .categoryId ==
                                                                    3
                                                                ? (userListingsList[index]
                                                                            .endDate !=
                                                                        ""
                                                                    ? "${userListingsList[index].startDate} ${Translate.of(context).translate('to')} ${userListingsList[index].endDate}"
                                                                    : userListingsList[
                                                                            index]
                                                                        .startDate)
                                                                : item
                                                                    .createDate,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Utils
                                                                      .getStatusColor(
                                                                          item.statusId),
                                                                ),
                                                                padding:const EdgeInsets.all(10),
                                                                child: Text(
                                                                    Translate.of(
                                                                            context)
                                                                        .translate(Utils.getStatus(item
                                                                            .statusId)),
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall!.copyWith(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                    ),),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                child:
                                                                    IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .more_vert),
                                                                  onPressed:
                                                                      () {
                                                                    _showOptionsDialog(
                                                                      context,
                                                                      index,
                                                                      item,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                        },
                      ),
                    ),
                  ],
                ),
                if (isLoadingMore)
                  const Positioned(
                    bottom: 5,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        setState(() {
          isLoadingMore = true;
        });
        userListingsList.addAll(await context
            .read<ProfileCubit>()
            .newListings(widget.user.id, ++pageNo));
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  void _onProductDetail(ProductModel item) {
    Navigator.pushNamed(context, Routes.productDetail, arguments: item);
  }

  Future<void> showDeleteConfirmation(
      BuildContext buildContext, int index) async {
    final result = await showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('delete_Confirmation')),
          content: Text(Translate.of(context)
              .translate('Are_you_sure_you_want_to_delete_this_item?')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text(Translate.of(context).translate('yes')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(Translate.of(context).translate('no')),
            ),
          ],
        );
      },
    );
    if (result == true) {
      if (!mounted) return;
      final deleteResponse = await context.read<ProfileCubit>().deleteUserList(
            userListingsList[index].cityId.toString(),
            userListingsList[index].id,
          );
      setState(() {
        if (deleteResponse) {
          userListingsList.removeAt(index);
        }
      });
      await AppBloc.homeCubit.onLoad(false);
    }
  }

  Future<void> _showOptionsDialog(
      BuildContext context, int index, ProductModel item) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Center(
            child: Text(Translate.of(context).translate('options'),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  fontWeight: FontWeight.bold,
                )),
          ),
          children: [
            ChatNowOptionWidget(item: item),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                updateListings(index);
              },
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: Text(Translate.of(context).translate('edit')),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                showDeleteConfirmation(context, index);
              },
              child: ListTile(
                leading: const Icon(Icons.delete),
                title: Text(Translate.of(context).translate('delete')),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateListings(int index) async {
    Navigator.pushNamed(context, Routes.submit,
            arguments: {'item': userListingsList[index], 'isNewList': false})
        .then((value) async {
      final response =
          await context.read<ProfileCubit>().loadUserListing(widget.user.id, 1);
      setState(() {
        userListingsList = response;
      });
    });
  }
}
