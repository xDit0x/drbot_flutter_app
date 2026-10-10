import 'package:flutter_learning/core/utils/date_time_keys.dart';

class SlotsRequest {
  final String doctorId;
  final DateTime date;

  const SlotsRequest({required this.doctorId, required this.date});

  String get dateKey => date.dateKey;
}
