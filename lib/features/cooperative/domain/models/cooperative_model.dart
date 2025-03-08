import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cropconnect/features/cooperative/domain/models/verification_requirements.dart';
import 'cooperative_invite_model.dart';

class CooperativeModel {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final String status; // 'verified' or 'unverified'
  final String? description;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> cropTypes;
  final List<String> members;
  final List<CooperativeInvite> pendingInvites;
  final VerificationRequirements verificationRequirements;
  final String? bannerUrl;

  CooperativeModel({
    required this.id,
    this.bannerUrl,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.cropTypes,
    required this.members,
    required this.pendingInvites,
    required this.verificationRequirements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'cropTypes': cropTypes,
      'members': members,
      'pendingInvites': pendingInvites.map((invite) => invite.toMap()).toList(),
      'verificationRequirements': verificationRequirements.toMap(),
      'bannerUrl': bannerUrl,
    };
  }

  factory CooperativeModel.fromMap(Map<String, dynamic> map) {
    return CooperativeModel(
      bannerUrl: map['bannerUrl'] ?? '',
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'unverified',
      description: map['description'],
      location: map['location'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      members: List<String>.from(map['members'] ?? []),
      pendingInvites: (map['pendingInvites'] as List<dynamic>?)
              ?.map((invite) => CooperativeInvite.fromMap(invite))
              .toList() ??
          [],
      verificationRequirements: VerificationRequirements.fromMap(
        map['verificationRequirements'] ?? {},
      ),
    );
  }

  // Helper method to check if cooperative is verified
  bool get isVerified => status == 'verified';

  // Helper method to check if a user is a member
  bool isMember(String userId) => members.contains(userId);

  // Helper method to check if a user has a pending invite
  bool hasPendingInvite(String userId) {
    return pendingInvites.any(
      (invite) => invite.userId == userId && invite.status == 'pending',
    );
  }
}
