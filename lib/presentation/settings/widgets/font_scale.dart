import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fontScaleKey = 'fontScale';

final fontScale = ValueNotifier<double>(1.0);

Future<void> loadFontScale() async {
  final preference = await SharedPreferences.getInstance();
  fontScale.value = preference.getDouble(_fontScaleKey) ?? 1.0;
}

Future<void> saveFontScale(double value) async {
  fontScale.value = value;

  try {
    final preference = await SharedPreferences.getInstance();
    await preference.setDouble(_fontScaleKey, value);
  } catch (_) {}
}
