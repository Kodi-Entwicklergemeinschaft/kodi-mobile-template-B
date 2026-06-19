import 'package:flutter/material.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CitySelection extends StatefulWidget {
  final List<dynamic> cityList;
  final List<String> selectedCities;
  final String? errorText;
  final Null Function(List<String> selectedCities, List<int> selectedCityIds) onChangeSelection;
  const CitySelection(this.cityList, this.selectedCities, this.errorText,
      this.onChangeSelection,
      {super.key});

  @override
  _CitySelectionState createState() => _CitySelectionState();
}

class _CitySelectionState extends State<CitySelection> {
  final controller = MultiSelectController<String>();
  List<DropdownItem<String>> cityListDropDownItems = [];

  @override
  void initState() {
    cityListDropDownItems = widget.cityList.map((city) {
      final String cityName = city['name'];
      final selected = widget.selectedCities.contains(cityName);
      return DropdownItem(label: cityName, value: cityName, selected: selected);
    }).toList();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final selectedBackgroundColor = isDarkMode ? const Color.fromARGB(255, 57, 57, 57) : const Color.fromARGB(255, 231, 231, 231);
    return Stack(
      children: [
        MultiDropdown<String>(
          controller: controller,
          items: cityListDropDownItems,
          chipDecoration: ChipDecoration(backgroundColor: selectedBackgroundColor),
          fieldDecoration: FieldDecoration(
            hintText: Translate.of(context).translate('choose_city'),
            hintStyle: TextStyle(color: textColor),
            showClearIcon: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(
                color: Colors.black87,
              ),
            ),
          ),
          dropdownDecoration: const DropdownDecoration(
            marginTop: 2,
            maxHeight: 500,
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            textColor: textColor,
            backgroundColor: Theme.of(context).colorScheme.background,
            selectedBackgroundColor: selectedBackgroundColor
          ),
          onSelectionChange: (selectedItems) {
            final selectedCityIds = widget.cityList
                .where((city) => selectedItems.contains(city['name']))
                .map((city) => city['id'] as int)
                .toList();
            widget.onChangeSelection.call(selectedItems, selectedCityIds);
          },
        ),
        if (widget.errorText != null)
          Positioned(left: 12,bottom: 0,
            child: Text(textAlign: TextAlign.start,
              Translate.of(context).translate(widget.errorText!),
              style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
