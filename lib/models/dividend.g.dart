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
      stock: fields[0] as Stock,
      amount: fields[1] as double,
      exDate: fields[2] as DateTime,
      paymentDate: fields[3] as DateTime,
      frequency: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Dividend obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.stock)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.exDate)
      ..writeByte(3)
      ..write(obj.paymentDate)
      ..writeByte(4)
      ..write(obj.frequency);
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
      stock: Stock.fromJson(json['stock'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toDouble(),
      exDate: DateTime.parse(json['exDate'] as String),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      frequency: json['frequency'] as String,
    );

Map<String, dynamic> _$DividendToJson(Dividend instance) => <String, dynamic>{
      'stock': instance.stock,
      'amount': instance.amount,
      'exDate': instance.exDate.toIso8601String(),
      'paymentDate': instance.paymentDate.toIso8601String(),
      'frequency': instance.frequency,
    };
