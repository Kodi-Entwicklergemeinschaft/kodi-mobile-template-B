import 'package:flutter/material.dart';
import 'package:your_app_name/src/presentation/main/home/widget/city_dropdown.dart';
import 'package:your_app_name/src/presentation/main/home/widget/home_swiper.dart';

class AppBarHomeSliver extends StatelessWidget {
  final double expandedHeight;
  final String? banners;
  final ValueSetter<String>? setLocationCallback;
  final List<String>? cityTitlesList;
  final String? hintText;
  final String? selectedOption;
  final VoidCallback? onSearchPressed;

  const AppBarHomeSliver({
    super.key,
    required this.expandedHeight,
    required this.setLocationCallback,
    required this.cityTitlesList,
    this.banners,
    this.hintText,
    this.selectedOption,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      // backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: onSearchPressed,
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            HomeSwipe(
              images: banners,
              height: expandedHeight,
            ),
            Container(
              height: 32,
              color: Theme.of(context).colorScheme.surface,
            ),
            CitiesDropDown(
              hintText: hintText,
              cityTitlesList: cityTitlesList,
              setLocationCallback: setLocationCallback,
              selectedOption: selectedOption,
            ),
          ],
        ),
      ),
    );
  }
}
