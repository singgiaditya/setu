import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorScreen extends ConsumerWidget {
  final String? initialFilePath;
  const EditorScreen({super.key, this.initialFilePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(child: Text('Editor Screen: $initialFilePath')),
    );
  }
}
