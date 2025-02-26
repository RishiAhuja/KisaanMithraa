import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ResourceOffer {
  final String id;
  final String listingId;
  final String userId;
  final String cooperativeId;
  final int quantity;
  final double pricePerUnit;
  final DateTime offerTime;
  final String status; // pending, accepted, rejected
  final DateTime? availableFrom;
  final DateTime? availableTo;

  ResourceOffer({
    String? id, // Make id optional in constructor
    required this.listingId,
    required this.userId,
    required this.cooperativeId,
    required this.quantity,
    required this.pricePerUnit,
    required this.offerTime,
    required this.status,
    this.availableFrom,
    this.availableTo,
  }) : id = id ?? const Uuid().v4(); // Generate ID if not provided

  ResourceOffer copyWith({
    String? id,
    String? listingId,
    String? userId,
    String? cooperativeId, // Add this
    int? quantity,
    double? pricePerUnit,
    DateTime? offerTime,
    String? status,
    DateTime? availableFrom,
    DateTime? availableTo,
  }) {
    return ResourceOffer(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      userId: userId ?? this.userId,
      cooperativeId: cooperativeId ?? this.cooperativeId, // Add this
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      offerTime: offerTime ?? this.offerTime,
      status: status ?? this.status,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'userId': userId,
      'cooperativeId': cooperativeId,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'offerTime': Timestamp.fromDate(offerTime),
      'status': status,
      'availableFrom':
          availableFrom != null ? Timestamp.fromDate(availableFrom!) : null,
      'availableTo':
          availableTo != null ? Timestamp.fromDate(availableTo!) : null,
    };
  }

  factory ResourceOffer.fromMap(Map<String, dynamic> map) {
    return ResourceOffer(
      id: map['id'] ?? '', // Handle potential null ID from map
      listingId: map['listingId'] ?? '',
      userId: map['userId'] ?? '',
      cooperativeId: map['cooperativeId'] ?? '', // Add this
      quantity: map['quantity']?.toInt() ?? 0,
      pricePerUnit: (map['pricePerUnit'] ?? 0.0).toDouble(),
      offerTime: (map['offerTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      availableFrom: map['availableFrom'] != null
          ? (map['availableFrom'] as Timestamp).toDate()
          : null,
      availableTo: map['availableTo'] != null
          ? (map['availableTo'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() {
    return 'ResourceOffer(id: $id, listingId: $listingId, userId: $userId, '
        'quantity: $quantity, pricePerUnit: $pricePerUnit, '
        'status: $status)';
  }
}
