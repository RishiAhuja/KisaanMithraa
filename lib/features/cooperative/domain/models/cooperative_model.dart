import 'package:cloud_firestore/cloud_firestore.dart';

class CooperativeModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String location;
  final List<String> cropTypes;
  final double latitude;
  final double longitude;
  final List<String> members;
  final String adminId;
  final String adminName;
  final String adminNumber;

  CooperativeModel({
    required this.adminId,
    required this.adminName,
    required this.adminNumber,
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.location,
    required this.cropTypes,
    required this.latitude,
    required this.longitude,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location,
      'cropTypes': cropTypes,
      'latitude': latitude,
      'longitude': longitude,
      'members': members,
      'adminId': adminId,
      'adminName': adminName,
      'adminNumber': adminNumber
    };
  }

  factory CooperativeModel.fromMap(Map<String, dynamic> map) {
    return CooperativeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      members: List<String>.from(map['members'] ?? []),
      adminId: map['adminId'],
      adminName: map['adminName'],
      adminNumber: map['adminNumber'],
    );
  }
}
