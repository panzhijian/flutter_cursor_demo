class Article {
  final int? id;
  final String? title;
  final String? author;
  final String? link;
  final String? niceDate;
  final String? desc;
  final String? shareUser;
  bool collect;
  final String? chapterName;
  final String? superChapterName;
  final List<Tag> tags;
  final int? originId;
  
  Article({
    this.id,
    this.title,
    this.author,
    this.link,
    this.niceDate,
    this.desc,
    this.shareUser,
    this.collect = false,
    this.chapterName,
    this.superChapterName,
    this.tags = const [],
    this.originId,
  });
  
  factory Article.fromJson(Map<String, dynamic> json) {
    List<Tag> tagList = [];
    if (json['tags'] != null) {
      tagList = (json['tags'] as List).map((i) => Tag.fromJson(i)).toList();
    }
    
    return Article(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      link: json['link'],
      niceDate: json['niceDate'],
      desc: json['desc'],
      shareUser: json['shareUser'],
      collect: json['collect'] ?? false,
      chapterName: json['chapterName'],
      superChapterName: json['superChapterName'],
      tags: tagList,
      originId: json['originId'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'link': link,
      'niceDate': niceDate,
      'desc': desc,
      'shareUser': shareUser,
      'collect': collect,
      'chapterName': chapterName,
      'superChapterName': superChapterName,
      'tags': tags.map((e) => e.toJson()).toList(),
      'originId': originId,
    };
  }
  
  Article copyWith({
    int? id,
    String? title,
    String? author,
    String? link,
    String? niceDate,
    String? desc,
    String? shareUser,
    bool? collect,
    String? chapterName,
    String? superChapterName,
    List<Tag>? tags,
    int? originId,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      link: link ?? this.link,
      niceDate: niceDate ?? this.niceDate,
      desc: desc ?? this.desc,
      shareUser: shareUser ?? this.shareUser,
      collect: collect ?? this.collect,
      chapterName: chapterName ?? this.chapterName,
      superChapterName: superChapterName ?? this.superChapterName,
      tags: tags ?? this.tags,
      originId: originId ?? this.originId,
    );
  }
  
  @override
  String toString() {
    return 'Article{id: $id, title: $title, author: $author}';
  }
}

class Tag {
  final String? name;
  final String? url;
  
  Tag({this.name, this.url});
  
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'],
      url: json['url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
} 