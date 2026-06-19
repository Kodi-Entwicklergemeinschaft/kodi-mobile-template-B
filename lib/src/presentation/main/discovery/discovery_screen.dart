import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_citizen_service.dart';
import 'package:your_app_name/src/data/model/model_multifilter.dart';
import 'package:your_app_name/src/data/remote/api/matomo_api.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/home/list_product/cubit/list_cubit.dart';
import 'package:your_app_name/src/presentation/widget/app_filter_button.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cubit/cubit.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  int? selectedLocationId;
  ProductFilter? selectedFilter;

  @override
  void initState() {
    super.initState();
    loadLocationList();
  }

  Future<void> loadLocationList() async {
    await context.read<DiscoveryCubit>().onLoad(1);
  }

  Future<void> loadSelectedLocation() async {
    final cityId = await context.read<DiscoveryCubit>().getCitySelected();
    setState(() {
      selectedLocationId = cityId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('cust_services')),
        actions: [
          BlocConsumer<DiscoveryCubit, DiscoveryState>(
            listener: (context, state) {},
            builder: (context, state) => state.maybeWhen(
                loaded: (list) => AppFilterButton(
                      multiFilter: MultiFilter(
                        hasLocationFilter: true,
                        currentLocation:
                            context.read<DiscoveryCubit>().currentCity ?? 0,
                        cities: context.read<DiscoveryCubit>().location,
                      ),
                      filterCallBack: (filter) async {
                        if (filter.currentLocation != null) {
                          context
                              .read<DiscoveryCubit>()
                              .onLocationFilter(filter.currentLocation!, true);
                        }
                      },
                    ),
                orElse: () => Container()),
          )
        ],
      ),
      body: BlocConsumer<DiscoveryCubit, DiscoveryState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (msg) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg))),
            orElse: () {},
          );
        },
        builder: (context, state) => state.when(
          loading: () {
            return const DiscoveryLoading();
          },
          loaded: (list) => DiscoveryLoaded(
            services: list,
          ),
          updated: (list) {
            return Container();
          },
          error: (e) => ErrorWidget('Failed to load listings.'),
          initial: () {
            return Container();
          },
        ),
      ),
    );
  }
}

class DiscoveryLoading extends StatelessWidget {
  const DiscoveryLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class DiscoveryLoaded extends StatefulWidget {
  final List<CitizenServiceModel> services;

  const DiscoveryLoaded({
    super.key,
    required this.services,
  });

  @override
  State<DiscoveryLoaded> createState() => _DiscoveryLoadedState();
}

class _DiscoveryLoadedState extends State<DiscoveryLoaded> {
  bool isLoading = false;
  final _scrollController = ScrollController();
  List<CitizenServiceModel> services = [];

  @override
  void initState() {
    super.initState();
    services = widget.services;
  }

  void scrollUp() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), //duration of scroll
        curve: Curves.fastOutSlowIn //scroll type
        );
  }

  @override
  Widget build(BuildContext context) {
    if (AppBloc.discoveryCubit.getDoesScroll()) {
      AppBloc.discoveryCubit.setDoesScroll(false);
      scrollUp();
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0), // Adjust padding as needed
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              mainAxisExtent: 300.0),
          itemCount: services.length,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int index) {
            //print(services[index].imageLink + ' ' + services[index].categoryId.toString());
            return InkWell(
              onTap: () {
                navigateToLink(services[index]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  services[index].imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> navigateToLink(CitizenServiceModel service) async {
    int cityId = await context.read<DiscoveryCubit>().getCityId();
    if (service.categoryId != null) {
      MatomoApi.trackMatomoEvent(context,
          cityId: cityId, categoryId: service.categoryId!, isCategory: true);
    }
    if (service.imageLink == "1") {
      await launchUrl(Uri.parse('https://your-participation-url.com'),
          mode: LaunchMode.inAppWebView);
    } else if (service.imageLink == "2") {
      await launchUrl(
          Uri.parse(await AppBloc.discoveryCubit.getCityLink() ?? ""),
          mode: LaunchMode.inAppWebView);
    } else if (service.imageLink == "10") {
      final cityId = await context.read<DiscoveryCubit>().getCitySelected();
      if (cityId != 0) {
        if (!mounted) return;
        Navigator.pushNamed(context, Routes.listGroups,
            arguments: {'id': service.arguments, 'title': 'forums'});
      } else {
        if (!mounted) return;
        _showCitySelectionPopup(context);
      }
    } else if (service.imageLink == "14") {
      await Navigator.pushNamed(context, Routes.discoveryDetail, arguments: {
        'id': 14,
      });
    } else if (service.imageLink == "15") {
      await Navigator.pushNamed(context, Routes.discoveryDetail, arguments: {
        'id': 15,
      });
    } else if (service.imageLink == "17") {
      await launchUrl(Uri.parse('https://your-wifi-portal-url.com'),
          mode: LaunchMode.inAppWebView);
    } else {
      AppBloc.discoveryCubit
          .setServiceValue(Preferences.type, service.type, null);
      if (service.categoryId != null) {
        AppBloc.discoveryCubit
            .setServiceValue(Preferences.categoryId, null, service.categoryId);
      }
      Navigator.pushNamed(context, Routes.listProduct, arguments: {
        'id': service.arguments,
        'title': '',
        'type': 'categoryService',
        'cityId': cityId
      });
    }
  }

  void _showCitySelectionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stadt Auswählen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(Translate.of(context).translate('please_select_city')),
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
}
