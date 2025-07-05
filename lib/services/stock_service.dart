import 'package:dio/dio.dart';
import '../models/stock.dart';

class StockService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://query2.finance.yahoo.com/v1/finance';

  Future<List<Stock>> searchStocks(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/search',
        queryParameters: {
          'q': query,
          'quotesCount': 20,
          'lang': 'ko-KR', // 한국어 설정
          'region': 'KR', // 한국 리전 설정
        },
      );

      if (response.statusCode == 200 && response.data['quotes'] != null) {
        final quotes = response.data['quotes'] as List;
        return quotes
            .where((quote) =>
                // EQUITY(주식)와 ETF 모두 포함
                (quote['quoteType'] == 'EQUITY' ||
                    quote['quoteType'] == 'ETF') &&
                quote['symbol'] != null &&
                quote['shortname'] != null)
            .map((quote) => Stock(
                  symbol: quote['symbol'],
                  name: quote['shortname'] ?? '',
                  exchange: quote['exchange'] ?? '',
                  currency: quote['currency'] ?? 'KRW', // 기본 통화를 KRW로 설정
                  currentPrice: 0.0, // 검색 결과에는 가격이 포함되지 않음
                ))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching stocks: $e');
      return [];
    }
  }

  Future<Stock?> getStockDetails(String symbol) async {
    try {
      final response = await _dio.get(
        '$baseUrl/quote',
        queryParameters: {
          'symbols': symbol,
          'lang': 'ko-KR', // 한국어로 상세 정보 요청
        },
      );

      if (response.statusCode == 200 &&
          response.data['quoteResponse']['result'] != null &&
          response.data['quoteResponse']['result'].isNotEmpty) {
        final quote = response.data['quoteResponse']['result'][0];
        return Stock(
          symbol: quote['symbol'],
          name: quote['shortName'] ?? '',
          exchange: quote['fullExchangeName'] ?? '',
          currency: quote['currency'] ?? 'KRW', // 기본 통화를 KRW로 설정
          currentPrice: (quote['regularMarketPrice'] ?? 0.0).toDouble(),
        );
      }
      return null;
    } catch (e) {
      print('Error getting stock details: $e');
      return null;
    }
  }
}
