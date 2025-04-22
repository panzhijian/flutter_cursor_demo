class Tree {
  final int id;
  final String name;
  final int courseId;
  final int parentChapterId;
  final bool userControlSetTop;
  final int order;
  final int visible;
  final List<Tree> children;
  
  Tree({
    required this.id,
    required this.name,
    this.courseId = 0,
    this.parentChapterId = 0,
    this.userControlSetTop = false,
    this.order = 0,
    this.visible = 1,
    this.children = const [],
  });
  
  factory Tree.fromJson(Map<String, dynamic> json) {
    List<Tree> childrenList = [];
    if (json['children'] != null) {
      childrenList = (json['children'] as List)
          .map((i) => Tree.fromJson(i))
          .toList();
    }
    
    return Tree(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      courseId: json['courseId'] ?? 0,
      parentChapterId: json['parentChapterId'] ?? 0,
      userControlSetTop: json['userControlSetTop'] ?? false,
      order: json['order'] ?? 0,
      visible: json['visible'] ?? 1,
      children: childrenList,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courseId': courseId,
      'parentChapterId': parentChapterId,
      'userControlSetTop': userControlSetTop,
      'order': order,
      'visible': visible,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
} 