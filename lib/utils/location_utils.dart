import 'dart:math' show asin, cos, pow, sin, sqrt, pi;
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationUtils {
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final lat1 = point1.latitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final lon1 = point1.longitude * (pi / 180);
    final lon2 = point2.longitude * (pi / 180);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * asin(sqrt(a));

    return earthRadius * c; // Returns distance in meters
  }
}
