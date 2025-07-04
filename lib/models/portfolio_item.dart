import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'stock.dart';

part 'portfolio_item.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class PortfolioItem {
  @HiveField(0)
  final Stock stock;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double averagePrice;

  @HiveField(3)
  final DateTime purchaseDate;

  PortfolioItem({
    required this.stock,
    required this.quantity,
    required this.averagePrice,
    required this.purchaseDate,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) =>
      _$PortfolioItemFromJson(json);
  Map<String, dynamic> toJson() => _$PortfolioItemToJson(this);
}
