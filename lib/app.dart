import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_manager.dart';
import 'shared/router/app_router.dart';

class SetuApp extends ConsumerWidget {
  const SetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'On|Bed',
      theme: themeState.themeData,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
