import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier to manage the current tab index in MainShell
class CurrentTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

/// Provider to manage the current tab index in MainShell
final currentTabIndexProvider = NotifierProvider<CurrentTabIndexNotifier, int>(
  CurrentTabIndexNotifier.new,
);
