import 'package:json_annotation/json_annotation.dart';

part 'stock.g.dart';

@JsonSerializable()
class Stock {
  @JsonKey(name: 'symbol')
  final String symbol;

  @JsonKey(name: 'shortname', defaultValue: '')
  final String name;

  @JsonKey(name: 'exchange', defaultValue: '')
  final String exchange;

  @JsonKey(name: 'currency', defaultValue: 'USD')
  final String currency;

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
