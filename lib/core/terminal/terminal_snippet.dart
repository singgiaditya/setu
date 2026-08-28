import 'package:equatable/equatable.dart';

class TerminalSnippet extends Equatable {
  final String id;
  final String title;
  final String command;
  final String category;
  final bool autoExecute;
  final DateTime createdAt;

  const TerminalSnippet({
    required this.id,
    required this.title,
    required this.command,
    this.category = 'General',
    this.autoExecute = true,
    required this.createdAt,
  });

  TerminalSnippet copyWith({
    String? id,
    String? title,
    String? command,
    String? category,
    bool? autoExecute,
    DateTime? createdAt,
  }) {
    return TerminalSnippet(
      id: id ?? this.id,
      title: title ?? this.title,
      command: command ?? this.command,
      category: category ?? this.category,
      autoExecute: autoExecute ?? this.autoExecute,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'command': command,
      'category': category,
      'autoExecute': autoExecute,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TerminalSnippet.fromJson(Map<String, dynamic> json) {
    return TerminalSnippet(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      command: json['command'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      autoExecute: json['autoExecute'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, title, command, category, autoExecute, createdAt];

  static List<TerminalSnippet> get defaultSnippets => [
        TerminalSnippet(
          id: 'preset_git_status',
          title: 'Git Status',
          command: 'git status',
          category: 'Git',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_git_log',
          title: 'Git Log (10)',
          command: 'git log --oneline -n 10',
          category: 'Git',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_git_diff',
          title: 'Git Diff',
          command: 'git diff',
          category: 'Git',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_docker_ps',
          title: 'Docker PS',
          command: 'docker ps -a',
          category: 'Docker',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_docker_stats',
          title: 'Docker Stats',
          command: 'docker stats --no-stream',
          category: 'Docker',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_system_top',
          title: 'System Monitor',
          command: 'htop || top',
          category: 'System',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_system_df',
          title: 'Disk Free',
          command: 'df -h',
          category: 'System',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_system_mem',
          title: 'Memory Usage',
          command: 'free -h',
          category: 'System',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_system_ports',
          title: 'Open Ports',
          command: 'ss -tulpn',
          category: 'System',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        TerminalSnippet(
          id: 'preset_tmux_ls',
          title: 'Tmux Sessions',
          command: 'tmux ls',
          category: 'Tmux',
          autoExecute: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
}
