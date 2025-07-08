import 'package:hive_flutter/hive_flutter.dart';
import '../models/portfolio_item.dart';
import '../models/stock.dart';
import '../models/dividend.dart';

class LocalDatabaseService {
  static const String portfolioBoxName = 'portfolio_items';
  static const String stockBoxName = 'stocks';
  static const String dividendBoxName = 'dividends';
  static const String cacheBoxName = 'cache';

  // 박스 참조
  static Box<PortfolioItem>? _portfolioBox;
  static Box<Stock>? _stockBox;
  static Box<Dividend>? _dividendBox;
  static Box? _cacheBox;

  // Getter for boxes
  static Box<PortfolioItem> get portfolioBox {
    if (_portfolioBox == null || !_portfolioBox!.isOpen) {
      throw Exception('Portfolio box is not initialized');
    }
    return _portfolioBox!;
  }

  static Box<Stock> get stockBox {
    if (_stockBox == null || !_stockBox!.isOpen) {
      throw Exception('Stock box is not initialized');
    }
    return _stockBox!;
  }

  static Box<Dividend> get dividendBox {
    if (_dividendBox == null || !_dividendBox!.isOpen) {
      throw Exception('Dividend box is not initialized');
    }
    return _dividendBox!;
  }

  static Box get cacheBox {
    if (_cacheBox == null || !_cacheBox!.isOpen) {
      throw Exception('Cache box is not initialized');
    }
    return _cacheBox!;
  }

  /// Hive 초기화 및 박스 열기
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // TypeAdapter 등록
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PortfolioItemAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(StockAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(DividendAdapter());
      }

      // 박스 열기
      _portfolioBox = await Hive.openBox<PortfolioItem>(portfolioBoxName);
      _stockBox = await Hive.openBox<Stock>(stockBoxName);
      _dividendBox = await Hive.openBox<Dividend>(dividendBoxName);
      _cacheBox = await Hive.openBox(cacheBoxName);
    } catch (e) {
      print('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// 포트폴리오 아이템 저장
  static Future<void> savePortfolioItem(PortfolioItem item) async {
    try {
      final key = item.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      await portfolioBox.put(key, item);
    } catch (e) {
      print('Error saving portfolio item locally: $e');
      rethrow;
    }
  }

  /// 포트폴리오 아이템 목록 가져오기
  static List<PortfolioItem> getPortfolioItems() {
    try {
      return portfolioBox.values.toList();
    } catch (e) {
      print('Error getting portfolio items from local storage: $e');
      return [];
    }
  }

  /// 포트폴리오 아이템 삭제
  static Future<void> deletePortfolioItem(String id) async {
    try {
      await portfolioBox.delete(id);
    } catch (e) {
      print('Error deleting portfolio item locally: $e');
      rethrow;
    }
  }

  /// 주식 정보 저장 (캐시)
  static Future<void> saveStock(Stock stock) async {
    try {
      await stockBox.put(stock.symbol, stock);
    } catch (e) {
      print('Error caching stock locally: $e');
      rethrow;
    }
  }

  /// 주식 정보 가져오기 (캐시에서)
  static Stock? getStock(String symbol) {
    try {
      return stockBox.get(symbol);
    } catch (e) {
      print('Error getting stock from local cache: $e');
      return null;
    }
  }

  /// 배당금 정보 저장
  static Future<void> saveDividend(String symbol, Dividend dividend) async {
    try {
      await dividendBox.put(symbol, dividend);
    } catch (e) {
      print('Error saving dividend locally: $e');
      rethrow;
    }
  }

  /// 배당금 정보 가져오기
  static Dividend? getDividend(String symbol) {
    try {
      return dividendBox.get(symbol);
    } catch (e) {
      print('Error getting dividend from local storage: $e');
      return null;
    }
  }

  /// 캐시 저장 (일반적인 키-값 쌍)
  static Future<void> setCache(String key, dynamic value) async {
    try {
      await cacheBox.put(key, value);
    } catch (e) {
      print('Error setting cache: $e');
      rethrow;
    }
  }

  /// 캐시 가져오기
  static T? getCache<T>(String key) {
    try {
      return cacheBox.get(key) as T?;
    } catch (e) {
      print('Error getting cache: $e');
      return null;
    }
  }

  /// 모든 로컬 데이터 삭제
  static Future<void> clearAll() async {
    try {
      await portfolioBox.clear();
      await stockBox.clear();
      await dividendBox.clear();
      await cacheBox.clear();
    } catch (e) {
      print('Error clearing local data: $e');
      rethrow;
    }
  }

  /// 동기화 상태 저장
  static Future<void> setSyncTimestamp(String key) async {
    try {
      await setCache('sync_$key', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error setting sync timestamp: $e');
      rethrow;
    }
  }

  /// 동기화 상태 확인
  static bool needsSync(String key,
      {Duration maxAge = const Duration(hours: 1)}) {
    try {
      final timestamp = getCache<int>('sync_$key');
      if (timestamp == null) return true;

      final lastSync = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(lastSync) > maxAge;
    } catch (e) {
      print('Error checking sync status: $e');
      return true;
    }
  }

  /// 메모리 최적화를 위한 리소스 정리
  static Future<void> dispose() async {
    try {
      await _portfolioBox?.close();
      await _stockBox?.close();
      await _dividendBox?.close();
      await _cacheBox?.close();

      // 박스 참조 제거로 메모리 절약
      _portfolioBox = null;
      _stockBox = null;
      _dividendBox = null;
      _cacheBox = null;
    } catch (e) {
      print('Error closing Hive boxes: $e');
    }
  }

  /// 메모리 사용량 최적화를 위한 데이터베이스 압축
  static Future<void> compactDatabase() async {
    try {
      if (_portfolioBox?.isOpen == true) await _portfolioBox!.compact();
      if (_stockBox?.isOpen == true) await _stockBox!.compact();
      if (_dividendBox?.isOpen == true) await _dividendBox!.compact();
      if (_cacheBox?.isOpen == true) await _cacheBox!.compact();
    } catch (e) {
      print('Error compacting database: $e');
    }
  }
}
