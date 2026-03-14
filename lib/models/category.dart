import 'package:flutter/material.dart';

/// 分类模型 - 纯数据类
class Category {
  int? id;
  final String name;
  final int? color;
  final String? icon;
  final DateTime? createdAt;

  Category({
    this.id,
    required this.name,
    this.color,
    this.icon,
    this.createdAt,
  });

  /// 从 Map 创建分类
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as int?,
      icon: map['icon'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  /// 复制并修改分类
  Category copyWith({
    int? id,
    String? name,
    int? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 获取颜色
  Color get colorValue {
    if (color == null) return Colors.blue;
    return Color(color!);
  }

  /// 获取图标
  IconData get iconData {
    switch (icon) {
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'shopping':
        return Icons.shopping_cart;
      case 'fitness':
        return Icons.fitness_center;
      case 'music':
        return Icons.music_note;
      default:
        return Icons.label;
    }
  }
}
