import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'priority_selection_provider.g.dart';

@riverpod
class PrioritySelectionNotifier extends _$PrioritySelectionNotifier {
  @override
  PrioritySelectionState build() {
    return const PrioritySelectionState();
  }

  void setPriorities(List<String> priorities) {
    state = state.copyWith(priorities: priorities);
  }

  void clearPriorities() {
    state = const PrioritySelectionState();
  }
}

class PrioritySelectionState {
  final List<String> priorities;
  final bool isLoading;
  final String? error;

  const PrioritySelectionState({
    this.priorities = const [],
    this.isLoading = false,
    this.error,
  });

  PrioritySelectionState copyWith({
    List<String>? priorities,
    bool? isLoading,
    String? error,
  }) {
    return PrioritySelectionState(
      priorities: priorities ?? this.priorities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
