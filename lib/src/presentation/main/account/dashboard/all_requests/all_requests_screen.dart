// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:your_app_name/src/data/model/model.dart';
import 'package:your_app_name/src/data/model/model_multifilter.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/account/dashboard/all_requests/cubit/all_requests_cubit.dart';
import 'package:your_app_name/src/presentation/main/account/dashboard/all_requests/cubit/all_requests_state.dart';
import 'package:your_app_name/src/presentation/main/add_listing/cubit/add_listing_cubit.dart';
import 'package:your_app_name/src/presentation/main/add_listing/cubit/add_listing_state.dart';
import 'package:your_app_name/src/presentation/widget/app_filter_button.dart';
import 'package:your_app_name/src/presentation/widget/app_placeholder.dart';
import 'package:your_app_name/src/utils/common_enums.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';

// ignore: depend_on_referenced_packages
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/chat_now/chat_now_option_widget.dart';

// ignore: must_be_immutable
class AllRequestsScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onStatusChanged;

  const AllRequestsScreen({required this.user, this.onStatusChanged, super.key});

  @override
  Widget build(BuildContext context) {
    if (user.roleId == 1) {
      return BlocBuilder<AllRequestsCubit, AllRequestsState>(
          builder: (context, state) => state.maybeWhen(
              loading: () => const AllRequestsLoading(),              loaded: (posts, isRefreshLoader,selectedStatus) => AllRequestsLoaded(
                  user: user, posts: posts, isRefreshLoader: isRefreshLoader,selectedStatus: selectedStatus, onStatusChanged: onStatusChanged,),
              orElse: () => ErrorWidget("Failed to load listings.")));
    }
    return const AllRequestsBlocked();
  }
}

class AllRequestsLoading extends StatelessWidget {
  const AllRequestsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            Translate.of(context).translate('all_requests'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator.adaptive()));
  }
}

class AllRequestsLoaded extends StatefulWidget {
  final List<ProductModel>? posts;
  final UserModel user;
  final bool isRefreshLoader;
  final PostStatusType selectedStatus;
  final VoidCallback? onStatusChanged;

  const AllRequestsLoaded(
      {required this.user,
      required this.isRefreshLoader,
      this.posts,
        required this.selectedStatus,
        this.onStatusChanged,
      super.key});

  @override
  State<AllRequestsLoaded> createState() => _AllRequestsLoadedState();
}

