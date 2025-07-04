// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dividend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dividend _$DividendFromJson(Map<String, dynamic> json) => Dividend(
      symbol: json['symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      exDate: DateTime.parse(json['exDate'] as String),
      payDate: DateTime.parse(json['payDate'] as String),
      frequency: json['frequency'] as String,
      dividendYield: (json['dividendYield'] as num).toDouble(),
    );

Map<String, dynamic> _$DividendToJson(Dividend instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'amount': instance.amount,
      'currency': instance.currency,
      'exDate': instance.exDate.toIso8601String(),
      'payDate': instance.payDate.toIso8601String(),
      'frequency': instance.frequency,
      'dividendYield': instance.dividendYield,
    };
