class UserInfo {
  final String? username;
  final int? id;
  final List<String>? chapterTops;
  final List<int>? collectIds;
  final String? email;
  final String? icon;
  final String? nickname;
  final String? password;
  final String? token;
  final int? type;
  
  UserInfo({
    this.username,
    this.id,
    this.chapterTops,
    this.collectIds,
    this.email,
    this.icon,
    this.nickname,
    this.password,
    this.token,
    this.type,
  });
  
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'],
      id: json['id'],
      chapterTops: json['chapterTops'] != null 
          ? List<String>.from(json['chapterTops']) 
          : [],
      collectIds: json['collectIds'] != null 
          ? List<int>.from(json['collectIds']) 
          : [],
      email: json['email'],
      icon: json['icon'],
      nickname: json['nickname'],
      password: json['password'],
      token: json['token'],
      type: json['type'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'id': id,
      'chapterTops': chapterTops,
      'collectIds': collectIds,
      'email': email,
      'icon': icon,
      'nickname': nickname,
      'password': password,
      'token': token,
      'type': type,
    };
  }
  
  @override
  String toString() {
    return 'UserInfo{username: $username, id: $id, email: $email, nickname: $nickname}';
  }
} 