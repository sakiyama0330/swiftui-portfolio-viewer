enum MediaKind { image, video }

class MediaAsset {
  final MediaKind kind;
  final String path; // assets/ または file パス

  const MediaAsset({required this.kind, required this.path});

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    final kindString = (json['kind'] as String?) ?? 'image';
    return MediaAsset(
      kind: kindString == 'video' ? MediaKind.video : MediaKind.image,
      path: json['path'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind == MediaKind.video ? 'video' : 'image',
        'path': path,
      };
}

class PortfolioItem {
  final String id;
  final String title;
  final String caption;
  final List<MediaAsset> media; // 複数メディア対応
  final List<String> tags;
  final int year;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.media,
    required this.tags,
    required this.year,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    // 後方互換: 旧フィールド(thumbnail, video)をmediaに変換
    final List<dynamic>? mediaJson = json['media'] as List<dynamic>?;
    List<MediaAsset> media = [];
    if (mediaJson != null) {
      media = mediaJson
          .map((e) => MediaAsset.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final thumb = json['thumbnail'] as String?;
      final video = json['video'] as String?;
      if (thumb != null && thumb.isNotEmpty) {
        media.add(MediaAsset(kind: MediaKind.image, path: thumb));
      }
      if (video != null && video.isNotEmpty) {
        media.add(MediaAsset(kind: MediaKind.video, path: video));
      }
    }

    return PortfolioItem(
      id: json['id'] as String,
      title: json['title'] as String,
      caption: json['caption'] as String,
      media: media,
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      year: (json['year'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'caption': caption,
      'media': media.map((m) => m.toJson()).toList(),
      'tags': tags,
      'year': year,
    };
  }
}

