import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu/core/storage/preferences_store.dart';
import 'package:setu/providers/storage_provider.dart';
import 'package:setu/features/onboarding/onboarding_screen.dart';
import 'package:setu/features/onboarding/onboarding_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OnboardingScreen renders first page with On|Bed title and Next button',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesStore.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStoreProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('On|Bed'), findsWidgets);
    expect(find.text('Your Machine, Anywhere.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  test('Onboarding pages data has 3 items', () {
    expect(onboardingPages.length, equals(3));
    expect(onboardingPages[0].title, equals('On|Bed'));
    expect(onboardingPages[1].title, equals('Private by Design'));
    expect(onboardingPages[2].title, equals('Code. Terminal. Files.'));
  });
}
