import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio_item.dart';
import 'portfolio_detail_screen.dart';
import 'portfolio_add_screen.dart';

class PortfolioListScreen extends StatelessWidget {
  final PortfolioController controller = Get.put(PortfolioController());

  PortfolioListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 포트폴리오'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.portfolioItems.isEmpty) {
          return const Center(
            child: Text(
              '포트폴리오가 비어있습니다.\n새로운 종목을 추가해보세요!',
              textAlign: TextAlign.center,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => PortfolioAddScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PortfolioItemCard extends StatelessWidget {
  final PortfolioItem item;

  const PortfolioItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () => Get.to(() => PortfolioDetailScreen(item: item)),
        title: Text(item.stock.name),
        subtitle: Text(item.stock.symbol),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${item.quantity}주'),
            Text(
                '평균단가: ${item.averagePrice.toStringAsFixed(2)} ${item.stock.currency}'),
          ],
        ),
      ),
    );
  }
}
