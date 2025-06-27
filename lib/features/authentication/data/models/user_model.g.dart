// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String,
      role: fields[3] as String,
      securityQuestion: fields[4] as String,
      securityAnswer: fields[5] as String,
      secretWord: fields[6] as String,
      cnic: fields[7] as String?,
      passport: fields[8] as String?,
      phoneNumbers: (fields[9] as List?)?.cast<String>(),
      nikkahNama: fields[10] as String?,
      husbandBirthday: fields[11] as String?,
      wifeBirthday: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.securityQuestion)
      ..writeByte(5)
      ..write(obj.securityAnswer)
      ..writeByte(6)
      ..write(obj.secretWord)
      ..writeByte(7)
      ..write(obj.cnic)
      ..writeByte(8)
      ..write(obj.passport)
      ..writeByte(9)
      ..write(obj.phoneNumbers)
      ..writeByte(10)
      ..write(obj.nikkahNama)
      ..writeByte(11)
      ..write(obj.husbandBirthday)
      ..writeByte(12)
      ..write(obj.wifeBirthday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