class _AllRequestsLoadedState extends State<AllRequestsLoaded> {
  final _scrollController = ScrollController(initialScrollOffset: 0.0);
  double previousScrollPosition = 0;
  bool isLoadingMore = false;
  int pageNo = 1;
  List<ProductModel>? posts;
  bool isSwiped = false;
  String selectedListingStatusValue = "pending";


  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    posts = widget.posts;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    posts = widget.posts;
    String uniqueKey = UniqueKey().toString();
    final memoryCacheManager = DefaultCacheManager();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('all_requests'),
        ),
        actions: [
          AppFilterButton(
              multiFilter: MultiFilter(
                  hasListingStatusFilter: true,
                  currentListingStatus: widget.selectedStatus.value,
              ),
              filterCallBack: (filter) async {
                final cubit = context.read<AllRequestsCubit>();
                if (filter.currentListingStatus == 1) {
                  cubit.updateSelectedStatus(PostStatusType.approved);
                } else if (filter.currentListingStatus == 2) {
                  cubit.updateSelectedStatus(PostStatusType.pending);
                } else if (filter.currentListingStatus == 3) {
                  cubit.updateSelectedStatus(PostStatusType.feedback);
                }
              }),
        ],
      ),
      body: Stack(children: [
        (posts?.isNotEmpty ?? false)
            ? Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 0),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  controller: _scrollController,
                  slivers: <Widget>[
                    CupertinoSliverRefreshControl(
                      onRefresh: _onRefresh,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index < posts!.length) {
                            final item = posts![index];
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (aContext) {
                                      Navigator.pushNamed(
                                          context, Routes.submit, arguments: {
                                        'item': item,
                                        'isNewList': false,
                                        'isAdmin': true
                                      }).then((value) async {
                                        await _onRefresh();
                                      });
                                    },
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label:
                                        Translate.of(context).translate('edit'),
                                  ),                                  SlidableAction(
                                    onPressed: (aContext) async {
                                      bool response =
                                          await showDeleteConfirmation(
                                              context, item);
                                      if (response) {
                                        // Call the callback to refresh dashboard
                                        widget.onStatusChanged?.call();
                                        await AppBloc.homeCubit
                                            .onLoad(false)
                                            .then((value) => _onRefresh());
                                      }
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: Translate.of(context)
                                        .translate('delete'),
                                  ),
                                ],
                              ),
                              key:
                                  Key(item.id.toString() + isSwiped.toString()),
                              child: InkWell(
                                onTap: () {
                                  _onProductDetail(item);
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          item.pdf == ''
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl: item.sourceId ==
                                                                2 ||
                                                            (item.sourceId == 3 || item.sourceId == 4)
                                                        ? item.image
                                                        : "${Application.picturesURL}${item.image}",
                                                    cacheManager:
                                                        memoryCacheManager,
                                                    placeholder:
                                                        (context, url) {
                                                      return AppPlaceholder(
                                                        child: Container(
                                                          width: 120,
                                                          height: 140,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
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
                                                    errorWidget:
                                                        (context, url, error) {
                                                      return AppPlaceholder(
                                                        child: Container(
                                                          width: 120,
                                                          height: 140,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(8),
                                                              bottomLeft: Radius
                                                                  .circular(8),
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                              Icons.error),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(11),
                                                  child: SizedBox(
                                                      width: 120,
                                                      height: 140,
                                                      child: const PDF()
                                                          .cachedFromUrl(
                                                        "${Application.picturesURL}${item.pdf}?cacheKey=$uniqueKey",
                                                        placeholder:
                                                            (progress) => Center(
                                                                child: Text(
                                                                    '$progress %')),
                                                        errorWidget: (error) =>
                                                            Center(
                                                                child: Text(error
                                                                    .toString())),
                                                      )),
                                                ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                const SizedBox(
                                                  height: 24,
                                                ),
                                                Text(
                                                  item.category ?? '',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item.title,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item.categoryId == 3
                                                      ? (item.endDate != ""
                                                          ? "${item.startDate} ${Translate.of(context).translate('to')} ${item.endDate}"
                                                          : item.startDate)
                                                      : item.createDate,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                          onPressed: item.statusId == 1
                                                              ? null
                                                              : () async {
                                                                  _openListingStatusActionPopUp(
                                                                      item);
                                                                },
                                                          child: Text(
                                                            Translate.of(
                                                                    context)
                                                                .translate(
                                                                    getStatusTanslation(
                                                                        item.statusId ??
                                                                            0,
                                                                        null)),
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
                                                        ),
                                                      ),
                                                      IconButton(
                                                            onPressed: () {
                                                              _openListingActionPopUp(
                                                                  item);
                                                            },
                                                            icon: const Icon(
                                                                Icons.more_vert)),
                                                    ]),
                                                const SizedBox(height: 8),
                                                const SizedBox(height: 4),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return (isLoadingMore)
                                ? const Positioned(
                                    bottom: 20,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  )
                                : Container();
                          }
                        },
                        childCount: posts!.length + 1,
                      ),
                    ),
                  ],
                ),
              )
            : Center(
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
              ),
      ]),
    ));
  }

  void _openListingActionPopUp(ProductModel item) {
    selectedListingStatusValue = Translate.of(context)
        .translate(getStatusTanslation(item.statusId!, null));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<AddListingCubit, AddListingState>(
            builder: (context, state) => state.maybeWhen(loading: () {
              return const CircularProgressIndicator();
            }, loaded: () {
              return SimpleDialog(
                  title: Center(
                    child: Text(Translate.of(context).translate('options'),
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color ??
                              Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  children: [
                      ChatNowOptionWidget(item: item),
                  ]);
            }, orElse: () {
              return AlertDialog(
                title: Text(Translate.of(context).translate("error")),
                content: Text(Translate.of(context)
                    .translate("cannot_connect_to_server")),
              );
            }));
      },
    );
  }

  void _openListingStatusActionPopUp(ProductModel item) {
    selectedListingStatusValue = Translate.of(context)
        .translate(getStatusTanslation(item.statusId!, null));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<AddListingCubit, AddListingState>(
            builder: (context, state) => state.maybeWhen(loading: () {
                  return const CircularProgressIndicator();
                }, loaded: () {
                  return SimpleDialog(
                      title: Center(
                        child: Text(Translate.of(context).translate('status'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      children: [
                        SimpleDialogOption(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: false,
                              hint: Text(Translate.of(context)
                                  .translate('change_status')),
                              value: selectedListingStatusValue,
                              onChanged: (chosen) =>
                                  _handleStatusChange(chosen, item),
                              items: _getAvailableStatusOptions(item.statusId ?? 0)
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ]);
                }, orElse: () {
                  return AlertDialog(
                    title: Text(Translate.of(context).translate("error")),
                    content: Text(Translate.of(context)
                        .translate("cannot_connect_to_server")),
                  );
                }));
      },
    );
  }
  Future<void> _handleStatusChange(String? chosen, ProductModel item) async {
    Navigator.of(context).pop();

    int choice = int.parse(getStatusTanslation(null, chosen));
    bool success =
        await context.read<AddListingCubit>().changeStatus(item, choice);

    if (success) {
      // Call the callback to refresh dashboard
      widget.onStatusChanged?.call();
      
      if (choice == 3) {
        Navigator.pushNamed(context, Routes.chat, arguments: {
          'listingId': item.id,
          'isAdmin': true,
        });
      }
    }

    selectedListingStatusValue =
        Translate.of(context).translate(chosen ?? "pending");
    _onRefresh();
  }

  List<String> _getAvailableStatusOptions(int currentStatus) {
    List<String> options = [];
    switch (currentStatus) {
      case 2: // Pending
        options.add(Translate.of(context).translate('pending'));
        options.add(Translate.of(context).translate('feedback'));
        options.add(Translate.of(context).translate('approved'));
        break;
      case 3: // Feedback
        options.add(Translate.of(context).translate('feedback'));
        options.add(Translate.of(context).translate('approved'));
        break;
      case 1: // Approved
        options.add(Translate.of(context).translate('approved'));
        break;
      default:
        options.add(Translate.of(context).translate('pending'));
        options.add(Translate.of(context).translate('feedback'));
        options.add(Translate.of(context).translate('approved'));
    }
    return options;
  }

  Future _scrollListener() async {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        setState(() {
          isLoadingMore = true;
          previousScrollPosition = _scrollController.position.pixels;
        });
        posts = await context
            .read<AllRequestsCubit>()
            .newListings(pageNo: ++pageNo, status: widget.selectedStatus);
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  Future<bool> showDeleteConfirmation(
      BuildContext context, ProductModel item) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('delete_Confirmation')),
          content: Text(Translate.of(context)
              .translate('Are_you_sure_you_want_to_delete_this_item?')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              }, // Yes
              child: Text(Translate.of(context).translate('yes')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // No
              child: Text(Translate.of(context).translate('no')),
            ),
          ],
        );
      },
    );
    if (result == true) {
      if (!mounted) return false;
      final deleteResponse =
          await context.read<AllRequestsCubit>().deleteUserList(
                item.cityId,
                item.id,
              );
      return deleteResponse;
    }
    return false;
  }

  Future _onRefresh() async {
    // posts = widget.posts;
    await context
        .read<AllRequestsCubit>()
        .onLoad(isRefreshLoader: true, status: widget.selectedStatus);
  }

  void _onProductDetail(ProductModel item) {
    if (item.sourceId == 2 || item.showExternal == 1) {
      _makeAction(item.website);
    } else if (item.showExternal == 0) {
      Navigator.pushNamed(context, Routes.productDetail, arguments: item);
    } else {
      Navigator.pushNamed(context, Routes.productDetail, arguments: item);
    }
  }

  String getStatusTanslation(int? statusId, String? statusName) {
    if (statusId != null) {
      switch (statusId) {
        case 1:
          return "approved";
        case 2:
          return "pending";
        case 3:
          return "feedback";
      }
    } else if (statusName != null) {
      if (statusName == Translate.of(context).translate('approved')) {
        return "1";
      } else if (statusName == Translate.of(context).translate('pending')) {
        return "2";
      } else if (statusName == Translate.of(context).translate('feedback')) {
        return "3";
      }
    }
    return "";
  }

  void _makeAction(String link) async {
    if (!link.startsWith("https://") && !link.startsWith("http://")) {
      link = "https://$link";
    }
    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(link));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        link,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height:
                    MediaQuery.of(context).size.height - kToolbarHeight - 30,
                child: WebViewWidget(
                  controller: webViewController,
                  gestureRecognizers: gestureRecognizers,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AllRequestsBlocked extends StatelessWidget {
  const AllRequestsBlocked({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('all_listings'),
        ),
      ),
      body: Center(
          child: Text(
        Translate.of(context).translate('all_listings_not_admin'),
        overflow: TextOverflow.fade,
      )),
    );
  }
}
