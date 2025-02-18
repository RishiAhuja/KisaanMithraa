import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'pending_invite_model.g.dart';

@HiveType(typeId: 2)
class PendingInvite {
  @HiveField(0)
  final String cooperativeId;

  @HiveField(1)
  final DateTime invitedAt;

  PendingInvite({
    required this.cooperativeId,
    required this.invitedAt,
  });

  factory PendingInvite.fromMap(Map<String, dynamic> map) {
    return PendingInvite(
      cooperativeId: map['cooperativeId'] as String,
      invitedAt: (map['invitedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cooperativeId': cooperativeId,
      'invitedAt': Timestamp.fromDate(invitedAt),
    };
  }
}
