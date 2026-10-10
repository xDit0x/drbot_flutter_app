import 'package:flutter/foundation.dart';

class RootNavigation {
  RootNavigation._();
  static final ValueNotifier<String?> pendingDestination = ValueNotifier(null);
  static void goTo(String label) => pendingDestination.value = label;
}
