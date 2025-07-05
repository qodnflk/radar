import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio_item.dart';

class PortfolioAddScreen extends StatefulWidget {
  const PortfolioAddScreen({super.key});

  @override
  _PortfolioAddScreenState createState() => _PortfolioAddScreenState();
}

class _PortfolioAddScreenState extends State<PortfolioAddScreen> {
  final PortfolioController controller = Get.find<PortfolioController>();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController sharesController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<PortfolioItem> searchResults = [];
  bool isSearching = false;
  bool isAdding = false;
  Timer? _debounce;

  @override
  void dispose() {
    searchController.dispose();
    sharesController.dispose();
    priceController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> searchStocks(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
        return;
      }

      setState(() => isSearching = true);
      try {
        final results = await controller.searchStocks(query);
        setState(() {
          searchResults = results;
          isSearching = false;
        });
      } catch (e) {
        Get.snackbar('오류', '종목 검색 중 오류가 발생했습니다');
        setState(() => isSearching = false);
      }
    });
  }

  Future<void> addStock(PortfolioItem stock) async {
    if (isAdding) return; // 중복 추가 방지

    try {
      if (sharesController.text.isEmpty || priceController.text.isEmpty) {
        Get.snackbar('오류', '모든 필드를 입력해주세요');
        return;
      }

      final shares = double.parse(sharesController.text);
      final price = double.parse(priceController.text);

      if (shares <= 0 || price <= 0) {
        Get.snackbar('오류', '수량과 가격은 0보다 커야 합니다');
        return;
      }

      setState(() => isAdding = true);

      final portfolioItem = PortfolioItem(
        symbol: stock.symbol,
        name: stock.name,
        shares: shares,
        averagePrice: price,
        purchaseDate: DateTime.now(),
      );

      // 종목 추가 전에 다이얼로그를 닫습니다
      Get.back();
      await controller.addPortfolioItem(portfolioItem);
      // 종목 추가 화면을 닫습니다
      Get.back();
    } catch (e) {
      Get.snackbar('오류', '올바른 숫자를 입력해주세요');
    } finally {
      setState(() => isAdding = false);
    }
  }

  void showAddDialog(PortfolioItem stock) {
    sharesController.clear();
    priceController.clear();

    Get.dialog(
      AlertDialog(
        title: Text('${stock.name} 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sharesController,
              decoration: const InputDecoration(
                labelText: '보유 수량',
                hintText: '예: 10',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              onSubmitted: (_) =>
                  FocusScope.of(context).nextFocus(), // Enter 키로 다음 필드로 이동
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: '평균 매수가',
                hintText: '예: 150.50',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (_) => addStock(stock), // Enter 키로 저장
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: isAdding ? null : () => addStock(stock),
            child: isAdding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('추가'),
          ),
        ],
      ),
      barrierDismissible: !isAdding, // 저장 중에는 바깥 클릭으로 닫기 방지
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종목 추가'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: '종목 검색',
                hintText: '종목명 또는 심볼을 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchStocks('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => searchStocks(value),
            ),
          ),
          Expanded(
            child: isSearching
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchController.text.isEmpty
                                  ? '종목을 검색해주세요'
                                  : '검색 결과가 없습니다',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final stock = searchResults[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.business),
                            ),
                            title: Text(stock.name),
                            subtitle: Text(stock.symbol),
                            trailing: const Icon(Icons.add),
                            onTap: () => showAddDialog(stock),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
