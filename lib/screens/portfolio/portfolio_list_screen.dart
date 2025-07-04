import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio_item.dart';
import 'portfolio_add_screen.dart';
import 'portfolio_detail_screen.dart';

class PortfolioListScreen extends StatelessWidget {
  final PortfolioController controller = Get.put(PortfolioController());

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 포트폴리오'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearConfirmDialog,
            tooltip: '포트폴리오 초기화',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const PortfolioAddScreen()),
            tooltip: '종목 추가',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.portfolioItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  '포트폴리오가 비어있습니다.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '우측 상단의 + 버튼을 눌러\n종목을 추가하세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const PortfolioAddScreen()),
                  icon: const Icon(Icons.add),
                  label: const Text('종목 추가하기'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.portfolioItems.length,
          itemBuilder: (context, index) {
            final item = controller.portfolioItems[index];
            return PortfolioItemCard(item: item);
          },
        );
      }),
    );
  }
}

class PortfolioItemCard extends StatelessWidget {
  final PortfolioItem item;
  final PortfolioController controller = Get.find();

  PortfolioItemCard({Key? key, required this.item}) : super(key: key);

  void _showDeleteConfirmDialog() {
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
              controller.deletePortfolioItem(item.id!);
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _showDeleteConfirmDialog();
        return false;
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          onTap: () => Get.to(() => PortfolioDetailScreen(item: item)),
          title: Text(item.name),
          subtitle: Text(item.symbol),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.totalValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${item.shares} 주 @ \$${item.averagePrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
