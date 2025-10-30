import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/portfolio_item.dart';

class PortfolioService {
  static const String _documentsJsonName = 'portfolio.json';

  // 読み込み優先度: Documents配下の編集済みJSON -> 同梱assets
  static Future<List<PortfolioItem>> loadPortfolio() async {
    try {
      final file = await _getDocumentsJsonFile();
      String jsonString;
      if (await file.exists()) {
        jsonString = await file.readAsString();
      } else {
        // 初回はassetsからコピーしてDocumentsへ保存
        jsonString = await rootBundle.loadString('assets/portfolio.json');
        await file.writeAsString(jsonString, flush: true);
      }
      List<dynamic>? jsonList;
      try {
        jsonList = json.decode(jsonString) as List<dynamic>;
      } catch (_) {
        jsonList = null;
      }

      // 0件やパース失敗時はassetsから再シード
      if (jsonList == null || jsonList.isEmpty) {
        final assetsJson = await rootBundle.loadString('assets/portfolio.json');
        await file.writeAsString(assetsJson, flush: true);
        jsonList = json.decode(assetsJson) as List<dynamic>;
      }

      return jsonList
          .map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading portfolio: $e');
      return [];
    }
  }

  static Future<void> savePortfolio(List<PortfolioItem> items) async {
    final file = await _getDocumentsJsonFile();
    final data = json.encode(items.map((e) => e.toJson()).toList());
    await file.writeAsString(data, flush: true);
  }

  // assetsのJSONでDocumentsのJSONを上書き（初期状態へリセット）
  static Future<void> resetToAssets() async {
    final file = await _getDocumentsJsonFile();
    final assetsJson = await rootBundle.loadString('assets/portfolio.json');
    await file.writeAsString(assetsJson, flush: true);
  }

  static Future<void> deleteMediaFileIfLocal(String path) async {
    try {
      if (path.startsWith('/')) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
  }

  static Future<String> documentsRoot() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> _getDocumentsJsonFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_documentsJsonName');
  }
}

