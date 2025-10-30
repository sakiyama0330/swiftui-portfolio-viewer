import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../models/portfolio_item.dart';
import 'portfolio_detail_view.dart';
import 'portfolio_card_view.dart';
import 'portfolio_new_view.dart';
import '../services/portfolio_service.dart';

class PortfolioListView extends StatefulWidget {
  const PortfolioListView({super.key});

  @override
  State<PortfolioListView> createState() => _PortfolioListViewState();
}

class _PortfolioListViewState extends State<PortfolioListView> {
  List<PortfolioItem> _items = [];
  bool _isLoading = true;
  VideoPlayerController? _bgController;
  bool _bgReady = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
    _initBackgroundVideo();
  }

  Future<void> _initBackgroundVideo() async {
    try {
      // 優先: 001_01.mov → 次点: 001_1.mov
      final candidates = <String>[
        'assets/videos/001_01.mov',
        'assets/videos/001_1.mov',
      ];
      VideoPlayerController? created;
      for (final p in candidates) {
        try {
          final c = VideoPlayerController.asset(p);
          await c.initialize();
          created = c;
          break;
        } catch (_) {}
      }
      if (created == null) return;
      _bgController = created;
      await _bgController!.setLooping(true);
      await _bgController!.setVolume(0);
      await _bgController!.play();
      if (mounted) setState(() => _bgReady = true);
    } catch (_) {}
  }

  Future<void> _loadPortfolio() async {
    var items = await PortfolioService.loadPortfolio();
    // 0件や極端に少ない場合は再シードを試みる
    if (items.isEmpty) {
      await PortfolioService.resetToAssets();
      items = await PortfolioService.loadPortfolio();
    }
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset(
            'assets/images/sakiyama_logo_white.jpg',
            width: 24,
            height: 24,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        title: const Text(
          'PORTFOLIO',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'リセット',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => _isLoading = true);
              await PortfolioService.resetToAssets();
              await _loadPortfolio();
            },
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_bgController != null && _bgReady)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _bgController!.value.size.width,
                height: _bgController!.value.size.height,
                child: VideoPlayer(_bgController!),
              ),
            )
          else
            Container(color: Colors.black),
          Container(color: Colors.black.withOpacity(0.35)),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_items.isEmpty)
            const Center(
              child: Text(
                'ポートフォリオが見つかりませんでした',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            Column(
              children: [
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: _items.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex -= 1;
                          setState(() {
                            final item = _items.removeAt(oldIndex);
                            _items.insert(newIndex, item);
                          });
                          await PortfolioService.savePortfolio(_items);
                        },
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Dismissible(
                            key: ValueKey(item.id),
                            background: Container(color: Colors.red),
                            onDismissed: (d) async {
                              setState(() {
                                _items.removeAt(index);
                              });
                              await PortfolioService.savePortfolio(_items);
                            },
                            child: GestureDetector(
                              onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PortfolioDetailView(item: item)),
                              );
                              // 戻ってきたら最新データを再読込（追加/削除を反映）
                              await _loadPortfolio();
                            },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: PortfolioCardView(item: item),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // SNSリンク
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[800]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              final uri = Uri.parse('https://x.com/sakiyama_VRC');
                              try {
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              } catch (e) {
                                // エラーハンドリング
                              }
                            },
                            child: const Text(
                              'X (Twitter)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<PortfolioItem>(
            context,
            MaterialPageRoute(builder: (_) => const PortfolioNewView()),
          );
          if (created != null) {
            setState(() {
              _items.insert(0, created);
            });
            await PortfolioService.savePortfolio(_items);
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  @override
  void dispose() {
    _bgController?.dispose();
    super.dispose();
  }
}
