import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_item.dart';
import '../models/stock.dart';

class PortfolioController extends GetxController {
  final RxList<PortfolioItem> portfolioItems = <PortfolioItem>[].obs;
  final RxBool isLoading = false.obs;

  static const String _boxName = 'portfolio';
  Box<PortfolioItem>? _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() async {
    super.onInit();
    await _initHive();
    await loadPortfolio();
  }

  @override
  void onClose() {
    _box?.close();
    super.onClose();
  }

  Future<void> _initHive() async {
    try {
      _box = await Hive.openBox<PortfolioItem>(_boxName);
    } catch (e) {
      Get.snackbar(
        '오류',
        'Hive 초기화 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadPortfolio() async {
    if (_box == null) {
      await _initHive();
    }

    isLoading.value = true;
    try {
      // 로컬 데이터 로드
      if (_box != null) {
        portfolioItems.value = _box!.values.toList();
      }

      // Firestore 데이터 동기화
      final snapshot = await _firestore.collection('portfolio').get();
      final cloudItems = snapshot.docs
          .map((doc) => PortfolioItem(
                stock: Stock(
                  symbol: doc['symbol'],
                  name: doc['name'],
                  exchange: doc['exchange'],
                  currency: doc['currency'],
                ),
                quantity: doc['quantity'],
                averagePrice: doc['averagePrice'].toDouble(),
                purchaseDate: (doc['purchaseDate'] as Timestamp).toDate(),
              ))
          .toList();

      // 로컬 데이터 업데이트
      if (_box != null) {
        await _box!.clear();
        await _box!.addAll(cloudItems);
      }
      portfolioItems.value = cloudItems;
    } catch (e) {
      Get.snackbar(
        '오류',
        '포트폴리오 로드 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPortfolioItem(PortfolioItem item) async {
    if (_box == null) {
      await _initHive();
    }

    try {
      // 로컬 저장
      if (_box != null) {
        final index = await _box!.add(item);
        portfolioItems.add(item);

        // Firestore 저장
        await _firestore.collection('portfolio').doc(index.toString()).set({
          'symbol': item.stock.symbol,
          'name': item.stock.name,
          'exchange': item.stock.exchange,
          'currency': item.stock.currency,
          'quantity': item.quantity,
          'averagePrice': item.averagePrice,
          'purchaseDate': item.purchaseDate,
        });

        Get.snackbar(
          '성공',
          '${item.stock.name} 종목이 추가되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '종목 추가 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updatePortfolioItem(int index, PortfolioItem item) async {
    if (_box == null) {
      await _initHive();
    }

    try {
      // 로컬 업데이트
      if (_box != null) {
        await _box!.putAt(index, item);
        portfolioItems[index] = item;

        // Firestore 업데이트
        await _firestore.collection('portfolio').doc(index.toString()).update({
          'quantity': item.quantity,
          'averagePrice': item.averagePrice,
        });

        Get.snackbar(
          '성공',
          '${item.stock.name} 종목이 업데이트되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '종목 업데이트 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deletePortfolioItem(int index) async {
    if (_box == null) {
      await _initHive();
    }

    try {
      if (_box != null) {
        final item = portfolioItems[index];

        // 로컬 삭제
        await _box!.deleteAt(index);
        portfolioItems.removeAt(index);

        // Firestore 삭제
        await _firestore.collection('portfolio').doc(index.toString()).delete();

        Get.snackbar(
          '성공',
          '${item.stock.name} 종목이 삭제되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '오류',
        '종목 삭제 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
