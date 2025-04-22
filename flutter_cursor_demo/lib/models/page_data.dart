class PageData<T> {
  final int curPage;
  final int offset;
  final bool over;
  final int pageCount;
  final int size;
  final int total;
  final List<T> datas;
  
  PageData({
    required this.curPage,
    required this.offset,
    required this.over,
    required this.pageCount,
    required this.size,
    required this.total,
    required this.datas,
  });
  
  factory PageData.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    List<T> datasList = [];
    if (json['datas'] != null) {
      datasList = (json['datas'] as List)
          .map((i) => fromJsonT(i as Map<String, dynamic>))
          .toList();
    }
    
    return PageData<T>(
      curPage: json['curPage'] ?? 1,
      offset: json['offset'] ?? 0,
      over: json['over'] ?? false,
      pageCount: json['pageCount'] ?? 0,
      size: json['size'] ?? 0,
      total: json['total'] ?? 0,
      datas: datasList,
    );
  }
  
  PageData<T> copyWith({
    int? curPage,
    int? offset,
    bool? over,
    int? pageCount,
    int? size,
    int? total,
    List<T>? datas,
    List<T>? appendDatas,
  }) {
    List<T> newDatas = datas ?? this.datas;
    if (appendDatas != null) {
      newDatas = [...this.datas, ...appendDatas];
    }
    
    return PageData<T>(
      curPage: curPage ?? this.curPage,
      offset: offset ?? this.offset,
      over: over ?? this.over,
      pageCount: pageCount ?? this.pageCount,
      size: size ?? this.size,
      total: total ?? this.total,
      datas: newDatas,
    );
  }
} 