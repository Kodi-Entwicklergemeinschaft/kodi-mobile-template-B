import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'event_tab_type.dart';

class EventTabSelector extends StatelessWidget {
  final EventTabType selectedTab;
  final Function(EventTabType) onTabChanged;

  const EventTabSelector(
      {Key? key, required this.selectedTab, required this.onTabChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;

    final backgroundColor = appBarTheme.backgroundColor;

    final unselectedTextColor = appBarTheme.foregroundColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: EventTabType.values.map((tab) {
          final isSelected = selectedTab == tab;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab.displayName(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : unselectedTextColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
