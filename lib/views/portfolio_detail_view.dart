import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/portfolio_item.dart';
import 'fullscreen_video_view.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/${widget.item.video}');
      await _controller!.initialize();
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
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
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: AspectRatio(
                                      aspectRatio: _controller!.value.aspectRatio,
                                      child: VideoPlayer(_controller!),
                                    ),
                                  ),
                                ),
                                // 全画面ボタン
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: _enterFullScreen,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                ),
                                // 再生/一時停止ボタン
                                if (!_controller!.value.isPlaying)
                                  Center(
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.play_circle_fill,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _controller!.play();
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
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
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
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
}
