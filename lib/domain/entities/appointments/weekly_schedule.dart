class TimeRange {
  final String start;
  final String end;
  const TimeRange({required this.end, required this.start});

  factory TimeRange.fromMap(Map<String, dynamic> timeRange) {
    return TimeRange(
      end: (timeRange['end'] ?? '').toString(),
      start: (timeRange['start'] ?? '').toString(),
    );
  }
  Map<String, dynamic> toMap() => {'start': start, 'end': end};
}

class WeeklySchedule {
  final Map<String, List<TimeRange>> days;

  const WeeklySchedule({this.days = const {}});

  static const List<String> _dayKeys = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  factory WeeklySchedule.fromMap(Map<String, dynamic> map) {
    final parsed = <String, List<TimeRange>>{};
    for (final day in _dayKeys) {
      final raw = map[day];
      parsed[day] = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => TimeRange.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : const [];
    }
    return WeeklySchedule(days: parsed);
  }

  Map<String, dynamic> toMap() => {
    for (final day in _dayKeys)
      day: (days[day] ?? const []).map((r) => r.toMap()).toList(),
  };

  String _keyFor(DateTime day) => (_dayKeys[day.weekday - 1]);

  bool worksOn(DateTime day) => (days[_keyFor(day)] ?? const []).isNotEmpty;

  DateTime _timeOf(DateTime day, String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  List<DateTime> slotsFor(DateTime day, int slotMinutes) {
    final result = <DateTime>[];
    for (final range in days[_keyFor(day)] ?? const []) {
      var cursor = _timeOf(day, range.start);
      final end = _timeOf(day, range.end);
      while (cursor.isBefore(end)) {
        result.add(cursor);
        cursor = cursor.add(Duration(minutes: slotMinutes));
      }
    }
    return result;
  }
}
