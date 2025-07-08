import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio_item.dart';

class PortfolioAddScreen extends StatefulWidget {
  final PortfolioItem? editingItem;

  const PortfolioAddScreen({super.key, this.editingItem});

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

  bool get isEditMode => widget.editingItem != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // 수정 모드일 때 기존 값으로 초기화
      final item = widget.editingItem!;
      searchController.text = '${item.name} (${item.symbol})';
      sharesController.text = item.shares.toString();
      priceController.text = item.averagePrice.toString();
    }
  }

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

  Future<void> addOrUpdateStock(PortfolioItem stock) async {
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
        id: isEditMode ? widget.editingItem!.id : null,
        symbol: stock.symbol,
        name: stock.name,
        shares: shares,
        averagePrice: price,
        purchaseDate:
            isEditMode ? widget.editingItem!.purchaseDate : DateTime.now(),
      );

      // 다이얼로그를 닫습니다
      Get.back();

      try {
        if (isEditMode) {
          await controller.editPortfolioItem(
              widget.editingItem!, portfolioItem);
        } else {
          await controller.addPortfolioItem(portfolioItem);
        }

        // 성공 시 화면을 닫고 포트폴리오 리스트로 돌아갑니다
        Get.back();
      } catch (e) {
        print('Portfolio operation error: $e');
        // 오류가 발생해도 화면을 닫습니다
        Get.back();
      }
    } catch (e) {
      Get.snackbar('오류', '올바른 숫자를 입력해주세요');
    } finally {
      setState(() => isAdding = false);
    }
  }

  void showAddDialog(PortfolioItem stock) {
    if (!isEditMode) {
      sharesController.clear();
      priceController.clear();
    }

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
                      color: const Color(0xFF1A237E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Color(0xFF1A237E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditMode ? '종목 정보 수정' : '종목 추가',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stock.name,
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
                      '종목 심볼: ${stock.symbol}',
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
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                onSubmitted: (_) => addOrUpdateStock(stock),
              ),
              const SizedBox(height: 24),

              // 액션 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isAdding ? null : () => Get.back(),
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
                    onPressed: isAdding ? null : () => addOrUpdateStock(stock),
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
                    child: isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEditMode ? Icons.edit : Icons.add,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEditMode ? '수정' : '추가',
                                style: const TextStyle(
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
      barrierDismissible: !isAdding,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 수정 모드일 때는 바로 다이얼로그 표시
    if (isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAddDialog(widget.editingItem!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '종목 수정' : '종목 추가'),
      ),
      body: isEditMode
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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
