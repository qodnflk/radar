import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/portfolio_controller.dart';
import '../../controllers/dividend_controller.dart';
import '../../models/portfolio_item.dart';
import '../../models/dividend.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final PortfolioItem item;

  const PortfolioDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  _PortfolioDetailScreenState createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  final PortfolioController controller = Get.find<PortfolioController>();
  final DividendController dividendController = Get.put(DividendController());
  late TextEditingController sharesController;
  late TextEditingController priceController;
  List<Dividend> dividends = [];
  bool isLoadingDividends = false;

  // 현재 아이템의 상태를 로컬에서 관리 (업데이트 반영용)
  late PortfolioItem currentItem;

  @override
  void initState() {
    super.initState();
    currentItem = widget.item; // 현재 아이템 초기화
    sharesController =
        TextEditingController(text: currentItem.shares.toString());
    priceController =
        TextEditingController(text: currentItem.averagePrice.toString());
    _loadDividends();
  }

  Future<void> _loadDividends() async {
    setState(() => isLoadingDividends = true);
    try {
      final yahooData =
          await dividendController.getDividendsForSymbol(currentItem.symbol);
      setState(() {
        dividends = yahooData;
        isLoadingDividends = false;
      });
    } catch (e) {
      print('Error loading dividends: $e');
      setState(() => isLoadingDividends = false);
    }
  }

  Future<void> _updateDividendData() async {
    if (isLoadingDividends) return; // 이미 로딩 중이면 중복 실행 방지

    setState(() => isLoadingDividends = true);

    try {
      // 타임아웃 설정으로 무한 로딩 방지
      await Future.any([
        dividendController.updateDividendData(currentItem.symbol),
        Future.delayed(const Duration(seconds: 1)) // 5초 타임아웃
      ]);

      final updatedDividends =
          await dividendController.getDividendsForSymbol(currentItem.symbol);

      if (mounted) {
        setState(() {
          dividends = updatedDividends;
          isLoadingDividends = false;
        });

        // 성공 메시지 (Get.snackbar 대신 ScaffoldMessenger 사용)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentItem.symbol} 배당 데이터가 업데이트되었습니다'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingDividends = false);

        // 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('배당 데이터 업데이트 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    sharesController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDividendRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void showEditDialog() {
    // 다이얼로그 표시 전에 컨트롤러 값을 현재 아이템으로 초기화
    sharesController.text = currentItem.shares.toString();
    priceController.text = currentItem.averagePrice.toString();

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
                            currentItem.name,
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
                        '종목 심볼: ${currentItem.symbol}',
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
                            id: currentItem.id,
                            symbol: currentItem.symbol,
                            name: currentItem.name,
                            shares: shares,
                            averagePrice: price,
                            purchaseDate: currentItem.purchaseDate,
                          );

                          // 수정 실행
                          await controller.updatePortfolioItem(updatedItem);

                          // 다이얼로그 즉시 닫기
                          Navigator.of(dialogContext).pop();

                          // 로컬 아이템 상태 업데이트
                          currentItem = updatedItem;

                          // 화면 즉시 새로고침
                          if (mounted) {
                            setState(() {
                              // currentItem이 업데이트되었으므로 화면에 즉시 반영됨
                            });
                          }
                        } catch (e) {
                          // 다이얼로그가 아직 열려있는지 확인 후 닫기
                          if (Navigator.of(dialogContext).canPop()) {
                            Navigator.of(dialogContext).pop();
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('수정 중 오류가 발생했습니다: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                        ],
                      ),
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

  void showDeleteDialog() {
    Get.dialog(
      Dialog(
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
                      color: const Color(0xFFD32F2F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Color(0xFFD32F2F),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '종목 삭제',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 경고 메시지
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD32F2F).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFD32F2F),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '다음 종목을 삭제하시겠습니까?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentItem.symbol} • ${currentItem.shares} 주',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '⚠️ 이 작업은 되돌릴 수 없습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD32F2F),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 액션 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
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
                        // 먼저 다이얼로그를 닫습니다
                        Get.back();
                        await controller.deletePortfolioItem(currentItem.id!);
                        // 상세 화면을 닫습니다
                        Get.back();
                        Get.snackbar(
                          '성공',
                          '${currentItem.name} 종목이 삭제되었습니다',
                          backgroundColor: const Color(0xFF2E7D32),
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar('오류', '종목 삭제 중 오류가 발생했습니다');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFFD32F2F).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_forever,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '삭제',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '기본 정보',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      _buildInfoRow('종목 심볼', currentItem.symbol),
                      _buildInfoRow('보유 수량',
                          '${NumberFormat('#,##0').format(currentItem.shares)} 주'),
                      _buildInfoRow('평균 매수가',
                          '\$${NumberFormat('#,##0.00').format(currentItem.averagePrice)}'),
                      _buildInfoRow('총 투자금',
                          '\$${NumberFormat('#,##0.00').format(currentItem.totalValue)}'),
                      _buildInfoRow(
                          '매수일',
                          DateFormat('yyyy년 MM월 dd일')
                              .format(currentItem.purchaseDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '배당금 정보',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _updateDividendData(),
                            tooltip: '배당 데이터 업데이트',
                          ),
                        ],
                      ),

                      // 다음 배당일 표시
                      Obx(() {
                        final nextDividendDate = dividendController
                            .getNextDividendDate(currentItem.symbol);
                        if (nextDividendDate != null) {
                          final daysUntil = nextDividendDate
                              .difference(DateTime.now())
                              .inDays;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.blue.shade600, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '다음 배당 예정일',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('yyyy년 MM월 dd일').format(nextDividendDate)} ($daysUntil일 후)',
                                        style: TextStyle(
                                            color: Colors.blue.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      // 예상 연간 배당금 표시
                      if (dividends.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on,
                                  color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '예상 연간 배당금 (총)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '\$${(dividends.first.annualAmount * currentItem.shares).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' (${currentItem.shares.toStringAsFixed(0)}주 × \$${dividends.first.annualAmount.toStringAsFixed(3)})',
                                            style: TextStyle(
                                              color: Colors.green.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isLoadingDividends)
                        const Center(child: CircularProgressIndicator())
                      else if (dividends.isEmpty)
                        const Center(child: Text('배당금 정보가 없습니다.'))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dividends.length,
                          itemBuilder: (context, index) {
                            final dividend = dividends[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index > 0) const Divider(),
                                _buildDividendRow('주당 배당금',
                                    '\$${dividend.amount.toStringAsFixed(3)}'),
                                _buildDividendRow('배당률',
                                    '${(dividend.dividendYield * 100).toStringAsFixed(1)}%'),
                                _buildDividendRow(
                                    '배당락일',
                                    DateFormat('yyyy년 MM월 dd일')
                                        .format(dividend.exDate)),
                                _buildDividendRow(
                                    '지급일',
                                    DateFormat('yyyy년 MM월 dd일')
                                        .format(dividend.payDate)),
                                _buildDividendRow('주기', dividend.frequency),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
