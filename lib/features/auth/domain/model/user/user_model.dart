import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/features/auth/domain/model/user/cooperative_membership_model.dart';
import 'package:cropconnect/features/auth/domain/model/user/pending_invite_model.dart';
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

  @HiveField(4)
  final String? soilType;

  @HiveField(5)
  final List<String>? crops;

  @HiveField(6)
  final String? state;

  @HiveField(7)
  final String? city;

  @HiveField(8)
  final double? latitude;

  @HiveField(9)
  final double? longitude;

  @HiveField(10)
  final List<CooperativeMembership> cooperatives;

  @HiveField(11)
  final List<PendingInvite> pendingInvites;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    this.soilType,
    this.crops,
    this.state,
    this.city,
    this.latitude,
    this.longitude,
    this.cooperatives = const [],
    this.pendingInvites = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      name: map['name'] ?? '',
      soilType: map['soilType'],
      crops: List<String>.from(map['crops'] ?? []),
      state: map['state'],
      city: map['city'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      cooperatives: map['cooperatives'] != null
          ? List<CooperativeMembership>.from(
              map['cooperatives'].map((x) => CooperativeMembership.fromMap(x)))
          : [],
      pendingInvites: map['pendingInvites'] != null
          ? List<PendingInvite>.from(
              map['pendingInvites'].map((x) => PendingInvite.fromMap(x)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'soilType': soilType,
      'crops': crops,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'cooperatives': cooperatives.map((x) => x.toMap()).toList(),
      'pendingInvites': pendingInvites.map((x) => x.toMap()).toList(),
    };
  }
}
