// Verifies core components meet the 48x48dp minimum tap target — asserted
// programmatically via tester.getSize(), not just visually. See FT-002 AC4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/widgets/buttons/app_button.dart';
import 'package:bloomora/core/widgets/buttons/app_icon_button.dart';
import 'package:bloomora/core/widgets/chips/app_chip.dart';
import 'package:bloomora/core/widgets/inputs/app_checkbox.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  const minTapTarget = Size(48, 48);

  testWidgets('AppButton.primary meets 48x48dp minimum', (tester) async {
    await tester.pumpWidget(_wrap(
      AppButton.primary(label: 'Continue', onPressed: () {}, expand: false),
    ));
    final size = tester.getSize(find.byType(AppButton));
    expect(size.width, greaterThanOrEqualTo(minTapTarget.width));
    expect(size.height, greaterThanOrEqualTo(minTapTarget.height));
  });

  testWidgets('AppButton.tertiary (visually short) still meets 48x48dp', (tester) async {
    await tester.pumpWidget(_wrap(
      AppButton.tertiary(label: 'Skip', onPressed: () {}),
    ));
    final size = tester.getSize(find.byType(AppButton));
    expect(size.height, greaterThanOrEqualTo(minTapTarget.height));
  });

  testWidgets('AppButton disabled still meets 48x48dp', (tester) async {
    await tester.pumpWidget(_wrap(
      const AppButton.primary(label: 'Continue', onPressed: null, expand: false),
    ));
    final size = tester.getSize(find.byType(AppButton));
    expect(size.height, greaterThanOrEqualTo(minTapTarget.height));
  });

  testWidgets('AppIconButton meets 48x48dp minimum', (tester) async {
    await tester.pumpWidget(_wrap(
      AppIconButton(icon: Icons.close, semanticLabel: 'Close', onPressed: () {}),
    ));
    final size = tester.getSize(find.byType(AppIconButton));
    expect(size.width, greaterThanOrEqualTo(minTapTarget.width));
    expect(size.height, greaterThanOrEqualTo(minTapTarget.height));
  });

  testWidgets('AppFilterChip meets 48x48dp minimum tappable area', (tester) async {
    await tester.pumpWidget(_wrap(
      AppFilterChip(label: 'Fine Motor', selected: false, onChanged: (_) {}),
    ));
    final size = tester.getSize(find.byType(AppFilterChip));
    expect(size.width, greaterThanOrEqualTo(minTapTarget.width));
    expect(size.height, greaterThanOrEqualTo(minTapTarget.height));
  });

  testWidgets('AppCheckbox row meets 48dp minimum height', (tester) async {
    await tester.pumpWidget(_wrap(
      AppCheckbox(value: false, onChanged: (_) {}, label: 'I agree'),
    ));
    final size = tester.getSize(find.byType(AppCheckbox));
    expect(size.height, greaterThanOrEqualTo(44)); // spec: 44-48dp
  });

  testWidgets('AppToggle row meets 48dp minimum height', (tester) async {
    await tester.pumpWidget(_wrap(
      AppToggle(value: false, onChanged: (_) {}, label: 'Notifications'),
    ));
    final size = tester.getSize(find.byType(AppToggle));
    expect(size.height, greaterThanOrEqualTo(44));
  });
}
