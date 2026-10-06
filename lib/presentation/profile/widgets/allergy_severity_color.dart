import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/entities/clinical/allergy.dart';

extension AllergySeverityColor on AllergySeverity {
  Color get color {
    switch (this) {
      case AllergySeverity.mild:
        return Colors.lightGreenAccent;
      case AllergySeverity.moderate:
        return Colors.orangeAccent;
      case AllergySeverity.severe:
        return Colors.redAccent;
    }
  }

  int get rank {
    switch (this) {
      case AllergySeverity.severe:
        return 0;
      case AllergySeverity.moderate:
        return 1;
      case AllergySeverity.mild:
        return 2;
    }
  }
}
