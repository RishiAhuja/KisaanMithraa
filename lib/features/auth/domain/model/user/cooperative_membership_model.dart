import 'package:hive/hive.dart';

part 'cooperative_membership_model.g.dart';

@HiveType(typeId: 1)
class CooperativeMembership {
  @HiveField(0)
  final String cooperativeId;

  @HiveField(1)
  final String role; // 'admin' or 'member'

  CooperativeMembership({
    required this.cooperativeId,
    required this.role,
  });

  factory CooperativeMembership.fromMap(Map<String, dynamic> map) {
    return CooperativeMembership(
      cooperativeId: map['cooperativeId'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cooperativeId': cooperativeId,
      'role': role,
    };
  }
}
