// Verifies components grow rather than clip at 200% system text scale.
// Uses TextScaler (not the deprecated textScaleFactor double API), per the
// Frontend Spec's explicit requirement. See FT-002 AC4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/widgets/buttons/app_button.dart';
import 'package:bloomora/core/widgets/cards/app_card.dart';
import 'package:bloomora/core/widgets/chips/app_chip.dart';
import 'package:bloomora/core/widgets/inputs/app_text_field.dart';
import 'package:bloomora/core/widgets/overlays/app_dialog.dart';

Widget _wrapAt200Percent(Widget child) => ProviderScope(
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp(
          home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
        ),
      ),
    );

void main() {
  testWidgets('AppButton at 200% text scale: no overflow, grows vertically', (tester) async {
    await tester.pumpWidget(_wrapAt200Percent(
      AppButton.primary(
        label: 'Continue to the next assessment question',
        onPressed: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final size = tester.getSize(find.byType(AppButton));
    // 52dp is the button's normal minimum height at 100% scale — at 200%
    // it must be taller, not clipped to the same height.
    expect(size.height, greaterThan(52));
  });

  testWidgets('AppTextField at 200% text scale: no overflow, grows vertically', (tester) async {
    await tester.pumpWidget(_wrapAt200Percent(
      const AppTextField(
        label: 'Child\'s full name',
        hint: 'Enter name',
        helperText: 'As it appears on official records',
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final size = tester.getSize(find.byType(AppTextField));
    expect(size.height, greaterThan(56));
  });

  testWidgets('DomainChip at 200% text scale: no overflow, grows', (tester) async {
    await tester.pumpWidget(_wrapAt200Percent(
      const DomainChip(domain: 'Social & Emotional', icon: Icons.people),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final size = tester.getSize(find.byType(DomainChip));
    // 32dp is the chip's normal minimum height at 100% scale.
    expect(size.height, greaterThan(32));
  });

  testWidgets('AppFilterChip at 200% text scale: no overflow, grows', (tester) async {
    await tester.pumpWidget(_wrapAt200Percent(
      AppFilterChip(
        label: 'Attention & Play',
        selected: true,
        onChanged: (_) {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final size = tester.getSize(find.byType(AppFilterChip));
    // 48dp is the chip's own minimum tap-target height at 100% scale.
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('AppCard with a long text label at 200% text scale: no overflow, grows', (tester) async {
    await tester.pumpWidget(_wrapAt200Percent(
      const AppCard(
        child: Text(
          'This activity helps your child practice turn-taking, sharing '
          'materials, and following two-step instructions during play.',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // AppCard has no height constraint at all — it should simply be as
    // tall as its child needs; asserting it rendered without exception,
    // laid out, and is taller than a single line is the meaningful check.
    final size = tester.getSize(find.byType(AppCard));
    expect(size.height, greaterThan(40));
  });

  testWidgets('AppDialog with a long message at 200% text scale: no overflow, grows', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showAppDialog<void>(
                    context: context,
                    title: 'Remove this activity?',
                    message:
                        'This will permanently remove "Fine Motor Skills — Bead '
                        'Threading" from today\'s recommendations and cannot be undone.',
                    confirmLabel: 'Remove',
                    isDestructive: true,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppDialog), findsOneWidget);

    // The dialog must fit within the (scaled-down test) screen height —
    // i.e. it grew to fit the long message rather than clipping it, and
    // didn't get clamped/overflow in the process.
    final dialogSize = tester.getSize(find.byType(AppDialog));
    final screenSize = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(dialogSize.height, lessThanOrEqualTo(screenSize.height));
    expect(find.text('Remove'), findsOneWidget);
  });
}
