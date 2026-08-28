import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/preferences_store.dart';
import 'providers/storage_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesStore = await PreferencesStore.init();

  runApp(
    ProviderScope(
      overrides: [
        preferencesStoreProvider.overrideWithValue(preferencesStore),
      ],
      child: const SetuApp(),
    ),
  );
}
