import 'package:flutter/material.dart';
import '../models/portfolio_item.dart';
import '../services/portfolio_service.dart';

class PortfolioEditView extends StatefulWidget {
  final PortfolioItem item;
  const PortfolioEditView({super.key, required this.item});

  @override
  State<PortfolioEditView> createState() => _PortfolioEditViewState();
}

class _PortfolioEditViewState extends State<PortfolioEditView> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _captionCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _yearCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _captionCtrl = TextEditingController(text: widget.item.caption);
    _tagsCtrl = TextEditingController(text: widget.item.tags.join(', '));
    _yearCtrl = TextEditingController(text: widget.item.year.toString());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _captionCtrl.dispose();
    _tagsCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final items = await PortfolioService.loadPortfolio();
    final idx = items.indexWhere((e) => e.id == widget.item.id);
    if (idx >= 0) {
      final tags = _tagsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final year = int.tryParse(_yearCtrl.text.trim()) ?? widget.item.year;
      final updated = PortfolioItem(
        id: widget.item.id,
        title: _titleCtrl.text.trim().isEmpty ? widget.item.title : _titleCtrl.text.trim(),
        caption: _captionCtrl.text.trim(),
        media: widget.item.media,
        tags: tags,
        year: year,
      );
      items[idx] = updated;
      await PortfolioService.savePortfolio(items);
      if (mounted) {
        Navigator.pop(context, updated);
      }
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('編集'),
        actions: [
          TextButton(
            onPressed: _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('タイトル', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            _Field(controller: _titleCtrl, hint: 'タイトル'),
            const SizedBox(height: 20),
            const Text('キャプション', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            _Field(controller: _captionCtrl, hint: 'キャプション', maxLines: 5),
            const SizedBox(height: 20),
            const Text('タグ（カンマ区切り）', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            _Field(controller: _tagsCtrl, hint: '例: 映像, 可視化, シミュレーション'),
            const SizedBox(height: 20),
            const Text('年（西暦）', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            _Field(controller: _yearCtrl, hint: '2025', keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  const _Field({required this.controller, required this.hint, this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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


