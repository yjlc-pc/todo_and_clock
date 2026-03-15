class Category {
  int? id;
  String name;
  String? icon; // 图标名称或路径
  String? color; // 分类颜色

  Category({
    this.id,
    required this.name,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
    );
  }
}