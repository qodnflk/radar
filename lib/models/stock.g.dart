// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockAdapter extends TypeAdapter<Stock> {
  @override
  final int typeId = 1;

  @override
  Stock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Stock(
      symbol: fields[0] as String,
      name: fields[1] as String,
      exchange: fields[2] as String,
      currency: fields[3] as String,
      currentPrice: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Stock obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exchange)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.currentPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
