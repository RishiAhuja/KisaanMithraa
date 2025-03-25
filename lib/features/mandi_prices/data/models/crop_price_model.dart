import 'package:equatable/equatable.dart';

class CropPriceModel extends Equatable {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final String grade;
  final String arrivalDate;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;

  const CropPriceModel({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.grade,
    required this.arrivalDate,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory CropPriceModel.fromJson(Map<String, dynamic> json) {
    return CropPriceModel(
      state: json['state'] as String,
      district: json['district'] as String,
      market: json['market'] as String,
      commodity: json['commodity'] as String,
      variety: json['variety'] as String,
      grade: json['grade'] as String,
      arrivalDate: json['arrival_date'] as String,
      minPrice: double.parse(json['min_price'] as String),
      maxPrice: double.parse(json['max_price'] as String),
      modalPrice: double.parse(json['modal_price'] as String),
    );
  }

  @override
  List<Object?> get props => [
        state,
        district,
        market,
        commodity,
        variety,
        grade,
        arrivalDate,
        minPrice,
        maxPrice,
        modalPrice,
      ];
}
