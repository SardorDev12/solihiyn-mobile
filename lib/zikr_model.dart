class Zikr {
  String title;
  int count;
  int limit;
  String category;
  bool isFavourite;
  bool isDone;

  Zikr({required this.title, this.count = 0, this.limit = 100, required this.category, this.isFavourite = false, this.isDone = false});
  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      title: json['title'],
      count: json['count'],
      limit: json['limit'],
      category: json['category'],
      isFavourite: json['isFavourite'],
      isDone: json['isDone'] ?? false,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'count': count,
      'limit': limit,
      'category': category,
      'isFavourite': isFavourite,
      'isDone': isDone,
    };
  }
}
