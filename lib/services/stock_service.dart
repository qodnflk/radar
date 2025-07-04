import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

class StockService {
  static const String _baseUrl =
      'https://query1.finance.yahoo.com/v8/finance/chart/';

  Future<Stock> getStockInfo(String symbol) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$symbol'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meta = data['chart']['result'][0]['meta'];

        return Stock(
          symbol: symbol,
          name: meta['symbol'], // Yahoo Finance API는 회사명을 직접 제공하지 않음
          exchange: meta['exchangeName'],
          currency: meta['currency'],
        );
      } else {
        throw Exception('Failed to load stock info');
      }
    } catch (e) {
      throw Exception('Error fetching stock info: $e');
    }
  }
}
