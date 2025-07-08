import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/analysis_controller.dart';
import '../../controllers/portfolio_controller.dart';
import '../../theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포트폴리오 분석'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => analysisController.refreshAnalysisData(),
            tooltip: '데이터 새로고침',
          ),
        ],
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
              _buildStatsSummary(),
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

  Widget _buildStatsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '포트폴리오 요약',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // 4개의 StatCard를 2x2 그리드로 배치하되, 더 넉넉한 크기로 조정
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 2.5, // 높이를 훨씬 더 넉넉하게 조정
              children: [
                _buildStatCard(
                  '총 투자금',
                  '\$${NumberFormat('#,##0.00').format(analysisController.totalInvestment)}',
                  Icons.account_balance_wallet,
                  AppColors.portfolioValue,
                ),
                _buildStatCard(
                  '예상 연간 배당',
                  '\$${analysisController.expectedAnnualDividend.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  AppColors.dividendIncome,
                ),
                _buildStatCard(
                  '평균 배당률',
                  '${(analysisController.averageDividendYield * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppTheme.successGreen,
                ),
                _buildStatCard(
                  '다양성 점수',
                  '${analysisController.diversityScore.toStringAsFixed(0)}점',
                  Icons.diversity_3,
                  AppTheme.primaryNavyLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20), // 패딩을 더 넉넉하게
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18), // 아이콘 크기 더 줄임
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11, // 제목 폰트 크기 더 줄임
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // 간격을 더 넉넉하게
          Flexible(
            // Expanded 대신 Flexible 사용
            child: Center(
              // 센터로 정렬
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14, // 값 폰트 크기 더 줄임
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
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
                                            .withOpacity(0.8),
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
                              ? colors[index % colors.length].withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isTouched
                              ? Border.all(
                                  color: colors[index % colors.length]
                                      .withOpacity(0.3))
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
