import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/portfolio_controller.dart';
import '../controllers/dividend_controller.dart';

class AnalysisController extends GetxController {
  final DividendController _dividendController = Get.find<DividendController>();
  final PortfolioController _portfolioController =
      Get.find<PortfolioController>();

  // 상태 관리
  final RxBool isLoading = false.obs;
  final RxMap<String, double> monthlyDividends = <String, double>{}.obs;
  final RxList<PieChartSectionData> portfolioComposition =
      <PieChartSectionData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _calculateAnalysisData();

    // 포트폴리오 변경시 분석 데이터 재계산
    ever(_portfolioController.portfolioItems, (_) => _calculateAnalysisData());
  }

  // 분석 데이터 계산
  Future<void> _calculateAnalysisData() async {
    if (_portfolioController.portfolioItems.isEmpty) return;

    isLoading.value = true;

    try {
      await Future.wait([
        _calculateMonthlyDividends(),
        _calculatePortfolioComposition(),
      ]);
    } catch (e) {
      // 분석 데이터 계산 오류 무시 (메모리 효율성을 위해 로깅 생략)
    } finally {
      isLoading.value = false;
    }
  }

  // 월별 배당금 분포 계산
  Future<void> _calculateMonthlyDividends() async {
    final Map<String, double> monthlyData = {};

    for (final item in _portfolioController.portfolioItems) {
      final dividends =
          await _dividendController.getDividendsForSymbol(item.symbol);

      for (final dividend in dividends) {
        final month = dividend.exDate.month;
        final monthKey = '$month월';
        final monthlyAmount = dividend.amount * item.shares;

        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0.0) + monthlyAmount;
      }
    }

    monthlyDividends.value = monthlyData;
  }

  // 포트폴리오 구성 계산
  Future<void> _calculatePortfolioComposition() async {
    final List<PieChartSectionData> sections = [];
    final totalValue = _portfolioController.portfolioItems
        .fold<double>(0.0, (sum, item) => sum + item.totalValue);

    if (totalValue == 0) {
      portfolioComposition.value = [];
      return;
    }

    final colors = [
      const Color(0xFF0293EE),
      const Color(0xFFF8B250),
      const Color(0xFF845EC2),
      const Color(0xFF4E9F3D),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECEA8),
      const Color(0xFFFF9AA2),
    ];

    for (int i = 0; i < _portfolioController.portfolioItems.length; i++) {
      final item = _portfolioController.portfolioItems[i];
      final percentage = (item.totalValue / totalValue) * 100;

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
      );
    }

    portfolioComposition.value = sections;
  }

  // 기본 통계 계산
  double get totalInvestment {
    return _portfolioController.portfolioItems
        .fold<double>(0.0, (sum, item) => sum + item.totalValue);
  }

  double get expectedAnnualDividend {
    return _dividendController
        .calculateTotalExpectedDividend(_portfolioController.portfolioItems);
  }

  double get averageDividendYield {
    return _dividendController
        .calculateAverageDividendYield(_portfolioController.portfolioItems);
  }

  // 월별 배당금 차트 데이터
  List<BarChartGroupData> get monthlyDividendChartData {
    final months = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월'
    ];

    return months.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final value = monthlyDividends[month] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: const Color(0xFF0293EE),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  // 최고 배당 월
  String get topDividendMonth {
    if (monthlyDividends.isEmpty) return '-';

    final maxEntry =
        monthlyDividends.entries.reduce((a, b) => a.value > b.value ? a : b);

    return maxEntry.key;
  }

  // 최고 배당금
  double get topDividendAmount {
    if (monthlyDividends.isEmpty) return 0.0;

    return monthlyDividends.values.reduce((a, b) => a > b ? a : b);
  }

  // 포트폴리오 다양성 점수 (간단한 계산)
  double get diversityScore {
    if (_portfolioController.portfolioItems.isEmpty) return 0.0;

    final totalValue = totalInvestment;
    if (totalValue == 0) return 0.0;

    // 허핀달 지수의 역수를 사용하여 다양성 점수 계산
    double herfindahl = 0.0;
    for (final item in _portfolioController.portfolioItems) {
      final weight = item.totalValue / totalValue;
      herfindahl += weight * weight;
    }

    // 0-100 점수로 변환 (100이 가장 다양함)
    final maxDiversity = 1.0 / _portfolioController.portfolioItems.length;
    final diversityRatio = (1.0 / herfindahl) / (1.0 / maxDiversity);

    return (diversityRatio * 100).clamp(0.0, 100.0);
  }

  // 수동 새로고침
  Future<void> refreshAnalysisData() async {
    await _calculateAnalysisData();
  }

  @override
  void onClose() {
    // 메모리 누수 방지를 위한 데이터 정리
    monthlyDividends.clear();
    portfolioComposition.clear();
    super.onClose();
  }
}
