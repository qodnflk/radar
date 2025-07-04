import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio_item.dart';

class PortfolioDetailScreen extends StatelessWidget {
  final PortfolioItem item;
  final PortfolioController controller = Get.find();

  PortfolioDetailScreen({super.key, required this.item});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('종목 삭제'),
        content: Text('${item.stock.name} 종목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final index = controller.portfolioItems.indexOf(item);
              if (index != -1) {
                controller.deletePortfolioItem(index);
                Get.back();
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = item.quantity * item.averagePrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.stock.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    Text('종목코드: ${item.stock.symbol}'),
                    const SizedBox(height: 8),
                    Text('거래소: ${item.stock.exchange}'),
                    const SizedBox(height: 8),
                    Text('통화: ${item.stock.currency}'),
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
                    Text('보유수량: ${item.quantity}주'),
                    const SizedBox(height: 8),
                    Text(
                        '평균단가: ${item.averagePrice.toStringAsFixed(2)} ${item.stock.currency}'),
                    const SizedBox(height: 8),
                    Text(
                        '총 투자금액: ${totalValue.toStringAsFixed(2)} ${item.stock.currency}'),
                    const SizedBox(height: 8),
                    Text('매수일: ${item.purchaseDate.toString().split(' ')[0]}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
