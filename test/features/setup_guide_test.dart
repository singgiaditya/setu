import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:setu/features/guide/data/setup_guide_data.dart';
import 'package:setu/features/guide/models/setup_guide_step.dart';
import 'package:setu/features/guide/setup_guide_screen.dart';

void main() {
  group('Setup Guide Data Tests', () {
    test('SetupGuideData contains valid steps across all categories', () {
      expect(SetupGuideData.steps, isNotEmpty);
      expect(SetupGuideData.faqs, isNotEmpty);

      // Verify essential categories exist
      final categories = SetupGuideData.steps.map((s) => s.category).toSet();
      expect(categories, contains(SetupCategory.quickStart));
      expect(categories, contains(SetupCategory.tailscale));
      expect(categories, contains(SetupCategory.sshAuth));
      expect(categories, contains(SetupCategory.sftpAndTools));

      // Verify OpenSSH install step has distro snippets
      final installStep = SetupGuideData.steps.firstWhere((s) => s.id == 'install_openssh');
      expect(installStep.distroSnippets, isNotNull);
      expect(installStep.distroSnippets!['Arch / Omarchy'], contains('pacman'));
      expect(installStep.distroSnippets!['Ubuntu / Debian'], contains('apt'));
    });
  });

  group('SetupGuideScreen Widget Tests', () {
    testWidgets('Renders SetupGuideScreen with search, categories, and step cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SetupGuideScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Setup Guide'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Quick Start'), findsOneWidget);
      expect(find.text('Install OpenSSH Server'), findsOneWidget);
    });

    testWidgets('Filtering category updates displayed steps', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SetupGuideScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Tailscale VPN category chip
      await tester.tap(find.text('Tailscale VPN'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tailscale'), findsWidgets);
      expect(find.text('Install OpenSSH Server'), findsNothing);
    });
  });
}
