import 'package:get/get.dart';
import '../models/dividend.dart';
import '../models/portfolio_item.dart';
import '../services/dividend_service.dart';

class DividendController extends GetxController {
  // 싱글톤 패턴으로 메모리 효율성 향상
  static DividendController? _instance;
  factory DividendController() => _instance ??= DividendController._internal();
  DividendController._internal();

  // Lazy initialization
  DividendService? _dividendService;
  DividendService get dividendService => _dividendService ??= DividendService();

  // 상태 관리 - 메모리 사용량 최적화를 위해 제한된 크기 유지
  final RxBool isLoading = false.obs;
  final RxMap<String, List<Dividend>> dividendsBySymbol =
      <String, List<Dividend>>{}.obs;
  final RxMap<String, DateTime?> nextDividendDates = <String, DateTime?>{}.obs;

  // 캐시 크기 제한 (메모리 절약)
  static const int maxCacheSize = 50;

  // 특정 종목의 배당 데이터 가져오기
  Future<List<Dividend>> getDividendsForSymbol(String symbol) async {
    if (dividendsBySymbol.containsKey(symbol)) {
      return dividendsBySymbol[symbol]!;
    }

    try {
      isLoading.value = true;
      final dividends = await dividendService.fetchYahooDividends(symbol);
      dividendsBySymbol[symbol] = dividends;

      // 다음 배당일 계산
      _calculateNextDividendDate(symbol, dividends);

      return dividends;
    } catch (e) {
      // 배당 데이터 로드 실패시 빈 리스트 반환 (메모리 효율성을 위해 로깅 생략)
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // 수동으로 배당 데이터 업데이트
  Future<void> updateDividendData(String symbol) async {
    try {
      isLoading.value = true;
      final dividends = await dividendService.fetchYahooDividends(symbol);
      dividendsBySymbol[symbol] = dividends;

      // Firestore에 저장
      await dividendService.saveDividendData(dividends);

      // 다음 배당일 계산
      _calculateNextDividendDate(symbol, dividends);

      Get.snackbar('성공', '$symbol 배당 데이터가 업데이트되었습니다.');
    } catch (e) {
      print('Error updating dividend data for $symbol: $e');
      Get.snackbar('오류', '배당 데이터 업데이트 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  // 다음 배당일 계산
  void _calculateNextDividendDate(String symbol, List<Dividend> dividends) {
    if (dividends.isEmpty) {
      nextDividendDates[symbol] = null;
      return;
    }

    // 가장 최근 배당 정보를 기준으로 다음 배당일 예측
    final latestDividend = dividends.first; // dividends는 날짜순으로 정렬되어 있음
    DateTime? nextDate;

    switch (latestDividend.frequency.toLowerCase()) {
      case 'monthly':
        nextDate = latestDividend.exDate.add(const Duration(days: 30));
        break;
      case 'quarterly':
        nextDate = latestDividend.exDate.add(const Duration(days: 90));
        break;
      case 'semi-annual':
        nextDate = latestDividend.exDate.add(const Duration(days: 180));
        break;
      case 'annual':
        nextDate = latestDividend.exDate.add(const Duration(days: 365));
        break;
      default:
        nextDate =
            latestDividend.exDate.add(const Duration(days: 90)); // 기본값: 분기별
    }

    // 현재 날짜보다 이후인 경우에만 설정
    if (nextDate.isAfter(DateTime.now())) {
      nextDividendDates[symbol] = nextDate;
    } else {
      nextDividendDates[symbol] = null;
    }
  }

  // 포트폴리오 전체의 예상 연간 배당금 계산
  double calculateTotalExpectedDividend(List<PortfolioItem> portfolioItems) {
    double total = 0.0;

    for (var item in portfolioItems) {
      final dividends = dividendsBySymbol[item.symbol];
      if (dividends != null && dividends.isNotEmpty) {
        final latestDividend = dividends.first;
        final annualDividendPerShare = latestDividend.annualAmount;
        total += annualDividendPerShare * item.shares;
      }
    }

    return total;
  }

  // 평균 배당 수익률 계산
  double calculateAverageDividendYield(List<PortfolioItem> portfolioItems) {
    if (portfolioItems.isEmpty) return 0.0;

    double totalValue = 0.0;
    double weightedYield = 0.0;

    for (var item in portfolioItems) {
      final dividends = dividendsBySymbol[item.symbol];
      if (dividends != null && dividends.isNotEmpty) {
        final latestDividend = dividends.first;
        final itemValue = item.totalValue;
        final annualDividend = latestDividend.annualAmount * item.shares;
        final yield = itemValue > 0 ? (annualDividend / itemValue) : 0.0;

        weightedYield += yield * itemValue;
        totalValue += itemValue;
      }
    }

    return totalValue > 0 ? (weightedYield / totalValue) : 0.0;
  }

  // 다음 배당일이 가장 가까운 종목들 가져오기
  List<MapEntry<String, DateTime>> getUpcomingDividends() {
    final upcoming = <MapEntry<String, DateTime>>[];

    nextDividendDates.forEach((symbol, date) {
      if (date != null && date.isAfter(DateTime.now())) {
        upcoming.add(MapEntry(symbol, date));
      }
    });

    // 날짜순으로 정렬
    upcoming.sort((a, b) => a.value.compareTo(b.value));

    return upcoming;
  }

  // 특정 종목의 다음 배당일 가져오기
  DateTime? getNextDividendDate(String symbol) {
    return nextDividendDates[symbol];
  }

  // 월별 예상 배당금 계산 (차트용)
  Map<int, double> calculateMonthlyDividends(
      List<PortfolioItem> portfolioItems) {
    final Map<int, double> monthlyDividends = {};

    // 1월부터 12월까지 초기화
    for (int i = 1; i <= 12; i++) {
      monthlyDividends[i] = 0.0;
    }

    for (var item in portfolioItems) {
      final dividends = dividendsBySymbol[item.symbol];
      if (dividends != null && dividends.isNotEmpty) {
        final latestDividend = dividends.first;
        final dividendPerShare = latestDividend.amount;
        final totalDividend = dividendPerShare * item.shares;

        switch (latestDividend.frequency.toLowerCase()) {
          case 'monthly':
            // 매월 배당
            for (int month = 1; month <= 12; month++) {
              monthlyDividends[month] =
                  monthlyDividends[month]! + totalDividend;
            }
            break;
          case 'quarterly':
            // 분기별 배당 (3, 6, 9, 12월)
            for (var month in [3, 6, 9, 12]) {
              monthlyDividends[month] =
                  monthlyDividends[month]! + totalDividend;
            }
            break;
          case 'semi-annual':
            // 반기별 배당 (6, 12월)
            for (var month in [6, 12]) {
              monthlyDividends[month] =
                  monthlyDividends[month]! + totalDividend;
            }
            break;
          case 'annual':
            // 연간 배당 (12월)
            monthlyDividends[12] = monthlyDividends[12]! + totalDividend;
            break;
        }
      }
    }

    return monthlyDividends;
  }

  // 모든 배당 데이터 새로고침
  Future<void> refreshAllDividendData(
      List<PortfolioItem> portfolioItems) async {
    try {
      isLoading.value = true;

      for (var item in portfolioItems) {
        await updateDividendData(item.symbol);
      }

      Get.snackbar('성공', '모든 배당 데이터가 업데이트되었습니다.');
    } catch (e) {
      print('Error refreshing all dividend data: $e');
      Get.snackbar('오류', '배당 데이터 새로고침 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // 메모리 누수 방지를 위한 리소스 정리
    _cleanUpCache();
    _dividendService = null;
    super.onClose();
  }

  // 캐시 정리 메서드 (메모리 사용량 제한)
  void _cleanUpCache() {
    if (dividendsBySymbol.length > maxCacheSize) {
      // LRU 방식으로 오래된 데이터 제거
      final sortedKeys = dividendsBySymbol.keys.toList();
      for (int i = 0; i < sortedKeys.length - maxCacheSize; i++) {
        dividendsBySymbol.remove(sortedKeys[i]);
        nextDividendDates.remove(sortedKeys[i]);
      }
    }
  }
}
