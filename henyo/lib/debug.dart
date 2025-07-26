import 'package:flutter/foundation.dart';

void debug(String msg) {
  if (kDebugMode) {
    debugPrint('henyou: $msg');
  }
}
