import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setu/core/theme/theme_typography.dart';
import 'package:setu/core/theme/themes/dark_theme.dart';
import 'package:setu/features/onboarding/widgets/feature_tour_sheet.dart';

void main() {
  group('FeatureTourSheet Widget Tests', () {
    testWidgets('Renders FeatureTourSheet and allows navigation and skipping', (tester) async {
      bool tourFinished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return FeatureTourSheet(
                  colors: darkThemeColors,
                  typography: SetuTypography(darkThemeColors),
                  onFinish: () => tourFinished = true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check first slide
      expect(find.text('SETU TOUR'), findsOneWidget);
      expect(find.text('1/5'), findsOneWidget);
      expect(find.text('Lewati (Skip)'), findsOneWidget);
      expect(find.text('Workstation Remote SSH'), findsOneWidget);

      // Tap Next button
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('Workspace-Centric Hub'), findsOneWidget);

      // Tap Skip button
      await tester.tap(find.text('Lewati (Skip)'));
      await tester.pumpAndSettle();

      expect(tourFinished, isTrue);
    });
  });
}
