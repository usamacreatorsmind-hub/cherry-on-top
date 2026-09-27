class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final int order;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.order = 0,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map, String id) {
    return BannerModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'order': order,
    };
  }
}
