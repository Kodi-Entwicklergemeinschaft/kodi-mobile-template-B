import 'package:flutter/cupertino.dart';

import '../../../../utils/translate.dart';

enum EventTabType {
  single,
  multi,
  recurring;

  String displayName(BuildContext context) {
    switch (this) {
      case EventTabType.single:
        return Translate.of(context).translate('single_event');
      case EventTabType.multi:
        return Translate.of(context).translate('multi_events');
      case EventTabType.recurring:
        return Translate.of(context).translate('recurring_events');
    }
  }

  String get apiValue {
    switch (this) {
      case EventTabType.single:
        return 'singleDay';
      case EventTabType.multi:
        return 'multiDay';
      case EventTabType.recurring:
        return 'recurring';
    }
  }
}