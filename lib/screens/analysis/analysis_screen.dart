import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/analysis_controller.dart';
import '../../controllers/portfolio_controller.dart';
import '../../theme/app_theme.dart';

// 말풍선 꼬리를 그리는 CustomPainter
class BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF3E0)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 10)
      ..lineTo(8, 0)
      ..lineTo(16, 10)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final AnalysisController analysisController = Get.put(AnalysisController());
  final PortfolioController portfolioController =
      Get.find<PortfolioController>();

  int? touchedIndex; // 터치된 섹션의 인덱스를 저장
  bool _showTaxInfo = false; // 세금 계산 기준 팝업 표시 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포트폴리오 분석'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: Obx(() {
        if (portfolioController.portfolioItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '분석할 포트폴리오가 없습니다',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '포트폴리오에 종목을 추가해주세요',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (analysisController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 통계 요약
              _buildDividendTaxCalculator(),
              const SizedBox(height: 24),

              // 월별 배당금 분포 차트
              _buildMonthlyDividendChart(),
              const SizedBox(height: 24),

              // 포트폴리오 구성 차트
              _buildPortfolioCompositionChart(),
              const SizedBox(height: 24),

              // 추가 인사이트
              _buildInsights(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDividendTaxCalculator() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFF8F9FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A237E),
                        Color(0xFF3F51B5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '세금 계산기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                // 정보 아이콘 버튼
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showTaxInfo = !_showTaxInfo;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF1A237E),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // 말풍선 팝업 (세금 계산 기준)
            if (_showTaxInfo)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 말풍선 꼬리
                    Positioned(
                      top: -8,
                      right: 24,
                      child: CustomPaint(
                        painter: BubbleTailPainter(),
                      ),
                    ),
                    // 내용
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Color(0xFFFF9800),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '세금 계산 기준',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9800),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• 미국 주식: 한미 조세협정 적용 15% 원천징수\n• 한국 세금: 연간 2,000만원 이하 분리과세 14% 적용\n• 실제 세금은 개인 소득 상황에 따라 달라질 수 있습니다.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF795548),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // 자동 계산 버튼
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: _calculateFromPortfolio,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('포트폴리오 기준 자동 계산'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 계산 결과 표시
            _buildTaxCalculationResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxCalculationResults() {
    final expectedDividend = analysisController.expectedAnnualDividend;

    // 세금 계산 (미국 주식 기준)
    final usTax = expectedDividend * 0.15; // 한미 조세협정 적용 15%
    final koreanTax = _calculateKoreanTax(expectedDividend - usTax);
    final totalTax = usTax + koreanTax;
    final afterTaxDividend = expectedDividend - totalTax;

    final taxData = [
      {
        'title': '예상 연간 배당금',
        'value': '\$${expectedDividend.toStringAsFixed(2)}',
        'icon': Icons.monetization_on,
        'gradientColors': [
          const Color(0xFF4CAF50),
          const Color(0xFF66BB6A),
        ],
      },
      {
        'title': '미국 원천징수세 (15%)',
        'value': '\$${usTax.toStringAsFixed(2)}',
        'icon': Icons.remove_circle,
        'gradientColors': [
          const Color(0xFFFF5722),
          const Color(0xFFFF7043),
        ],
      },
      {
        'title': '한국 배당소득세',
        'value': '\$${koreanTax.toStringAsFixed(2)}',
        'icon': Icons.account_balance,
        'gradientColors': [
          const Color(0xFFFF9800),
          const Color(0xFFFFB74D),
        ],
      },
      {
        'title': '세후 실수령액',
        'value': '\$${afterTaxDividend.toStringAsFixed(2)}',
        'icon': Icons.account_balance_wallet,
        'gradientColors': [
          const Color(0xFF2196F3),
          const Color(0xFF21CBF3),
        ],
      },
    ];

    return Column(
      children: [
        // 세금 계산 결과 카드들
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1, // 1.3에서 1.1로 줄여서 오버플로우 해결
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: taxData.length,
          itemBuilder: (context, index) {
            final data = taxData[index];
            return _buildModernSummaryCard(
              data['title'] as String,
              data['value'] as String,
              data['icon'] as IconData,
              data['gradientColors'] as List<Color>,
              index,
            );
          },
        ),
      ],
    );
  }

  // 한국 배당소득세 계산 (간단한 추정)
  double _calculateKoreanTax(double dividendIncome) {
    // USD를 KRW로 환산 (대략적인 환율 1,300원 적용)
    final dividendKRW = dividendIncome * 1300;

    // 연간 2,000만원 이하는 분리과세 14%
    if (dividendKRW <= 20000000) {
      return (dividendKRW * 0.14) / 1300; // 다시 USD로 환산
    } else {
      // 2,000만원 초과시 종합과세 (최대 45%로 추정)
      return (dividendKRW * 0.30) / 1300; // 다시 USD로 환산
    }
  }

  void _calculateFromPortfolio() {
    // 포트폴리오 기준 자동 계산 완료 스낵바
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('포트폴리오 기준으로 세금이 자동 계산되었습니다'),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildModernSummaryCard(String title, String value, IconData icon,
      List<Color> gradientColors, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      padding: const EdgeInsets.all(12), // 16에서 12로 줄임
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 아이콘 컨테이너
          Container(
            padding: const EdgeInsets.all(8), // 10에서 8로 줄임
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24, // 28에서 24로 줄임
            ),
          ),
          const SizedBox(height: 4), // 8에서 6으로 줄임
          // 타이틀
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12, // 13에서 12로 줄임
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 값
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, // 18에서 16으로 줄임
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyDividendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '월별 배당금 분포',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (analysisController.topDividendMonth != '-')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dividendIncome.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              AppColors.dividendIncome.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '최고: ${analysisController.topDividendMonth}',
                      style: const TextStyle(
                        color: AppColors.dividendIncome,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: analysisController.monthlyDividends.isEmpty
                  ? const Center(
                      child: Text(
                        '배당 데이터가 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: analysisController.topDividendAmount * 1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
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
                              return BarTooltipItem(
                                '${months[group.x]}\n\$${rod.toY.toStringAsFixed(2)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  '1',
                                  '2',
                                  '3',
                                  '4',
                                  '5',
                                  '6',
                                  '7',
                                  '8',
                                  '9',
                                  '10',
                                  '11',
                                  '12'
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < months.length) {
                                  return Text(
                                    months[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '\$${value.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: analysisController.monthlyDividendChartData,
                        gridData: const FlGridData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCompositionChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '포트폴리오 구성',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                // 파이 차트를 가운데 배치
                SizedBox(
                  height: 200,
                  child: analysisController.portfolioComposition.isEmpty
                      ? const Center(
                          child: Text(
                            '포트폴리오 데이터가 없습니다',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Center(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections:
                                        analysisController.portfolioComposition,
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 60,
                                    pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event,
                                          pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            touchedIndex = null;
                                            return;
                                          }
                                          final newIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                          // 인덱스가 유효한 범위 내에 있는지 확인
                                          if (newIndex >= 0 &&
                                              newIndex <
                                                  portfolioController
                                                      .portfolioItems.length) {
                                            touchedIndex = newIndex;
                                          } else {
                                            touchedIndex = null;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                // 중앙에 터치된 항목 정보 표시
                                if (touchedIndex != null &&
                                    touchedIndex! >= 0 &&
                                    touchedIndex! <
                                        portfolioController
                                            .portfolioItems.length)
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            portfolioController
                                                .portfolioItems[touchedIndex!]
                                                .symbol,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Builder(
                                            builder: (context) {
                                              // 안전한 인덱스 접근을 위한 추가 검증
                                              if (touchedIndex == null ||
                                                  touchedIndex! < 0 ||
                                                  touchedIndex! >=
                                                      portfolioController
                                                          .portfolioItems
                                                          .length) {
                                                return const SizedBox.shrink();
                                              }

                                              final totalValue =
                                                  portfolioController
                                                      .portfolioItems
                                                      .fold<double>(
                                                          0.0,
                                                          (sum,
                                                                  item) =>
                                                              sum +
                                                              item.totalValue);
                                              final percentage =
                                                  (portfolioController
                                                              .portfolioItems[
                                                                  touchedIndex!]
                                                              .totalValue /
                                                          totalValue *
                                                          100)
                                                      .toStringAsFixed(1);
                                              return Text(
                                                '$percentage%',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 2),
                                          if (touchedIndex != null &&
                                              touchedIndex! >= 0 &&
                                              touchedIndex! <
                                                  portfolioController
                                                      .portfolioItems.length)
                                            Text(
                                              '\$${NumberFormat('#,##0.00').format(portfolioController.portfolioItems[touchedIndex!].totalValue)}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // 기본 상태에서 "터치하세요" 메시지 표시
                                if (touchedIndex == null)
                                  Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50
                                            .withValues(alpha: 0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.touch_app,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '터치하세요',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                // 범례를 아래쪽에 배치
                if (analysisController.portfolioComposition.isNotEmpty)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: portfolioController.portfolioItems
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final colors = [
                        AppTheme.primaryNavy,
                        AppTheme.secondaryGold,
                        AppColors.dividendIncome,
                        AppTheme.primaryNavyLight,
                        AppTheme.secondaryGoldLight,
                        AppTheme.successGreen,
                        AppTheme.infoBlue,
                        AppTheme.warningOrange,
                        AppTheme.primaryNavyDark,
                        AppTheme.secondaryGoldDark,
                      ];

                      // 각 종목의 비중 계산
                      final totalValue = portfolioController.portfolioItems
                          .fold<double>(
                              0.0, (sum, item) => sum + item.totalValue);
                      final percentage = (item.totalValue / totalValue * 100)
                          .toStringAsFixed(1);

                      // 터치된 항목인지 확인
                      final bool isTouched = touchedIndex != null &&
                          touchedIndex! >= 0 &&
                          touchedIndex! <
                              portfolioController.portfolioItems.length &&
                          touchedIndex == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTouched ? 12 : 8,
                          vertical: isTouched ? 8 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: isTouched
                              ? colors[index % colors.length]
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isTouched
                              ? Border.all(
                                  color: colors[index % colors.length]
                                      .withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: isTouched ? 14 : 12,
                              height: isTouched ? 14 : 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                isTouched
                                    ? '${item.symbol} ($percentage%)'
                                    : item.symbol,
                                key: ValueKey(isTouched),
                                style: TextStyle(
                                  fontSize: isTouched ? 13 : 12,
                                  fontWeight: isTouched
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isTouched
                                      ? colors[index % colors.length]
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인사이트',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              Icons.calendar_today,
              '최고 배당 월',
              '${analysisController.topDividendMonth}에 가장 많은 배당금을 받습니다',
              AppTheme.primaryNavy,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.trending_up,
              '포트폴리오 다양성',
              '${analysisController.diversityScore.toStringAsFixed(0)}점 - ${_getDiversityComment(analysisController.diversityScore)}',
              AppColors.dividendIncome,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              Icons.attach_money,
              '연간 배당 수익률',
              '총 투자금 대비 ${((analysisController.expectedAnnualDividend / analysisController.totalInvestment) * 100).toStringAsFixed(1)}%의 배당 수익률을 기대할 수 있습니다',
              AppTheme.secondaryGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDiversityComment(double score) {
    if (score >= 80) return '매우 다양한 포트폴리오입니다';
    if (score >= 60) return '적절히 다양한 포트폴리오입니다';
    if (score >= 40) return '다소 집중된 포트폴리오입니다';
    return '매우 집중된 포트폴리오입니다';
  }
}
