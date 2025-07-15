import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'portfolio_item.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class PortfolioItem {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String symbol;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final double shares;
  @HiveField(4)
  final double averagePrice;
  @HiveField(5)
  final DateTime purchaseDate;
  @HiveField(6)
  double? currentPrice; // 현재 가격 추가

  PortfolioItem({
    this.id,
    required this.symbol,
    required this.name,
    required this.shares,
    required this.averagePrice,
    required this.purchaseDate,
    this.currentPrice,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    try {
      // ID 처리
      final String? id = json['id'] as String?;

      // 필수 문자열 필드 처리
      final String symbol = json['symbol'] as String? ?? '';
      final String name = json['name'] as String? ?? '';

      // 숫자 필드 처리
      final double shares = (json['shares'] as num?)?.toDouble() ?? 0.0;
      final double averagePrice =
          (json['averagePrice'] as num?)?.toDouble() ?? 0.0;
      final double? currentPrice = (json['currentPrice'] as num?)?.toDouble();

      // 날짜 처리
      DateTime purchaseDate;
      final purchaseDateRaw = json['purchaseDate'];
      if (purchaseDateRaw is Timestamp) {
        purchaseDate = purchaseDateRaw.toDate();
      } else if (purchaseDateRaw is String) {
        purchaseDate = DateTime.parse(purchaseDateRaw);
      } else {
        purchaseDate = DateTime.now();
      }

      return PortfolioItem(
        id: id,
        symbol: symbol,
        name: name,
        shares: shares,
        averagePrice: averagePrice,
        purchaseDate: purchaseDate,
        currentPrice: currentPrice,
      );
    } catch (e) {
      print('Error parsing PortfolioItem: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'symbol': symbol,
        'name': name,
        'shares': shares,
        'averagePrice': averagePrice,
        'purchaseDate': Timestamp.fromDate(purchaseDate),
        'currentPrice': currentPrice,
      };
    } catch (e) {
      print('Error converting PortfolioItem to JSON: $e');
      rethrow;
    }
  }

  // 기존 매입 기준 총액 (변경 없음)
  double get totalValue => shares * averagePrice;

  // 현재 시가 총액
  double get currentTotalValue => (currentPrice ?? averagePrice) * shares;

  // 손익 계산
  double get gainLoss => currentTotalValue - totalValue;

  // 수익률 계산
  double get gainLossPercentage =>
      totalValue > 0 ? (gainLoss / totalValue) * 100 : 0;

  // 현재 가격이 있는지 확인
  bool get hasCurrentPrice => currentPrice != null;

  // 손익 상태 (수익/손실/변동없음)
  String get gainLossStatus {
    if (gainLoss > 0) return 'profit';
    if (gainLoss < 0) return 'loss';
    return 'neutral';
  }

  // PortfolioItem 복사 (currentPrice 업데이트용)
  PortfolioItem copyWith({
    String? id,
    String? symbol,
    String? name,
    double? shares,
    double? averagePrice,
    DateTime? purchaseDate,
    double? currentPrice,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      shares: shares ?? this.shares,
      averagePrice: averagePrice ?? this.averagePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  @override
  String toString() {
    return 'PortfolioItem(id: $id, symbol: $symbol, name: $name, shares: $shares, averagePrice: $averagePrice, currentPrice: $currentPrice)';
  }
}
