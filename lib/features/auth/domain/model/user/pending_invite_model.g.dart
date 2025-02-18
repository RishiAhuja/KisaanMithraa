// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_invite_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingInviteAdapter extends TypeAdapter<PendingInvite> {
  @override
  final int typeId = 2;

  @override
  PendingInvite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingInvite(
      cooperativeId: fields[0] as String,
      invitedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingInvite obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cooperativeId)
      ..writeByte(1)
      ..write(obj.invitedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingInviteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
