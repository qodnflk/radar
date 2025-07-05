import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio_item.dart';
import '../../models/dividend.dart';
import '../../services/dividend_service.dart';

class PortfolioDetailScreen extends StatefulWidget {
  final PortfolioItem item;

  const PortfolioDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  _PortfolioDetailScreenState createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen> {
  final PortfolioController controller = Get.find<PortfolioController>();
  final DividendService _dividendService = DividendService();
  late TextEditingController sharesController;
  late TextEditingController priceController;
  List<Dividend> dividends = [];
  bool isLoadingDividends = false;

  @override
  void initState() {
    super.initState();
    sharesController =
        TextEditingController(text: widget.item.shares.toString());
    priceController =
        TextEditingController(text: widget.item.averagePrice.toString());
    _loadDividends();
  }

  Future<void> _loadDividends() async {
    setState(() => isLoadingDividends = true);
    try {
      final yahooData =
          await _dividendService.fetchYahooDividends(widget.item.symbol);
      setState(() {
        dividends = yahooData;
        isLoadingDividends = false;
      });
    } catch (e) {
      print('Error loading dividends: $e');
      setState(() => isLoadingDividends = false);
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
    Get.dialog(
      AlertDialog(
        title: Text('${widget.item.name} 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sharesController,
              decoration: const InputDecoration(
                labelText: '보유 수량',
                hintText: '예: 10',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: '평균 매수가',
                hintText: '예: 150.50',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final shares = double.parse(sharesController.text);
                final price = double.parse(priceController.text);

                final updatedItem = PortfolioItem(
                  id: widget.item.id,
                  symbol: widget.item.symbol,
                  name: widget.item.name,
                  shares: shares,
                  averagePrice: price,
                  purchaseDate: widget.item.purchaseDate,
                );

                await controller.updatePortfolioItem(updatedItem);
                Get.back();
                Get.snackbar('성공', '${widget.item.name} 종목이 수정되었습니다');
              } catch (e) {
                Get.snackbar('오류', '올바른 숫자를 입력해주세요');
              }
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('종목 삭제'),
        content: Text('${widget.item.name} 종목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // 먼저 다이얼로그를 닫습니다
                Get.back();
                await controller.deletePortfolioItem(widget.item.id!);
                // 상세 화면을 닫습니다
                Get.back();
              } catch (e) {
                Get.snackbar('오류', '종목 삭제 중 오류가 발생했습니다');
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
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
                      _buildInfoRow('종목 심볼', widget.item.symbol),
                      _buildInfoRow('보유 수량', '${widget.item.shares} 주'),
                      _buildInfoRow('평균 매수가', '\$${widget.item.averagePrice}'),
                      _buildInfoRow('총 투자금', '\$${widget.item.totalValue}'),
                      _buildInfoRow('매수일',
                          widget.item.purchaseDate.toString().split(' ')[0]),
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
                      Text(
                        '배당금 정보',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
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
                                _buildDividendRow('배당금',
                                    '\$${dividend.amount.toStringAsFixed(3)}'),
                                _buildDividendRow('배당률',
                                    '${(dividend.dividendYield * 100).toStringAsFixed(1)}%'),
                                _buildDividendRow('배당락일',
                                    dividend.exDate.toString().split(' ')[0]),
                                _buildDividendRow('지급일',
                                    dividend.payDate.toString().split(' ')[0]),
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
