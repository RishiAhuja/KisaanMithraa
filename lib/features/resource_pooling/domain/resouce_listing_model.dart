import 'package:cloud_firestore/cloud_firestore.dart';
import 'resource_offer_model.dart';

enum ListingType {
  request,
  offer,
}

enum TransactionType {
  buy,
  sell,
  rent,
}

class ResourceListing {
  final String id;
  final String cooperativeId;
  final String userId;
  final String title;
  final String description;
  final ListingType listingType;
  final TransactionType transactionType;
  final double pricePerUnit;
  final int quantityRequired;
  final String unit;
  final DateTime createdAt;
  final DateTime availableFrom;
  final DateTime? availableTo;
  final String status;
  final List<ResourceOffer> offers;

  const ResourceListing({
    required this.id,
    required this.cooperativeId,
    required this.userId,
    required this.title,
    required this.description,
    required this.listingType,
    required this.transactionType,
    required this.pricePerUnit,
    required this.quantityRequired,
    required this.unit,
    required this.createdAt,
    required this.availableFrom,
    this.availableTo,
    required this.status,
    this.offers = const [],
  });

  ResourceListing copyWith({
    String? id,
    String? cooperativeId,
    String? userId,
    String? title,
    String? description,
    ListingType? listingType,
    TransactionType? transactionType,
    double? pricePerUnit,
    int? quantityRequired,
    String? unit,
    DateTime? createdAt,
    DateTime? availableFrom,
    DateTime? availableTo,
    String? status,
    List<ResourceOffer>? offers,
  }) {
    return ResourceListing(
      id: id ?? this.id,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      listingType: listingType ?? this.listingType,
      transactionType: transactionType ?? this.transactionType,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantityRequired: quantityRequired ?? this.quantityRequired,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      status: status ?? this.status,
      offers: offers ?? this.offers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cooperativeId': cooperativeId,
      'userId': userId,
      'title': title,
      'description': description,
      'listingType': listingType.name,
      'transactionType': transactionType.name,
      'pricePerUnit': pricePerUnit,
      'quantityRequired': quantityRequired,
      'unit': unit,
      'createdAt': Timestamp.fromDate(createdAt),
      'availableFrom': Timestamp.fromDate(availableFrom),
      'availableTo':
          availableTo != null ? Timestamp.fromDate(availableTo!) : null,
      'status': status,
      'offers': offers.map((offer) => offer.toMap()).toList(),
    };
  }

  factory ResourceListing.fromMap(Map<String, dynamic> map, String id) {
    return ResourceListing(
      id: id,
      cooperativeId: map['cooperativeId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      listingType: ListingType.values.firstWhere(
        (e) => e.name == map['listingType'],
        orElse: () => ListingType.request,
      ),
      transactionType: TransactionType.values.firstWhere(
        (e) => e.name == map['transactionType'],
        orElse: () => TransactionType.buy,
      ),
      pricePerUnit: (map['pricePerUnit'] ?? 0.0).toDouble(),
      quantityRequired: map['quantityRequired']?.toInt() ?? 0,
      unit: map['unit'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      availableFrom: (map['availableFrom'] as Timestamp).toDate(),
      availableTo: map['availableTo'] != null
          ? (map['availableTo'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'active',
      offers: (map['offers'] as List<dynamic>?)
              ?.map((offer) => ResourceOffer.fromMap(
                    offer as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'ResourceListing(id: $id, title: $title, type: ${listingType.name}, '
        'transaction: ${transactionType.name}, quantity: $quantityRequired $unit)';
  }

  int get totalOfferedQuantity {
    return offers
        .where((offer) => offer.status == 'accepted')
        .fold(0, (sum, offer) => sum + offer.quantity);
  }

  bool get isComplete => totalOfferedQuantity >= quantityRequired;
}
