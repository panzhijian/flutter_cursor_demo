class HotKeyword {
  final int id;
  final String name;
  final int order;
  final int visible;
  
  HotKeyword({
    required this.id,
    required this.name,
    required this.order,
    required this.visible,
  });
  
  factory HotKeyword.fromJson(Map<String, dynamic> json) {
    return HotKeyword(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      visible: json['visible'] ?? 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'visible': visible,
    };
  }
} 