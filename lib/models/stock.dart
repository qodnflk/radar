import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'stock.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Stock {
  @HiveField(0)
  @JsonKey(name: 'symbol')
  final String symbol;

  @HiveField(1)
  @JsonKey(name: 'shortname', defaultValue: '')
  final String name;

  @HiveField(2)
  @JsonKey(name: 'exchange', defaultValue: '')
  final String exchange;

  @HiveField(3)
  @JsonKey(name: 'currency', defaultValue: 'USD')
  final String currency;

  @HiveField(4)
  @JsonKey(name: 'regularMarketPrice', defaultValue: 0.0)
  final double currentPrice;

  Stock({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currency,
    required this.currentPrice,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
  Map<String, dynamic> toJson() => _$StockToJson(this);
}
