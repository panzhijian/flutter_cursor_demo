class Article {
  final int? id;
  final String? title;
  final String? author;
  final String? link;
  final String? niceDate;
  final String? desc;
  final String? shareUser;
  final bool collect;
  final String? chapterName;
  final String? superChapterName;
  final List<Tag> tags;
  
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
    };
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