// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BranchModelAdapter extends TypeAdapter<BranchModel> {
  @override
  final int typeId = 0;

  @override
  BranchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BranchModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      region: fields[2] as String?,
      regionId: fields[3] as int?,
      address: fields[4] as String?,
      lat: fields[5] as String?,
      long: fields[6] as String?,
      phone: fields[7] as String?,
      locationUrl: fields[8] as String?,
      workTime: fields[9] as WorkTime?,
      bookToday: fields[10] as int?,
      deliveryPrice: fields[11] as int?,
      polygon: (fields[12] as List?)?.cast<PolygonPoint>(),
      center: fields[13] as BranchCenter?,
    );
  }

  @override
  void write(BinaryWriter writer, BranchModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.region)
      ..writeByte(3)
      ..write(obj.regionId)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.lat)
      ..writeByte(6)
      ..write(obj.long)
      ..writeByte(7)
      ..write(obj.phone)
      ..writeByte(8)
      ..write(obj.locationUrl)
      ..writeByte(9)
      ..write(obj.workTime)
      ..writeByte(10)
      ..write(obj.bookToday)
      ..writeByte(11)
      ..write(obj.deliveryPrice)
      ..writeByte(12)
      ..write(obj.polygon)
      ..writeByte(13)
      ..write(obj.center);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkTimeAdapter extends TypeAdapter<WorkTime> {
  @override
  final int typeId = 1;

  @override
  WorkTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkTime(
      alldays: fields[0] as Alldays?,
      fri: fields[1] as Fri?,
      sat: fields[2] as Mon?,
      sun: fields[3] as Mon?,
      mon: fields[4] as Mon?,
      tue: fields[5] as Mon?,
      wed: fields[6] as Mon?,
      thu: fields[7] as Mon?,
      openAllDays: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkTime obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.alldays)
      ..writeByte(1)
      ..write(obj.fri)
      ..writeByte(2)
      ..write(obj.sat)
      ..writeByte(3)
      ..write(obj.sun)
      ..writeByte(4)
      ..write(obj.mon)
      ..writeByte(5)
      ..write(obj.tue)
      ..writeByte(6)
      ..write(obj.wed)
      ..writeByte(7)
      ..write(obj.thu)
      ..writeByte(8)
      ..write(obj.openAllDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlldaysAdapter extends TypeAdapter<Alldays> {
  @override
  final int typeId = 2;

  @override
  Alldays read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alldays(
      period: fields[0] as int?,
      morning: fields[1] as Afternone?,
      afternone: fields[2] as Afternone?,
    );
  }

  @override
  void write(BinaryWriter writer, Alldays obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.period)
      ..writeByte(1)
      ..write(obj.morning)
      ..writeByte(2)
      ..write(obj.afternone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlldaysAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FriAdapter extends TypeAdapter<Fri> {
  @override
  final int typeId = 3;

  @override
  Fri read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Fri(
      period: fields[0] as int?,
      morning: fields[1] as Afternone?,
      afternone: fields[2] as Afternone?,
      lock: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Fri obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.period)
      ..writeByte(1)
      ..write(obj.morning)
      ..writeByte(2)
      ..write(obj.afternone)
      ..writeByte(3)
      ..write(obj.lock);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AfternoneAdapter extends TypeAdapter<Afternone> {
  @override
  final int typeId = 4;

  @override
  Afternone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Afternone(
      timeopen: fields[0] as String?,
      timeclose: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Afternone obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timeopen)
      ..writeByte(1)
      ..write(obj.timeclose);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AfternoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MonAdapter extends TypeAdapter<Mon> {
  @override
  final int typeId = 5;

  @override
  Mon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mon(
      lock: fields[0] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Mon obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.lock);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PolygonPointAdapter extends TypeAdapter<PolygonPoint> {
  @override
  final int typeId = 6;

  @override
  PolygonPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PolygonPoint(
      lat: fields[0] as double?,
      lng: fields[1] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PolygonPoint obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolygonPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BranchCenterAdapter extends TypeAdapter<BranchCenter> {
  @override
  final int typeId = 7;

  @override
  BranchCenter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BranchCenter(
      lat: fields[0] as double?,
      lng: fields[1] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BranchCenter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lng);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchCenterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
