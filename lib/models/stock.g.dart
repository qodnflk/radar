// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stock _$StockFromJson(Map<String, dynamic> json) => Stock(
      symbol: json['symbol'] as String,
      name: json['shortname'] as String? ?? '',
      exchange: json['exchange'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      currentPrice: (json['regularMarketPrice'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$StockToJson(Stock instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'shortname': instance.name,
      'exchange': instance.exchange,
      'currency': instance.currency,
      'regularMarketPrice': instance.currentPrice,
    };
