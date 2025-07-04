import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'dividend.g.dart';

@JsonSerializable()
class Dividend {
  @JsonKey(name: 'symbol')
  final String symbol;

  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'exDate')
  final DateTime exDate;

  @JsonKey(name: 'payDate')
  final DateTime payDate;

  @JsonKey(name: 'frequency')
  final String frequency;

  @JsonKey(name: 'dividendYield')
  final double dividendYield;

  Dividend({
    required this.symbol,
    required this.amount,
    required this.currency,
    required this.exDate,
    required this.payDate,
    required this.frequency,
    required this.dividendYield,
  });

  factory Dividend.fromJson(Map<String, dynamic> json) {
    return Dividend(
      symbol: json['symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      exDate: (json['exDate'] as Timestamp).toDate(),
      payDate: (json['payDate'] as Timestamp).toDate(),
      frequency: json['frequency'] as String,
      dividendYield: (json['dividendYield'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'amount': amount,
        'currency': currency,
        'exDate': Timestamp.fromDate(exDate),
        'payDate': Timestamp.fromDate(payDate),
        'frequency': frequency,
        'dividendYield': dividendYield,
      };

  // 연간 배당금 계산
  double get annualAmount {
    switch (frequency.toLowerCase()) {
      case 'monthly':
        return amount * 12;
      case 'quarterly':
        return amount * 4;
      case 'semi-annual':
        return amount * 2;
      case 'annual':
        return amount;
      default:
        return amount;
    }
  }
}
