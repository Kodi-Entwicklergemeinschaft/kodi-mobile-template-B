import 'package:flutter/material.dart';
import 'package:your_app_name/src/data/model/model_recurring_rule.dart';
import 'package:your_app_name/src/utils/datetime.dart';
import 'package:intl/intl.dart';

import '../../../../utils/common.dart';
import '../../../../utils/translate.dart';
import '../../../widget/app_picker_item.dart';
import '../../../widget/app_text_input.dart';
import 'package:your_app_name/src/utils/validate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/add_listing_cubit.dart';

class AddRecurringEventWidget extends StatefulWidget {
  final int recurringRuleKey;
  final Function(bool) addRuleCallback;
  final Function(bool) emptyRepeatUntilTimeCallback;
  final RecurrenceRuleModel? recurrenceRule;

  const AddRecurringEventWidget(
      {super.key,
      required this.recurringRuleKey,
      required this.addRuleCallback,
      required this.emptyRepeatUntilTimeCallback,
      this.recurrenceRule});

  @override
  State<AddRecurringEventWidget> createState() =>
      _AddRecurringEventWidgetState();
}

class _AddRecurringEventWidgetState extends State<AddRecurringEventWidget> {
  String? selectedRecurringType;
  String? _errorInterval;
  final _textIntervalController = TextEditingController(text: "1");
  final _focusInterval = FocusNode();
  String? _startDate;
  String? _endDate;
  String? _repeatUntilDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimeOfDay? _repeatUntilTime;
  List<String> _exceptionDates = [];
  List<String> _selectedWeekDays = [];
  final List<String> _weekDays = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
  ];
  String? _weekDayError;
  String? _selectedMonthlyWeekDay; // only one
  String? _selectedOrdinal;
  String? _ordinalError;

  final List<String> _ordinals = [
    "first",
    "second",
    "third",
    "fourth",
    "last",
  ];

  @override
  void initState() {
    if (widget.recurrenceRule != null) {
      selectedRecurringType = widget.recurrenceRule!.freq;

      String? interval = widget.recurrenceRule!.interval.toString();
      _textIntervalController.text = interval;

      if (selectedRecurringType != null && selectedRecurringType == "Weekly") {
        _selectedWeekDays = widget.recurrenceRule!.weekdays ?? [];
      } else if (selectedRecurringType != null &&
          selectedRecurringType == "Monthly") {
        if (widget.recurrenceRule!.weekdays != null &&
            widget.recurrenceRule!.weekdays!.isNotEmpty) {
          String weekDay = widget.recurrenceRule!.weekdays!.first;
          _selectedMonthlyWeekDay = weekDay;
        }
      }

      if (widget.recurrenceRule!.start != null) {
        ParsedDateTime parsedStartDate =
            parseDateTimeString(widget.recurrenceRule!.start!);
        _startDate = parsedStartDate.date;
        _startTime = parsedStartDate.time;
      }

      if (widget.recurrenceRule!.end != null) {
        ParsedDateTime parsedStartDate =
            parseDateTimeString(widget.recurrenceRule!.end!);
        _endDate = parsedStartDate.date;
        _endTime = parsedStartDate.time;
      }

      if (widget.recurrenceRule!.repeatUntil != null) {
        ParsedDateTime parsedStartDate =
            parseDateTimeString(widget.recurrenceRule!.repeatUntil!);
        _repeatUntilDate = parsedStartDate.date;
        _repeatUntilTime = parsedStartDate.time;
      }

      if (widget.recurrenceRule!.dayOrdinal != null) {
        if (widget.recurrenceRule!.dayOrdinal != null) {
          _selectedOrdinal =
              _numberToOrdinal(widget.recurrenceRule!.dayOrdinal!);
        }
      }

      if (widget.recurrenceRule!.exceptions != null &&
          widget.recurrenceRule!.exceptions!.isNotEmpty) {
        List<ExceptionDate> exceptions = widget.recurrenceRule!.exceptions!;
        List<String> dates = exceptions.map((e) => e.date).toList();
        _exceptionDates = dates;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool canSelectStartDate = selectedRecurringType != null &&
        !(selectedRecurringType == "Weekly" && _selectedWeekDays.isEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.onSurface,
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: Translate.of(context).translate('recurring_type'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              children: const <TextSpan>[
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _customDropDown(
              items: ["Daily", "Weekly", "Monthly"],
              hint: Translate.of(context).translate('select_recurring_type'),
              onSelected: (value) {
                setState(() {
                  selectedRecurringType = value;
                  _selectedOrdinal = null;
                  _selectedMonthlyWeekDay = null;
                  _selectedWeekDays = [];
                  _startDate = null;
                  _startTime = null;
                  _endDate = null;
                  _endTime = null;
                  _repeatUntilDate = null;
                  _repeatUntilTime = null;
                  _exceptionDates.clear();
                  widget.addRuleCallback(false);
                });
                context.read<AddListingCubit>().updateRecurringRule(
                    key: widget.recurringRuleKey,
                    freq: selectedRecurringType,
                    isReset: true);
                widget.emptyRepeatUntilTimeCallback(false);
              },
              value: selectedRecurringType),
          if (selectedRecurringType != null)
            selectedRecurringType == "Daily"
                ? _buildDailyUi()
                : selectedRecurringType == "Weekly"
                    ? _buildWeeklyUi()
                    : selectedRecurringType == "Monthly"
                        ? _buildMonthlyUi()
                        : SizedBox.shrink(),
          _dateTimeCommonUi(canSelectStartDate)
        ],
      ),
    );
  }

  Widget _buildDailyUi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('interval'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          hintText: Translate.of(context).translate('input_interval'),
          errorText: _errorInterval,
          controller: _textIntervalController,
          focusNode: _focusInterval,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          onChanged: (text) {
            _errorInterval = UtilValidator.validate(
                _textIntervalController.text,
                type: ValidateType.number);
            context.read<AddListingCubit>().updateRecurringRule(
                key: widget.recurringRuleKey,
                interval: int.parse(_textIntervalController.text));
          },
          onSubmitted: (text) {
            Utils.fieldFocusChange(context, _focusInterval, _focusInterval);
            context.read<AddListingCubit>().updateRecurringRule(
                key: widget.recurringRuleKey,
                interval: int.parse(_textIntervalController.text));
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWeeklyUi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('interval'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          hintText: Translate.of(context).translate('input_interval'),
          errorText: _errorInterval,
          controller: _textIntervalController,
          focusNode: _focusInterval,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          onChanged: (text) {
            _errorInterval = UtilValidator.validate(
                _textIntervalController.text,
                type: ValidateType.number);
            context.read<AddListingCubit>().updateRecurringRule(
                key: widget.recurringRuleKey,
                interval: int.parse(_textIntervalController.text));
          },
          onSubmitted: (text) {
            context.read<AddListingCubit>().updateRecurringRule(
                key: widget.recurringRuleKey,
                interval: int.parse(_textIntervalController.text));
            Utils.fieldFocusChange(context, _focusInterval, _focusInterval);
          },
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate("week_days"),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppPickerItem(
          leading: Icon(
            Icons.date_range,
            color: Theme.of(context).hintColor,
          ),
          value: _selectedWeekDays.isEmpty
              ? null
              : "${_selectedWeekDays.length} ${Translate.of(context).translate("selected")}",
          title: Translate.of(context).translate("select_weekdays"),
          onPressed: () {
            _onSelectWeekDays();
          },
        ),
        if (_weekDayError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _weekDayError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        if (_selectedWeekDays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedWeekDays.map((day) {
                return Chip(
                  label: Text(Translate.of(context).translate(day)),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedWeekDays.remove(day);
                      context.read<AddListingCubit>().updateRecurringRule(
                          key: widget.recurringRuleKey,
                          weekdays: _selectedWeekDays);
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthlyUi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('interval'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          hintText: Translate.of(context).translate('input_interval'),
          errorText: _errorInterval,
          controller: _textIntervalController,
          focusNode: _focusInterval,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          onChanged: (text) {
            _errorInterval = UtilValidator.validate(
                _textIntervalController.text,
                type: ValidateType.number);
            context.read<AddListingCubit>().updateRecurringRule(
                key: widget.recurringRuleKey,
                interval: int.parse(_textIntervalController.text));
          },
          onSubmitted: (text) {
            Utils.fieldFocusChange(context, _focusInterval, _focusInterval);
            context.read<AddListingCubit>().updateRecurringRule(
                key: widget.recurringRuleKey,
                interval: int.parse(_textIntervalController.text));
          },
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('week_days'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: Translate.of(context).translate('optional'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        AppPickerItem(
          leading: Icon(
            Icons.date_range,
            color: Theme.of(context).hintColor,
          ),
          value: _selectedMonthlyWeekDay == null
              ? null
              : Translate.of(context).translate(_selectedMonthlyWeekDay!),
          title: Translate.of(context).translate('select_weekdays'),
          onPressed: _onSelectSingleWeekDay,
        ),

        // ORDINAL (only if weekday selected)
        if (_selectedMonthlyWeekDay != null) ...[
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: Translate.of(context).translate('select_ordinal'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _customDropDown(
            items: _ordinals,
            hint: Translate.of(context).translate('select_ordinal'),
            value: _selectedOrdinal,
            onSelected: (val) {
              setState(() {
                _selectedOrdinal = val;
                _ordinalError = null;
              });
              context.read<AddListingCubit>().updateRecurringRule(
                  key: widget.recurringRuleKey,
                  dayOrdinal: _ordinalToNumber(_selectedOrdinal));
            },
          ),
          if (_ordinalError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _ordinalError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ]
      ],
    );
  }

  Widget _customDropDown({
    required List<String> items,
    required String hint,
    required String? value,
    required Function(String) onSelected,
  }) {
    return DropdownButton<String>(
      isExpanded: true,
      menuMaxHeight: 200,
      hint: Text(hint),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item, // logic value
                child: Text(
                  Translate.of(context).translate(item), // UI label
                ),
              ))
          .toList(),
      onChanged: (val) {
        if (val != null) onSelected(val);
      },
    );
  }

  Widget _dateTimeCommonUi(bool canSelectStartDate) {
    final canSelectStartTime = _startDate != null;
    final canSelectEndDate = _startTime != null;
    final canSelectEndTime = _endDate != null;
    final canSelectRepeatDate = _endTime != null;
    final canSelectRepeatTime = _repeatUntilDate != null;
    final canSelectExceptions = (_endTime != null) &&
        ((_repeatUntilDate != null && _repeatUntilTime != null) ||
            _repeatUntilDate == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(
            labelKey: 'start_date',
            icon: Icons.calendar_today_outlined,
            value: _startDate,
            titleKey: 'choose_date',
            onPressed: () => _onShowStartDatePicker(_startDate),
            visibility: canSelectStartDate),
        _section(
            labelKey: 'start_time',
            icon: Icons.access_time,
            value: _startTime?.format(context),
            titleKey: 'choose_stime',
            onPressed: canSelectStartTime
                ? () => _onShowStartTimePicker(_startTime)
                : null,
            visibility: canSelectStartTime),
        _section(
            labelKey: 'end_date',
            icon: Icons.calendar_today_outlined,
            value: _endDate,
            titleKey: 'choose_date',
            onPressed:
            canSelectEndDate ? () => _onShowEndDatePicker(_endDate) : null,
            visibility: canSelectEndDate),
        _section(
            labelKey: 'end_time',
            icon: Icons.access_time,
            value: _endTime?.format(context),
            titleKey: 'choose_etime',
            onPressed:
            canSelectEndTime ? () => _onShowEndTimePicker(_endTime) : null,
            visibility: canSelectEndTime),

        // Optional fields shown after end time
        _section(
            labelKey: 'repeat_until_date',
            icon: Icons.calendar_today_outlined,
            value: _repeatUntilDate,
            titleKey: 'choose_date',
            onPressed: canSelectRepeatDate
                ? () => _onShowRepeatUntilDatePicker(_repeatUntilDate)
                : null,
            visibility: canSelectRepeatDate,
            isOptional: true),
        _section(
            labelKey: 'repeat_until_time',
            icon: Icons.access_time,
            value: _repeatUntilTime?.format(context),
            titleKey: 'choose_repeat_until_time',
            onPressed: canSelectRepeatTime
                ? () => _onShowRepeatTimePicker(_repeatUntilTime)
                : null,
            visibility: canSelectRepeatTime),

        _exceptionSection(canSelectExceptions),
      ],
    );
  }

  Widget _label(String key, {bool required = true, bool optional = false}) {
    return Text.rich(
      TextSpan(
        text: Translate.of(context).translate(key),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
          if (optional)
            TextSpan(
              text: Translate.of(context).translate('optional'),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(
      {required String labelKey,
      required IconData icon,
      required String titleKey,
      String? value,
      VoidCallback? onPressed,
      bool visibility = true,
      bool isOptional = false,
      }) {
    return Visibility(
      visible: visibility,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _label(labelKey, required: !isOptional, optional: isOptional),
          const SizedBox(height: 8),
          AppPickerItem(
            leading: Icon(icon, color: Theme.of(context).hintColor),
            value: value,
            title: Translate.of(context).translate(titleKey),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget _exceptionSection(bool canSelectExceptions) {
    return Visibility(
      visible: canSelectExceptions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _label('exception_dates', required: false, optional: true),
          const SizedBox(height: 8),
          AppPickerItem(
            leading: Icon(Icons.event_busy, color: Theme.of(context).hintColor),
            value: _exceptionDates.isEmpty
                ? null
                : "${_exceptionDates.length} ${Translate.of(context).translate('selected')}",
            title: Translate.of(context).translate('add_exception_date'),
            onPressed: canSelectExceptions ? _onAddExceptionDate : null,
          ),
          if (_exceptionDates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _exceptionDates.map((date) {
                  return Chip(
                    label: Text(date),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _exceptionDates.remove(date);
                      });
                      context.read<AddListingCubit>().updateRecurringRule(
                            key: widget.recurringRuleKey,
                            exceptionDates: _exceptionDates,
                          isRepeatExceptionDates: _exceptionDates.isEmpty);
                    },
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Text(
              _repeatUntilDate != null
                  ? "${Translate.of(context).translate('select_exception_date_text')} $_startDate to $_repeatUntilDate) - ${Translate.of(context).translate('select_exception_date_info')}"
                  : "${Translate.of(context).translate('select_exception_date_from_text')} $_startDate",
              style: Theme.of(context).textTheme.bodyMedium)
        ],
      ),
    );
  }

  void _onShowStartDatePicker(String? startDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.dateView;
        _startTime = null;
        _endDate = null;
        _endTime = null;
        _repeatUntilDate = null;
        _repeatUntilTime = null;
        _exceptionDates.clear();
        widget.addRuleCallback(false);
      });
      context.read<AddListingCubit>().updateRecurringRule(
          key: widget.recurringRuleKey,
          start: null,
          end: _endDate,
          repeatUntil: _repeatUntilDate,
          exceptionDates: _exceptionDates);
      widget.emptyRepeatUntilTimeCallback(false);
    }
  }

  void _onShowEndDatePicker(String? endDate) async {
    if (_startDate == null) return;

    final start = DateFormat('yyyy-MM-dd').parse(_startDate!);
    final picked = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: start,
      lastDate: DateTime(start.year + 2),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked.dateView;
        _endTime = null;
        _repeatUntilDate = null;
        _repeatUntilTime = null;
        _exceptionDates.clear();
        widget.addRuleCallback(false);
      });

      context.read<AddListingCubit>().updateRecurringRule(
          key: widget.recurringRuleKey,
          end: null,
          repeatUntil: _repeatUntilDate,
          isResetRepeatUntil: true,
          isRepeatExceptionDates: true,
          exceptionDates: _exceptionDates);
      widget.emptyRepeatUntilTimeCallback(false);
    }
  }

  void _onShowRepeatUntilDatePicker(String? repeatUntilDate) async {
    if (_endDate == null) return;

    final end = DateFormat('yyyy-MM-dd').parse(_endDate!);
    final picked = await showDatePicker(
      context: context,
      initialDate: end,
      firstDate: end,
      lastDate: DateTime(end.year + 2),
    );

    if (picked != null) {
      setState(() {
        _repeatUntilDate = picked.dateView;
        _repeatUntilTime = null;
        _exceptionDates.clear();
      });
      context.read<AddListingCubit>().updateRecurringRule(
          key: widget.recurringRuleKey,
          repeatUntil: null,
          isResetRepeatUntil: true,
          isRepeatExceptionDates: true,
          exceptionDates: _exceptionDates);
      widget.emptyRepeatUntilTimeCallback(true);
    }
  }

  Future<void> _onShowStartTimePicker(TimeOfDay? startTime) async {
    if (startTime != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: startTime,
      );

      if (pickedTime != null) {
        setState(() {
          _startTime = pickedTime;
        });
        if (_startDate != null && _startTime != null) {
          context.read<AddListingCubit>().updateRecurringRule(
              key: widget.recurringRuleKey,
              start: buildDateTimeString(_startDate ?? '', _startTime!));
          widget.emptyRepeatUntilTimeCallback(false);
        }
      }
    } else {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _startTime = pickedTime;
        });
        if (_startDate != null && _startTime != null) {
          context.read<AddListingCubit>().updateRecurringRule(
              key: widget.recurringRuleKey,
              start: buildDateTimeString(_startDate ?? '', _startTime!));
          widget.emptyRepeatUntilTimeCallback(false);
        }
      }
    }
  }

  Future<void> _onShowEndTimePicker(TimeOfDay? endTime) async {
    if (_startTime == null || _startDate == null || _endDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: endTime ?? _startTime!,
    );

    if (pickedTime == null) return;

    if (_startDate == _endDate &&
        !_isTimeAfter(pickedTime, _startTime!)) {
      _showError('end_time_must_be_greater_than_start_time');
      return;
    }

    setState(() {
      _endTime = pickedTime;
      _repeatUntilDate = null;
      _repeatUntilTime = null;
      _exceptionDates.clear();
    });

    context.read<AddListingCubit>().updateRecurringRule(
      key: widget.recurringRuleKey,
      end: buildDateTimeString(_endDate!, _endTime!),
      isResetRepeatUntil: true,
      isRepeatExceptionDates: true,
    );
    widget.addRuleCallback(true);
    widget.emptyRepeatUntilTimeCallback(false);
  }


  // Future<void> _onShowEndTimePicker(TimeOfDay? endTime) async {
  //   if (endTime != null) {
  //     final pickedTime = await showTimePicker(
  //       context: context,
  //       initialTime: endTime,
  //     );
  //
  //     if (pickedTime != null) {
  //       setState(() {
  //         _endTime = pickedTime;
  //       });
  //       if (_endDate != null && _endTime != null) {
  //         context.read<AddListingCubit>().updateRecurringRule(
  //             key: widget.recurringRuleKey,
  //             end: buildDateTimeString(_endDate ?? '', _endTime!));
  //       }
  //     }
  //   } else {
  //     final pickedTime = await showTimePicker(
  //       context: context,
  //       initialTime: TimeOfDay.now(),
  //     );
  //
  //     if (pickedTime != null) {
  //       setState(() {
  //         _endTime = pickedTime;
  //       });
  //       if (_endDate != null && _endTime != null) {
  //         context.read<AddListingCubit>().updateRecurringRule(
  //             key: widget.recurringRuleKey,
  //             end: buildDateTimeString(_endDate ?? '', _endTime!));
  //       }
  //     }
  //   }
  // }


  bool _isTimeAfter(TimeOfDay a, TimeOfDay b) {
    return (a.hour * 60 + a.minute) > (b.hour * 60 + b.minute);
  }

  bool _isTimeAfterOrEqual(TimeOfDay a, TimeOfDay b) {
    return (a.hour * 60 + a.minute) >= (b.hour * 60 + b.minute);
  }

  void _showError(String key) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Translate.of(context).translate(key)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _onShowRepeatTimePicker(TimeOfDay? repeatUntilTime) async {
    if (_repeatUntilDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: repeatUntilTime ?? _endTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    if (_endDate != null &&
        _endTime != null &&
        _endDate == _repeatUntilDate &&
        !_isTimeAfterOrEqual(pickedTime, _endTime!)) {
      _showError('repeat_until_time_must_be_greater_or_equal_end_time');
      return;
    }

    setState(() {
      _repeatUntilTime = pickedTime;
    });

    context.read<AddListingCubit>().updateRecurringRule(
      key: widget.recurringRuleKey,
      isRepeatExceptionDates: true,
      repeatUntil:
      buildDateTimeString(_repeatUntilDate!, _repeatUntilTime!),
    );
    widget.emptyRepeatUntilTimeCallback(false);
  }

  void _onAddExceptionDate() async {
    if (_startDate == null) return;

    final start = DateFormat('yyyy-MM-dd').parse(_startDate!);
    final end = (_repeatUntilDate != null)
        ? DateFormat('yyyy-MM-dd').parse(_repeatUntilDate!)
        :  DateTime(start.year + 25);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now.isBefore(start)
          ? start
          : now.isAfter(end)
              ? end
              : now,
      firstDate: start, // inclusive
      lastDate: end, // inclusive
    );

    if (picked != null) {
      final date = picked.dateView;
      if (!_exceptionDates.contains(date)) {
        setState(() {
          _exceptionDates.add(date);
        });
        if (_exceptionDates != null && _exceptionDates.isNotEmpty) {
          context.read<AddListingCubit>().updateRecurringRule(
              key: widget.recurringRuleKey, exceptionDates: _exceptionDates);
        }
      }
    }
  }

  void _onSelectWeekDays() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select week days",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._weekDays.map((day) {
                      final isSelected = _selectedWeekDays.contains(day);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(Translate.of(context).translate(day)),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (checked) {
                          setSheetState(() {
                            if (checked == true) {
                              _selectedWeekDays.add(day);
                            } else {
                              _selectedWeekDays.remove(day);
                            }
                          });

                          context.read<AddListingCubit>().updateRecurringRule(
                              key: widget.recurringRuleKey,
                              weekdays: _selectedWeekDays);

                          if (_selectedWeekDays.isNotEmpty) {
                            setState(() {
                              _weekDayError = null;
                            });
                          }
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedWeekDays.isEmpty) {
                            setState(() {
                              _weekDayError = Translate.of(context).translate(
                                  'please_select_at_least_one_weekday');
                            });
                            return;
                          }

                          setState(() {
                            _weekDayError = null;
                          });

                          Navigator.pop(context);
                        },
                        child: Text(Translate.of(context).translate('done')),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onSelectSingleWeekDay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translate.of(context).translate('select_weekdays'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._weekDays.map((day) {
                  return RadioListTile<String>(
                    value: day,
                    groupValue: _selectedMonthlyWeekDay,
                    title: Text(Translate.of(context).translate(day)),
                    onChanged: (val) {
                      setState(() {
                        _selectedMonthlyWeekDay = val;
                        _selectedOrdinal = null; // reset ordinal
                      });
                      if (_selectedMonthlyWeekDay != null) {
                        context.read<AddListingCubit>().updateRecurringRule(
                            key: widget.recurringRuleKey,
                            weekdays: [_selectedMonthlyWeekDay!]);
                      }
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonthlyWeekDay = null;
                      _selectedOrdinal = null;
                    });
                    context.read<AddListingCubit>().updateRecurringRule(
                        key: widget.recurringRuleKey, weekdays: []);
                    Navigator.pop(context);
                  },
                  child: const Text("Clear selection"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String buildDateTimeString(String date, TimeOfDay time) {
    final parsedDate = DateFormat('yyyy-MM-dd').parse(date);

    final dateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      time.hour,
      time.minute,
    );

    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  int? _ordinalToNumber(String? ordinal) {
    switch (ordinal) {
      case "first":
        return 1;
      case "second":
        return 2;
      case "third":
        return 3;
      case "fourth":
        return 4;
      case "last":
        return -1;
      default:
        return null;
    }
  }

  ParsedDateTime parseDateTimeString(String dateTimeStr) {
    final parsed = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStr);

    return ParsedDateTime(
      DateFormat('yyyy-MM-dd').format(parsed),
      TimeOfDay(hour: parsed.hour, minute: parsed.minute),
    );
  }

  String? _numberToOrdinal(int number) {
    switch (number) {
      case 1:
        return "first";
      case 2:
        return "second";
      case 3:
        return "third";
      case 4:
        return "fourth";
      case -1:
        return "last";
      default:
        return null;
    }
  }
}
