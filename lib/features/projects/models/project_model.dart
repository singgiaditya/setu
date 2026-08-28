import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final String remotePath;
  final DateTime? lastOpened;
  final bool isFavorite;

  const ProjectModel({
    required this.id,
    required this.name,
    this.emoji = '📁',
    required this.remotePath,
    this.lastOpened,
    this.isFavorite = false,
  });

  ProjectModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? remotePath,
    DateTime? lastOpened,
    bool? isFavorite,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      remotePath: remotePath ?? this.remotePath,
      lastOpened: lastOpened ?? this.lastOpened,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'remotePath': remotePath,
        'lastOpened': lastOpened?.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📁',
      remotePath: json['remotePath'] as String? ?? '',
      lastOpened: json['lastOpened'] != null
          ? DateTime.tryParse(json['lastOpened'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        emoji,
        remotePath,
        lastOpened,
        isFavorite,
      ];
}
