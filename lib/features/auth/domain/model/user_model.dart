import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final DateTime createdAt;

  UserModel({
    required this.name,
    required this.id,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
