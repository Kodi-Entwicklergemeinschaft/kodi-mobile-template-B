import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/translate.dart';

class UpcomingEvent {
  final DateTime startDate;
  final DateTime endDate;

  UpcomingEvent({
    required this.startDate,
    required this.endDate,
  });

  factory UpcomingEvent.fromJson(Map<String, dynamic> json) {
    return UpcomingEvent(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

class UpcomingEventsWidget extends StatefulWidget {
  final List<UpcomingEvent> upcomingDates;

  const UpcomingEventsWidget({
    super.key,
    required this.upcomingDates,
  });

  @override
  State<UpcomingEventsWidget> createState() => _UpcomingEventsWidgetState();
}

class _UpcomingEventsWidgetState extends State<UpcomingEventsWidget> {
  bool showAll = false;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  String _formatDateTimeRange(DateTime start, DateTime end) {
    final startStr = _formatDateTime(start);
    final endTime = _formatDateTime(end);
    return "$startStr - $endTime";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.upcomingDates.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    final primaryColor = theme.primaryColor;
    final backgroundColor =
        appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final foregroundColor =
        appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    final itemsToShow = showAll
        ? (widget.upcomingDates.length > 10 ? 10 : widget.upcomingDates.length)
        : (widget.upcomingDates.length > 5 ? 5 : widget.upcomingDates.length);

    final hasMore = widget.upcomingDates.length > 5;
    final canShowMore = !showAll && hasMore;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_repeat,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                Translate.of(context).translate('recurring_details'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...List.generate(itemsToShow, (index) {
            final event = widget.upcomingDates[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatDateTimeRange(
                        event.startDate,
                        event.endDate,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: foregroundColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          if (canShowMore || (showAll && widget.upcomingDates.length > 10))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    showAll = !showAll;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      showAll
                          ? Translate.of(context).translate('show_less')
                          : Translate.of(context).translate('view_more'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      showAll
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
