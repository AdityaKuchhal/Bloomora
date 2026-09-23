import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_provider.dart';

/// Shows the default mobile pattern for a secondary task: a bottom sheet
/// with radius-xl(24) top corners, ~45% black scrim, 24dp content padding,
/// and a drag handle. Content scrolls if it's taller than the sheet.
///
/// Also the base for the select/dropdown field pattern (see
/// inputs/app_select_field.dart) — don't bury choices in a long wheel
/// picker.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool showDragHandle = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (context) => _AppBottomSheetShell(
      showDragHandle: showDragHandle,
      builder: builder,
    ),
  );
}

class _AppBottomSheetShell extends ConsumerWidget {
  final bool showDragHandle;
  final WidgetBuilder builder;

  const _AppBottomSheetShell({required this.showDragHandle, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space3),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.border,
                    borderRadius: AppRadius.pillRadius,
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space6,
                  AppSpacing.space4,
                  AppSpacing.space6,
                  AppSpacing.space6,
                ),
                child: Builder(builder: builder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
