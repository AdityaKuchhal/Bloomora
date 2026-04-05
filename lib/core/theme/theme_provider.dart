import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

// ─── Preference keys ──────────────────────────────────────────────────────────

const _kGender = 'theme_gender';
const _kDark   = 'theme_dark';

// ─── State ────────────────────────────────────────────────────────────────────

class ThemeState {
  /// `'boy'` | `'girl'` | `'unset'`
  final String gender;
  final bool isDark;

  const ThemeState({
    this.gender = 'unset',
    this.isDark = false,
  });

  ThemeState copyWith({String? gender, bool? isDark}) => ThemeState(
        gender: gender ?? this.gender,
        isDark: isDark ?? this.isDark,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _load();
  }

  // Load persisted prefs on startup
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString(_kGender) ?? 'unset';
    final isDark = prefs.getBool(_kDark) ?? false;
    state = ThemeState(gender: gender, isDark: isDark);
  }

  Future<void> setGender(String gender) async {
    assert(gender == 'boy' || gender == 'girl' || gender == 'unset');
    state = state.copyWith(gender: gender);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGender, gender);
  }

  Future<void> toggleDark() async {
    state = state.copyWith(isDark: !state.isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDark, state.isDark);
  }

  /// Convenience: set brightness explicitly
  Future<void> setBrightness({required bool isDark}) async {
    state = state.copyWith(isDark: isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDark, isDark);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Holds the current [ThemeState]. keepAlive so it survives route changes.
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

/// Derives the active [AppColorScheme] from [themeNotifierProvider].
/// Widgets read this to get colors; they don't touch ThemeState directly.
final activeColorSchemeProvider = Provider<AppColorScheme>((ref) {
  final state = ref.watch(themeNotifierProvider);
  return AppColors.forProfile(gender: state.gender, isDark: state.isDark);
});