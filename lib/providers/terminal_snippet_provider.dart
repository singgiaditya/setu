import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/preferences_store.dart';
import '../core/terminal/terminal_snippet.dart';
import 'storage_provider.dart';

class TerminalSnippetsNotifier extends Notifier<List<TerminalSnippet>> {
  @override
  List<TerminalSnippet> build() {
    final prefs = ref.watch(preferencesStoreProvider);
    final saved = prefs.getSavedSnippets();
    if (saved.isEmpty) {
      final defaults = TerminalSnippet.defaultSnippets;
      _persist(prefs, defaults);
      return defaults;
    }
    return saved.map((e) => TerminalSnippet.fromJson(e)).toList();
  }

  Future<void> _persist(PreferencesStore prefs, List<TerminalSnippet> list) async {
    await prefs.saveSnippets(list.map((e) => e.toJson()).toList());
  }

  Future<void> addSnippet(TerminalSnippet snippet) async {
    final prefs = ref.read(preferencesStoreProvider);
    final updated = [...state, snippet];
    state = updated;
    await _persist(prefs, updated);
  }

  Future<void> updateSnippet(TerminalSnippet snippet) async {
    final prefs = ref.read(preferencesStoreProvider);
    final updated = state.map((s) => s.id == snippet.id ? snippet : s).toList();
    state = updated;
    await _persist(prefs, updated);
  }

  Future<void> deleteSnippet(String id) async {
    final prefs = ref.read(preferencesStoreProvider);
    final updated = state.where((s) => s.id != id).toList();
    state = updated;
    await _persist(prefs, updated);
  }

  Future<void> resetToPresets() async {
    final prefs = ref.read(preferencesStoreProvider);
    final defaults = TerminalSnippet.defaultSnippets;
    state = defaults;
    await _persist(prefs, defaults);
  }
}

final terminalSnippetsProvider =
    NotifierProvider<TerminalSnippetsNotifier, List<TerminalSnippet>>(
  TerminalSnippetsNotifier.new,
);

final scopedSnippetsProvider =
    Provider.family<List<TerminalSnippet>, String?>((ref, workspaceId) {
  final allSnippets = ref.watch(terminalSnippetsProvider);
  if (workspaceId == null || workspaceId.isEmpty) {
    return allSnippets.where((s) => s.isGlobal).toList();
  }
  return allSnippets
      .where((s) => s.isGlobal || s.workspaceId == workspaceId)
      .toList();
});

final workspaceOnlySnippetsProvider =
    Provider.family<List<TerminalSnippet>, String>((ref, workspaceId) {
  final allSnippets = ref.watch(terminalSnippetsProvider);
  return allSnippets.where((s) => s.workspaceId == workspaceId).toList();
});

final snippetCategoriesProvider =
    Provider.family<List<String>, String?>((ref, workspaceId) {
  final snippets = ref.watch(scopedSnippetsProvider(workspaceId));
  final categories = <String>{'All'};
  for (final s in snippets) {
    categories.add(s.category);
  }
  return categories.toList();
});
