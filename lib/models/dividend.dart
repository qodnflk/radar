import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'stock.dart';

part 'dividend.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class Dividend {
  @HiveField(0)
  final Stock stock;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime exDate;

  @HiveField(3)
  final DateTime paymentDate;

  @HiveField(4)
  final String frequency; // quarterly, monthly, annual, etc.

  Dividend({
    required this.stock,
    required this.amount,
    required this.exDate,
    required this.paymentDate,
    required this.frequency,
  });

  factory Dividend.fromJson(Map<String, dynamic> json) =>
      _$DividendFromJson(json);
  Map<String, dynamic> toJson() => _$DividendToJson(this);
}
