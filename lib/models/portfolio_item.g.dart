// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PortfolioItemAdapter extends TypeAdapter<PortfolioItem> {
  @override
  final int typeId = 0;

  @override
  PortfolioItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortfolioItem(
      id: fields[0] as String?,
      symbol: fields[1] as String,
      name: fields[2] as String,
      shares: fields[3] as double,
      averagePrice: fields[4] as double,
      purchaseDate: fields[5] as DateTime,
      currentPrice: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PortfolioItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.shares)
      ..writeByte(4)
      ..write(obj.averagePrice)
      ..writeByte(5)
      ..write(obj.purchaseDate)
      ..writeByte(6)
      ..write(obj.currentPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortfolioItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      currentPrice: (json['currentPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'shares': instance.shares,
      'averagePrice': instance.averagePrice,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'currentPrice': instance.currentPrice,
    };
