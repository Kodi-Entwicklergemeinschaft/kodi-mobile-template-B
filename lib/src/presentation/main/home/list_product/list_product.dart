import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_category.dart';
import 'package:your_app_name/src/data/model/model_multifilter.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/data/model/model_setting.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/widget/app_filter_button.dart';
import 'package:your_app_name/src/presentation/widget/app_navbar.dart';
import 'package:your_app_name/src/presentation/widget/app_product_item.dart';
import 'package:your_app_name/src/presentation/widget/app_text_input.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'cubit/cubit.dart';
import 'event_tab_selector.dart';
import 'event_tab_type.dart';

class ListProductScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ListProductScreen({super.key, required this.arguments});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  late bool isCity;
  late bool isCategoryService;
  late bool shouldShowTabs;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  MultiFilter? selectedFilter;
  EventTabType selectedEventTab = EventTabType.single;

  Map<EventTabType, MultiFilter?> filterPerTab = {};

  @override
  void initState() {
    super.initState();

    final type = widget.arguments['type'];
    final id = widget.arguments['id'];

    isCity = type == 'location';
    isCategoryService = type == 'categoryService';

    shouldShowTabs =
        type == 'categoryService' &&
            id == 5;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadListingsList();
    });
  }

  Future<void> loadListingsList() async {
    if (isCity) {
      await context.read<ListCubit>().setCategoryFilter(0, null);
    }

    final eventType = shouldShowTabs ? selectedEventTab.apiValue : null;
    final startDate = selectedFilter?.startDate;
    final endDate = selectedFilter?.endDate;

    await context.read<ListCubit>().onLoad(
          selectedFilter?.currentLocation ?? _getPassedCityId(),
          eventType: eventType,
          startDate: startDate,
          endDate: endDate,
        );
  }

  MultiFilter whatCanFilter(bool isEvent) {
    MultiFilter? currentTabFilter = filterPerTab[selectedEventTab];

    if (isCity) {
      return MultiFilter(
        hasCategoryFilter: true,
        categories: _getCategories(),
        currentCategory: currentTabFilter?.currentCategory ?? 0,
        eventType: shouldShowTabs ? selectedEventTab.apiValue : null,
      );
    }

    if (isEvent) {
      return MultiFilter(
        hasProductEventFilter: true,
        currentProductEventFilter: currentTabFilter?.currentProductEventFilter,
        hasLocationFilter: true,
        currentLocation:
            currentTabFilter?.currentLocation ?? _getPassedCityId(),
        cities: AppBloc.discoveryCubit.location,
        multipleCityFilter: false,
        eventType: shouldShowTabs ? selectedEventTab.apiValue : null,
        startDate: currentTabFilter?.startDate,
        endDate: currentTabFilter?.endDate,
        hasDateRangeFilter: (currentTabFilter?.startDate != null &&
            currentTabFilter?.endDate != null),
      );
    } else {
      return MultiFilter(
        hasLocationFilter: true,
        currentLocation:
            currentTabFilter?.currentLocation ?? _getPassedCityId(),
        cities: AppBloc.discoveryCubit.location,
        eventType: shouldShowTabs ? selectedEventTab.apiValue : null,
      );
    }
  }

  void _updateSelectedFilter(MultiFilter? filter) async {
    if (context.read<ListCubit>().isSearching) {
      _searchController.clear();
      context.read<ListCubit>().isSearching = false;
      context.read<ListCubit>().searchTerm = "";
    }

    filterPerTab[selectedEventTab] = filter;
    selectedFilter = filter;

    if (filter == null) {
      await loadListingsList();
      return;
    }

    dynamic loadedList = context.read<ListCubit>().getLoadedList();

    final eventType = shouldShowTabs ? selectedEventTab.apiValue : null;
    final startDate = filter.startDate;
    final endDate = filter.endDate;

    if (filter.hasProductEventFilter ?? false) {
      loadedList = await context.read<ListCubit>().updateLoadedList(
            filter.currentLocation,
            eventType: eventType,
            startDate: startDate,
            endDate: endDate,
          );
      context.read<ListCubit>().onDateProductFilter(
          filter.currentProductEventFilter,
          loadedList,
          filter.hasLocationFilter,
          filter.currentLocation);
    } else if (filter.hasLocationFilter ?? false) {
      loadListingsList();
    }

    if (filter.hasDateRangeFilter ?? false) {
      loadListingsList();
    }

    if (filter.hasCategoryFilter ?? false) {
      context.read<ListCubit>().setCategoryFilter(filter.currentCategory ?? 0,
          selectedFilter?.currentLocation ?? _getPassedCityId());
    }
  }

  void _onEventTabChanged(EventTabType newTab) async {
    if (selectedEventTab != newTab) {
      setState(() {
        filterPerTab[selectedEventTab] = null;
        selectedEventTab = newTab;
        selectedFilter = filterPerTab[newTab];
      });

      final cubit = context.read<ListCubit>();
      if (cubit.isSearching) {
        cubit.clearSearchOnTabChange();
        _searchController.clear();
      }

      context.read<ListCubit>().emit(const ListState.loading());

      await Future.delayed(Duration.zero);

      await loadListingsList();
    }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: widget.arguments['title'] != ''
              ? Text(widget.arguments['title'])
              : FutureBuilder<String?>(
                  future: context.read<ListCubit>().getCategory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator.adaptive();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Container();
                    } else {
                      String category = snapshot.data!;
                      return Text(Translate.of(context).translate(category));
                    }
                  }),
          actions: [
            FutureBuilder<bool?>(
              future: context.read<ListCubit>().categoryPreferencesCall(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                } else if (snapshot.hasError) {
                  return Container();
                } else {
                  bool isEvent = snapshot.data ?? false;
                  return Row(
                    children: [
                      if (isEvent)
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _makeAction(
                                "https://your-event-create-url.com");
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      AppFilterButton(
                        voidCallback: () {
                          MultiFilter multiFilter = whatCanFilter(isEvent);
                          Navigator.pushNamed(context, Routes.filterScreen,
                              arguments: {
                                "multifilter": multiFilter
                              }).then((filter) =>
                              {_updateSelectedFilter(filter as MultiFilter?)});
                        },
                      ),
                      IconButton(
                          onPressed: () {
                            _searchListings();
                          },
                          icon: Icon(
                            Icons.search,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.white,
                          ))
                    ],
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (shouldShowTabs)
              EventTabSelector(
                selectedTab: selectedEventTab,
                onTabChanged: _onEventTabChanged,
              ),
            Expanded(
              child: BlocConsumer<ListCubit, ListState>(
                listener: (context, state) {
                  state.maybeWhen(
                    error: (msg) => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(msg))),
                    orElse: () {},
                  );
                },
                builder: (context, state) => state.when(
                  loading: () => const ListLoading(),
                  loaded: (list, listCity) => ListLoaded(
                    key: ValueKey(
                        '${selectedFilter?.currentLocation ?? _getPassedCityId()}_$selectedEventTab'),
                    list: list,
                    listCity: listCity,
                    selectedId:
                        selectedFilter?.currentLocation ?? _getPassedCityId(),
                    onScrollOnSearchResult: () {
                      _onSearchListScroll();
                    },
                    eventType:
                        shouldShowTabs ? selectedEventTab.apiValue : null,
                  ),
                  updated: (list, listCity) {
                    return ListLoaded(
                      key: ValueKey(
                          '${selectedFilter?.currentLocation ?? _getPassedCityId()}_$selectedEventTab'),
                      list: list,
                      listCity: listCity,
                      updated: true,
                      selectedId:
                          selectedFilter?.currentLocation ?? _getPassedCityId(),
                      onScrollOnSearchResult: () {
                        _onSearchListScroll();
                      },
                      eventType:
                          shouldShowTabs ? selectedEventTab.apiValue : null,
                    );
                  },
                  error: (e) => ErrorWidget('Failed to load listings.'),
                  initial: () {
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _searchListings() async {
    String? searchResult = await openSearchDialog();
    final eventType = shouldShowTabs ? selectedEventTab.apiValue : null;

    if (searchResult is String && searchResult.trim() != "") {
      context.read<ListCubit>().searchListing(searchResult.trim(), true,
          selectedFilter?.currentLocation ?? _getPassedCityId(),
          eventType: eventType);
    } else if ((searchResult == null || searchResult.trim() == "") &&
        context.read<ListCubit>().isSearching) {
      context.read<ListCubit>().cancelSearch(
          selectedFilter?.currentLocation ?? _getPassedCityId(),
          eventType: eventType,
          startDate: selectedFilter?.startDate,
          endDate: selectedFilter?.endDate);
    }
  }

  Future<String?> openSearchDialog() async {
    String? searchRequest = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            Navigator.pop(
                context,
                _searchController.text.trim().isEmpty
                    ? null
                    : _searchController.text);
          },
          child: SimpleDialog(
              title: Center(
                  child: Text(Translate.of(context).translate('search_title'))),
              contentPadding: const EdgeInsets.all(24.0),
              children: [
                AppTextInput(
                  hintText: Translate.of(context).translate('search_title'),
                  keyboardType: TextInputType.text,
                  controller: _searchController,
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        Navigator.pop(context, null);
                      },
                      child: Text(Translate.of(context).translate('cancel')),
                    ),
                    const SizedBox(width: 8.0),
                    TextButton(
                      onPressed: () {
                        String content = _searchController.text;
                        Navigator.pop(context, content);
                      },
                      child: Text(
                        Translate.of(context).translate('search_title'),
                      ),
                    ),
                  ],
                ),
              ]),
        );
      },
    );
    return searchRequest;
  }

  void _onSearchListScroll() {
    final eventType = shouldShowTabs ? selectedEventTab.apiValue : null;

    context.read<ListCubit>().searchListing(
        context.read<ListCubit>().searchTerm,
        false,
        selectedFilter?.currentLocation ?? _getPassedCityId(),
        eventType: eventType);
  }

  int? _getPassedCityId() {
    if (widget.arguments.containsKey("cityId")) {
      return widget.arguments['cityId'];
    } else if (widget.arguments.containsKey("id")) {
      return widget.arguments['id'];
    }
    return null;
  }

  _getCategories() {
    final categories = AppBloc.homeCubit.category;
    if (categories is List<CategoryModel>) {
      categories.removeWhere((category) => category.id == 17);
    }
    return categories;
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
  final List<ProductModel> list;
  final dynamic selectedId;
  final List listCity;
  final bool updated;
  final VoidCallback onScrollOnSearchResult;
  final String? eventType;

  const ListLoaded(
      {super.key,
      required this.list,
      required this.selectedId,
      required this.listCity,
      this.updated = false,
      required this.onScrollOnSearchResult,
      this.eventType});

  @override
  State<ListLoaded> createState() => _ListLoadedState();
}

