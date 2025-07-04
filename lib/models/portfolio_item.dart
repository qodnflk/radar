import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'portfolio_item.g.dart';

@JsonSerializable()
class PortfolioItem {
  String? id;

  final String symbol;
  final String name;
  final double shares;
  final double averagePrice;
  final DateTime purchaseDate;

  PortfolioItem({
    this.id,
    required this.symbol,
    required this.name,
    required this.shares,
    required this.averagePrice,
    required this.purchaseDate,
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
      };
    } catch (e) {
      print('Error converting PortfolioItem to JSON: $e');
      rethrow;
    }
  }

  double get totalValue => shares * averagePrice;

  @override
  String toString() {
    return 'PortfolioItem(id: $id, symbol: $symbol, name: $name, shares: $shares, averagePrice: $averagePrice)';
  }
}
