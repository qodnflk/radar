import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/portfolio_controller.dart';
import '../../controllers/dividend_controller.dart';
import '../../models/portfolio_item.dart';
import 'portfolio_add_screen.dart';
import 'portfolio_detail_screen.dart';
import '../analysis/analysis_screen.dart';
import '../../widgets/portfolio_card.dart';
import '../../theme/app_theme.dart';

class PortfolioListScreen extends StatelessWidget {
  final PortfolioController controller = Get.put(PortfolioController());
  final DividendController dividendController = Get.put(DividendController());

  PortfolioListScreen({super.key});

  void _showClearConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('포트폴리오 초기화'),
        content: const Text('정말로 포트폴리오를 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearPortfolio();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, PortfolioItem item) {
    final sharesController =
        TextEditingController(text: item.shares.toString());
    final priceController =
        TextEditingController(text: item.averagePrice.toString());

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFF1A237E),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '종목 정보 수정',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 종목 심볼 표시
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.label,
                        color: Color(0xFFFFB300),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '종목 심볼: ${item.symbol}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 입력 필드들
                TextField(
                  controller: sharesController,
                  decoration: InputDecoration(
                    labelText: '보유 수량',
                    hintText: '예: 10',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A237E),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: '평균 매수가 (USD)',
                    hintText: '예: 150.50',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A237E),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 24),

                // 액션 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        sharesController.dispose();
                        priceController.dispose();
                        Navigator.of(dialogContext).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final shares = double.parse(sharesController.text);
                          final price = double.parse(priceController.text);

                          final updatedItem = PortfolioItem(
                            id: item.id,
                            symbol: item.symbol,
                            name: item.name,
                            shares: shares,
                            averagePrice: price,
                            purchaseDate: item.purchaseDate,
                          );

                          // 수정 실행
                          await controller.updatePortfolioItem(updatedItem);

                          // 다이얼로그 닫기
                          sharesController.dispose();
                          priceController.dispose();
                          Navigator.of(dialogContext).pop();

                          // 성공 메시지
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} 종목이 수정되었습니다'),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('올바른 숫자를 입력해주세요'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0xFF1A237E).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          Icons.save,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(PortfolioItem item) {
    Get.dialog(
      AlertDialog(
        title: const Text('종목 삭제'),
        content: Text('${item.name} 종목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePortfolioItem(item.id ?? item.symbol);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    return Obx(() {
      final portfolioItems = controller.portfolioItems;
      if (portfolioItems.isEmpty) return const SizedBox.shrink();

      // 총 투자금 계산
      final totalInvestment = portfolioItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalValue,
      );

      // 현재 총 가치 계산
      final totalCurrentValue = controller.totalCurrentValue;

      // 총 손익 계산
      final totalGainLoss = controller.totalGainLoss;
      final totalGainLossPercentage = controller.totalGainLossPercentage;

      // 예상 연간 배당금 계산
      final expectedDividend =
          dividendController.calculateTotalExpectedDividend(portfolioItems);

      // 평균 배당 수익률 계산
      final averageYield =
          dividendController.calculateAverageDividendYield(portfolioItems);

      // 다음 배당 일정
      final upcomingDividends = dividendController.getUpcomingDividends();

      // 통계 데이터 리스트
      final summaryData = [
        {
          'title': '총 투자금',
          'value': '\$${NumberFormat('#,##0').format(totalInvestment)}',
          'icon': Icons.account_balance_wallet,
          'gradientColors': [
            const Color(0xFF2196F3),
            const Color(0xFF21CBF3),
          ],
        },
        {
          'title': '현재 가치',
          'value': '\$${NumberFormat('#,##0').format(totalCurrentValue)}',
          'icon': Icons.trending_up,
          'gradientColors': [
            const Color(0xFF673AB7),
            const Color(0xFF9C27B0),
          ],
        },
        {
          'title': '총 손익',
          'value':
              '${totalGainLoss >= 0 ? '+' : ''}\$${NumberFormat('#,##0').format(totalGainLoss)}',
          'icon':
              totalGainLoss >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
          'gradientColors': totalGainLoss >= 0
              ? [
                  const Color(0xFF4CAF50),
                  const Color(0xFF66BB6A),
                ]
              : [
                  const Color(0xFFFF5722),
                  const Color(0xFFFF7043),
                ],
        },
        {
          'title': '수익률',
          'value':
              '${totalGainLossPercentage >= 0 ? '+' : ''}${totalGainLossPercentage.toStringAsFixed(1)}%',
          'icon': totalGainLossPercentage >= 0
              ? Icons.trending_up
              : Icons.trending_down,
          'gradientColors': totalGainLossPercentage >= 0
              ? [
                  const Color(0xFFE91E63),
                  const Color(0xFFFF4081),
                ]
              : [
                  const Color(0xFFFF5722),
                  const Color(0xFFFF7043),
                ],
        },
        {
          'title': '보유 종목',
          'value': '${portfolioItems.length}개',
          'icon': Icons.inventory,
          'gradientColors': [
            const Color(0xFFFF9800),
            const Color(0xFFFFB74D),
          ],
        },
        {
          'title': '예상 연간 배당',
          'value': '\$${expectedDividend.toStringAsFixed(2)}',
          'icon': Icons.monetization_on,
          'gradientColors': [
            const Color(0xFF00BCD4),
            const Color(0xFF4DD0E1),
          ],
        },
        {
          'title': '평균 배당률',
          'value': '${(averageYield * 100).toStringAsFixed(1)}%',
          'icon': Icons.trending_up,
          'gradientColors': [
            const Color(0xFF9C27B0),
            const Color(0xFFBA68C8),
          ],
        },
      ];

      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 포트폴리오 요약 헤더
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: Text(
                '포트폴리오 요약',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
              ),
            ),
            // 모던한 Horizontal Scroll 카드들
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: summaryData.length,
                itemBuilder: (context, index) {
                  final data = summaryData[index];
                  return Container(
                    width: 140,
                    margin: EdgeInsets.only(
                      right: index < summaryData.length - 1 ? 16 : 0,
                    ),
                    child: _buildModernSummaryCard(
                      data['title'] as String,
                      data['value'] as String,
                      data['icon'] as IconData,
                      data['gradientColors'] as List<Color>,
                      index,
                    ),
                  );
                },
              ),
            ),
            // 마지막 가격 업데이트 시간 표시
            if (controller.lastPriceUpdate.value.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppTheme.primaryNavy,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '마지막 가격 업데이트: ${controller.lastPriceUpdate.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // 다음 배당 일정 카드
            if (upcomingDividends.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: Card(
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '다음 배당 일정',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...upcomingDividends.take(3).map((entry) {
                            final daysUntil =
                                entry.value.difference(DateTime.now()).inDays;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    '${DateFormat('MM/dd').format(entry.value)} ($daysUntil일 후)',
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          if (upcomingDividends.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '외 ${upcomingDividends.length - 3}개 더...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildModernSummaryCard(String title, String value, IconData icon,
      List<Color> gradientColors, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // BoxShadow(
          //   color: gradientColors[0].withValues(alpha: 0.3),
          //   blurRadius: 15,
          //   offset: const Offset(0, 8),
          // ),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 5),
          // 타이틀
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          // 값
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포트폴리오'),
        actions: [
          // 실시간 가격 업데이트 버튼
          Obx(() => IconButton(
                icon: controller.isPriceUpdating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: controller.isPriceUpdating.value
                    ? null
                    : controller.manualPriceUpdate,
                tooltip: '가격 업데이트',
              )),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Get.to(() => const AnalysisScreen()),
            tooltip: '포트폴리오 분석',
          ),
          // IconButton(
          //   icon: const Icon(Icons.delete_outline),
          //   onPressed: _showClearConfirmDialog,
          //   tooltip: '포트폴리오 초기화',
          // ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const PortfolioAddScreen()),
            tooltip: '종목 추가',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.manualSync();
        },
        color: AppTheme.primaryNavy,
        backgroundColor: Colors.white,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.portfolioItems.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 메인 아이콘
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.trending_up,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // 메인 메시지
                        Text(
                          '종목을 추가해 보세요!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 서브 메시지
                        Text(
                          '첫 번째 투자 종목을 추가하여\n배당 포트폴리오를 시작해보세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // 액션 버튼
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Get.to(() => const PortfolioAddScreen()),
                            icon:
                                const Icon(Icons.add_circle_outline, size: 24),
                            label: const Text(
                              '첫 종목 추가하기',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 도움말 카드들
                        Row(
                          children: [
                            Expanded(
                              child: _buildHelpCard(
                                Icons.search,
                                '종목 검색',
                                '원하는 주식을\n쉽게 찾아보세요',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildHelpCard(
                                Icons.pie_chart,
                                '포트폴리오 분석',
                                '배당 수익률을\n분석해보세요',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 포트폴리오 요약 카드
                _buildPortfolioSummary(),
                // 포트폴리오 목록
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.portfolioItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.portfolioItems[index];
                    return PortfolioCard(
                      item: item,
                      onTap: () =>
                          Get.to(() => PortfolioDetailScreen(item: item)),
                      onEdit: () =>
                          Get.to(() => PortfolioDetailScreen(item: item)),
                      onDelete: () => _showDeleteConfirmDialog(item),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showQuickEditDialog(BuildContext context, PortfolioItem item) {
    final sharesController =
        TextEditingController(text: item.shares.toString());
    final priceController =
        TextEditingController(text: item.averagePrice.toString());

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('${item.name} 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sharesController,
                decoration: const InputDecoration(
                  labelText: '보유 수량',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: '평균 매수가 (USD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                sharesController.dispose();
                priceController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final shares = double.parse(sharesController.text);
                  final price = double.parse(priceController.text);

                  final updatedItem = PortfolioItem(
                    id: item.id,
                    symbol: item.symbol,
                    name: item.name,
                    shares: shares,
                    averagePrice: price,
                    purchaseDate: item.purchaseDate,
                  );

                  await controller.updatePortfolioItem(updatedItem);

                  sharesController.dispose();
                  priceController.dispose();

                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} 종목이 수정되었습니다'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('올바른 숫자를 입력해주세요'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}
