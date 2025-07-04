import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/portfolio_controller.dart';
import '../../models/stock.dart';
import '../../models/portfolio_item.dart';
import '../../services/stock_service.dart';

class PortfolioAddScreen extends StatefulWidget {
  const PortfolioAddScreen({super.key});

  @override
  State<PortfolioAddScreen> createState() => _PortfolioAddScreenState();
}

class _PortfolioAddScreenState extends State<PortfolioAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockService = StockService();
  final _portfolioController = Get.find<PortfolioController>();

  Stock? _selectedStock;
  DateTime _purchaseDate = DateTime.now();

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _searchStock() async {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    try {
      final stock = await _stockService.getStockInfo(symbol);
      setState(() {
        _selectedStock = stock;
      });
    } catch (e) {
      Get.snackbar(
        '오류',
        '종목 검색 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  void _addPortfolio() {
    if (!_formKey.currentState!.validate() || _selectedStock == null) return;

    final quantity = int.parse(_quantityController.text);
    final price = double.parse(_priceController.text);

    final portfolioItem = PortfolioItem(
      stock: _selectedStock!,
      quantity: quantity,
      averagePrice: price,
      purchaseDate: _purchaseDate,
    );

    _portfolioController.addPortfolioItem(portfolioItem);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종목 추가'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _symbolController,
                      decoration: const InputDecoration(
                        labelText: '종목 심볼',
                        hintText: '예: AAPL',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '종목 심볼을 입력하세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _searchStock,
                    child: const Text('검색'),
                  ),
                ],
              ),
              if (_selectedStock != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('종목명: ${_selectedStock!.name}'),
                        Text('거래소: ${_selectedStock!.exchange}'),
                        Text('통화: ${_selectedStock!.currency}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '수량',
                    hintText: '보유 수량을 입력하세요',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '수량을 입력하세요';
                    }
                    if (int.tryParse(value) == null) {
                      return '올바른 숫자를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '평균단가',
                    hintText: '매수 평균단가를 입력하세요',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '평균단가를 입력하세요';
                    }
                    if (double.tryParse(value) == null) {
                      return '올바른 숫자를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('매수일'),
                  subtitle: Text(_purchaseDate.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addPortfolio,
                  child: const Text('추가하기'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