class _ListLoadedState extends State<ListLoaded> {
  List<ProductModel> list = [];
  List listCity = [];
  final _scrollController = ScrollController(initialScrollOffset: 0.0);
  bool isLoading = false;
  bool isLoadingMore = false;
  final PageType _pageType = PageType.list;
  final ProductViewType _listMode = Application.setting.listMode;
  double previousScrollPosition = 0;
  int pageNo = 1;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    if (!widget.updated) loadListingsList();
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
        });
        if (context.read<ListCubit>().isSearching) {
          widget.onScrollOnSearchResult.call();
        } else {
          list = await context.read<ListCubit>().newListings(
              ++pageNo, widget.selectedId,
              eventType: widget.eventType);
        }
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildContent(),
        )
      ],
    );
  }

  Future<void> loadListingsList() async {
    setState(() {
      isLoading = true;
    });
    await context
        .read<ListCubit>()
        .onLoad(widget.selectedId, eventType: widget.eventType);
    setState(() {
      isLoading = false;
    });
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

  void _onProductDetail(ProductModel item) {
    if (item.sourceId == 2 || item.showExternal == 1) {
      _makeAction(item.website);
    } else if (item.showExternal == 0) {
      Navigator.pushNamed(context, Routes.productDetail, arguments: item);
    } else {
      Navigator.pushNamed(context, Routes.productDetail, arguments: item);
    }
  }

  Widget _buildItem({
    ProductModel? item,
    required ProductViewType type,
  }) {
    switch (type) {
      case ProductViewType.list:
        if (item != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppProductItem(
              isRefreshLoader: true,
              cityName: ListCubit.getCityNameFromId(
                  widget.listCity, item.cityId ?? 0),
              onPressed: () {
                _onProductDetail(item);
              },
              item: item,
              type: _listMode,
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppProductItem(
            isRefreshLoader: true,
            type: _listMode,
          ),
        );
      default:
        if (item != null) {
          return AppProductItem(
            isRefreshLoader: true,
            onPressed: () {
              _onProductDetail(item);
            },
            item: item,
            type: _listMode,
          );
        }
        return AppProductItem(
          isRefreshLoader: true,
          type: _listMode,
        );
    }
  }

  Widget _buildContent() {
    list = widget.list;
    return BlocBuilder<ListCubit, ListState>(
      builder: (context, state) {
        if (_pageType == PageType.list) {
          Widget contentList = CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final item = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 5),
                      child: _buildItem(item: item, type: _listMode),
                    );
                  },
                  childCount: list.length,
                ),
              ),
            ],
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
                    bottom: 5,
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
}
