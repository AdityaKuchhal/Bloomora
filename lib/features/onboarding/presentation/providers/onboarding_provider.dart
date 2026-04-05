import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/parent_model.dart';
import '../../domain/models/child_model.dart';

part 'onboarding_provider.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void updateParentData(ParentModel parent) {
    state = state.copyWith(parent: parent);
  }

  void updateChildData(ChildModel child) {
    state = state.copyWith(child: child);
  }

  void clearData() {
    state = const OnboardingState();
  }
}

@riverpod
class ParentNotifier extends _$ParentNotifier {
  @override
  ParentModel? build() {
    return null;
  }

  void setParent(ParentModel parent) {
    state = parent;
  }

  void clearParent() {
    state = null;
  }
}

@Riverpod(keepAlive: true)
class ChildNotifier extends _$ChildNotifier {
  @override
  ChildModel? build() {
    return null;
  }

  void setChild(ChildModel child) {
    state = child;
  }

  void clearChild() {
    state = null;
  }
}

class OnboardingState {
  final ParentModel? parent;
  final ChildModel? child;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.parent,
    this.child,
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    ParentModel? parent,
    ChildModel? child,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      parent: parent ?? this.parent,
      child: child ?? this.child,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
