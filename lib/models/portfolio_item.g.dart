// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PortfolioItemAdapter extends TypeAdapter<PortfolioItem> {
  @override
  final int typeId = 1;

  @override
  PortfolioItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortfolioItem(
      stock: fields[0] as Stock,
      quantity: fields[1] as int,
      averagePrice: fields[2] as double,
      purchaseDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PortfolioItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.stock)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.averagePrice)
      ..writeByte(3)
      ..write(obj.purchaseDate);
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
      stock: Stock.fromJson(json['stock'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      averagePrice: (json['averagePrice'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      'stock': instance.stock,
      'quantity': instance.quantity,
      'averagePrice': instance.averagePrice,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
    };
