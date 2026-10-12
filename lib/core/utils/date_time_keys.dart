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

  String get monthName {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
