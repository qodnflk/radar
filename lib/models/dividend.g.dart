// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dividend.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DividendAdapter extends TypeAdapter<Dividend> {
  @override
  final int typeId = 2;

  @override
  Dividend read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dividend(
      symbol: fields[0] as String,
      amount: fields[1] as double,
      currency: fields[2] as String,
      exDate: fields[3] as DateTime,
      payDate: fields[4] as DateTime,
      frequency: fields[5] as String,
      dividendYield: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Dividend obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.exDate)
      ..writeByte(4)
      ..write(obj.payDate)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.dividendYield);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DividendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
