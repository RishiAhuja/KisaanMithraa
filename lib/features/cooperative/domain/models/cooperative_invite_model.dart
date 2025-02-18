import 'package:cloud_firestore/cloud_firestore.dart';

class CooperativeInvite {
  final String userId;
  final DateTime invitedAt;
  final String status; // 'pending', 'accepted', 'declined'

  CooperativeInvite({
    required this.userId,
    required this.invitedAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'invitedAt': Timestamp.fromDate(invitedAt),
      'status': status,
    };
  }

  factory CooperativeInvite.fromMap(Map<String, dynamic> map) {
    return CooperativeInvite(
      userId: map['userId'] ?? '',
      invitedAt: (map['invitedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }
}
