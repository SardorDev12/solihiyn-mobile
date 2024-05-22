class Zikr {
  String title;
  int count;
  int limit;
  String category;
  bool isFavourite;
  bool isDone;

  Zikr({required this.title, this.count = 0, required this.limit, this.category = "Daily", this.isFavourite = false, this.isDone = false});
  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      title: json['title'],
      count: json['count'],
      limit: json['limit'],
      category: json['category'],
      isFavourite: json['isFavourite'] ?? false,
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
