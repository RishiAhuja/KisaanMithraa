import 'package:equatable/equatable.dart';

class WatchlistItem extends Equatable {
  final String market;
  final String commodity;
  final String variety;
  final String state;
  final String district;

  const WatchlistItem({
    required this.market,
    required this.commodity,
    required this.variety,
    required this.state,
    required this.district,
  });

  // Create from JSON for storage
  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      market: json['market'] as String,
      commodity: json['commodity'] as String,
      variety: json['variety'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'market': market,
      'commodity': commodity,
      'variety': variety,
      'state': state,
      'district': district,
    };
  }

  // Unique identifier for this watchlist item
  String get uniqueId => '$state-$district-$market-$commodity-$variety';

  @override
  List<Object?> get props => [market, commodity, variety, state, district];
}
