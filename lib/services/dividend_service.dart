import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dividend.dart';

class DividendService {
  final Dio _dio = Dio();
  final _firestore = FirebaseFirestore.instance;
  final String yahooBaseUrl =
      'https://query2.finance.yahoo.com/v8/finance/chart';
  final String krxBaseUrl =
      'http://data.krx.co.kr/comm/bldAttendant/getJsonData.cmd';

  // Yahoo Finance API를 통한 배당금 데이터 수집
  Future<List<Dividend>> fetchYahooDividends(String symbol) async {
    try {
      final response = await _dio.get(
        '$yahooBaseUrl/$symbol',
        queryParameters: {
          'range': '1y',
          'interval': '1mo',
          'events': 'div',
        },
      );

      if (response.statusCode == 200 &&
          response.data['chart']['result'] != null &&
          response.data['chart']['result'][0]['events']?['dividends'] != null) {
        final dividends =
            response.data['chart']['result'][0]['events']['dividends'] as Map;
        final List<Dividend> results = [];

        for (var div in dividends.values) {
          results.add(Dividend(
            symbol: symbol,
            amount: (div['amount'] as num).toDouble(),
            currency: 'USD', // Yahoo Finance는 대부분 USD
            exDate: DateTime.fromMillisecondsSinceEpoch(div['date'] * 1000),
            payDate: DateTime.fromMillisecondsSinceEpoch(
                div['date'] * 1000), // 정확한 지급일은 별도로 조회 필요
            frequency: _determineDividendFrequency(dividends.length),
            dividendYield: 0.0, // 수익률은 현재 주가 기준으로 별도 계산 필요
          ));
        }

        return results;
      }
      return [];
    } catch (e) {
      print('Error fetching Yahoo dividends: $e');
      return [];
    }
  }

  // KRX API를 통한 배당금 데이터 수집
  Future<List<Dividend>> fetchKrxDividends(String symbol) async {
    try {
      final response = await _dio.post(
        krxBaseUrl,
        data: {
          'bld': 'dbms/MDC/STAT/standard/MDCSTAT03901',
          'locale': 'ko_KR',
          'searchType': '1',
          'mktId': 'ALL',
          'trdDd': DateTime.now().toString().split(' ')[0].replaceAll('-', ''),
          'isuCd': symbol,
        },
      );

      if (response.statusCode == 200 && response.data['output'] != null) {
        final dividends = response.data['output'] as List;
        return dividends
            .map((div) => Dividend(
                  symbol: symbol,
                  amount: double.parse(div['dvdAmt']),
                  currency: 'KRW',
                  exDate: DateTime.parse(div['exDvdDd']),
                  payDate: DateTime.parse(div['dvdPayDd']),
                  frequency: 'annual', // KRX는 대부분 연 1회
                  dividendYield: double.parse(div['dvdYld']),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching KRX dividends: $e');
      return [];
    }
  }

  // 배당금 데이터를 Firestore에 저장
  Future<void> saveDividendData(List<Dividend> dividends) async {
    final batch = _firestore.batch();

    for (var dividend in dividends) {
      final docRef = _firestore
          .collection('dividends')
          .doc('${dividend.symbol}_${dividend.exDate.millisecondsSinceEpoch}');
      batch.set(docRef, dividend.toJson());
    }

    await batch.commit();
  }

  // 배당 주기 결정
  String _determineDividendFrequency(int dividendCount) {
    if (dividendCount >= 12) return 'monthly';
    if (dividendCount >= 4) return 'quarterly';
    if (dividendCount >= 2) return 'semi-annual';
    return 'annual';
  }

  // 특정 종목의 최근 배당금 데이터 조회
  Future<List<Dividend>> getRecentDividends(String symbol) async {
    try {
      final snapshot = await _firestore
          .collection('dividends')
          .where('symbol', isEqualTo: symbol)
          .orderBy('exDate', descending: true)
          .limit(4)
          .get();

      return snapshot.docs.map((doc) => Dividend.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting recent dividends: $e');
      return [];
    }
  }
}
