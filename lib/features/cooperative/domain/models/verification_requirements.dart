class VerificationRequirements {
  final int minimumMembers;
  final int acceptedInvites;

  VerificationRequirements({
    required this.minimumMembers,
    required this.acceptedInvites,
  });

  Map<String, dynamic> toMap() {
    return {
      'minimumMembers': minimumMembers,
      'acceptedInvites': acceptedInvites,
    };
  }

  factory VerificationRequirements.fromMap(Map<String, dynamic> map) {
    return VerificationRequirements(
      minimumMembers: map['minimumMembers'] ?? 3,
      acceptedInvites: map['acceptedInvites'] ?? 0,
    );
  }
}
