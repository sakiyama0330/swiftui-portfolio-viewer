class PortfolioItem {
  final String id;
  final String title;
  final String caption;
  final String thumbnail;
  final String video;
  final List<String> tags;
  final int year;

  PortfolioItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.thumbnail,
    required this.video,
    required this.tags,
    required this.year,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'] as String,
      title: json['title'] as String,
      caption: json['caption'] as String,
      thumbnail: json['thumbnail'] as String,
      video: json['video'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e.toString()).toList(),
      year: json['year'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'caption': caption,
      'thumbnail': thumbnail,
      'video': video,
      'tags': tags,
      'year': year,
    };
  }
}

