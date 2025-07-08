import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_item.dart';
import '../services/stock_service.dart';
import '../services/local_database_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class PortfolioController extends GetxController {
  // 싱글톤 인스턴스로 메모리 효율성 향상
  static PortfolioController? _instance;
  factory PortfolioController() =>
      _instance ??= PortfolioController._internal();
  PortfolioController._internal();

  // Lazy initialization으로 메모리 사용량 감소
  StockService? _stockService;
  StockService get stockService => _stockService ??= StockService();

  final _firestore = FirebaseFirestore.instance;

  final RxList<PortfolioItem> portfolioItems = <PortfolioItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = true.obs;
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
    _loadInitialData();
    _setupPortfolioListener();
  }

  @override
  void onClose() {
    // 메모리 누수 방지를 위한 리소스 정리
    _portfolioSubscription?.cancel();
    _portfolioSubscription = null;

    // 대용량 리스트 정리
    portfolioItems.clear();

    // 서비스 인스턴스 정리
    _stockService = null;

    super.onClose();
  }

  /// 초기 데이터 로드 (로컬 우선, 온라인 백업)
  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;

      // 먼저 로컬 데이터 로드
      await _loadLocalData();

      // 동기화가 필요한지 확인
      if (LocalDatabaseService.needsSync('portfolio')) {
        await _syncWithFirebase();
      }
    } catch (e) {
      _showSnackBar('오류', '데이터 로드 중 오류가 발생했습니다', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// 로컬 데이터 로드
  Future<void> _loadLocalData() async {
    try {
      final localItems = LocalDatabaseService.getPortfolioItems();
      if (localItems.isNotEmpty) {
        portfolioItems.value = localItems;
      }
    } catch (e) {
      // 로컬 데이터 로드 실패해도 계속 진행 (메모리 효율성을 위해 로깅 생략)
    }
  }

  /// Firebase와 동기화
  Future<void> _syncWithFirebase() async {
    try {
      isOnline.value = true;
      final snapshot = await _firestore.collection('portfolio').get();
      final firebaseItems = <PortfolioItem>[];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          firebaseItems.add(PortfolioItem.fromJson(data));
        } catch (e) {
          // 파싱 오류 무시 (메모리 효율성을 위해 로깅 생략)
        }
      }

      // Firebase 데이터를 로컬에 저장
      for (final item in firebaseItems) {
        await LocalDatabaseService.savePortfolioItem(item);
      }

      portfolioItems.value = firebaseItems;
      await LocalDatabaseService.setSyncTimestamp('portfolio');
    } catch (e) {
      print('Error syncing with Firebase: $e');
      isOnline.value = false;
      _showSnackBar('오프라인', '네트워크 연결을 확인해주세요', isError: true);
    }
  }

  void _setupPortfolioListener() {
    try {
      _portfolioSubscription?.cancel();
      _portfolioSubscription =
          _firestore.collection('portfolio').snapshots().listen((snapshot) {
        // 로딩 중이면 리스너 업데이트 무시 (수동 작업 중)
        if (isLoading.value) return;

        isOnline.value = true;
        final items = <PortfolioItem>[];

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            data['id'] = doc.id;

            if (data['purchaseDate'] is Timestamp) {
              data['purchaseDate'] =
                  (data['purchaseDate'] as Timestamp).toDate();
            }

            final item = PortfolioItem.fromJson(data);
            items.add(item);

            // 로컬에도 저장
            LocalDatabaseService.savePortfolioItem(item);
          } catch (e) {
            print('Error parsing portfolio item: $e');
          }
        }

        // 현재 리스트와 다를 때만 업데이트
        if (items.length != portfolioItems.length ||
            !_areListsEqual(items, portfolioItems)) {
          portfolioItems.value = items;
          LocalDatabaseService.setSyncTimestamp('portfolio');
        }
      }, onError: (error) {
        print('Error in portfolio listener: $error');
        isOnline.value = false;
        _showSnackBar('오프라인', '실시간 업데이트가 일시 중단되었습니다', isError: true);
      });
    } catch (e) {
      print('Error setting up portfolio listener: $e');
    }
  }

  bool _areListsEqual(List<PortfolioItem> list1, List<PortfolioItem> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].symbol != list2[i].symbol) return false;
    }
    return true;
  }

  Future<void> clearPortfolio() async {
    try {
      isLoading.value = true;

      if (isOnline.value) {
        // Firebase에서 삭제
        final snapshot = await _firestore.collection('portfolio').get();
        final batch = _firestore.batch();

        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }

      // 로컬에서도 삭제
      await LocalDatabaseService.clearAll();

      // 메모리 리스트도 비우기
      portfolioItems.clear();
      portfolioItems.refresh();

      _showSnackBar('성공', '포트폴리오가 초기화되었습니다');

      // 잠시 대기 후 로딩 해제 (UI 업데이트 보장)
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      print('Error clearing portfolio: $e');
      _showSnackBar('오류', '포트폴리오 초기화 중 오류가 발생했습니다', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPortfolioItem(PortfolioItem item) async {
    try {
      isLoading.value = true;

      final data = {
        'symbol': item.symbol,
        'name': item.name,
        'shares': item.shares,
        'averagePrice': item.averagePrice,
        'purchaseDate': Timestamp.fromDate(item.purchaseDate),
      };

      if (isOnline.value) {
        // Firebase에 추가
        final docRef = await _firestore.collection('portfolio').add(data);
        item = PortfolioItem(
          id: docRef.id,
          symbol: item.symbol,
          name: item.name,
          shares: item.shares,
          averagePrice: item.averagePrice,
          purchaseDate: item.purchaseDate,
        );
      } else {
        // 오프라인 모드: 임시 ID 생성
        item = PortfolioItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          symbol: item.symbol,
          name: item.name,
          shares: item.shares,
          averagePrice: item.averagePrice,
          purchaseDate: item.purchaseDate,
        );
      }

      // 로컬에도 저장
      await LocalDatabaseService.savePortfolioItem(item);

      // 메모리 리스트에도 추가하여 UI에 즉시 반영
      portfolioItems.add(item);
      portfolioItems.refresh();

      _showSnackBar('성공', '${item.name} 종목이 추가되었습니다');

      // 잠시 대기 후 로딩 해제 (UI 업데이트 보장)
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      print('Error adding portfolio item: $e');
      _showSnackBar('오류', '종목 추가 중 오류가 발생했습니다', isError: true);
    } finally {
      isLoading.value = false;
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

      if (isOnline.value) {
        // Firebase 업데이트
        await _firestore.collection('portfolio').doc(item.id).update(data);
      }

      // 로컬도 업데이트
      await LocalDatabaseService.savePortfolioItem(item);

      // 메모리 리스트에서도 업데이트하여 UI에 즉시 반영
      final index = portfolioItems.indexWhere((p) => p.id == item.id);
      if (index != -1) {
        portfolioItems[index] = item;
        portfolioItems.refresh(); // GetX 리스트 새로고침
      }

      _showSnackBar('성공', '${item.name} 종목이 수정되었습니다');
    } catch (e) {
      print('Error updating portfolio item: $e');
      _showSnackBar('오류', '종목 수정 중 오류가 발생했습니다', isError: true);
      rethrow;
    }
  }

  Future<void> deletePortfolioItem(String id) async {
    try {
      isLoading.value = true;

      final item = portfolioItems.firstWhere((item) => item.id == id);

      if (isOnline.value) {
        // Firebase에서 삭제
        await _firestore.collection('portfolio').doc(id).delete();
      }

      // 로컬에서도 삭제
      await LocalDatabaseService.deletePortfolioItem(id);

      // 메모리 리스트에서도 제거
      portfolioItems.removeWhere((item) => item.id == id);
      portfolioItems.refresh();

      _showSnackBar('성공', '${item.name} 종목이 삭제되었습니다');
    } catch (e) {
      print('Error deleting portfolio item: $e');
      _showSnackBar('오류', '종목 삭제 중 오류가 발생했습니다', isError: true);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PortfolioItem>> searchStocks(String query) async {
    try {
      final stocks = await stockService.searchStocks(query);

      // 검색 결과를 로컬 캐시에 저장
      for (final stock in stocks) {
        await LocalDatabaseService.saveStock(stock);
      }

      return stocks
          .map((stock) => PortfolioItem(
                symbol: stock.symbol,
                name: stock.name,
                shares: 0,
                averagePrice: 0,
                purchaseDate: DateTime.now(),
              ))
          .toList();
    } catch (e) {
      print('Error searching stocks: $e');
      _showSnackBar('오류', '종목 검색 중 오류가 발생했습니다', isError: true);
      return [];
    }
  }

  /// 수동 동기화
  Future<void> manualSync() async {
    try {
      isLoading.value = true;
      await _syncWithFirebase();
      _showSnackBar('성공', '데이터가 동기화되었습니다');
    } catch (e) {
      print('Error in manual sync: $e');
      _showSnackBar('오류', '동기화 중 오류가 발생했습니다', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removePortfolioItem(PortfolioItem item) async {
    await LocalDatabaseService.deletePortfolioItem(item.id ?? item.symbol);
    portfolioItems.removeWhere((p) => p.symbol == item.symbol);
    portfolioItems.refresh();
  }

  Future<void> editPortfolioItem(
      PortfolioItem originalItem, PortfolioItem updatedItem) async {
    try {
      isLoading.value = true;

      // 기존 아이템을 삭제하고 새 아이템으로 교체
      await LocalDatabaseService.deletePortfolioItem(
          originalItem.id ?? originalItem.symbol);
      await LocalDatabaseService.savePortfolioItem(updatedItem);

      // 메모리에서도 업데이트
      final index = portfolioItems
          .indexWhere((item) => item.symbol == originalItem.symbol);
      if (index != -1) {
        portfolioItems[index] = updatedItem;
        portfolioItems.refresh();
      }

      Get.snackbar(
        '성공',
        '${updatedItem.name} 정보가 업데이트되었습니다',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green.shade700,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '포트폴리오 업데이트 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red.shade700,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
