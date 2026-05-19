import 'package:flutter/material.dart';

class DemoState {
  static final ValueNotifier<bool> isEmptyState = ValueNotifier<bool>(false);

  static void toggle() {
    isEmptyState.value = !isEmptyState.value;
  }
}
