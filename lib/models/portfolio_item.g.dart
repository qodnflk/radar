// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioItem _$PortfolioItemFromJson(Map<String, dynamic> json) =>
    PortfolioItem(
      id: json['id'] as String?,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      shares: (json['shares'] as num).toDouble(),
      averagePrice: (json['averagePrice'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'shares': instance.shares,
      'averagePrice': instance.averagePrice,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
    };
