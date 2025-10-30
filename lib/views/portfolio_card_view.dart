import 'dart:io';
import 'package:flutter/material.dart';
import '../models/portfolio_item.dart';

class PortfolioCardView extends StatelessWidget {
  final PortfolioItem item;

  const PortfolioCardView({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[900],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildThumbnail(),
            ),
          ),
          // Title and Year
          Padding(
            padding: Localizations.localeOf(context).languageCode == 'ja'
                ? const EdgeInsets.fromLTRB(16, 16, 16, 20)
                : const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.15,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  item.year.toString(),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    // 最初の画像メディア、なければ動画のサムネ代替
    final imageMedia = item.media.firstWhere(
      (m) => m.kind == MediaKind.image,
      orElse: () => item.media.isNotEmpty ? item.media.first : const MediaAsset(kind: MediaKind.image, path: ''),
    );
    if (imageMedia.path.isEmpty) {
      return Container(color: Colors.grey[800]);
    }
    final path = imageMedia.path;
    if (path.startsWith('images/') || path.startsWith('assets/')) {
      final assetPath = path.startsWith('assets/') ? path : 'assets/$path';
      return Image.asset(assetPath, fit: BoxFit.cover, width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
        return Container(color: Colors.grey[800]);
      });
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: Colors.grey[800]);
      },
    );
  }
}
