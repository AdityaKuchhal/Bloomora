import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  DashboardState build() {
    return const DashboardState();
  }

  void updateProgress(int completedActivities, int totalActivities) {
    state = state.copyWith(
      completedActivities: completedActivities,
      totalActivities: totalActivities,
    );
  }

  void updateStreak(int streakDays) {
    state = state.copyWith(streakDays: streakDays);
  }

  void updateTotalTime(int totalMinutes) {
    state = state.copyWith(totalMinutes: totalMinutes);
  }

  void addSuggestion(String suggestion) {
    final suggestions = List<String>.from(state.suggestions);
    suggestions.add(suggestion);
    state = state.copyWith(suggestions: suggestions);
  }

  void removeSuggestion(int index) {
    final suggestions = List<String>.from(state.suggestions);
    if (index < suggestions.length) {
      suggestions.removeAt(index);
      state = state.copyWith(suggestions: suggestions);
    }
  }
}

class DashboardState {
  final int completedActivities;
  final int totalActivities;
  final int streakDays;
  final int totalMinutes;
  final List<String> suggestions;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.completedActivities = 0,
    this.totalActivities = 0,
    this.streakDays = 0,
    this.totalMinutes = 0,
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? completedActivities,
    int? totalActivities,
    int? streakDays,
    int? totalMinutes,
    List<String>? suggestions,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      completedActivities: completedActivities ?? this.completedActivities,
      totalActivities: totalActivities ?? this.totalActivities,
      streakDays: streakDays ?? this.streakDays,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  double get progressPercentage {
    if (totalActivities == 0) return 0.0;
    return completedActivities / totalActivities;
  }
}
