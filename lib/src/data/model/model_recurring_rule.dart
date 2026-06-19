class RecurrenceRuleModel {
  final String? freq;
  final int? interval;
  final List<String>? weekdays;
  final String? start;
  final String? end;
  final String? repeatUntil;
  final List<ExceptionDate>? exceptions;
  final int? dayOrdinal;

  RecurrenceRuleModel({
    required this.freq,
    required this.interval,
    this.weekdays,
    required this.start,
    required this.end,
    required this.repeatUntil,
    this.exceptions,
    this.dayOrdinal,
  });

  factory RecurrenceRuleModel.fromJson(Map<String, dynamic> json) {
    return RecurrenceRuleModel(
      freq: json['freq'],
      interval: json['interval'],
      weekdays: json['weekdays'] != null
          ? List<String>.from(json['weekdays'])
          : null,
      start: json['start'],
      end: json['end'],
      repeatUntil: json['repeatUntil'],
      dayOrdinal: json['dayOrdinal'],
      exceptions: json['exceptions'] != null
          ? (json['exceptions'] as List)
          .map((e) => ExceptionDate.fromJson(e))
          .toList()
          : null,
    );
  }

  RecurrenceRuleModel copyWith({
    String? freq,
    int? interval,
    List<String>? weekdays,
    String? start,
    String? end,
    String? repeatUntil,
    List<ExceptionDate>? exceptions,
    int? dayOrdinal,
    bool isResetRepeatUntil = false,
    bool isRepeatExceptionDates = false
  }) {
    return RecurrenceRuleModel(
      freq: freq ?? this.freq,
      interval: interval ?? this.interval,
      weekdays: weekdays ?? this.weekdays,
      start: start ?? this.start,
      end: end ?? this.end,
      repeatUntil:
          isResetRepeatUntil ? repeatUntil : repeatUntil ?? this.repeatUntil,
      exceptions: isRepeatExceptionDates ? exceptions : exceptions ?? this.exceptions,
      dayOrdinal: dayOrdinal ?? this.dayOrdinal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "freq": freq,
      "interval": interval,
      if (weekdays != null) "weekdays": weekdays,
      "start": start,
      "end": end,
      "repeatUntil": repeatUntil,
      if (dayOrdinal != null) "dayOrdinal": dayOrdinal,
      if (exceptions != null)
        "exceptions": exceptions!.map((e) => e.toJson()).toList(),
    };
  }
}


class ExceptionDate {
  final String date;

  ExceptionDate({required this.date});

  factory ExceptionDate.fromJson(Map<String, dynamic> json) {
    return ExceptionDate(
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "date": date,
    };
  }
}