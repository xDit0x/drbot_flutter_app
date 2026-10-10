extension DateTimeKeys on DateTime {
  /// yyyyMMdd
  String get dateKey {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  /// HHmm
  String get timeKey {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h$m';
  }
}
