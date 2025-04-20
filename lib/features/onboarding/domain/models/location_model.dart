class StateDistrictModel {
  final String state;
  final List<String> districts;

  StateDistrictModel({
    required this.state,
    required this.districts,
  });

  factory StateDistrictModel.fromJson(Map<String, dynamic> json) {
    return StateDistrictModel(
      state: json['state'],
      districts: List<String>.from(json['districts']),
    );
  }
}
