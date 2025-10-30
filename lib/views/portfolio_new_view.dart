import 'package:flutter/material.dart';
import '../models/portfolio_item.dart';
import '../services/portfolio_service.dart';

class PortfolioNewView extends StatefulWidget {
  const PortfolioNewView({super.key});

  @override
  State<PortfolioNewView> createState() => _PortfolioNewViewState();
}

class _PortfolioNewViewState extends State<PortfolioNewView> {
  final _titleCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _imagePathCtrl = TextEditingController();
  final _videoPathCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _captionCtrl.dispose();
    _tagsCtrl.dispose();
    _yearCtrl.dispose();
    _imagePathCtrl.dispose();
    _videoPathCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final items = await PortfolioService.loadPortfolio();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final tags = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final year = int.tryParse(_yearCtrl.text.trim()) ?? DateTime.now().year;
    final List<MediaAsset> media = [];
    final img = _imagePathCtrl.text.trim();
    final vid = _videoPathCtrl.text.trim();
    if (img.isNotEmpty) {
      media.add(MediaAsset(kind: MediaKind.image, path: img));
    }
    if (vid.isNotEmpty) {
      media.add(MediaAsset(kind: MediaKind.video, path: vid));
    }
    final newItem = PortfolioItem(
      id: id,
      title: _titleCtrl.text.trim().isEmpty ? 'Untitled' : _titleCtrl.text.trim(),
      caption: _captionCtrl.text.trim(),
      media: media,
      tags: tags,
      year: year,
    );
    items.insert(0, newItem);
    await PortfolioService.savePortfolio(items);
    if (mounted) {
      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('新規作品'),
        actions: [
          TextButton(
            onPressed: _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('追加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('タイトル', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 2)),
            const SizedBox(height: 8),
            _field(_titleCtrl, 'タイトル'),
            const SizedBox(height: 20),
            const Text('キャプション', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 2)),
            const SizedBox(height: 8),
            _field(_captionCtrl, 'キャプション', maxLines: 5),
            const SizedBox(height: 20),
            const Text('画像パス（例: images/HIMG0032.jpg または assets/images/...）', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 2)),
            const SizedBox(height: 8),
            _field(_imagePathCtrl, 'images/HIMG0032.jpg'),
            const SizedBox(height: 20),
            const Text('動画パス（例: videos/001.mov または assets/videos/...）', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 2)),
            const SizedBox(height: 8),
            _field(_videoPathCtrl, 'videos/001.mov'),
            const SizedBox(height: 20),
            const Text('タグ（カンマ区切り）', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 2)),
            const SizedBox(height: 8),
            _field(_tagsCtrl, '例: 映像, 可視化, シミュレーション'),
            const SizedBox(height: 20),
            const Text('年（西暦）', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 2)),
            const SizedBox(height: 8),
            _field(_yearCtrl, '2025', keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}


