import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import 'app_colors.dart';

// ─── Preference keys ──────────────────────────────────────────────────────────

const _kPreviewGender = 'theme_preview_gender';
const _kPaletteOverrides = 'theme_palette_overrides_by_child';
const _kThemeMode = 'theme_mode';

// ─── Theme mode (brightness axis — separate from palette family) ──────────────

enum AppThemeMode { light, dark, system }

// ─── State ────────────────────────────────────────────────────────────────────

class ThemeState {
  /// `'boy'` | `'girl'` | `'unset'`. Used ONLY when there is no active
  /// child yet (splash/auth/onboarding, before a [ChildModel] exists to
  /// resolve a real per-child palette from) — e.g. so the child-profile
  /// form can live-preview Ocean/Blossom as the parent picks a gender.
  /// Persisted globally, not per child, because there's no child id to key
  /// it by yet. See [ThemeNotifier.setGender].
  final String previewGender;

  /// childId -> `'boy'` | `'girl'` manual palette override. Once a child
  /// exists, this — not [previewGender] — drives palette resolution (see
  /// `activeColorSchemeProvider`). Empty means "use each child's own
  /// `gender` field". Set via the (future, FT-053) Settings screen through
  /// [ThemeNotifier.setPaletteOverride]; the resolution logic here is in
  /// scope for FT-002, the settings UI that calls it is not.
  final Map<String, String> paletteOverrides;

  final AppThemeMode themeMode;

  /// Last-known platform brightness, kept live via
  /// [WidgetsBindingObserver.didChangePlatformBrightness] so
  /// [AppThemeMode.system] switches immediately on OS change without
  /// needing a BuildContext.
  final Brightness systemBrightness;

  const ThemeState({
    this.previewGender = 'unset',
    this.paletteOverrides = const {},
    this.themeMode = AppThemeMode.system,
    this.systemBrightness = Brightness.light,
  });

  /// Resolved light/dark, folding [AppThemeMode.system] against
  /// [systemBrightness].
  bool get resolvedIsDark => switch (themeMode) {
        AppThemeMode.light => false,
        AppThemeMode.dark => true,
        AppThemeMode.system => systemBrightness == Brightness.dark,
      };

  ThemeState copyWith({
    String? previewGender,
    Map<String, String>? paletteOverrides,
    AppThemeMode? themeMode,
    Brightness? systemBrightness,
  }) =>
      ThemeState(
        previewGender: previewGender ?? this.previewGender,
        paletteOverrides: paletteOverrides ?? this.paletteOverrides,
        themeMode: themeMode ?? this.themeMode,
        systemBrightness: systemBrightness ?? this.systemBrightness,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<ThemeState> with WidgetsBindingObserver {
  ThemeNotifier()
      : super(ThemeState(
          // Routed through WidgetsBinding, not the bare dart:ui
          // PlatformDispatcher.instance singleton — the latter isn't the
          // object Flutter's test framework overrides
          // (tester.platformDispatcher.platformBrightnessTestValue), so
          // using it directly would silently ignore both tests and any
          // future runtime override mechanism.
          systemBrightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
        )) {
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangePlatformBrightness() {
    state = state.copyWith(
      systemBrightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final previewGender = prefs.getString(_kPreviewGender) ?? 'unset';

    Map<String, String> overrides = const {};
    final rawOverrides = prefs.getString(_kPaletteOverrides);
    if (rawOverrides != null) {
      try {
        final decoded = jsonDecode(rawOverrides) as Map<String, dynamic>;
        overrides = decoded.map((k, v) => MapEntry(k, v as String));
      } catch (_) {
        // Corrupt/old-format prefs value — fall back to no overrides
        // rather than crash startup.
      }
    }

    final rawMode = prefs.getString(_kThemeMode);
    final matches = AppThemeMode.values.where((m) => m.name == rawMode);
    final themeMode = matches.isEmpty ? AppThemeMode.system : matches.first;

    state = state.copyWith(
      previewGender: previewGender,
      paletteOverrides: overrides,
      themeMode: themeMode,
    );
  }

  /// Pre-child palette preview — e.g. the child-profile form calling this
  /// live as the parent taps Boy/Girl, before the child is actually
  /// created. Not tied to any child id. See [ThemeState.previewGender].
  Future<void> setGender(String gender) async {
    assert(gender == 'boy' || gender == 'girl' || gender == 'unset');
    state = state.copyWith(previewGender: gender);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPreviewGender, gender);
  }

  /// Sets (or, with `gender: null`, clears) a manual palette override for
  /// one child, persisted per that child's id. Never affects semantic
  /// success/warning/error/info colors — those are palette-independent by
  /// construction (see [AppColors]), not part of what this touches.
  Future<void> setPaletteOverride(String childId, String? gender) async {
    assert(gender == null || gender == 'boy' || gender == 'girl');
    final next = Map<String, String>.from(state.paletteOverrides);
    if (gender == null) {
      next.remove(childId);
    } else {
      next[childId] = gender;
    }
    state = state.copyWith(paletteOverrides: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaletteOverrides, jsonEncode(next));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode.name);
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Holds the current [ThemeState]. keepAlive so it survives route changes.
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

/// Derives the active [AppColorScheme]. Widgets read this to get colors;
/// they don't touch [ThemeState] directly.
///
/// Resolution: if a child is active (`childNotifierProvider`), use that
/// child's manual override if one is set, else that child's own `gender`
/// field. If no child is active yet (splash/auth/onboarding), fall back to
/// [ThemeState.previewGender]. Brightness comes from [AppThemeMode],
/// resolving [AppThemeMode.system] against the live platform brightness.
final activeColorSchemeProvider = Provider<AppColorScheme>((ref) {
  final themeState = ref.watch(themeNotifierProvider);
  final activeChild = ref.watch(childNotifierProvider);

  final String gender;
  if (activeChild != null) {
    final override = themeState.paletteOverrides[activeChild.id];
    gender = (override ?? activeChild.gender).toLowerCase();
  } else {
    gender = themeState.previewGender;
  }

  return AppColors.forProfile(gender: gender, isDark: themeState.resolvedIsDark);
});
