import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_multifilter.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';

class AppFilterButton extends StatelessWidget {
  final MultiFilter? multiFilter;
  final Function(MultiFilter filter)? filterCallBack;
  final VoidCallback? voidCallback;

  const AppFilterButton(
      {super.key, this.multiFilter, this.filterCallBack, this.voidCallback});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (voidCallback == null)
          ? () async {
              Navigator.pushNamed(context, Routes.filterScreen, arguments: {
                "multifilter": multiFilter
              }).then((filter) => {
                    if (filter != null) {filterCallBack!(filter as MultiFilter)}
                  });
            }
          : voidCallback,
      style: TextButton.styleFrom(
        textStyle: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      icon: Icon(
        Icons.filter_list_rounded,
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
      ),
    );
  }
}
