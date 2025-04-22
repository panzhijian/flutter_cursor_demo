class BannerItem {
  final int? id;
  final String? title;
  final String? desc;
  final String? imagePath;
  final String? url;
  final int? isVisible;
  final int? order;
  final int? type;
  
  BannerItem({
    this.id,
    this.title,
    this.desc,
    this.imagePath,
    this.url,
    this.isVisible,
    this.order,
    this.type,
  });
  
  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      title: json['title'],
      desc: json['desc'],
      imagePath: json['imagePath'],
      url: json['url'],
      isVisible: json['isVisible'],
      order: json['order'],
      type: json['type'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'imagePath': imagePath,
      'url': url,
      'isVisible': isVisible,
      'order': order,
      'type': type,
    };
  }
} 