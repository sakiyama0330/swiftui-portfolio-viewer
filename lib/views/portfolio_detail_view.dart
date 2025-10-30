import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import '../models/portfolio_item.dart';
import 'fullscreen_video_view.dart';
import 'portfolio_edit_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/portfolio_service.dart';
import 'package:path_provider/path_provider.dart';

class PortfolioDetailView extends StatefulWidget {
  final PortfolioItem item;

  const PortfolioDetailView({
    super.key,
    required this.item,
  });

  @override
  State<PortfolioDetailView> createState() => _PortfolioDetailViewState();
}

class _PortfolioDetailViewState extends State<PortfolioDetailView> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  int _currentIndex = 0; // 表示中メディア

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // 現在インデックスのメディアが動画の場合のみ初期化
      final current = widget.item.media.isNotEmpty ? widget.item.media[_currentIndex] : null;
      if (current == null || current.kind != MediaKind.video) {
        return;
      }
      final path = current.path;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else if (path.startsWith('assets/')) {
        _controller = VideoPlayerController.asset('assets/${path.substring('assets/'.length)}');
      } else if (path.startsWith('/')) {
        _controller = VideoPlayerController.file(File(path));
      } else {
        // assets直下指定（拡張子は問わない: .mp4 .mov .m4v .webm 等）
        _controller = VideoPlayerController.asset('assets/$path');
      }
      await _controller!.initialize();
      await _controller!.setLooping(true);
      _controller!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error loading video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _enterFullScreen() {
    if (_controller != null && _isInitialized) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoView(controller: _controller!),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _onAddMedia,
            icon: const Icon(Icons.add_circle_outline),
          ),
          if (widget.item.media.isNotEmpty)
            IconButton(
              onPressed: _onDeleteCurrentMedia,
              icon: const Icon(Icons.delete_outline),
            ),
          IconButton(
            onPressed: _onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // メディアギャラリー（画像/動画）
              if (widget.item.media.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PageView.builder(
                      onPageChanged: (i) async {
                        setState(() {
                          _currentIndex = i;
                          _isInitialized = false;
                          _hasError = false;
                        });
                        await _controller?.pause();
                        await _controller?.dispose();
                        _controller = null;
                        await _initializeVideo();
                      },
                      itemCount: widget.item.media.length,
                      itemBuilder: (context, index) {
                        final m = widget.item.media[index];
                        if (m.kind == MediaKind.image) {
                          final isAsset = m.path.startsWith('images/') || m.path.startsWith('assets/');
                          if (isAsset) {
                            final assetPath = m.path.startsWith('assets/') ? m.path : 'assets/${m.path}';
                            return Image.asset(assetPath, fit: BoxFit.cover);
                          } else {
                            return Image.file(File(m.path), fit: BoxFit.cover);
                          }
                        } else {
                          // video
                          return Container(
                            color: Colors.black,
                            child: _hasError
                                ? _buildErrorPlaceholder()
                                : _isInitialized && _controller != null
                                    ? Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_controller!.value.isPlaying) {
                                                  _controller!.pause();
                                                } else {
                                                  _controller!.play();
                                                }
                                              });
                                            },
                                            child: AspectRatio(
                                              aspectRatio: _controller!.value.aspectRatio,
                                              child: VideoPlayer(_controller!),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            right: 12,
                                            child: IconButton(
                                              icon: const Icon(Icons.fullscreen, color: Colors.white, size: 28),
                                              onPressed: _enterFullScreen,
                                            ),
                                          ),
                                          // タイムライン（シーク可能）
                                          Positioned(
                                            left: 12,
                                            right: 12,
                                            bottom: 0,
                                            child: VideoProgressIndicator(
                                              _controller!,
                                              allowScrubbing: true,
                                              colors: VideoProgressColors(
                                                playedColor: Colors.white,
                                                bufferedColor: Colors.white24,
                                                backgroundColor: Colors.white10,
                                              ),
                                            ),
                                          ),
                                          if (!_controller!.value.isPlaying)
                                            Center(
                                              child: IconButton(
                                                icon: const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
                                                onPressed: () {
                                                  setState(() {
                                                    _controller!.play();
                                                  });
                                                },
                                              ),
                                            ),
                                        ],
                                      )
                                    : const Center(child: CircularProgressIndicator(color: Colors.white)),
                          );
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              // Title and Year
              Text(
                widget.item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300, // ヘッダーに合わせる
                  letterSpacing: 2,            // ヘッダーに合わせる
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.year.toString(),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 1,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 32),
              // Caption
              Text(
                widget.item.caption,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  height: 1.7,
                ),
              ),
              // Tags
              if (widget.item.tags.isNotEmpty) ...[
                const SizedBox(height: 32),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.item.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.play_circle_fill,
          size: 60,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 12),
        Text(
          '映像の読み込みに失敗しました',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _onAddMedia() async {
    // ユーザーに選択させる（画像 or 動画）
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo, color: Colors.white),
            title: const Text('写真を追加', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, 'image'),
          ),
          ListTile(
            leading: const Icon(Icons.movie, color: Colors.white),
            title: const Text('動画を追加', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, 'video'),
          ),
        ]),
      ),
    );
    if (action == null) return;

    String? savedPath;
    MediaAsset? newAsset;
    if (action == 'image') {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        savedPath = await _savePickedFile(File(picked.path), 'images');
        if (savedPath != null) {
          newAsset = MediaAsset(kind: MediaKind.image, path: savedPath);
        }
      }
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result != null && result.files.single.path != null) {
        savedPath = await _savePickedFile(File(result.files.single.path!), 'videos');
        if (savedPath != null) {
          newAsset = MediaAsset(kind: MediaKind.video, path: savedPath);
        }
      }
    }

    if (newAsset == null) return;

    // 不変リストを壊さないようにコピーして追加
    final updatedMedia = List<MediaAsset>.from(widget.item.media)..add(newAsset);
    final items = await PortfolioService.loadPortfolio();
    final idx = items.indexWhere((e) => e.id == widget.item.id);
    if (idx >= 0) {
      final newItem = PortfolioItem(
        id: widget.item.id,
        title: widget.item.title,
        caption: widget.item.caption,
        media: updatedMedia,
        tags: widget.item.tags,
        year: widget.item.year,
      );
      items[idx] = newItem;
      await PortfolioService.savePortfolio(items);
      if (mounted) {
        // 追加後は新しいアイテムで画面を再オープン
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PortfolioDetailView(item: newItem)),
        );
      }
    }
  }

  Future<String?> _savePickedFile(File src, String folder) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${dir.path}/$folder');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }
      final fileName = src.path.split('/').last;
      final dest = File('${mediaDir.path}/$fileName');
      await src.copy(dest.path);
      return dest.path; // 絶対パスで保存
    } catch (e) {
      print('Save picked file error: $e');
      return null;
    }
  }

  Future<void> _onEdit() async {
    final updated = await Navigator.push<PortfolioItem>(
      context,
      MaterialPageRoute(builder: (_) => PortfolioEditView(item: widget.item)),
    );
    if (updated != null && mounted) {
      setState(() {
        // widget.itemはfinalなので、再描画用に参照を更新するために新インスタンスを渡す画面遷移が理想だが
        // この画面では読み取り用途のため一時的にフィールドを置き換える
      });
      // 再読み込み
      final items = await PortfolioService.loadPortfolio();
      final refreshed = items.firstWhere((e) => e.id == updated.id, orElse: () => updated);
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PortfolioDetailView(item: refreshed)),
        );
      }
    }
  }

  Future<void> _onDeleteCurrentMedia() async {
    if (widget.item.media.isEmpty) return;
    final target = widget.item.media[_currentIndex];
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('メディアを削除', style: TextStyle(color: Colors.white)),
        content: const Text('このメディアを削除しますか？ローカルに保存されたファイルも削除されます。', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('削除')),
        ],
      ),
    );
    if (ok != true) return;
    await _controller?.pause();
    await _controller?.dispose();
    _controller = null;
    await PortfolioService.deleteMediaFileIfLocal(target.path);
    final updatedMedia = List<MediaAsset>.from(widget.item.media)..removeAt(_currentIndex);
    final items = await PortfolioService.loadPortfolio();
    final idx = items.indexWhere((e) => e.id == widget.item.id);
    if (idx >= 0) {
      final newItem = PortfolioItem(
        id: widget.item.id,
        title: widget.item.title,
        caption: widget.item.caption,
        media: updatedMedia,
        tags: widget.item.tags,
        year: widget.item.year,
      );
      items[idx] = newItem;
      await PortfolioService.savePortfolio(items);
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PortfolioDetailView(item: newItem)),
        );
      }
    }
  }
}
