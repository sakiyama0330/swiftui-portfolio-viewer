import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/portfolio_item.dart';

class PortfolioService {
  static Future<List<PortfolioItem>> loadPortfolio() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/portfolio.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((json) => PortfolioItem.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading portfolio: $e');
      return [];
    }
  }
}

