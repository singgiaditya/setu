import 'package:equatable/equatable.dart';
import '../theme_colors.dart';

class CustomThemeModel extends Equatable {
  final String id;
  final String name;
  final SetuColors colors;
  final bool isDark;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomThemeModel({
    required this.id,
    required this.name,
    required this.colors,
    this.isDark = true,
    required this.createdAt,
    required this.updatedAt,
  });

  CustomThemeModel copyWith({
    String? id,
    String? name,
    SetuColors? colors,
    bool? isDark,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomThemeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colors: colors ?? this.colors,
      isDark: isDark ?? this.isDark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CustomThemeModel.fromJson(Map<String, dynamic> json) {
    return CustomThemeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colors: SetuColors.fromJson(json['colors'] as Map<String, dynamic>),
      isDark: json['isDark'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colors': colors.toJson(),
    'isDark': isDark,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, colors, isDark, createdAt, updatedAt];
}
