import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_item.dart';
import '../models/stock.dart';
import '../services/stock_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class PortfolioController extends GetxController {
  final StockService _stockService = StockService();
  final _firestore = FirebaseFirestore.instance;
  
  final RxList<PortfolioItem> portfolioItems = <PortfolioItem>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription<QuerySnapshot>? _portfolioSubscription;

  void _showSnackBar(String title, String message, {bool isError = false}) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      isDismissible: true,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _setupPortfolioListener();
  }

  @override
  void onClose() {
    _portfolioSubscription?.cancel();
    super.onClose();
  }

  void _setupPortfolioListener() {
    try {
      _portfolioSubscription?.cancel();
      _portfolioSubscription = _firestore
          .collection('portfolio')
          .snapshots()
          .listen((snapshot) {
        final items = <PortfolioItem>[];
        
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            data['id'] = doc.id;
            
            if (data['purchaseDate'] is Timestamp) {
              data['purchaseDate'] = (data['purchaseDate'] as Timestamp).toDate();
            }
            
            items.add(PortfolioItem.fromJson(data));
          } catch (e) {
            print('Error parsing portfolio item: $e');
          }
        }
        
        portfolioItems.value = items;
      }, onError: (error) {
        print('Error in portfolio listener: $error');
        _showSnackBar('오류', '포트폴리오 업데이트 중 오류가 발생했습니다', isError: true);
      });
    } catch (e) {
      print('Error setting up portfolio listener: $e');
    }
  }

  Future<void> clearPortfolio() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore.collection('portfolio').get();
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _showSnackBar('성공', '포트폴리오가 초기화되었습니다');
    } catch (e) {
      print('Error clearing portfolio: $e');
      _showSnackBar('오류', '포트폴리오 초기화 중 오류가 발생했습니다', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPortfolioItem(PortfolioItem item) async {
    try {
      final data = {
        'symbol': item.symbol,
        'name': item.name,
        'shares': item.shares,
        'averagePrice': item.averagePrice,
        'purchaseDate': Timestamp.fromDate(item.purchaseDate),
      };
      
      await _firestore.collection('portfolio').add(data);
      
      // 먼저 다이얼로그를 닫고
      Get.back();
      // 그 다음 종목 추가 화면을 닫음
      Get.back();
      
      _showSnackBar('성공', '${item.name} 종목이 추가되었습니다');
    } catch (e) {
      print('Error adding portfolio item: $e');
      _showSnackBar('오류', '종목 추가 중 오류가 발생했습니다', isError: true);
      rethrow;
    }
  }

  Future<void> updatePortfolioItem(PortfolioItem item) async {
    try {
      if (item.id == null) {
        throw Exception('Portfolio item ID is null');
      }

      final data = {
        'symbol': item.symbol,
        'name': item.name,
        'shares': item.shares,
        'averagePrice': item.averagePrice,
        'purchaseDate': Timestamp.fromDate(item.purchaseDate),
      };

      await _firestore.collection('portfolio').doc(item.id).update(data);
      _showSnackBar('성공', '${item.name} 종목이 수정되었습니다');
    } catch (e) {
      print('Error updating portfolio item: $e');
      _showSnackBar('오류', '종목 수정 중 오류가 발생했습니다', isError: true);
      rethrow;
    }
  }

  Future<void> deletePortfolioItem(String id) async {
    try {
      final item = portfolioItems.firstWhere((item) => item.id == id);
      await _firestore.collection('portfolio').doc(id).delete();
      _showSnackBar('성공', '${item.name} 종목이 삭제되었습니다');
    } catch (e) {
      print('Error deleting portfolio item: $e');
      _showSnackBar('오류', '종목 삭제 중 오류가 발생했습니다', isError: true);
      rethrow;
    }
  }

  Future<List<PortfolioItem>> searchStocks(String query) async {
    try {
      final stocks = await _stockService.searchStocks(query);
      return stocks.map((stock) => PortfolioItem(
        symbol: stock.symbol,
        name: stock.name,
        shares: 0,
        averagePrice: 0,
        purchaseDate: DateTime.now(),
      )).toList();
    } catch (e) {
      print('Error searching stocks: $e');
      _showSnackBar('오류', '종목 검색 중 오류가 발생했습니다', isError: true);
      return [];
    }
  }
}
