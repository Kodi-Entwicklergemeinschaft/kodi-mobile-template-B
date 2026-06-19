import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_multifilter.dart';
import 'package:your_app_name/src/presentation/main/home/forum/list_groups/cubit/cubit.dart';
import 'package:your_app_name/src/presentation/main/home/list_product/cubit/list_cubit.dart';
import 'package:your_app_name/src/presentation/widget/app_picker_item.dart';
import 'package:your_app_name/src/utils/common_enums.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:intl/intl.dart';

class FilterScreen extends StatefulWidget {
  final MultiFilter multiFilter;

  const FilterScreen({super.key, required this.multiFilter});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int? currentCity;
  List<int> currentCities = [];
  int? currentCategory;
  int? currentListingStatus;
  ProductFilter? currentProductEventFilter;
  GroupFilter? currentForumGroupFilter;
  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    if (widget.multiFilter.multipleCityFilter) {
      currentCities = widget.multiFilter.currentLocation.cast<int>();
    } else {
      currentCity = widget.multiFilter.currentLocation;
    }
    currentCategory = widget.multiFilter.currentCategory;
    currentProductEventFilter = widget.multiFilter.currentProductEventFilter;
    currentListingStatus = widget.multiFilter.currentListingStatus;
    currentForumGroupFilter = widget.multiFilter.currentForumGroupFilter;
    startDate = widget.multiFilter.startDate;
    endDate = widget.multiFilter.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Filter"),
      ),
      body: SingleChildScrollView(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            Navigator.pop(
                context,
                MultiFilter(
                  currentLocation: (widget.multiFilter.multipleCityFilter)
                      ? currentCities
                      : currentCity,
                  currentProductEventFilter: currentProductEventFilter,
                  currentListingStatus: currentListingStatus,
                  currentForumGroupFilter: currentForumGroupFilter,
                  currentCategory: currentCategory,
                  hasForumGroupFilter: widget.multiFilter.hasForumGroupFilter,
                  hasProductEventFilter:
                      widget.multiFilter.hasProductEventFilter,
                  hasLocationFilter: widget.multiFilter.hasLocationFilter,
                  hasListingStatusFilter:
                      widget.multiFilter.hasListingStatusFilter,
                  hasCategoryFilter: widget.multiFilter.hasCategoryFilter,
                  eventType: widget.multiFilter.eventType,
                  startDate: startDate,
                  endDate: endDate,
                  hasDateRangeFilter: (startDate != null && endDate != null),
                ));
          },
          child: Column(
            children: [
              if (widget.multiFilter.hasLocationFilter == true)
                ..._buildLocationFilter(),
              if (widget.multiFilter.hasProductEventFilter == true)
                ..._buildProductEventFilter(),
              if (widget.multiFilter.hasProductEventFilter == true)
                ..._buildDateRangeFilter(),
              if (widget.multiFilter.hasListingStatusFilter == true)
                ..._buildListingStatusFilter(),
              if (widget.multiFilter.hasForumGroupFilter == true)
                ..._buildForumGroupFilter(),
              if (widget.multiFilter.hasCategoryFilter == true)
                ..._buildCategoryFilter(),
            ],
          ),
        ),
      ),
    ));
  }

  List<Widget> _buildLocationFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_city'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          (widget.multiFilter.multipleCityFilter)
              ? ChoiceChip(
                  label:
                      Text(Translate.of(context).translate('select_location')),
                  selected: currentCities.contains(0),
                  onSelected: (selected) {
                    setState(() {
                      currentCities = [];
                      currentCities.add(0);
                    });
                  },
                )
              : ChoiceChip(
                  label:
                      Text(Translate.of(context).translate('select_location')),
                  selected: 0 == currentCity,
                  onSelected: (selected) {
                    setState(() {
                      currentCity = 0;
                    });
                  },
                ),
          ...widget.multiFilter.cities!.map((city) {
            return (widget.multiFilter.multipleCityFilter)
                ? ChoiceChip(
                    label: Text(city.title),
                    selected: currentCities.contains(city.id),
                    onSelected: (selected) {
                      setState(() {
                        if (currentCities.contains(city.id)) {
                          currentCities.remove(city.id);
                        } else {
                          currentCities.add(city.id);
                          currentCities.remove(0);
                        }
                      });
                    },
                  )
                : ChoiceChip(
                    label: Text(city.title),
                    selected: city.id == currentCity,
                    onSelected: (selected) {
                      setState(() {
                        currentCity = city.id;
                      });
                    },
                  );
          }),
        ]),
      )
    ];
  }

  List<Widget> _buildListingStatusFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_listing_status'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all')),
            selected: currentListingStatus == 0,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = 0;
              });
            },
          ),
          ChoiceChip(
            label: Text(Translate.of(context).translate('approved')),
            selected: currentListingStatus == PostStatusType.approved.value,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = PostStatusType.approved.value;
              });
            },
          ),
          ChoiceChip(
            label: Text(Translate.of(context).translate('pending')),
            selected: currentListingStatus == PostStatusType.pending.value,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = PostStatusType.pending.value;
              });
            },
          ),
          ChoiceChip(
            label: Text(Translate.of(context).translate('feedback')),
            selected: currentListingStatus == PostStatusType.feedback.value,
            onSelected: (selected) {
              setState(() {
                currentListingStatus = PostStatusType.feedback.value;
              });
            },
          ),
        ]),
      )
    ];
  }

  List<Widget> _buildForumGroupFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_forum'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all')),
            selected: currentForumGroupFilter == null,
            onSelected: (selected) {
              setState(() {
                currentForumGroupFilter = null;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('all_groups')),
                Icon(
                  Icons.groups,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentForumGroupFilter == GroupFilter.allGroups,
            onSelected: (selected) {
              setState(() {
                currentForumGroupFilter = GroupFilter.allGroups;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('my_groups')),
                Icon(
                  Icons.person,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentForumGroupFilter == GroupFilter.myGroups,
            onSelected: (selected) {
              setState(() {
                currentForumGroupFilter = GroupFilter.myGroups;
              });
            },
          ),
        ]),
      )
    ];
  }

  List<Widget> _buildProductEventFilter() {
    bool isDateRangeActive = (startDate != null || endDate != null);

    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('choose_time_period'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all')),
            selected: currentProductEventFilter == null && !isDateRangeActive,
            onSelected: (selected) {
              setState(() {
                currentProductEventFilter = null;
                startDate = null;
                endDate = null;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('this_month')),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentProductEventFilter == ProductFilter.month &&
                !isDateRangeActive,
            onSelected: (selected) {
              setState(() {
                currentProductEventFilter = ProductFilter.month;
                startDate = null;
                endDate = null;
              });
            },
          ),
          ChoiceChip(
            label: Wrap(
              spacing: 4.0,
              children: [
                Text(Translate.of(context).translate('this_week')),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  size: 18,
                )
              ],
            ),
            selected: currentProductEventFilter == ProductFilter.week &&
                !isDateRangeActive,
            onSelected: (selected) {
              setState(() {
                currentProductEventFilter = ProductFilter.week;
                startDate = null;
                endDate = null;
              });
            },
          ),
        ]),
      )
    ];
  }

  List<Widget> _buildDateRangeFilter() {
    bool isDateRangeActive = (startDate != null || endDate != null);

    return [
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                Translate.of(context).translate('date_range'),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDateRangeActive
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            if (isDateRangeActive)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Date Range Active',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              Translate.of(context).translate('start_date'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            AppPickerItem(
              leading: Icon(
                Icons.calendar_today_outlined,
                color: startDate != null
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor,
              ),
              value: startDate,
              title: Translate.of(context).translate('choose_date'),
              onPressed: () => _onShowStartDatePicker(),
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('end_date'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            AppPickerItem(
              leading: Icon(
                Icons.calendar_today_outlined,
                color: endDate != null
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor,
              ),
              value: endDate,
              title: Translate.of(context).translate('choose_date'),
              onPressed: () => _onShowEndDatePicker(),
            ),
            if (startDate != null || endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: Text(Translate.of(context).translate('clear_date')),
                    onPressed: () {
                      setState(() {
                        startDate = null;
                        endDate = null;
                      });
                    },
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ];
  }

  void _onShowStartDatePicker() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        startDate != null ? DateFormat('yyyy-MM-dd').parse(startDate!) : now;
    final DateTime firstDate = DateTime(now.year - 1);
    final DateTime lastDate = DateTime(now.year + 2);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      setState(() {
        startDate = DateFormat('yyyy-MM-dd').format(picked);

        currentProductEventFilter = null;

        if (endDate != null) {
          final endDateTime = DateFormat('yyyy-MM-dd').parse(endDate!);
          if (endDateTime.isBefore(picked)) {
            endDate = null;
          }
        }
      });
    }
  }

  void _onShowEndDatePicker() async {
    final DateTime now = DateTime.now();

    final DateTime firstDate = startDate != null
        ? DateFormat('yyyy-MM-dd').parse(startDate!)
        : DateTime(now.year - 1);

    final DateTime initialDate = endDate != null
        ? DateFormat('yyyy-MM-dd').parse(endDate!)
        : (startDate != null ? firstDate : now);

    final DateTime lastDate = DateTime(now.year + 2);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && mounted) {
      setState(() {
        endDate = DateFormat('yyyy-MM-dd').format(picked);

        currentProductEventFilter = null;
      });
    }
  }

  List<Widget> _buildCategoryFilter() {
    return [
      const SizedBox(
        height: 8,
      ),
      Center(
          child: Text(
        Translate.of(context).translate('input_category'),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      )),
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8.0, children: [
          ChoiceChip(
            label: Text(Translate.of(context).translate('all_Categories')),
            selected: 0 == currentCategory,
            onSelected: (selected) {
              setState(() {
                currentCategory = 0;
              });
            },
          ),
          ...widget.multiFilter.categories!.map((category) {
            return ChoiceChip(
              label: Text(category.title),
              selected: category.id == currentCategory,
              onSelected: (selected) {
                setState(() {
                  currentCategory = category.id;
                });
              },
            );
          }),
        ]),
      )
    ];
  }
}
