import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Stock {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String exchange;

  @HiveField(3)
  final String currency;

  Stock({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currency,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
  Map<String, dynamic> toJson() => _$StockToJson(this);
}
